#
# Cookbook:: mongodb_test
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

execute 'sudo su -'

#execute 'zypper update -y'

#execute 'zypper refresh'

%w[ /data /data/db /data/db/mongodb /data/db/mongodb/Install_Mongo /data/db/mongodb/LOG ].each do |path|
  directory path do
#    owner "root"
#    group "root"
     mode  "0777"
#    recursive false
   end
end

#directory "/data/db/mongodb/LOG" do
#  owner "root"
#  mode  "0777"
#end

cookbook_file "/data/db/mongodb/Install_Mongo/Install_Mongodb_Sles.sh" do
  source "Install_Mongodb_Sles.sh"
  mode 0777
end

execute "install mongodb" do
  command "sh /data/db/mongodb/Install_Mongo/Install_Mongodb_Sles.sh /data01/db mongodb suse12 3.6.2  > MONGODB.out"
end

cookbook_file "/data/db/mongodb/Install_Mongo/mongo_crt_usr.sh" do
  source "mongo_crt_usr.sh"
  mode 0777
end

execute "install mongodb" do
  command "sh /data/db/mongodb/Install_Mongo/mongo_crt_usr.sh admin"
end

cookbook_file "/data/db/mongodb/Install_Mongo/MongoShrad.sh" do
  source "MongoShrad.sh"
  mode 0777
end

execute "MongoShrad.sh" do
  command "sh /data/db/mongodb/Install_Mongo/MongoShrad.sh testdb"
end
