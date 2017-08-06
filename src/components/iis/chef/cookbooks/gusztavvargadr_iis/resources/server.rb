property :server_options, Hash, required: true

default_action :install

action :install do
  gusztavvargadr_windows_features '' do
    features_options server_options['features']
  end

  gusztavvargadr_windows_chocolatey_packages '' do
    chocolatey_packages_options server_options['chocolatey_packages']
  end
end
