require "#{File.dirname(__FILE__)}/../../../../Vagrantfile.core"

class ConsulAgentChefSoloProvisioner < ChefSoloProvisioner
  @@consul_agent = {
    recipes: ['consul::default'],
    consul: {
      servers: [],
      encrypt: '',
      acl_agent_token: '',
    },
  }

  def self.consul_agent(options = {})
    @@consul_agent = @@consul_agent.deep_merge(options)
  end

  def initialize(vm, options = {})
    super(vm, @@consul_agent.deep_merge(json: json(vm, options)).deep_merge(options))
  end

  def json(vm, options)
    {
      'consul' => {
        'version' => '0.9.0',
        'config' => {
          'options' => {
            'node_name' => vm.hostname,
            'client_addr' => '127.0.0.1',
            'ui' => true,
            'ca_file' => '/vagrant-data/tls/ca.cert',
            'cert_file' => '/vagrant-data/tls/consul.cert',
            'key_file' => '/vagrant-data/tls/consul.key',
            'verify_outgoing' => true,
            'verify_incoming_rpc' => true,
            'retry_join' => options[:consul][:servers],
            'encrypt' => options[:consul][:encrypt],
            'acl_datacenter' => 'dc1',
            'acl_agent_token' => options[:consul][:acl_agent_token],
          },
        },
      },
    }
  end
end

class ConsulServerChefSoloProvisioner < ConsulAgentChefSoloProvisioner
  def json(vm, options)
    super(vm, options).deep_merge(
      'consul' => {
        'config' => {
          'options' => {
            'addresses' => {
              'https' => '0.0.0.0',
            },
            'ports' => {
              'https' => 8501,
            },
            'server' => true,
            'bootstrap_expect' => options[:consul][:servers].count,
            'acl_default_policy' => 'deny',
            'acl_master_token' => options[:consul][:acl_master_token],
          },
        },
      }
    )
  end
end

class ConsulClientChefSoloProvisioner < ConsulAgentChefSoloProvisioner
  def json(vm, options)
    super(vm, options).deep_merge(
      'consul' => {
        'config' => {
          'options' => {
          },
        },
      }
    )
  end
end
