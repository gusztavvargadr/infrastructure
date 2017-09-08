require "#{File.dirname(__FILE__)}/../../core/vagrant/Vagrantfile.core"

class OctopusServerChefSoloProvisioner < ChefSoloProvisioner
  @@octopus_server = {
    'run_list' => ['recipe[gusztavvargadr_octopus::server]'],
    'octopus' => {
      'execute_username' => 'vagrant',
      'execute_password' => 'vagrant',
      'web_username' => 'vagrant',
      'web_password' => 'Vagrant42',
      'import' => {},
    },
  }

  def self.octopus_server(options = {})
    @@octopus_server = @@octopus_server.deep_merge(options)
  end

  def initialize(vm, options = {})
    super(vm, @@octopus_server.deep_merge(options))
  end

  def json(vm, options)
    super(vm, options).deep_merge(
      'gusztavvargadr_octopus' => {
        'server' => {
          'execute_username' => options['octopus']['execute_username'],
          'execute_password' => options['octopus']['execute_password'],
          'web_addresses' => [
            'http://localhost',
            "http://#{vm.hostname}",
          ],
          'web_username' => options['octopus']['web_username'],
          'web_password' => options['octopus']['web_password'],
          'node_name' => vm.hostname,
          'import' => options['octopus']['import'],
        },
      }
    )
  end
end

class OctopusTentacleChefSoloProvisioner < ChefSoloProvisioner
  @@octopus_tentacle = {
    'run_list' => ['recipe[gusztavvargadr_octopus::tentacle]'],
    'octopus' => {
      'execute_username' => 'vagrant',
      'execute_password' => 'vagrant',
      'server_hostname' => '',
      'server_api_key' => '',
      'server_thumbprint' => '',
      'environment_names' => [],
      'tenant_names' => [],
      'role_names' => [],
    },
  }

  def self.octopus_server(options = {})
    @@octopus_tentacle = @@octopus_tentacle.deep_merge(options)
  end

  def initialize(vm, options = {})
    super(vm, @@octopus_tentacle.deep_merge(options))
  end

  def json(vm, options)
    super(vm, options).deep_merge(
      'gusztavvargadr_octopus' => {
        'tentacle' => {
          'execute_username' => options['octopus']['execute_username'],
          'execute_password' => options['octopus']['execute_password'],
          'server_web_address' => "http://#{options['octopus']['server_hostname']}",
          'server_api_key' => options['octopus']['server_api_key'],
          'server_thumbprint' => options['octopus']['server_thumbprint'],
          'node_name' => vm.hostname,
          'public_hostname' => vm.hostname,
          'environment_names' => options['octopus']['environment_names'],
          'tenant_names' => options['octopus']['tenant_names'],
          'role_names' => options['octopus']['role_names'],
        },
      }
    )
  end
end
