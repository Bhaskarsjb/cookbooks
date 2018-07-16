#
# Cookbook:: Oracledb_test
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

execute "sudo su -"


directory "/home/oracle" do
  owner 'oracle'
  mode  "0777"
end

user 'oracle' do
  comment 'A oracle user'
  home '/home/oracle'
  shell '/bin/bash'
end

cookbook_file "/home/oracle/oracle_auto_install.sh" do
  source "oracle_auto_install.sh"
  mode 0777
end

execute "install oracle" do
  command "sh /home/oracle/oracle_auto_install.sh p599 2048 12.2.0.1 /u01/app/oracle /u01/app/oraInventory /home/oracle /usr/local/bin tcs.com"
#  user 'oracle'
#  cwd '/home/oracle'
end
