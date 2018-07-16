#
# Cookbook:: postgresql_test
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

execute 'sudo su -'

directory '/root/postgresql' do
  mode "0777"
  owner "root"
end

#directory '/postgresql/Install' do
#  mode "0777"
#  owner "root"
#end

cookbook_file '/root/postgresql/postgresql.sh' do
  source'postgresql.sh'
  mode 0777
end

cookbook_file '/root/postgresql/postgresql-script' do
  source'postgresql-script'
  mode 0777
end

cookbook_file '/root/postgresql/postgresql.service' do
  source'postgresql.service'
  mode 0777
end

#bash 'install postgresql' do 
#  cwd '/home/ec2-user'
#  code <<-EOH
#  sudo su -
#  sh /root/postgresql/postgresql.sh 10.1 /var/lib/postgresql/bin /var/lib/postgresql/data /var/lib/postgresql/log /root/postgresql
#  EOH
#end

directory '/var/lib/postgresql/10.1' do
  mode "0777"
  owner "postgres"
end
directory '/var/lib/postgresql/10.1/archive' do
  mode "0777"
  owner "postgres"
end

cookbook_file '/root/postgresql/postgresql_archiving.sh' do
  source'postgresql_archiving.sh'
  mode 0777
end

bash 'install postgresql' do
  cwd '/home/ec2-user'
  code <<-EOH
  sudo su -
  sh /root/postgresql/postgresql_archiving.sh archive 1GB 10 on  "cp %p /var/lib/postgresql/10.1/archive/%f" 1h
  EOH
end
