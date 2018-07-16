resource_name :motd
property :message, kind_of: String, name_property: true

action :create do
  file '/etc/motd' do
    content "#{message}\n"
    mode '0644'
  end
end
