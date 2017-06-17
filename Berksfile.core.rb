def gusztavvargadr_sources
  source 'https://supermarket.chef.io'
end

def gusztavvargadr_cookbook(type, name)
  cookbook "gusztavvargadr_#{name}", path: "#{File.dirname(__FILE__)}/src/#{type}/#{name}/chef/cookbooks/gusztavvargadr_#{name}"
end
