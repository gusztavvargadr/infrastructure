directory = File.dirname(__FILE__)
require "#{directory}/../../../../Vagrantfile.core"

class OctopusServer
  @@defaults = {
    chef_json: {
      'gusztavvargadr_octopus' => {
        'server' => {
          'execute_username' => 'vagrant',
          'execute_password' => 'vagrant',
          'web_username' => 'vagrant',
          'web_password' => 'Vagrant42',
        },
      },
    },
  }

  attr_reader :options

  def initialize(vm, options = {})
    @options = @@defaults.deep_merge(options)

    vm.environment.options[:octopus][:server][:hostname] = vm.hostname

    ChefSoloProvisioner.new(vm) do |chef|
      chef.vagrant.add_recipe 'gusztavvargadr_octopus::server'
      chef.vagrant.add_recipe 'gusztavvargadr_octopus::client'

      chef.vagrant.json = chef_json(vm)
    end
  end

  def chef_json(vm)
    options[:chef_json].deep_merge(
      'gusztavvargadr_octopus' => {
        'server' => {
          'web_address' => "http://#{vm.hostname}:80/",
          'node_name' => vm.hostname,
        },
      }
    )
  end
end

class OctopusTentacle
  @@defaults = {
    chef_json: {
      'gusztavvargadr_octopus' => {
        'tentacle' => {
          'execute_username' => 'vagrant',
          'execute_password' => 'vagrant',
        },
      },
    },
  }

  attr_reader :options

  def initialize(vm, options = {})
    @options = @@defaults.deep_merge(options)

    ChefSoloProvisioner.new(vm) do |chef|
      chef.vagrant.add_recipe 'gusztavvargadr_octopus::tentacle'
      chef.vagrant.add_recipe 'gusztavvargadr_octopus::client'

      chef.vagrant.json = chef_json(vm)
    end
  end

  def chef_json(vm)
    options[:chef_json].deep_merge(
      'gusztavvargadr_octopus' => {
        'tentacle' => {
          'server_web_address' => "http://#{vm.environment.options[:octopus][:server][:hostname]}:80/",
          'server_api_key' => vm.environment.options[:octopus][:server][:api_key],
          'server_thumbprint' => vm.environment.options[:octopus][:server][:thumbprint],
          'node_name' => vm.hostname,
          'public_host_name' => vm.hostname,
          'environment_names' => vm.environment.options[:octopus][:tentacle][:environment_names],
          'tenant_names' => vm.environment.options[:octopus][:tentacle][:tenant_names],
        },
      }
    )
  end
end
