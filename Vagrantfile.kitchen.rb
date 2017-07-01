options = {
  provider: {
    memory: 4096,
    cpus: 2,
    linked_clone: true,
    nested_virtualization: true,
  },
  network: {
    bridge: ENV['VAGRANT_NETWORK_BRIDGE'],
  },
  synced_folder: {
    username: ENV['VAGRANT_SMB_USERNAME'],
    password: ENV['VAGRANT_SMB_PASSWORD'],
  }
}

Vagrant.configure('2') do |config|
  config.vm.provider 'hyperv' do |hyperv, override|
    hyperv.memory = options[:provider][:memory]
    hyperv.cpus = options[:provider][:cpus]
    hyperv.differencing_disk = options[:provider][:linked_clone]
    hyperv.enable_virtualization_extensions = options[:provider][:nested_virtualization]

    override.vm.network 'public_network', bridge: options[:network][:bridge]
    override.vm.synced_folder '.', '/vagrant', type: 'smb', smb_username: options[:synced_folder][:username], smb_password: options[:synced_folder][:password]
  end

  config.vm.provider 'virtualbox' do |virtualbox|
    virtualbox.memory = options[:provider][:memory]
    virtualbox.cpus = options[:provider][:cpus]
    virtualbox.linked_clone = options[:provider][:linked_clone]
  end
end
