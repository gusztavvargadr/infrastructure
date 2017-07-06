default_action :install

action :enable do
  powershell_script 'Enable Updates' do
    code <<-EOH
      Set-Service wuauserv -StartupType Automatic
    EOH
    action :run
  end
end

action :start do
  powershell_script 'Start Updates' do
    code <<-EOH
      Start-Service wuauserv
    EOH
    action :run
  end
end

action :configure do
  powershell_script 'Configure Updates' do
    code <<-EOH
      Install-PackageProvider -Name Nuget -Force
      Install-Module PSWindowsUpdate -Force -Confirm:$false

      Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false

      reg add 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\DeliveryOptimization\\Config' /v DODownloadMode /t REG_DWORD /d 0 /f
    EOH
  end
end

action :install do
  gusztavvargadr_windows_powershell_script_elevated 'Install Updates' do
    code <<-EOH
      Get-WUInstall -MicrosoftUpdate -AcceptAll -IgnoreReboot
    EOH
    timeout 28_800
    action :run
  end
end

action :cleanup do
  gusztavvargadr_windows_powershell_script_elevated 'Clean up Updates' do
    code <<-EOH
      DISM.exe /Online /Cleanup-Image /AnalyzeComponentStore
      DISM.exe /Online /Cleanup-Image /StartComponentCleanup
      DISM.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase
      DISM.exe /Online /Cleanup-Image /AnalyzeComponentStore
    EOH
    timeout 28_800
    action :run
  end
end

action :stop do
  powershell_script 'Stop Updates' do
    code <<-EOH
      Stop-Service wuauserv
    EOH
  end
end

action :disable do
  powershell_script 'Disable Updates' do
    code <<-EOH
      Set-Service wuauserv -StartupType Disabled
    EOH
  end
end
