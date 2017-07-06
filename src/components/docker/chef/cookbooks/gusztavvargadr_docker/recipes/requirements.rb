powershell_script 'Set service \'WinRM\' to \'Autostart (Delayed)\'' do
  code 'sc.exe config winrm start= delayed-auto'
  action :run
end

gusztavvargadr_windows_features '' do
  features_options node['gusztavvargadr_docker']['requirements']['features']
end
