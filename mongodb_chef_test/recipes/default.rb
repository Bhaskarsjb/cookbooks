#
# Cookbook:: mongodb_chef_test
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
######################################################

#Create directories for mongodb install

%W[ #{node['mongodb_chef_test']['data']} #{node['mongodb_chef_test']['MONGODATAPATH']} #{node['mongodb_chef_test']['MONGOPATH']} #{node['mongodb_chef_test']['SCRIPTDIR']} #{node['mongodb_chef_test']['LOG']} #{node['mongodb_chef_test']['VARMONGO']} ].each do |path|
  directory path do
    mode 0777
    recursive true
  end
end

#Create mongodb group and user

%w[ dba mongodb  ].each do |grp|
  group grp do 
    action :create
  end
end

user 'mongodb' do
  comment 'A mongodb user'
  group 'mongodb'
  gid 'dba'
  home '/usr/sbin'
end

#Change the ownership under /var/mongodb..

%W[ #{node['mongodb_chef_test']['VARMONGO']} #{node['mongodb_chef_test']['MONGODATAPATH']} ].each do |path|
  directory path do
    owner "#{MONGOUSER}"
    group 'mongodb'
    recursive true
  end
end


