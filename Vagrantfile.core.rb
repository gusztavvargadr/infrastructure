class Environment
  @@defaults = {
    name: 'default.local',
    hostmanager: {
      host: false,
      guest: false,
    },
  }

  def self.defaults(defaults = {})
    @@defaults = @@defaults.deep_merge(defaults)
  end

  attr_reader :options
  attr_reader :vms
  attr_reader :vagrant

  def initialize(options = {})
    @options = @@defaults.deep_merge(options)
    @vms = []

    Vagrant.configure('2') do |vagrant|
      @vagrant = vagrant

      vagrant_configure

      yield self if block_given?
    end
  end

  def vagrant_configure
    vagrant.hostmanager.enabled = hostmanager_enabled?
    vagrant.hostmanager.manage_host = options[:hostmanager][:host]
    vagrant.hostmanager.manage_guest = options[:hostmanager][:guest]
  end

  def hostmanager_enabled?
    options[:hostmanager][:host] || options[:hostmanager][:guest]
  end
end

class VM
  @@defaults = {
    name: 'default',
    box: '',
    autostart: true,
    primary: false,
  }

  def self.defaults(defaults = {})
    @@defaults = @@defaults.deep_merge(defaults)
  end

  attr_reader :environment
  attr_reader :options
  attr_reader :vagrant

  def initialize(environment, options = {})
    @environment = environment
    environment.vms.push self
    @options = @@defaults.deep_merge(options)

    @environment.vagrant.vm.define @options[:name], vagrant_options do |vagrant|
      @vagrant = vagrant

      vagrant_configure

      yield self if block_given?
    end
  end

  def vagrant_options
    {
      autostart: options[:autostart],
      primary: options[:primary],
    }
  end

  def vagrant_configure
    vagrant.vm.box = options[:box] unless options[:box].to_s.empty?
    vagrant.hostmanager.aliases = [hostname] if environment.hostmanager_enabled?
  end

  def hostname
    "#{options[:name]}.#{environment.options[:name]}"
  end
end

class Provider
  @@defaults = {
    type: '',
    memory: 1024,
    cpus: 1,
    linked_clone: true,
  }

  def self.defaults(options = {})
    @@defaults = @@defaults.deep_merge(options)
  end

  attr_reader :vm
  attr_reader :options
  attr_reader :vagrant
  attr_reader :override

  def initialize(vm, options = {})
    @vm = vm
    @options = @@defaults.deep_merge(options)

    @vm.vagrant.vm.provider @options[:type] do |vagrant, override|
      @vagrant = vagrant
      @override = override

      vagrant_configure

      yield self if block_given?
    end
  end

  def vagrant_configure
    vagrant.memory = options[:memory]
    vagrant.cpus = options[:cpus]
  end
end

class HyperVProvider < Provider
  def initialize(vm, options = {})
    super(vm, options.deep_merge(type: 'hyperv'))
  end

  def vagrant_configure
    super

    vagrant.vmname = vm.hostname
    vagrant.differencing_disk = options[:linked_clone]

    override.vm.network 'public_network', bridge: ENV['VAGRANT_HYPERV_NETWORK_BRIDGE']
    override.vm.synced_folder '.', '/vagrant',
      type: 'smb',
      smb_username: ENV['VAGRANT_HYPERV_SMB_USERNAME'],
      smb_password: ENV['VAGRANT_HYPERV_SMB_PASSWORD']
  end
end

class VirtualBoxProvider < Provider
  def initialize(vm, options = {})
    super(vm, options.deep_merge(type: 'virtualbox'))
  end

  def vagrant_configure
    super

    vagrant.name = vm.hostname
    vagrant.linked_clone = options[:linked_clone]
  end
end

class Provisioner
  @@defaults = {
    type: '',
    run: '',
  }

  def self.defaults(defaults = {})
    @@defaults = @@defaults.deep_merge(defaults)
  end

  attr_reader :vm
  attr_reader :options
  attr_reader :vagrant

  def initialize(vm, options = {})
    @vm = vm
    @options = @@defaults.deep_merge(options)

    @vm.vagrant.vm.provision @options[:type], vagrant_options do |vagrant|
      @vagrant = vagrant

      vagrant_configure

      yield self if block_given?
    end
  end

  def vagrant_options
    {
      run: options[:run],
    }
  end

  def vagrant_configure
  end
end

class FileProvisioner < Provisioner
  def initialize(vm, options = {})
    super(vm, options.deep_merge(type: 'file'))
  end

  def vagrant_options
    super.deep_merge(source: options[:source], destination: options[:destination])
  end
end

class ShellProvisioner < Provisioner
  def initialize(vm, options = {})
    super(vm, options.deep_merge(type: 'shell'))
  end

  def vagrant_options
    super.deep_merge(inline: options[:inline], path: options[:path])
  end
end

class ChefSoloProvisioner < Provisioner
  def initialize(vm, options = {})
    super(vm, options.deep_merge(type: 'chef_solo'))
  end
end

class ChefZeroProvisioner < Provisioner
  def initialize(vm, options = {})
    super(vm, options.deep_merge(type: 'chef_zero'))
  end
end

class DockerProvisioner < Provisioner
  def initialize(vm, options = {})
    super(vm, options.deep_merge(type: 'docker'))
  end

  def vagrant_configure
    super

    options[:builds].each do |build|
      vagrant.build_image build[:path], args: build[:args]
    end

    options[:runs].each do |run|
      vagrant.run run[:container],
        image: run[:image],
        args: run[:args],
        cmd: run[:cmd],
        restart: run[:restart]
    end
  end
end

class ::Hash
  def deep_merge(other)
    merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : Array === v1 && Array === v2 ? v1 | v2 : [:undefined, nil, :nil].include?(v2) ? v1 : v2 }
    self.merge(other.to_h, &merger)
  end
end
