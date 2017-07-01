class ConsulAgentDockerProvisioner < DockerProvisioner
  def initialize(type, run)
    super(
      [
        {
          path: '/vagrant/docker/cli',
          args: '-t local/consul:cli',
        },
        {
          path: '/vagrant/docker/agent',
          args: '-t local/consul:agent',
        },
        {
          path: "/vagrant/docker/#{type}",
          args: "-t local/consul:#{type}",
        },
      ],
      [
        run,
      ],
      run: 'always'
    )
  end
end

class ConsulAgentDockerProvisionerRun < DockerProvisionerRun
  attr_reader :type

  def initialize(type)
    super("consul-#{type}", "local/consul:#{type}")
    @type = type
  end

  def define_args(vm, environment)
    args = [
      '--network host',
      "--hostname #{vm.vm.hostname}",
      "--volume ~/docker/consul/#{type}/data:/consul/data",
      '--env \'CONSUL_BIND_INTERFACE=eth0\'',
      "--env 'CONSUL_LOCAL_CONFIG=#{define_args_local_config(vm, environment).to_json}'",
      "--env 'CONSUL_HTTP_ADDR=https://#{vm.vm.hostname}:8500'",
      "--env 'CONSUL_HTTP_TOKEN=#{environment.options[:acl_cli_token]}'",
    ]
    args.join(' ')
  end

  def define_args_local_config(vm, environment)
    {
      retry_join: environment.vms.select { |evm| evm.options[:type] == 'server' }.map { |svm| svm.hostname(environment) },
      encrypt: environment.options[:encrypt],
      acl_agent_token: environment.options[:acl_agent_token],
    }.merge(define_args_local_config_core(vm, environment))
  end

  def define_cmd(vm, environment)
    'agent'
  end
end

class ConsulServerDockerProvisionerRun < ConsulAgentDockerProvisionerRun
  def initialize
    super('server')
  end

  def define_args_local_config_core(vm, environment)
    {
      bootstrap_expect: environment.vms.count { |evm| evm.options[:type] == 'server' },
      acl_master_token: environment.options[:acl_master_token],
    }
  end
end

class ConsulClientDockerProvisionerRun < ConsulAgentDockerProvisionerRun
  def initialize
    super('client')
  end

  def define_args_local_config_core(vm, environment)
    {}
  end
end

class ConsulAgentVM < VM
  def initialize(type, index, run)
    super(
      "#{type}-#{index}",
      'gusztavvargadr/u14',
      [
        HyperVProvider.new,
        VirtualBoxProvider.new,
      ],
      [
        ConsulAgentDockerProvisioner.new(type, run),
      ],
      type: type
    )
  end
end

class ConsulServerVM < ConsulAgentVM
  def initialize(index)
    super('server', index, ConsulServerDockerProvisionerRun.new)
  end
end

class ConsulClientVM < ConsulAgentVM
  def initialize(index)
    super('client', index, ConsulClientDockerProvisionerRun.new)
  end
end
