powershell_script 'Set service \'WinRM\' to \'Autostart\'' do
  code 'sc.exe config winrm start= auto'
  action :run
end

gusztavvargadr_windows_native_packages '' do
  native_packages_options node['gusztavvargadr_docker']['engine']['native_packages']
end
