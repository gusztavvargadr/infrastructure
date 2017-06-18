default['gusztavvargadr_iis']['server'] = {
  'features' => {
    'IIS-WebServerRole' => {},
    'IIS-ASPNET45' => {},
  },
  'native_packages' => {
    '.NET Core Windows Server Hosting' => {
      'source' => 'http://download.microsoft.com/download/3/8/1/381CBBF3-36DA-4983-BFF3-5881548A70BE/DotNetCore.1.0.4_1.1.1-WindowsHosting.exe',
      'install' => [
        '/install',
        '/quiet',
        '/norestart',
      ],
      'directory' => 'C:/Program Files/dotnet/dotnet.exe',
    },
  },
}
