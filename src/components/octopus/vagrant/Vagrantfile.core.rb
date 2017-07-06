directory = File.dirname(__FILE__)
require "#{directory}/../../../../Vagrantfile.core"

class OctopusServer
  @@defaults = {
    'execute_username' => 'vagrant',
    'execute_password' => 'vagrant',
    'web_username' => 'vagrant',
    'web_password' => 'Vagrant42',
  }

  attr_reader :options

  def initialize(vm, options = {})
    @options = @@defaults.deep_merge(options)

    ChefSoloProvisioner.new(vm) do |chef|
      chef.vagrant.add_recipe 'gusztavvargadr_octopus::server'

      chef.vagrant.json = {
        'gusztavvargadr_octopus' => {
          'server' => @options,
        },
      }
    end
  end
end

class OctopusTentacle
  @@defaults = {
    'execute_username' => 'vagrant',
    'execute_password' => 'vagrant',
  }

  attr_reader :options

  def initialize(vm, options = {})
    @options = @@defaults.deep_merge(options)

    ChefSoloProvisioner.new(vm) do |chef|
      chef.vagrant.add_recipe 'gusztavvargadr_octopus::tentacle'

      chef.vagrant.json = {
        'gusztavvargadr_octopus' => {
          'tentacle' => @options,
        },
      }
    end
  end
end
