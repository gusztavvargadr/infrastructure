directory = File.dirname(__FILE__)
require "#{directory}/../../../../Vagrantfile.core"

class VaultServer
  def initialize(vm)
    vm.vagrant.vm.synced_folder "#{File.dirname(__FILE__)}/../docker", '/vagrant-docker'

    DockerProvisioner.new(
      vm,
      builds: [
        {
          path: '/vagrant-docker/cli',
          args: '-t local/vault:cli',
        },
        {
          path: '/vagrant-docker/server',
          args: '-t local/vault:server',
        },
      ],
      runs: [
        {
          container: 'vault-server',
          image: 'local/vault:server',
          args: docker_run_args(vm),
          cmd: 'server',
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
      "--env 'VAULT_LOCAL_CONFIG=#{docker_run_args_local_config(vm).to_json}'",
      "--env 'VAULT_ADDR=https://#{vm.hostname}:8200'",
      "--env 'VAULT_TOKEN=#{vm.environment.options[:vault][:token]}'",
    ]
    args.join(' ')
  end

  def docker_run_args_local_config(vm)
    {
      backend: {
        consul: {
          address: vm.environment.options[:vault][:consul][:address],
          scheme: 'https',
          path: 'vault/',
          token: vm.environment.options[:vault][:consul][:token],
        },
      },
    }
  end
end


class VaultUi
  def initialize(vm)
    vm.vagrant.vm.synced_folder '.', '/vagrant', disabled: true

    target_vm = vm.environment.vms[0]

    vm.vagrant.vm.provider 'docker' do |d|
      d.build_dir = "#{File.dirname(__FILE__)}/../docker/ui"
      d.env = {
        'VAULT_URL_DEFAULT' => "https://#{target_vm.hostname}:8200",
        'VAULT_AUTH_DEFAULT' => 'TOKEN',
        'NODE_TLS_REJECT_UNAUTHORIZED' => 0,
      }
      d.create_args = ['--network', 'host']
    end
  end
end

class VaultCli
  def initialize(vm)
    vm.vagrant.vm.synced_folder '.', '/vagrant', disabled: true

    target_vm = vm.environment.vms[0]

    vm.vagrant.vm.provider 'docker' do |d|
      d.build_dir = "#{File.dirname(__FILE__)}/../docker/cli"
      d.env = {
        'VAULT_ADDR' => "https://#{target_vm.hostname}:8200",
        'VAULT_TOKEN' => target_vm.environment.options[:vault][:token],
      }
      d.create_args = ['--network', 'host']
      d.cmd = ['vault', 'mounts']
      d.remains_running = false
    end
  end
end
