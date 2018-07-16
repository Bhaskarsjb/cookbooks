#
# Cookbook:: mysql_sr_CDH
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

execute "sudo su"

%w[ /data/db/ /data/db/MYSQL /data/db/MYSQL/LOG /data/db/MYSQL/scripts /data/db/MYSQL/PKG /var/mysql /var/mysql/bin /data01 /data01/db ].each do |path|
  directory path do
    owner "root"
    group "root"
    mode  "0777"
   end
end


ENV['MYSQLPATH'] = '/data/db/MYSQL'

ENV['SCRIPTDIR'] = '/data/db/MYSQL/scripts'

ENV['MYSQLDATAPATH'] = '/data01/db'

ENV['MYSQLUSR'] = 'mysql'

ENV['MYSQLBINPATH'] = '/var/mysql/bin'

ENV['LOGFILE'] = '/data/db/MYSQL/LOG/Install_Mysql_Sles_$DATE.out'


bash 'Initialization' do
    code <<-EOH
      DATE=`date +\"%Y%m%d_%H%M%S\"`;export DATE
      MYSQLPATH=/data/db/MYSQL;export MYSQLPATH
      SCRIPTDIR=$MYSQLPATH/scripts;export SCRIPTDIR
      MYSQLDATAPATH=/data01/db;export MYSQLDATAPATH
      MYSQLUSR=mysql;export MYSQLUSR
      MYSQLBINPATH=/var/mysql/bin;export MYSQLBINPATH
      PRIMARY=0
      PRIMARYHOST=""
      AUTH=0
      PASSWORD="password"
      LOGFILE=$MYSQLPATH/LOG/Install_Mysql_Sles_$DATE.out
      uname -a >> $LOGFILE
      export PATH=/usr/bin:/usr/sbin:$PATH
    EOH
end

#execute 'echo "Checking for wget pkgs.." >> $LOGFILE'

package 'wget' do
  action :install
end


tar_extract 'http://ftp.gnu.org/gnu/glibc/glibc-2.1.2.tar.gz' do
  target_dir '/data/db/MYSQL/PKG'
  creates '/data/db/MYSQL/PKG/lib'
end

#tar_package 'http://ftp.gnu.org/gnu/glibc/glibc-2.1.2.tar.gz' do
#  prefix '/tools/glibc-2.12'
#  creates '/tools/glibc-2.12/bin/pgpool'
#  configure_flags ['--HOST=x86_64-redhat-linux-gnu']
#  action :install
#end

#bash 'glib installation' do
#    cwd '/data/db/MYSQL/PKG/glibc-2.1.2' 
#    user "root"
#    group "root"
#    code <<-EOH
#    sleep 1s
#    sudo rpm -q glibc-2.1.2
#    if [ $? != 0 ]
#    then
#    cd /data/db/MYSQL/PKG
#    wget http://ftp.gnu.org/gnu/glibc/glibc-2.1.2.tar.gz
#    tar -xzvf glibc-2.1.2.tar.gz
#    cd glibc-2.1.2
#    ./configure --prefix=/tools/glibc-2.12
#    make j2
#    make -j2 install
#    fi
#    EOH
#end

group 'mysql' do
  action :create
#  members 'mysql'
  append true
end

user 'mysql' do
  shell '/bin/false'
  gid 'mysql'
  system true
end


%w[ /var/mysql /var/mysql/bin /data01 /data01/db ].each do |path|
  directory path do
    owner "mysql"
    group "mysql"
    mode  "0777"
    action :nothing
   end
end

remote_file '/data/db/MYSQL/PKG/mysql57-community-release-el7-7.noarch.rpm' do
  source 'https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm'
end

package 'mysql57-community-release-el7-7.noarch.rpm' do
  source '/data/db/MYSQL/PKG/mysql57-community-release-el7-7.noarch.rpm'
  action :install
end

package 'mysql-community-server'

execute 'yum repolist enabled | grep "mysql.*-community.*"'
execute 'yum repolist all | grep mysql'

service 'mysqld' do
  action [:start, :enable]
end

bash 'Generating key file with random data at $MYSQLPATH/mysql.key"' do
    cwd '/data/db/MYSQL/PKG/glibc-2.1.2' 
    user "root"
    code <<-EOH
    tr -cd '[:alnum:]' < /dev/urandom | fold -w50 | head -n1 > "$MYSQLPATH/mysql.key"
    cp "$MYSQLPATH/mysql.key" $MYSQLBINPATH/
    chmod 700 "$MYSQLPATH/mysql.key" "$MYSQLBINPATH/mysql.key"
#    group "root"
    EOH
not_if { ::File.exist?('/data/db/MYSQL/mysql.key') }
end

#bash 'creating mysql service' do
#    code <<-EOH
#    cd /etc/init.d/ || exit
#    chmod +x mysql
#    UP=$(ps -efa|grep -i mysqld|wc -l);
#    if [ "$UP" -lt 1 ];
#    then
#    EOH
#end        

#PASS1=`sudo grep 'temporary password' /var/log/mysqld.log|cut -d " " -f11`

#https://stackoverflow.com/questions/45607648/how-to-test-variable-with-chef-not-if-guard

bash 'password alter' do
  group 'root'
  user 'root'
  code <<-EOH
#    PASS1=`sudo grep 'temporary password' /var/log/mysqld.log|cut -d " " -f11`
    PASS1='MyNewPass4!'
#    echo $PASS1
      mysql -u root --password=MyNewPass4! --connect-expired-password 
      ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass4!';
      \EOH
    echo "    " >> /etc/my.cnf
    echo "[mysql]" >> /etc/my.cnf
    echo "user=root" >> /etc/my.cnf
    echo "password=MyNewPass4!" >> /etc/my.cnf
    EOH
  not_if { shell_out!('$PASS1').stdout != 'MyNewPass4!' }
#  not_if { shell_out!('$PASS1').stdout == shell_out!('sudo grep \'temporary password\' /var/log/mysqld.log|cut -d " " -f11').stdout }
end

#execute "mysql -u root --password=$PASS1 --connect-expired-password"
#execute "ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass4!';"
#execute "SHOW DATABASES;"

#include_recipe 'CDH_test_prerequisites'

#execute 'echo "MYSQL IS INSTALLED" >> /root/a.txt'
