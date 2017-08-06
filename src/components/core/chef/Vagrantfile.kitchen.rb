require "#{File.dirname(__FILE__)}/../vagrant/Vagrantfile.core"

Provider.core(memory: 4096, cpus: 2)

Environment.new(name: 'kitchen.local') do |environment|
  VM.new(environment) do |vm|
    HyperVProvider.new(vm)
    VirtualBoxProvider.new(vm)
  end
end
