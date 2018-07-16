cookbook_file "Configuration.ps1" do
   source 'Configuration.ps1'
#  path 'C:\Program Files\Microsoft SQL Server\SQL SERVER 2014 EEE\Configuration.ps1'
   path 'E:\Configuration.ps1'
   rights :full_control, 'Everyone'
end

cookbook_file "SQLInstall.ps1" do
  source 'SQLInstall.ps1'
#path 'C:\Program Files\Microsoft SQL Server\SQL SERVER 2014 EEE\SQLInstall.ps1'
  path 'E:\SQLInstall.ps1'
  rights :full_control, 'Everyone'
end

powershell_script 'SQL 2014 INSTALLATION1' do
#  code "c:/7-zip/samplefile.ps1"
  code "E:/Configuration.ps1 -Action RemoveNode -SQLVERSION SQL2014 -FAILOVERCLUSTERNETWORKNAME SQLCLUSTER -SQLSETUPEXEPATH  E:/SQLSErver2014/" 
    #  cwd 'C:/7-zip'
  user 'cloud\bhaskar5'
  password 'Password123'
  elevated true
end

