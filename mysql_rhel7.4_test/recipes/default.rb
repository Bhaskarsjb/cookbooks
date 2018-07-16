#
# Cookbook:: mysql_rhel7.4_test
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#THIS IS MYSQL INSTALLLATION FOR CDH ON RHEL.7.4

execute "sudo su"


%w[ /data/db /data/db/MYSQL /data/db/MYSQL/scripts /data/db/MYSQL/LOG ].each do |path|
  directory path do
    owner "root"
    group "root"
    mode  "0777"
   end
end

cookbook_file "/data/db/MYSQL/scripts/Install_Mysql_Rhel74.sh" do
  source "Install_Mysql_Rhel74.sh"
  mode 0777
end

execute "Install_Mysql_Rhel74.sh" do
  command "sh Install_Mysql_Rhel74.sh /data01/db mysql"
  cwd '/data/db/MYSQL/scripts'
  group 'root'
  user 'root'
end
