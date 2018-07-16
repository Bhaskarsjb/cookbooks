#
# Cookbook:: batch_sample
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

#cookbook_file "NamedInstance_Install.bat" do
#  source 'sample.bat'
#  path 'C:\Program Files\Microsoft SQL Server\SQL SERVER 2014 EEE\NamedInstance_Install.bat'
#  mode 0777
#  rights :full_control, 'Everyone'
#end

Chef::ReservedNames::Win32::Security.add_account_right('bhusia', 'SeAssignPrimaryTokenPrivilege')

batch "run-script" do
  cwd 'C:\\Program Files\\Microsoft SQL Server\\SQL SERVER 2014 EEE'
  code "SQLServer 2014"
#  user "bhusia"
#  password "Windows@14"
  action :run
end
