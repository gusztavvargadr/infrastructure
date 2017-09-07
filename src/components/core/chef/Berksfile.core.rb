def gusztavvargadr_sources
  source 'https://supermarket.chef.io'
end

def gusztavvargadr_cookbook(type, name, version = '')
  cookbook_name = "gusztavvargadr_#{name}"
  cookbook_name = "#{cookbook_name}_#{version}" unless version.to_s.empty?

  cookbook_path = "#{File.dirname(__FILE__)}/../../../../src/#{type}/#{name}/chef/cookbooks/#{cookbook_name}"

  cookbook cookbook_name, path: cookbook_path
end
