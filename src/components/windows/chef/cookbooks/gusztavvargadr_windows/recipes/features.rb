gusztavvargadr_windows_features '' do
  features_options node['gusztavvargadr_windows']['features'] ? node['gusztavvargadr_windows']['features'] : {}
  action :install
end
