#
# Cookbook:: SQL2014_Nandish
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

cookbook_file "Configuration.ps1" do
  source 'Configuration.ps1'
#  path 'C:\Program Files\Microsoft SQL Server\SQL SERVER 2014 EEE\Configuration.ps1'
   path 'C:\sql-2014\Configuration.ps1'
  rights :full_control, 'Everyone'
end

cookbook_file "SQLInstall.ps1" do
  source 'SQLInstall.ps1'
#  path 'C:\Program Files\Microsoft SQL Server\SQL SERVER 2014 EEE\SQLInstall.ps1'
  path 'C:\sql-2014\SQLInstall.ps1'
  rights :full_control, 'Everyone'
end

#cookbook_file "samplefile.ps1" do
#  source 'samplefile.ps1'
#  path 'C:\7-zip\samplefile.ps1'
#  mode 0777
#  rights :full_control, 'Everyone'
#end

#powershell_script 'SQL 2014 INSTALLATION' do
# code "Configure.ps1 -action install -SQLVERSION sql2014 -SQLSETUPEXEPATH 'C:\Program Files\Microsoft SQL Server\SQL SERVER 2014 EEE'"
#  code ". Configure.ps1 -action install -SQLVERSION sql2014 -SQLSETUPEXEPATH C"
#  cwd 'C:\Program Files\Microsoft SQL Server\SQL SERVER 2014 EEE'
#  user "bhusia"
#  password "Windows@14"
#  elevated true
#end

powershell_script 'SQL 2014 INSTALLATION1' do
#  code "c:/7-zip/samplefile.ps1"
  code "c:/sql-2014/Configuration.ps1 -action uninstall -SQLVERSION SQL2014 -SQLSETUPEXEPATH c:/sql-2014/" 
#  cwd 'C:/7-zip'
  user 'bhusia'
  password 'Windows@14'
  elevated true
end


