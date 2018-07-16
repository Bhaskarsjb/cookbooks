#
# Cookbook:: mount-test
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

execute 'sudo mkfs -t ext4 /dev/xvdf' do
  command 'sudo mkfs -t ext4 /dev/xvdf'
  not_if do
  File.exist?('/newvolume')
  end
end

directory '/newvolume' do
  action :create
#  recurssive :true
  owner 'root'
  group 'root'
  mode 0775
end

mount '/newvolume' do
  device '/dev/xvdf'
  fstype 'ext4'
  action [ :umount, :disable ]
end


