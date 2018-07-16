powershell_script 'Install IIS' do 
  code 'windowsFeature Web-server'
  guard_interpreter :powershell_script 
  not_if "(Get-WindowsFeature -Name Web-Server).Installed"
end

powershell_script 'Install IIS Management Console' do 
  code 'Add-WindowsFeature Web-Mgmt-Console' 
  guard_interpreter :powershell_script
  not_if "(Get-WindowsFeature-Name Web-MGMT-Console).Installed"
end 

powershell_script 'Install ASP.NET' do 
  code 'Add-WindowsFeature  web-ASP-Net45'
  guard_interpreter :powershell_script
  not_if "(Get-WindowsFeature -Name Web-Server).Installed"
end  

powershell_script 'Install IIS Static Content' do 
  code 'Add-WindowsFeature Web-Static-Content'
  guard_interpreter :powershell_script
  not_if "(Get-WindowsFeature -Name Web-Static-Content).Installed"
end 

service 'w3svc' do 
  action [:start, :enable]
end 

directory "C:/inetpub/wwwroot" do
recursive true 
end 

template "c:/inetpub/wwwroot/index.html" do 
  source 'index.html.erb'
end 

directory "C:/Users/Administrator/Desktop/dir_test" do
  recursive true
end

template "C:/Users/Administrator/Desktop/dir_test/sample.txt" do
  source 'index.html.erb'
end
