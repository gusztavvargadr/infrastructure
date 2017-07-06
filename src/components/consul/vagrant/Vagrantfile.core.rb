directory = File.dirname(__FILE__)
require "#{directory}/../../../../Vagrantfile.core"

class ConsulAgent
  @@defaults = {
    'type' => '',
  }

  attr_reader :options

  def initialize(vm, options = {})
    @options = @@defaults.deep_merge(vm.environment.options[:consul]).deep_merge(options)

    vm.vagrant.vm.synced_folder "#{File.dirname(__FILE__)}/../docker", '/vagrant-docker'

    DockerProvisioner.new(
      vm,
      builds: [
        {
          path: '/vagrant-docker/cli',
          args: '-t local/consul:cli',
        },
        {
          path: '/vagrant-docker/agent',
          args: '-t local/consul:agent',
        },
        {
          path: "/vagrant-docker/#{options[:type]}",
          args: "-t local/consul:#{options[:type]}",
        },
      ],
      runs: [
        {
          container: "consul-#{options[:type]}",
          image: "local/consul:#{options[:type]}",
          args: docker_run_args(vm),
          cmd: 'agent',
          restart: 'unless-stopped',
        },
      ],
      run: 'always'
    )
  end

  def docker_run_args(vm)
    args = [
      '--network host',
      "--hostname #{vm.hostname}",
      "--volume ~/docker/consul/#{options[:type]}/data:/consul/data",
      '--env \'CONSUL_BIND_INTERFACE=eth0\'',
      "--env 'CONSUL_LOCAL_CONFIG=#{docker_run_args_local_config(vm).to_json}'",
      "--env 'CONSUL_HTTP_ADDR=https://#{vm.hostname}:8500'",
      "--env 'CONSUL_HTTP_TOKEN=#{options[:acl_cli_token]}'",
    ]
    args.join(' ')
  end

  def docker_run_args_local_config(vm)
    {
      retry_join: vm.environment.vms.select { |evm| evm.hostname().index('server') == 0 }.map(&:hostname),
      encrypt: options[:encrypt],
      acl_agent_token: options[:acl_agent_token],
    }
  end
end

class ConsulServer < ConsulAgent
  def initialize(vm)
    super(vm, type: 'server')
  end

  def docker_run_args_local_config(vm)
    super.merge(
      bootstrap_expect: vm.environment.vms.count { |evm| evm.hostname().index('server') == 0 },
      acl_master_token: options[:acl_master_token]
    )
  end
end

class ConsulClient < ConsulAgent
  def initialize(vm)
    super(vm, type: 'client')
  end
end

class ConsulCli
  def initialize(vm)
    vm.vagrant.vm.synced_folder '.', '/vagrant', disabled: true

    target_vm = vm.environment.vms[0]

    vm.vagrant.vm.provider 'docker' do |d|
      d.build_dir = "#{File.dirname(__FILE__)}/../docker/cli"
      d.env = {
        'CONSUL_HTTP_ADDR' => "https://#{target_vm.hostname}:8500",
        'CONSUL_HTTP_TOKEN' => vm.environment.options[:consul][:acl_cli_token],
      }
      d.create_args = ['--network', 'host']
      d.cmd = ['consul', 'members']
      d.remains_running = false
    end
  end
end
