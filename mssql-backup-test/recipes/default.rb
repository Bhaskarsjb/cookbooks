#
# Cookbook:: mssql-backup-test
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

#
# Copyright:: 2018, The Authors, All Rights Reserved.

execute "sudo su -"

%w[ /mnt/disks/MSSQL /mnt/disks/MSSQL/BACKUP ].each do |path|
  directory path do
    owner "root"
    group "root"
    mode  "0777"
   end
end

cookbook_file "/mnt/disks/SCRIPTS/backup.sh" do
  source "backup.sh"
  mode 0777
end

execute "backup-db" do
  command "sh backup.sh"
  cwd '/mnt/disks/SCRIPTS'
#  group 'root'
  user 'root'
end

#execute "sqlcmd1" do
#  command "sqlcmd -S mssql-chef-test -U SA -P 'Test@123$' -Q "BACKUP DATABASE [TestDB] TO DISK = N'/mnt/disks/MSSQL/BACKUP/TestDB.bak' WITH INIT, NOUNLOAD , NAME = N'TestDB backup', NOSKIP , STATS = 10, NOFORMAT" -o output.txt "
#end



#bash 'backup-db' do
#    code <<-EOH
#    DB_NAME=TestDB
#    DB_HOSTNAME=mssql-chef-test
#
#    BK_FILE=/mnt/disks/MSSQL/BACKUP/$DB_NAME.bak
#    
#   DB_NAME=$1
#    sqlcmd -S $DB_HOSTNAME -U SA -P 'Test@123$' -Q "IF NOT EXISTS (SELECT * FROM sysdatabases WHERE name='$DB_NAME') Print N'wrong DBName';" 
#   sqlcmd -S $DB_HOSTNAME -U SA -P 'Test@123$' -Q "BACKUP DATABASE [$DB_NAME] TO DISK = N'$BK_FILE' WITH INIT, NOUNLOAD , NAME = N'$DB_NAME backup', NOSKIP , STATS = 10, NOFORMAT" -o output.txt 
#
#    echo Done! 
#    EOH
#end
