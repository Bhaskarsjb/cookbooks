#https://docs.chef.io/dsl_recipe.html
# https://www.ebicus.com/nl/blog/big-data-setting-up-the-cluster/ "big data setting up in the cluster"
# Cookbook:: CDH_test_prerequisites
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

#log "#{node.default['CDH_test_prerequisites']['fs_type']}"

#if node.attribute?('ipaddress')
#  log 'IP IS AVAILABLE'
#  package 'httpd'
#elsif
#  log 'IP IS NOT AVAILABLE'
#end


#if node['ipaddress']=='172.31.23.20'
#  log 'IP IS AVAILABLE'
#elsif
#log 'IP IS NOT AVAILABLE'
#end


#execute 'sudo yum update -y'

execute 'sudo su'
execute 'rm -rf /root/a.txt'

ENV['NV'] = node['platform_version']

package 'wget' do
  action :install
end

case node['platform_version']
when '6.4', '6.5', '6.6', '6.7', '6.8', '6.9', '7.1', '7.2', '7.0', '7.3', '7.4'
  log '###########################  PLATFORM VERSION IS SUPPORTED: rhel- 7.2   #################'
  execute 'echo "   * PLATFORM VERSION SUPPORTED: rhel-"$NV"" >> /root/a.txt'
else
  log '###########################  PLATFORM VERSION IS NOT SUPPORTED   #################'
  execute 'echo "   * PLATFORM VERSION NOT SUPPORTED: rhel-"$NV"" >> /root/a.txt'
end

#case node['platform']
#when 'debian', 'ubuntu'
#  log 'do debian/ubuntu things'
#when 'redhat', 'centos', 'fedora'
#  log '*@*@**@*@*@*@*@*@**@*@*@*@*@* DO REDHAT/CENTOS/FEDORA THINGS  @*@*@*@*@*@*@*@*@*@*@*@*@*@*'
#end


#bash 'Execute my script' do 
#  user 'root'
#  cwd  '/home/ubuntu/'
#  code <<-EOH
#    curl -Is http://www.google.com | head -1
#    if [ $? != "HTTP/1.1 200 OK" ]
#    then
#    echo "Internet access is enabled" >> /home/ec2-user/client.log
#    else
#    echo "Internet access is not enbled " >> /home/ec2-user/client.log
#    fi
#  EOH
#end

#execute 'sudo yum update -y'

yum_package 'firewalld' do
  action :install
end

service 'firewalld' do
  action [:start, :enable]
end

package 'ntp' do
  action :install
end


if node['hostname']=='CDH_test_prerequisites'
  cookbook_file "/etc/ntp.conf" do
    source "ntp.conf"
    mode 0777
    force_unlink true 
  end
end

if node['hostname']!='CDH_test_prerequisites'
  cookbook_file "/etc/ntp.conf" do
    source "ntp_node.conf"
    mode 0777
    force_unlink true
  end
end


execute 'firewall-cmd --add-service=ntp --permanent'
execute 'firewall-cmd --reload'

execute 'echo "   * NTP SERVER IS INSTALLED AND CONFIGURED" >> /root/a.txt'

service 'ntpd' do
  action [:start, :enable]
end

#swap_file 'swappiness' do
#  swappiness 10
#  action :nothing
#end
#bash 'swappiness check' do
#  code <<-EOH
#    sysctl -w vm.swappiness=20
#    sysctl -a | grep vm.swappiness | cut -c 17-18
#    if [ $? ! = 20 ]
#    then 
#    echo "Internet access is enabled" >> /home/ec2-user/client.log
#    else
#    echo "Internet access is not enbled " >> /home/ec2-user/client.log
#    EOH
#end

#execute 'sysctl -a | grep vm.swappiness'

package 'perl' do
  action :install
end

execute 'echo "   * PERL IS INSTALLED" >> /root/a.txt'

package 'python-psycopg2' do
  action :install
end

execute 'echo "   * PYTHON-PSYCOPG2 IS INSTALLED" >> /root/a.txt'

#Cannot allocate memory - fork(2) error for below command,  we can use wget with root permission manually

remote_file '/etc/yum.repos.d/cloudera-manager.repo' do
  source 'http://archive.cloudera.com/cm5/redhat/7/x86_64/cm/cloudera-manager.repo'
  mode '0755'
#  force_unlink 'True'
end

package 'oracle-j2sdk1.7' do
  action :install
end

execute 'echo "   * JDK (oracle-j2sdk1.7) IS INSTALLED" >> /root/a.txt'

