#
# Cookbook:: sqlserver2014_windowsgcp
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.



directory 'C:\MSSQL' do
  rights :full_control, 'Everyone'
  inherits false
  action :create
end

directory 'C:\MSSQL\DATA' do
  rights :full_control, 'Everyone'
  inherits false
  action :create
end

directory 'C:\MSSQL\LOG' do
  rights :full_control, 'Everyone'
  inherits false
  action :create
end

directory 'C:\MSSQL\BACKUP' do
  rights :full_control, 'Everyone'
  inherits false
  action :create
end

directory 'C:\Program Files\Microsoft SQL Server' do
  rights :full_control, 'Everyone'
  inherits true
  action :create
end

directory 'C:\Program Files\Microsoft SQL Server\SQL SERVER 2014 EEE' do
  rights :full_control, 'Everyone'
  inherits true
  action :create
end

cookbook_file "\SQL2014_Tested.bat" do
  source 'SQL2014_Tested.bat'
  path 'C:\SQL-2014\SQL2014_Tested.bat'
#  mode 0777
  rights :full_control, 'Everyone'
end

batch "run-script" do
#  cwd 'C:\\Program Files\\Microsoft SQL Server\\SQL SERVER 2014 EEE'
  code "C:\\SQL-2014\\SQL2014_Tested.bat"
  user "bhusia"
  password "Windows@14"
  action :run
end
