target_directory = '/Program Files/dotnet'

describe directory(target_directory) do
  it { should exist }
end
