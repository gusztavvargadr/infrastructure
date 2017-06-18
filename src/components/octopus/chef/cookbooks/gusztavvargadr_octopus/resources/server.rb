property :server_instance_name, String, name_property: true
property :server_options, Hash, required: true

default_action :install

action :install do
  server_version = server_options['version']

  if server_version.to_s.empty?
    chocolatey_package 'octopusdeploy' do
      action :install
    end
  else
    chocolatey_package 'octopusdeploy' do
      version server_version
      action :install
    end
  end
end

action :configure do
  server_instance_name = 'Server' if server_instance_name.to_s.empty?
  server_execute_username = server_options['execute_username']
  server_execute_password = server_options['execute_password']
  server_home_directory_path = server_options['home_directory_path']
  server_service_username = server_options['service_username']
  server_storage_connection_string = server_options['storage_connection_string']
  server_web_address = server_options['web_address']
  server_web_username = server_options['web_username']
  server_web_password = server_options['web_password']
  server_communication_port = server_options['communication_port']
  server_node_name = server_options['node_name']
  server_license = server_options['license']

  return if server_web_username.to_s.empty?

  server_executable_file_path = 'C:\\Program Files\\Octopus Deploy\\Octopus\\Octopus.Server.exe'
  gusztavvargadr_windows_powershell_script_elevated "Configure '#{server_instance_name}'" do
    code <<-EOH
      & "#{server_executable_file_path}" create-instance --instance "#{server_instance_name}" --config "#{server_home_directory_path}\\#{server_instance_name}.config" --console
      & "#{server_executable_file_path}" configure --instance "#{server_instance_name}" --home "#{server_home_directory_path}" --storageConnectionString "#{server_storage_connection_string}" --upgradeCheck "False" --upgradeCheckWithStatistics "False" --webAuthenticationMode "UsernamePassword" --webForceSSL "False" --webListenPrefixes "#{server_web_address}" --commsListenPort "#{server_communication_port}" --serverNodeName "#{server_node_name}" --console
      & "#{server_executable_file_path}" database --instance "#{server_instance_name}" --create --grant "#{server_service_username}" --console
      & "#{server_executable_file_path}" service --instance "#{server_instance_name}" --stop --console
      & "#{server_executable_file_path}" admin --instance "#{server_instance_name}" --username "#{server_web_username}" --password "#{server_web_password}" --console
      #{unless server_license.to_s.empty?
          "& \"#{server_executable_file_path}\" license --instance \"#{server_instance_name}\" --licenseBase64 \"#{server_license}\" --console"
        end}
      & "#{server_executable_file_path}" service --instance "#{server_instance_name}" --install --reconfigure --start --console
    EOH
    user server_execute_username
    password server_execute_password
    action :run
    not_if { ::File.exist?("#{server_home_directory_path}\\#{server_instance_name}.config") }
  end

  web_port = URI(server_web_address).port
  powershell_script "Enable '#{server_instance_name}' web port '#{web_port}'" do
    code <<-EOH
      netsh advfirewall firewall add rule "name=Octopus Server '#{server_instance_name}' Web" dir=in action=allow protocol=TCP localport=#{web_port}
    EOH
    action :run
  end

  powershell_script "Enable '#{server_instance_name}' communication port '#{server_communication_port}'" do
    code <<-EOH
      netsh advfirewall firewall add rule "name=Octopus Server '#{server_instance_name}' Communication" dir=in action=allow protocol=TCP localport=#{server_communication_port}
    EOH
    action :run
  end
end

action :import do
  server_instance_name = 'Server' if server_instance_name.to_s.empty?
  server_execute_username = server_options['execute_username']
  server_execute_password = server_options['execute_password']
  server_import = server_options['import']

  return if server_import.nil?

  server_import.each do |server_import_directory_path, server_import_options|
    next if server_import_directory_path.to_s.empty?

    server_executable_directory_path = 'C:\\Program Files\\Octopus Deploy\\Octopus'
    gusztavvargadr_windows_powershell_script_elevated "Import '#{server_instance_name}' from '#{server_import_directory_path}'" do
      code <<-EOH
        & "#{server_executable_directory_path}\\Octopus.Migrator.exe" import --instance "#{server_instance_name}" --directory "#{server_import_directory_path}" --password "#{server_import_options['password']}" --overwrite --console
        & "#{server_executable_directory_path}\\Octopus.Server.exe" service --instance "#{server_instance_name}" --stop --start --console
      EOH
      user server_execute_username
      password server_execute_password
      action :run
    end
  end
end
