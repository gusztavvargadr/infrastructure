options = {
  provider: {
    memory: 2048,
    cpus: 2,
    linked_clone: true,
    nested_virtualization: true,
  },
  network: {
    bridge: ENV['VAGRANT_NETWORK_BRIDGE'],
  },
}

Vagrant.configure('2') do |config|
  config.vm.network 'public_network', bridge: options[:network][:bridge]

  config.vm.provider 'hyperv' do |hyperv|
    hyperv.memory = options[:provider][:memory]
    hyperv.cpus = options[:provider][:cpus]
    hyperv.differencing_disk = options[:provider][:linked_clone]
    hyperv.enable_virtualization_extensions = options[:provider][:nested_virtualization]
  end

  config.vm.provider 'virtualbox' do |virtualbox|
    virtualbox.memory = options[:provider][:memory]
    virtualbox.cpus = options[:provider][:cpus]
    virtualbox.linked_clone = options[:provider][:linked_clone]
  end
end
