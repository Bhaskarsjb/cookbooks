#https://www.tecmint.com/install-latest-mysql-on-rhel-centos-and-fedora/
# Cookbook:: mysql_CDH
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

execute "elevate permission" do
 command "sudo su "
end

execute "yum update" do
 command "yum -y update"
end

# Now download and add the following MySQL Yum repository to your respective Linux distribution system’s repository list to install the latest version of MySQL

remote_file 'mysql57-community-release-el7-7.noarch.rpm' do
  source 'http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm'
end

# now install the downloaded package

#execute 'mysql-community-repo' do
# command 'yum localinstall mysql57-community-release-el7-7.noarch.rpm'
# action :run
#end

package 'mysql57-community-release-el7-7.noarch.rpm' do
  source '/mysql57-community-release-el7-7.noarch.rpm'
  action :install
end

# The above installation command adds the MySQL Yum repository to system’s repository list and downloads the GnuPG key to verify the integrity of the packages.

# verify that the MySQL Yum repository has been added successfully by using following command.

# yum repolist enabled | grep "mysql.*-community.*"


# Install latest version of MySQL (currently 5.7) using the following command.

package 'mysql-community-server' do 
  action :install
end

service 'mysqld' do
  action [:start, :enable]
end


bash 'password alter' do
  group 'root'
  user 'root'
  code <<-EOH
    PASS1=`sudo grep 'temporary password' /var/log/mysqld.log|cut -d " " -f11`
    mysql -u root --password=$PASS1 --connect-expired-password <<-EOF
    ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass4!';
    SHOW DATABASES;
    EOF 
    NPWD=MyNewPass4!;export NPWD
    echo "    " >> /etc/my.cnf
    echo "[mysql]" >> /etc/my.cnf
    echo "user=root" >> /etc/my.cnf
    echo "password=$NPWD" >> /etc/my.cnf
    mysql -uroot -e show databases
    exit 0
    EOH
end
