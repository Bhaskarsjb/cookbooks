#
# Cookbook:: mssql-test
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

execute "sudo su -"

%w[ /mnt/disks /mnt/disks/BACKUP /mnt/disks/DATA /mnt/disks/LOG /mnt/disks/DUMP /mnt/disks/SCRIPTS ].each do |path|
  directory path do
#    owner "root"
#    group "root"
     mode  "0777"
#    recursive false
   end
end


cookbook_file "/mnt/disks/SCRIPTS/Install_MSSQL2017.sh" do
  source "Install_MSSQL2017.sh"
  mode 0777
end

execute "install mssql" do
  command "sh /mnt/disks/SCRIPTS/Install_MSSQL2017.sh"
end
