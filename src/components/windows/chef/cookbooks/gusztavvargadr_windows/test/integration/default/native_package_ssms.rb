target_directory = '/Program Files (x86)/Microsoft SQL Server/130/Tools/Binn/ManagementStudio'

describe directory(target_directory) do
  it { should exist }
end
