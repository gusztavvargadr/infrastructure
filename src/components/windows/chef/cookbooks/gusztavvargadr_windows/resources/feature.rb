property :feature_name, String, name_property: true
property :feature_options, Hash, required: true

default_action :install

action :install do
  gusztavvargadr_windows_powershell_script_elevated "Install Feature '#{feature_name}'" do
    code <<-EOH
      DISM.exe /Online /Enable-Feature /FeatureName:#{feature_name} /NoRestart /All
    EOH
    action :run
  end
end
