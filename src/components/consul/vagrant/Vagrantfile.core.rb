require "#{File.dirname(__FILE__)}/../../core/vagrant/Vagrantfile.core"

class ConsulServerChefSoloProvisioner < ChefSoloProvisioner
  def json(vm, options)
    super(vm, options).deep_merge(
      'gusztavvargadr_consul' => {
        'server' => {
          'config' => {
            'options' => {
              'node_name' => vm.hostname,
              'bootstrap_expect' => options['json']['gusztavvargadr_consul']['server']['config']['options']['retry_join'].count,
            },
          },
        },
      }
    )
  end
end

class ConsulClientChefSoloProvisioner < ChefSoloProvisioner
  def json(vm, options)
    super(vm, options).deep_merge(
      'gusztavvargadr_consul' => {
        'client' => {
          'config' => {
            'options' => {
              'node_name' => vm.hostname,
            },
          },
        },
      }
    )
  end
end
