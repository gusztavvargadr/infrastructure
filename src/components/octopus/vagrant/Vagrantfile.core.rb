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

    ChefSoloProvisioner.new(vm) do |chef|
      chef.vagrant.add_recipe 'gusztavvargadr_octopus::server'

      chef.vagrant.json = chef_json(vm)
    end
  end

  def chef_json(vm)
    {
      'gusztavvargadr_octopus' => {
        'server' => {
          'web_address' => "http://#{vm.hostname}:80/",
          'node_name' => vm.hostname,
        },
      },
    }.deep_merge(options[:chef_json])
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

      chef.vagrant.json = chef_json(vm)
    end
  end

  def chef_json(vm)
    target_vm = vm.environment.vms[0]

    {
      'gusztavvargadr_octopus' => {
        'tentacle' => {
          'server_web_address' => "http://#{target_vm.hostname}:80/",
          'node_name' => vm.hostname,
        },
      },
    }.deep_merge(options[:chef_json])
  end
end
