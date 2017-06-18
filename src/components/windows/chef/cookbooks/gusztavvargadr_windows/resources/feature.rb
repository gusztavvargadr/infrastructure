property :feature_name, String, name_property: true
property :feature_options, Hash, required: true

default_action :install

action :install do
  windows_feature feature_name do
    all true
    action :install
  end
end
