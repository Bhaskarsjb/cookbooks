
#%W[ #{node['postgresql_chef_test']['InstallFolder']} #{node['postgresql_chef_test']['InstallFolder']}/#{node['postgresql_chef_test']['PostgreVersion']} #{node['postgresql_chef_test']['postgresql']} #{node['postgresql_chef_test']['postgresql']}/#{node['postgresql_chef_test']['DataFolder']} #{node['postgresql_chef_test']['postgresql']}/#{node['postgresql_chef_test']['binarypath']} #{node['postgresql_chef_test']['postgresql']}/#{node['postgresql_chef_test']['logfilepath']} #{node['postgresql_chef_test']['postgresql']}/#{node['postgresql_chef_test']['logfilepath']}/#{node['postgresql_chef_test']['PostgreVersion']} #{node['postgresql_chef_test']['postgresql']}/#{node['postgresql_chef_test']['DataFolder']}/#{node['postgresql_chef_test']['PostgreVersion']} #{node['postgresql_chef_test']['postgresql']}/#{node['postgresql_chef_test']['binarypath']}/#{node['postgresql_chef_test']['PostgreVersion']} ].each do |path|
#  directory path do
#    owner "root"
#    group "root"
#    mode  "0777"
#    recursive true
#  end
#end


%W[ #{node['mongodb_chef_test']['data']} #{node['mongodb_chef_test']['MONGODATAPATH']} #{node['mongodb_chef_test']['MONGOPATH']} #{node['mongodb_chef_test']['SCRIPTDIR']} #{node['mongodb_chef_test']['LOG']} #{node['mongodb_chef_test']['VARMONGO']} #{node['mongodb_chef_test']['PKG']} ].each do |path|
  directory path do
    mode 0777
    recursive true
  end
end

#Create mongodb group and user

%w[ dba mongodb ].each do |grp|
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


%W[ #{node['mongodb_chef_test']['VARMONGO']} #{node['mongodb_chef_test']['MONGODATAPATH']} #{node['mongodb_chef_test']['MONGOPATH']} ].each do |path|
  directory path do
    owner "#{node['mongodb_chef_test']['MONGOUSER']}"
    group 'mongodb'
    recursive true
  end
end

%w[ glibc cyrus-sasl ].each do |pkg|
  zypper_package pkg do
    action :install
  end
end

tar_extract "https://downloads.mongodb.com/linux/mongodb-linux-x86_64-enterprise-#{node['mongodb_chef_test']['OSVER']}-#{node['mongodb_chef_test']['DBVER']}.tgz" do
  target_dir "#{node['mongodb_chef_test']['PKG']}"
  creates "#{node['mongodb_chef_test']['PKG']}/lib"
  tar_flags [ '-v' ]
end
