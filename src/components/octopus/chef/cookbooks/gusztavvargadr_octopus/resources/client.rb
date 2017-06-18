property :client_options, Hash, required: true

default_action :install

action :install do
  client_version = client_options['version']

  if client_version.to_s.empty?
    chocolatey_package 'octopustools' do
      action :install
    end
  else
    chocolatey_package 'octopustools' do
      version client_version
      action :install
    end
  end
end
