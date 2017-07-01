class VaultServerDockerProvisioner < DockerProvisioner
  def initialize
    super(
      [
        {
          path: '/vagrant/docker/cli',
          args: '-t local/vault:cli',
        },
        {
          path: '/vagrant/docker/server',
          args: '-t local/vault:server',
        },
      ],
      [
        VaultServerDockerProvisionerRun.new,
      ],
      run: 'always'
    )
  end
end

class VaultServerDockerProvisionerRun < DockerProvisionerRun
  def initialize
    super('vault-server', 'local/vault:server')
  end

  def define_args(vm, environment)
    args = [
      '--network host',
      "--hostname #{vm.vm.hostname}",
      "--env 'VAULT_LOCAL_CONFIG=#{define_args_local_config(vm, environment).to_json}'",
      "--env 'VAULT_ADDR=https://#{vm.vm.hostname}:8200'",
      "--env 'VAULT_TOKEN=#{environment.options[:cli_token]}'",
    ]
    args.join(' ')
  end

  def define_args_local_config(vm, environment)
    {
      backend: {
        consul: {
          address: environment.options[:consul_address],
          scheme: 'https',
          path: 'vault/',
          token: environment.options[:consul_token],
        }
      }
    }
  end

  def define_cmd(vm, environment)
    'server'
  end
end

class VaultServerVM < VM
  def initialize(index)
    super(
      "server-#{index}",
      'gusztavvargadr/u14',
      [
        HyperVProvider.new,
        VirtualBoxProvider.new,
      ],
      [
        VaultServerDockerProvisioner.new,
      ]
    )
  end
end
