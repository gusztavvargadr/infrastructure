class Environment
  @@options = {
    hostmanager: {
      host: true,
      guest: false,
    },
    domain: 'local',
  }

  attr_reader :name
  attr_reader :vms
  attr_reader :options

  def initialize(name, vms, options = {})
    @name = name
    @vms = vms
    @options = @@options.merge(options)
  end

  def define
    Vagrant.configure('2') do |config|
      config.hostmanager.enabled = options[:hostmanager][:host] || options[:hostmanager][:guest]
      config.hostmanager.manage_host = options[:hostmanager][:host]
      config.hostmanager.manage_guest = options[:hostmanager][:guest]

      @vms.each do |vm|
        vm.define config, self
      end

      yield config
    end
  end
end

class VM
  @@options = {
    type: '',
  }

  attr_reader :name
  attr_reader :box
  attr_reader :providers
  attr_reader :provisioners
  attr_reader :options

  def initialize(name, box, providers = [], provisioners = [], options = {})
    @name = name
    @box = box
    @providers = providers
    @provisioners = provisioners
    @options = @@options.merge(options)
  end

  def hostname(environment)
    "#{name}.#{environment.name}.#{environment.options[:domain]}"
  end

  def define(config, environment)
    config.vm.define name do |vm|
      vm.vm.box = box
      vm.vm.hostname = hostname(environment)

      vm.vm.network 'public_network', bridge: ENV['VAGRANT_NETWORK_BRIDGE']
      vm.vm.synced_folder '.', '/vagrant', type: 'smb', smb_username: ENV['VAGRANT_SMB_USERNAME'], smb_password: ENV['VAGRANT_SMB_PASSWORD']

      providers.each do |provider|
        provider.define vm, environment
      end

      vm.vm.provision 'file', source: '/Windows/System32/drivers/etc/hosts', destination: '/tmp/hosts', run: 'always'
      vm.vm.provision 'shell', inline: 'mv /tmp/hosts /etc/hosts', run: 'always'

      provisioners.each do |provisioner|
        provisioner.define vm, environment
      end
    end
  end
end

class Provider
  @@options = {
    memory: 1024,
    cpus: 1,
    linked_clone: true,
  }

  attr_reader :type
  attr_reader :options

  def initialize(type, options = {})
    @type = type
    @options = @@options.merge(options)
  end

  def define(vm, environment)
    vm.vm.provider type do |provider|
      define_core(provider, vm, environment)
    end
  end
end

class HyperVProvider < Provider
  def initialize(options = {})
    super('hyperv', options)
  end

  def define_core(provider, vm, environment)
    provider.vmname = vm.vm.hostname
    provider.memory = options[:memory]
    provider.cpus = options[:cpus]
    provider.differencing_disk = options[:linked_clone]
  end
end

class VirtualBoxProvider < Provider
  def initialize(options = {})
    super('virtualbox', options)
  end

  def define_core(provider, vm, environment)
    provider.name = vm.vm.hostname
    provider.memory = options[:memory]
    provider.cpus = options[:cpus]
    provider.linked_clone = options[:linked_clone]
  end
end

class Provisioner
  @@options = {
    run: '',
  }

  attr_reader :type
  attr_reader :options

  def initialize(type, options = {})
    @type = type
    @options = @@options.merge(options)
  end

  def define(vm, environment)
    vm.vm.provision type, run: options[:run] do |provisioner|
      define_core(provisioner, vm, environment)
    end
  end
end

class DockerProvisioner < Provisioner
  attr_reader :builds
  attr_reader :runs

  def initialize(builds = [], runs = [], options = {})
    super('docker', options)
    @builds = builds
    @runs = runs
  end

  def define_core(provisioner, vm, environment)
    builds.each do |build|
      provisioner.build_image build[:path], args: build[:args]
    end

    runs.each do |run|
      run.define provisioner, vm, environment
    end
  end
end

class DockerProvisionerRun
  attr_reader :container
  attr_reader :image
  attr_reader :restart

  def initialize(container, image, restart = 'unless-stopped')
    @container = container
    @image = image
    @restart = restart
  end

  def define(provisioner, vm, environment)
    provisioner.run container,
      image: image,
      args: define_args(vm, environment),
      cmd: define_cmd(vm, environment),
      restart: restart
  end
end
