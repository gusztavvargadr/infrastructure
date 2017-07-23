require "#{File.dirname(__FILE__)}/../Vagrantfile.core"

Environment.environment(hostmanager: { host: true, guest: false })

class WindowsSampleVM < VM
  @@windows_sample = {
    box: 'gusztavvargadr/w16s',
  }

  def self.windows_sample(options = {})
    @@windows_sample = @@windows_sample.deep_merge(options)
  end

  def initialize(environment, options = {})
    super(environment, @@windows_sample.deep_merge(options))
  end

  def vagrant_configure
    super

    HyperVProvider.new(self, memory: 2048, cpus: 2)
    VirtualBoxProvider.new(self, memory: 2048, cpus: 2)

    FileProvisioner.new(self,
      source: 'C:/Windows/System32/drivers/etc/hosts',
      destination: 'C:/Windows/System32/drivers/etc/hosts',
      run: 'always')
  end
end

class UbuntuSampleVM < VM
  @@ubuntu_sample = {
    box: 'gusztavvargadr/u14',
  }

  def self.ubuntu_sample(options = {})
    @@ubuntu_sample = @@ubuntu_sample.deep_merge(options)
  end

  def initialize(environment, options = {})
    super(environment, @@ubuntu_sample.deep_merge(options))
  end

  def vagrant_configure
    super

    HyperVProvider.new(self, memory: 1024, cpus: 1)
    VirtualBoxProvider.new(self, memory: 1024, cpus: 1)

    FileProvisioner.new(self,
      source: 'C:/Windows/System32/drivers/etc/hosts',
      destination: '/tmp/etc/hosts',
      run: 'always')
    ShellProvisioner.new(self,
      inline: 'mv /tmp/etc/hosts /etc/hosts',
      run: 'always')
  end
end
