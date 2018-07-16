#
# Cookbook:: postgres_upgrade
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

execute 'sudo su'

cookbook_file '/root/postgresql/10.1' do
  source'postgresql-upgrade'
  mode 0777
end

bash 'postgresql-upgrade' do
  cwd '/home/ec2-user'
  code <<-EOH
  sudo su -
  sh /root/postgresql/10.1/postgresql-upgrade.sh 10.2 /var/lib/postgresql/bin /var/lib/postgresql/data /var/lib/postgresql/log /root/postgresql 5433 10.1
  EOH
end
