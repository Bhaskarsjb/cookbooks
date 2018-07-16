#
# Cookbook:: mysql_suse11
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

execute 'sudo su -'

%w[ /data /data/db /data/db/MYSQL /data/db/MYSQL/scripts /data/db/MYSQL/LOG ].each do |path| 
  directory path do
#    owner "root"
#    group "root"
     mode  "0777"
#    recursive false
   end
end

cookbook_file "/data/db/MYSQL/scripts/Install_Mysql_Sles.sh" do
  source "Install_Mysql_Sles.sh"
  mode 0777
end

execute "install mysql" do
  command "sh /data/db/MYSQL/scripts/Install_Mysql_Sles.sh /data02/db mysql"
end