#remote_file '/etc/yum.repos.d/python.repo' do
#  source 'http://archives.fedoraproject.org/pub/archive/epel/5/i386/epel-release-5-4.noarch.rpm'
#end

bash 'swappiness check' do
  code <<-EOH
    sysctl -w vm.swappiness=1
    sysctl -a | grep vm.swappiness | cut -c 17
    if [ $? != 1 ]
      then 
      echo "   * "$(sysctl -a | grep vm.swappiness)"" >> /root/a.txt
      else
      echo "   * vm.swappiness is not set to 1 " >> /root/a.txt
    fi
    curl -Is http://www.google.com | head -1 | cut -c 10-12
    if [ $? != 200 ]
      then
      echo "   * Internet access is enabled" >> /root/a.txt
      else
      echo "   * Internet access is not enbled" >> /root/a.txt
    fi
    EOH
end

#################################################
#remote_file "your-remote-file" do
#  ...
#  not_if "rpm -qa | grep -qx 'your-package'"
#end
####I###################i##########################

#https://discourse.chef.io/t/include-recipe-if-file-exists/6988

if node['hostname']=="CDH_test_prerequisites"
  ruby_block 'Include at run time' do
    block do
      run_context. include_recipe 'mysql_sr_CDH'
    end
    not_if { ::File.exist?("/etc/my.cnf") }
  end  
  execute 'echo "   * MYSQL INSTALLED" >> /root/a.txt'
end

node.default['CDH_test_prerequisites']['fs_type']==shell_out!('$df -T |grep "^/dev/*" |cut -c 16-18').stdout

#node.default['CDH_test_prerequisites']['fs_type'] = "xfs"

#if node.default['CDH_test_prerequisites']['fs_type']!='xfs'
#  log 'IP IS AVAILABLE'
#elsif
log "#{node.default['CDH_test_prerequisites']['fs_type']}"
#end

#if [ $? != 'ext' ]
bash 'Checking filesystem type of root volume' do
  code <<-EOH
    if [ $(df -T |grep "^/dev/*" |cut -c 16-18) == 'ext' ]
      then
      echo "   * Filesystem Type is "$(df -T |grep "^/dev/*" |cut -c 16-18)"" >> /root/a.txt
      else
      echo "   * Filesystem Type is ""$(df -T |grep "^/dev/*" |cut -c 16-18)"" and not ext4/ext3!!!" >> /root/a.txt
    fi
    EOH
end

bash 'Checking the size of root volume' do
  code <<-EOH
    if [ $(df -H |grep "^/dev/*" |cut -c 18-19) -lt '50' ]
      then
      echo "   * Root Volume Size is  "$(df -H |grep "^/dev/*" |cut -c 18-20)", but os portion should have atleast 50Gb" >> /root/a.txt
      else
      echo "   * Root Volume Size is  "$(df -H |grep "^/dev" |cut -c 18-20)"" >> /root/a.txt
    fi
    EOH
end

#To chef if volume is raid configured or not

# https://www.tecmint.com/create-raid-10-in-linux/
# mdadm -D /dev/mdxx # Raid is software

#package 'mdadm' do
#  action :install
#end


# If raid is hardware 

# https://stackoverflow.com/questions/4440873/get-details-of-raid-configuration-linux

package 'pciutils' do
  action :install
end


bash "Checking volume is raid configured or not" do
  code <<-EOH
    lspci -vv | grep -i raid
    if [ $? != 0 ]
    then
    echo "   * Volume is not raid configured" >> /root/a.txt
    else
    echo "   * Volume is raid configured" >> /root/a.txt
    fi
  EOH
end

#execute 'sendemail -t bhaskar.5@tcs.com -m "CDH PREREQUISITES LOG FILE." -a /root/a.txt'
#node.default['CDH_test_prerequisites']['subnet']==shell_out!('$(ohai | grep subnet_ipv4_cidr_block | cut -c 36-49)').stdout
#execute 'ohai | grep subnet_ipv4_cidr_block | cut -c 36-49 >> /root/a.txt'

bash "Checking the subnet" do
  code <<-EOH
    cidr=`ohai | grep subnet_ipv4_cidr_block | cut -c 36-49`
    if [ $cidr == "172.31.16.0/20" ]
    then
    echo "   * Node belongs to the same subnet: "$(ohai | grep subnet_ipv4_cidr_block | cut -c 36-49)"" >> /root/a.txt
    else
    echo "   * Node belongs to a different subnet: "$(ohai | grep subnet_ipv4_cidr_block | cut -c 36-49)"" >> /root/a.txt
    fi
  EOH
end


