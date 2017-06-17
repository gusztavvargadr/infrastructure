target_file_path = '/Temp/hosts'

describe file(target_file_path) do
  it { should exist }
end
