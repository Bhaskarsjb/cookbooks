#
# Cookbook:: postgresql_chef_test
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

#Create PostgreSQL user account

# Initialize the Parameters
PostgreVersion="#{node['postgresql_chef_test']['PostgreVersion']}"
binarypath="#{node['postgresql_chef_test']['binarypath']}"
DataFolder="#{node['postgresql_chef_test']['DataFolder']}"
logfilepath="#{node['postgresql_chef_test']['logfilepath']}"
InstallFolder="#{node['postgresql_chef_test']['InstallFolder']}"
port="#{node['postgresql_chef_test']['port']}"

#Create sysconfig file for systemclt

template "/etc/sysconfig/postgresql" do
                source "postgresql_sysconfig.erb"
                mode 0777
                owner "root"
                group "root"
                variables(
                                :POSTGRES_DATADIR => "#{node['postgresql_chef_test']['DataFolder']}/#{node['postgresql_chef_test']['PostgreVersion']}",
                                :POSTGRES_OPTIONS => "#{node['postgresql_chef_test']['port']}",
                                :POSTGRE_BINDIR => "#{node['postgresql_chef_test']['binarypath']}/#{node['postgresql_chef_test']['PostgreVersion']}",
                                :POSTGRES_LOGDIR => "#{node['postgresql_chef_test']['logfilepath']}/#{node['postgresql_chef_test']['PostgreVersion']}"
                )
end

#Initialize the Installation log file location
#execute "LOGFILE=#{InstallFolder}-#{PostgreVersion}-Installlogfile.out"

##########################################################################
#Creating software, Data, Binary directories and Server logoutput filename
##########################################################################

