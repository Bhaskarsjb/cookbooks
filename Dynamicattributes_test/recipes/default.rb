#
# Cookbook:: Dynamicattributes_test
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

template "/data/ssl.conf" do
                source "ssl.conf.erb"
                mode 0644
                owner "root"
                group "root"
                variables(
                                :sslcertificate => "#{node['apache']['sslpath']}/chef_sanketdangi_com.crt",
                                :sslkey => "#{node['apache']['sslpath']}/chef.sanketdangi.com.key",
                                :sslcacertificate => "#{node['apache']['sslpath']}/chef_sanketdangi_com.ca-bundle",
                                :servername => "#{node['apache']['servername']}"
                )
end
