property :tentacle_instance_name, String, name_property: true
property :tentacle_options, Hash, required: true

action :install do
  tentacle_version = tentacle_options['version']

  if tentacle_version.to_s.empty?
    chocolatey_package 'octopusdeploy.tentacle' do
      action :install
    end
  else
    chocolatey_package 'octopusdeploy.tentacle' do
      version tentacle_version
      action :install
    end
  end
end

action :configure do
  tentacle_instance_name = 'Tentacle' if tentacle_instance_name.to_s.empty?
  tentacle_execute_username = tentacle_options['execute_username']
  tentacle_execute_password = tentacle_options['execute_password']
  tentacle_home_directory_path = tentacle_options['home_directory_path']
  tentacle_communication_port = tentacle_options['communication_port']
  tentacle_server_web_address = tentacle_options['server_web_address']
  tentacle_server_web_username = tentacle_options['server_web_username']
  tentacle_server_web_password = tentacle_options['server_web_password']
  tentacle_server_api_key = tentacle_options['server_api_key']
  tentacle_server_communication_port = tentacle_options['server_communication_port']
  tentacle_node_name = tentacle_options['node_name']
  tentacle_environment_names = tentacle_options['environment_names']
  tentacle_tenant_names = tentacle_options['tenant_names']
  tentacle_role_names = tentacle_options['role_names']

  return if tentacle_server_web_username.to_s.empty? && tentacle_server_api_key.to_s.empty?

  executable_path = 'C:\\Program Files\\Octopus Deploy\\Tentacle\\Tentacle.exe'
  credentials =
    if tentacle_server_web_username.to_s.empty?
      "--apiKey=\"#{tentacle_server_api_key}\""
    else
      "--username \"#{tentacle_server_web_username}\" --password \"#{tentacle_server_web_password}\""
    end
  environments = tentacle_environment_names.map { |environment_name| "--environment=\"#{environment_name}\"" }.join(' ')
  tenants = tentacle_tenant_names.map { |tenant_name| "--tenant=\"#{tenant_name}\"" }.join(' ')
  roles = tentacle_role_names.map { |role_name| "--role=\"#{role_name}\"" }.join(' ')
  gusztavvargadr_windows_powershell_script_elevated "Configure '#{tentacle_instance_name}'" do
    code <<-EOH
      & "#{executable_path}" create-instance --instance "#{tentacle_instance_name}" --config "#{tentacle_home_directory_path}\\#{tentacle_instance_name}.config" --console
      & "#{executable_path}" new-certificate --instance "#{tentacle_instance_name}" --if-blank --console
      & "#{executable_path}" configure --instance "#{tentacle_instance_name}" --reset-trust --console
      & "#{executable_path}" configure --instance "#{tentacle_instance_name}" --home "#{tentacle_home_directory_path}" --app "#{tentacle_home_directory_path}\\Applications" --port "#{tentacle_communication_port}" --noListen "True" --console
      & "#{executable_path}" service --instance "#{tentacle_instance_name}" --stop --console
      & "#{executable_path}" polling-proxy --instance "#{tentacle_instance_name}" --proxyEnable "False" --proxyUsername "" --proxyPassword "" --proxyHost "" --proxyPort ""  --console
      & "#{executable_path}" service --instance "#{tentacle_instance_name}" --start  --console
      & "#{executable_path}" register-with --instance "#{tentacle_instance_name}" --server "#{tentacle_server_web_address}" --name "#{tentacle_node_name}" --comms-style "TentacleActive" --server-comms-port "#{tentacle_server_communication_port}" #{credentials} --force #{environments} #{tenants} #{roles} --console
      & "#{executable_path}" service --instance "#{tentacle_instance_name}" --install --start --console
    EOH
    action :run
    user tentacle_execute_username
    password tentacle_execute_password
    not_if { ::File.exist?("#{tentacle_home_directory_path}\\#{tentacle_instance_name}.config") }
  end

  powershell_script "Enable '#{tentacle_instance_name}' communication port '#{tentacle_communication_port}'" do
    code <<-EOH
      netsh advfirewall firewall add rule "name=Octopus Tentacle '#{tentacle_instance_name}' Communication" dir=in action=allow protocol=TCP localport=#{tentacle_communication_port}
    EOH
    action :run
  end
end
