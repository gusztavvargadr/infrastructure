require "#{File.dirname(__FILE__)}/../../../../Vagrantfile.core"

class ConsulAgent
  @@defaults = {
    type: '',
    synced_folder_destination: '/vagrant-docker',
    docker_image_name: 'local/consul',
  }

  attr_reader :options

  def initialize(vm, options = {})
    @options = @@defaults.deep_merge(options)

    vm.vagrant.vm.synced_folder "#{File.dirname(__FILE__)}/../docker", @options[:synced_folder_destination]

    DockerProvisioner.new(
      vm,
      builds: [
        {
          path: "#{@options[:synced_folder_destination]}/cli",
          args: "-t #{@options[:docker_image_name]}:cli",
        },
        {
          path: "#{@options[:synced_folder_destination]}/agent",
          args: "-t #{@options[:docker_image_name]}:agent",
        },
        {
          path: "#{@options[:synced_folder_destination]}/#{options[:type]}",
          args: "-t #{@options[:docker_image_name]}:#{options[:type]}",
        },
      ],
      runs: [
        {
          container: "consul-#{options[:type]}",
          image: "#{@options[:docker_image_name]}:#{options[:type]}",
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
      "--env 'CONSUL_HTTP_TOKEN=#{vm.environment.options[:consul][:acl_cli_token]}'",
    ]
    args.join(' ')
  end

  def docker_run_args_local_config(vm)
    {
      retry_join: vm.environment.options[:consul][:server][:nodes].map { |node| node[:hostname] },
      encrypt: vm.environment.options[:consul][:encrypt],
      acl_agent_token: vm.environment.options[:consul][:acl_agent_token],
    }
  end
end

class ConsulServer < ConsulAgent
  def initialize(vm, options = {})
    super(vm, options.deep_merge(type: 'server'))

    vm.environment.options[:consul][:server][:nodes].push hostname: vm.hostname
  end

  def docker_run_args_local_config(vm)
    super.merge(
      bootstrap_expect: vm.environment.options[:consul][:server][:count],
      acl_master_token: vm.environment.options[:consul][:acl_master_token]
    )
  end
end

class ConsulClient < ConsulAgent
  def initialize(vm, options = {})
    super(vm, options.deep_merge(type: 'client'))

    vm.environment.options[:consul][:client][:nodes].push hostname: vm.hostname
  end
end

class ConsulCli
  def initialize(vm)
    vm.vagrant.vm.synced_folder '.', '/vagrant', disabled: true

    server_hostname = vm.environment.options[:consul][:server][:nodes][0][:hostname]

    vm.vagrant.vm.provider 'docker' do |d|
      d.build_dir = "#{File.dirname(__FILE__)}/../docker/cli"
      d.env = {
        'CONSUL_HTTP_ADDR' => "https://#{server_hostname}:8500",
        'CONSUL_HTTP_TOKEN' => vm.environment.options[:consul][:acl_cli_token],
      }
      d.create_args = ['--network', 'host']
      d.cmd = ['consul', 'members']
      d.remains_running = false
    end
  end
end
