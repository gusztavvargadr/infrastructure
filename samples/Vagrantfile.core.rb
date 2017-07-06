directory = File.dirname(__FILE__)
require "#{directory}/../Vagrantfile.core"

Environment.defaults(hostmanager: { host: true, guest: false })
Provider.defaults(memory: 2048, cpus: 2)

class WindowsSample
  def initialize(vm)
    HyperVProvider.new(vm, memory: 2048, cpus: 2)
    VirtualBoxProvider.new(vm, memory: 2048, cpus: 2)

    FileProvisioner.new(vm,
      source: 'C:/Windows/System32/drivers/etc/hosts',
      destination: 'C:/Windows/System32/drivers/etc/hosts',
      run: 'always')
  end
end

class LinuxSample
  def initialize(vm)
    HyperVProvider.new(vm, memory: 1024, cpus: 1)
    VirtualBoxProvider.new(vm, memory: 1024, cpus: 1)

    FileProvisioner.new(vm,
      source: 'C:/Windows/System32/drivers/etc/hosts',
      destination: '/tmp/etc/hosts',
      run: 'always')
    ShellProvisioner.new(vm,
      inline: 'mv /tmp/etc/hosts /etc/hosts',
      run: 'always')
  end
end
