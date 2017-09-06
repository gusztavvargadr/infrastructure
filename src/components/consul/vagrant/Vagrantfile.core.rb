require "#{File.dirname(__FILE__)}/../../core/vagrant/Vagrantfile.core"

class ConsulAgentChefSoloProvisioner < ChefSoloProvisioner
  @@consul_agent = {
    consul: {
      type: '',
      servers: [],
      encrypt: '',
      acl_agent_token: '',
    },
  }

  def self.consul_agent(options = {})
    @@consul_agent = @@consul_agent.deep_merge(options)
  end

  def initialize(vm, options = {})
    super(vm, @@consul_agent.deep_merge(options))
  end

  def json(vm, options)
    super(vm, options).deep_merge(
      'gusztavvargadr_consul' => {
        options[:consul][:type] => {
          'config' => {
            'options' => {
              'node_name' => vm.hostname,
              'retry_join' => options[:consul][:servers],
              'encrypt' => options[:consul][:encrypt],
              'acl_agent_token' => options[:consul][:acl_agent_token],
            },
          },
        }
      }
    )
  end
end

class ConsulServerChefSoloProvisioner < ConsulAgentChefSoloProvisioner
  @@consul_server = {
    run_list: ['recipe[gusztavvargadr_consul::server]'],
    consul: {
      type: 'server',
      acl_master_token: '',
    },
  }

  def self.consul_server(options = {})
    @@consul_server = @@consul_server.deep_merge(options)
  end

  def initialize(vm, options = {})
    super(vm, @@consul_server.deep_merge(options))
  end

  def json(vm, options)
    super(vm, options).deep_merge(
      'gusztavvargadr_consul' => {
        'server' => {
          'config' => {
            'options' => {
              'bootstrap_expect' => options[:consul][:servers].count,
              'acl_master_token' => options[:consul][:acl_master_token],
            },
          },
        },
      }
    )
  end
end

class ConsulClientChefSoloProvisioner < ConsulAgentChefSoloProvisioner
  @@consul_client = {
    run_list: ['recipe[gusztavvargadr_consul::client]'],
    consul: {
      type: 'client',
      acl_client_token: '',
    },
  }

  def self.consul_client(options = {})
    @@consul_client = @@consul_client.deep_merge(options)
  end

  def initialize(vm, options = {})
    super(vm, @@consul_client.deep_merge(options))
  end

  def json(vm, options)
    super(vm, options).deep_merge(
      'gusztavvargadr_consul' => {
        'client' => {
          'config' => {
            'options' => {
              'acl_token' => options[:consul][:acl_client_token],
            },
          },
        },
      }
    )
  end
end
