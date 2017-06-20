property :edition, String, name_property: true

action :install do
  directory_path = "#{Chef::Config[:file_cache_path]}/gusztavvargadr_vs/2017_#{edition}"

  directory directory_path do
    recursive true
    action :create
  end

  installer_file_name = 'installer.exe'
  installer_file_path = "#{directory_path}/#{installer_file_name}"
  installer_file_source = node['gusztavvargadr_vs']["2017_#{edition}"]['installer_file_url']
  remote_file installer_file_path do
    source installer_file_source
    action :create
  end

  installer_options = node['gusztavvargadr_vs']["2017_#{edition}"]['installer_options'].join(' ')

  gusztavvargadr_windows_powershell_script_elevated "Install Visual Studio 2017 #{edition}" do
    code <<-EOH
      Start-Process "#{installer_file_path.tr('/', '\\')}" "#{installer_options}" -Wait
    EOH
    action :run
  end
end
