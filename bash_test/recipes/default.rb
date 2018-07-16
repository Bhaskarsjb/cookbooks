#
# Cookbook:: bash_test
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
cookbook_file "/tmp/bash.sh" do
  source "bash.sh"
  mode 0777
end

execute "install httpd" do
  command "sh /tmp/bash.sh"
end

motd "welcome to chef custom resource"
