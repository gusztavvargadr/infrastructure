target_file_path = '/Temp/robots.txt'

describe file(target_file_path) do
  it { should exist }
end
