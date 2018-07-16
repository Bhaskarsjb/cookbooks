#
# Cookbook:: Clustercheck
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

execute 'sudo su -'
execute 'rm -rf /root/log1.txt'

#execute 'ssh' do
#  cwd '/root'
#  command 'ssh root@mongonode2'
#end

#execute 'ls-ltr' do 
#  cwd '/root'
#  command 'ls -lrt >> /root/log.txt'
#end

execute "install mongodb" do
  command "sh /root/test.sh"
end

bash 'swappiness check' do
  cwd '/root'
  code <<-EOH
    sudo su -
    ls -ltr >> /root/log1.txt
      ssh root@mongonode2 <<\EOF  >> /root/log1.txt
      sleep 5
      ls -ltr >> /root/log1.txt
      exit >> /root/log1.txt
      EOF
    ssh root@mongonode3 >> /root/log1.txt
    ls -ltr >> /root/log1.txt
    exit >> /root/log1.txt
 EOH
end
