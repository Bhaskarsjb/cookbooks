#
# Cookbook:: mssql-restore-test
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

#
# Cookbook:: mssql-restore-test
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.


cookbook_file "/mnt/disks/SCRIPTS/Restore_SingleDB.sh" do
  source "Restore_SingleDB.sh"
  mode 0777
end

execute "Restore-db" do
  command "sh Restore_SingleDB.sh TestDB mssql-chef-test"
  cwd '/mnt/disks/SCRIPTS'
  group 'root'
  user 'root'
end