%W[ #{node['postgresql_chef_test']['InstallFolder']} #{node['postgresql_chef_test']['InstallFolder']}/#{node['postgresql_chef_test']['PostgreVersion']} #{node['postgresql_chef_test']['postgresql']} #{node['postgresql_chef_test']['DataFolder']} #{node['postgresql_chef_test']['binarypath']} #{node['postgresql_chef_test']['logfilepath']} #{node['postgresql_chef_test']['DataFolder']}/#{node['postgresql_chef_test']['PostgreVersion']} #{node['postgresql_chef_test']['binarypath']}/#{node['postgresql_chef_test']['PostgreVersion']} #{node['postgresql_chef_test']['logfilepath']}/#{node['postgresql_chef_test']['PostgreVersion']} ].each do |path|
  directory path do
    mode 0777
    owner 'root'
    group 'root'
    recursive true
  end
end


logfilepath="#{node['postgresql_chef_test']['logfilepath']}"
PostgreVersion="#{node['postgresql_chef_test']['PostgreVersion']}"

#execute "umask 077 #{logfilepath}/#{PostgreVersion}"
#execute 'umask 077 /var/lib/postgresql/log/10.1'

#Installing wget package

package 'wget' do 
  action :install
end

#Download Postgresql tar binaries

#tar_extract "https://ftp.postgresql.org/pub/source/v\"#{node[:postgresql_chef_test][:PostgreVersion]/postgresql-10.1.tar.gz\"}" do
#tar_extract 'https://"#{node[:postgresql_chef_test][:postgresql]/postgresql-node[:postgresql_chef_test][:postgresql]}".tar.gz' do
#  target_dir '/root/postgresql'
#  creates '/root/postgresql/lib_chef'
#end

#tar_extract "https://ftp.postgresql.org/pub/source/v\"#{node['postgresql_chef_test']['InstallFolder']}\""

#execute 'wget -P $InstallFolder/$PostgreVersion https://ftp.postgresql.org/pub/source/v$PostgreVersion/postgresql-$PostgreVersion.tar.gz'

extract_path = "#{node['postgresql_chef_test']['InstallFolder']}/#{node['postgresql_chef_test']['PostgreVersion']}"
remote_file "#{node['postgresql_chef_test']['InstallFolder']}/#{node['postgresql_chef_test']['PostgreVersion']}/postgresql-#{node['postgresql_chef_test']['PostgreVersion']}.tar.gz}" do
  source "#{node['postgresql_chef_test']['url']}"
  owner 'root'
  group 'root'
  mode '0755'
#not_if { ::File.exist?(extract_path) }
end

#Extracting Binaries

tar_extract "#{node['postgresql_chef_test']['InstallFolder']}/#{node['postgresql_chef_test']['PostgreVersion']}/postgresql-#{node['postgresql_chef_test']['PostgreVersion']}.tar.gz}"  do
  action :extract_local
  target_dir "#{node['postgresql_chef_test']['InstallFolder']}/#{node['postgresql_chef_test']['PostgreVersion']}"
  creates "#{node['postgresql_chef_test']['InstallFolder']}/#{node['postgresql_chef_test']['PostgreVersion']}/lib"
end

#Installing Readline package

zypper_package 'readline-devel' do
  action :install
#  version 'readline-devel-6.3-83.10.1.x86_64'
  options '--name'
end

#Installing zlib package

zypper_package 'zlib-devel' do
  action :install
  options '--name'
end

#Installing Readline gcc Packages

zypper_package 'gcc' do
  action :install
  options '--name'
end

#PostGreInstallation

zypper_package 'make' do
  action :install
end

execute 'sleep 1s'

#tar_package 'https://ftp.postgresql.org/pub/source/v10.1/postgresql-10.1.tar.gz' do
#  source_directory '/root/postgresql'
#  prefix '/var/lib/postgresql/bin/10.1'
#  configure_flags [ '--bindir /var/lib/postgresql/bin/10.1' ]
#  creates '/var/lib/postgresql/bin/'
#  action :install
#end

PostgreVersion="#{node['postgresql_chef_test']['PostgreVersion']}"
InstallFolder="#{node['postgresql_chef_test']['InstallFolder']}"
binarypath="#{node['postgresql_chef_test']['binarypath']}"
install_path = "#{node['postgresql_chef_test']['InstallFolder']}/#{node['postgresql_chef_test']['PostgreVersion']}"
bash 'PostGreInstallation' do 
  cwd ::File.dirname(install_path)
  code <<-EOH
    sudo su -
    #{install_path}/postgresql-#{PostgreVersion}/configure --prefix=#{binarypath}/#{PostgreVersion}/ --bindir=#{binarypath}/#{PostgreVersion}
    sleep 2s
    sudo zypper -n install make
    sudo make install
    sudo zypper refresh
  EOH
#not_if { ::Directory.exist?(binarypath/PostgreVersion) }
end

#Create PostgreSQL user account
bash 'PostgreSQL user account' do
  cwd '/home/ec2-user'
  code <<-EOH
    sudo su -
    sudo useradd postgres 
    sudo groupadd postgres 
    sudo groupadd dba 
    sudo /usr/sbin/useradd -m -g postgres -G dba pgsql
  EOH
end


#Start the PostgreSQL services with specified data directory.

bash 'PostgreSQL user account permission' do
  cwd '/home/ec2-user'
  code <<-EOH
    sudo su -
    chown -R postgres #{DataFolder}/#{PostgreVersion}
    chown -R postgres #{binarypath}/#{PostgreVersion}
    chown -R postgres #{logfilepath}/#{PostgreVersion}
    chmod -R 755 #{DataFolder}/#{PostgreVersion}
    chmod -R 755 #{binarypath}/#{PostgreVersion}
    chmod -R 755 #{logfilepath}/#{PostgreVersion}
  EOH
end

#{binarypath}/#{PostgreVersion}/initdb -D #{DataFolder}/#{PostgreVersion}
#su - postgres --command "#{binarypath}/#{PostgreVersion}/pg_ctl -D #{DataFolder}/#{PostgreVersion}/ -o '-p #{port}' -l #{'logfilepath'}/#{PostgreVersion}/postgres_serverlog.out start" 

#execute 'su - postgres --command "/var/lib/postgresql/bin/10.1/initdb -D /var/lib/postgresql/data/10.1"'

bash 'Start the PostgreSQL services [initdb]' do 
  cwd '/root'
  code <<-EOH
  su - postgres --command "#{binarypath}/#{PostgreVersion}/initdb -D #{DataFolder}/#{PostgreVersion}"
  if [ $? != 0 ]
  then
  echo "Postgres service restart failed.. please validate the logfile..."
  exit 0
  fi
  EOH
end

#execute "su - postgres --command \"/var/lib/postgresql/bin/10.1/pg_ctl -D /var/lib/postgresql/data/10.1/ -o '-p 5432' -l /var/lib/postgresql/log/10.1/postgres_serverlog.out start\""


bash 'Start the PostgreSQL services [pg_ctl]' do
  cwd '/root'
  code <<-EOH
  su - postgres --command "#{binarypath}/#{PostgreVersion}/pg_ctl -D #{DataFolder}/#{PostgreVersion}/ -o #{port} -l #{logfilepath}/#{PostgreVersion}/postgres_serverlog.out start" 
  if [ $? != 0 ]
  then
  echo "Postgres service restart failed.. please validate the logfile..."
  exit 0
  fi
  EOH
end

execute 'sleep 2s'

#Display Checking version....
#version=shell_out!("#{binarypath}/#{PostgreVersion}/postgres -V").stdout
#log "Checking version.... :: #{version}"

#Display Log destination folder
#logdest=shell_out!("#{binarypath}/#{PostgreVersion}/psql -U postgres -p #{port} -c 'show log_destination;'"
#log "Log destination folder is #{logdest}"

#Display Data Directory Location
#datadirloc=shell_out!("#{binarypath}/#{PostgreVersion}/psql -U postgres -p #{port} -c \"show data_directory;\""
#log "Data destination directory location is :: #{logdest}"

#Display Log Directory...."
#logdir=shell_out!("#{binarypath}/#{PostgreVersion}/psql -U postgres -p #{port} -c \"show show log_directory;\""
#log "Log Directory is :: #{logdir}"

log "Script executed successfully!"
log "Script executed successfully!"

#Process to create files for systemctl

directory '/usr/share/postgresql' do
  owner 'postgres'
  mode '0777'
  recursive true
end

cookbook_file "/usr/share/postgresql/postgresql-script" do
  source "postgresql--script"
  mode 0777
#  force_unlink true
  owner 'postgres'
#  recursive true
end  

#Process to create postgresql.service file

cookbook_file "/usr/lib/systemd/system/postgresql.service" do
  source "postgresql.service"
  mode 0777
#  force_unlink true
  owner 'postgres'
  group 'postgres'
end

bash 'restart' do
  cwd '/root'
  code <<-EOH
    chown -R postgres /etc/sysconfig/postgresql 
    chmod +x /usr/share/postgresql/postgresql-script
    su - postgres -c "/var/lib/postgresql/bin/10.1/pg_ctl -D /var/lib/postgresql/data/10.1 stop"
  EOH
end    

execute 'ln -s /usr/lib/systemd/system/postgresql.service /etc/systemd/system/multi-user.target.wants/postgresql.service'
execute 'systemctl enable postgresql'
execute 'systemctl start postgresql'


