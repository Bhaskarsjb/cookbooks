#
# Cookbook:: Mongo3nodecluster
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# Elevating the permission
execute 'sudo su -'

#Creating the preinstallation directorites
%w[ /data /data/db /data/db/mongodb /data/db/mongodb/Install_Mongo /data/db/mongodb/LOG ].each do |path|
  directory path do
    owner "root"
#    group "root"
     mode  "0777"
#    recursive false
   end
end

#Importing the installation script to the remote server to the specified location
cookbook_file "/data/db/mongodb/Install_Mongo/Install_Mongodb_Sles.sh" do
  source "Install_Mongodb_Sles.sh"
  mode 0777
end

#Installing mongodb
#execute "install mongodb" do
#  command "sh /data/db/mongodb/Install_Mongo/Install_Mongodb_Sles.sh /data01/db mongodb suse12 3.6.2  > MONGODB.out"
#end

#Importing the script to create the mongo admin users
cookbook_file "/data/db/mongodb/Install_Mongo/mongo_crt_usr.sh" do
  source "mongo_crt_usr.sh"
  mode 0777
end

#bash 'installing mongodb' do
#  cwd '/home/bhusia'
#  code <<-EOH
#    sudo su -
#    sh /data/db/mongodb/Install_Mongo/Install_Mongodb_Sles.sh /data01/db mongodb suse12 3.6.2  > MONGODB.out
#    EOH
#end

#Creating the mongo admin users

#execute "install mongodb" do
#  command "sh /data/db/mongodb/Install_Mongo/mongo_crt_usr.sh admin"
#end

#bash 'Creating Users' do
#  cwd '/home/bhusia'
#  code <<-EOH
#    sudo su -
#    sh /data/db/mongodb/Install_Mongo/mongo_crt_usr.sh admin
#    EOH
#end

if node['ipaddress']=='10.160.0.6'
  cookbook_file "/data/db/mongodb/Install_Mongo/Mongo_noderepl.sh" do
    source "Mongo_noderepl.sh"
    mode 0777
#    force_unlink true
  end
#  execute "Mongo_noderepl" do
#    command "sh /data/db/mongodb/Install_Mongo/Mongo_noderepl.sh 10.160.0.7 10.160.0.8"
#  end
  bash 'mongo_noderepl' do
     cwd '/home/bhusia'
     code <<-EOH
     sudo su -
     sh /data/db/mongodb/Install_Mongo/Mongo_noderepl.sh 10.160.0.7 10.160.0.8 >> mongocluster.out
     EOH
  end
end





