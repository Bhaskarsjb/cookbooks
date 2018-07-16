#https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-8-on-ubuntu-14-04
# Cookbook:: 1-click-deploy
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

bash "update-apt-repository" do
  user "root"
  code <<-EOH
  apt-get update
  EOH
end

package 'default-jdk' do
  action :install
end

group 'tomcat-group' do
  group_name "#{node['1-click-deploy']['tomcat_group']}"
  action :create
end

user 'tomcat-user' do
  username "#{node['1-click-deploy']['tomcat_user']}"
#  shell '/bin/nologin'
  shell '/bin/nologin'
  group 'tomcat'
  home '/opt/tomcat'
end

directory '/opt/tomcat' do
  action :create
  group 'tomcat'
end

remote_file 'Downloading tomcat binary distribution' do
  source 'http://mirrors.ibiblio.org/apache/tomcat/tomcat-8/v8.0.52/bin/apache-tomcat-8.0.52.tar.gz'
  path '/opt/tomcat/apache-tomcat-8.0.52.tar.gz'
  owner "#{node['1-click-deploy']['tomcat_user']}"
  group "#{node['1-click-deploy']['tomcat_group']}"
  mode '0755'
end


#tar_extract '/opt/tomcat/apache-tomcat-8.0.52.tar.gz' do
#  action :extract_local
#  target_dir '/opt/tomcat'
#  creates '/opt/myapp/mycode/lib'
#  tar_flags ['-v' ,'--strip-components 1']
#end

#execute 'tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1'
bash 'extract_module' do
  cwd '/opt/tomcat'
  code <<-EOH 
    tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1
    EOH
end



directory '/opt/tomcat/conf' do
  group "#{node['1-click-deploy']['tomcat_group']}"
  mode '0777'
  recursive true
  action :nothing
end

%w[ /opt/tomcat/webapps /opt/tomcat/work /opt/tomcat/temp /opt/tomcat/logs ].each do |path|
  directory path do
     owner "tomcat"
    group "root"
     mode  "0777"
    recursive false
   end
end

bash 'extract_module' do
  cwd '/opt/tomcat'
  code <<-EOH
    chgrp -R tomcat /opt/tomcat
    chmod -R g+r conf
    chmod g+x conf
    chown -R tomcat webapps/ work/ temp/ logs/
    EOH
end

template "Install upstart script tomcat.conf" do
                source "tomcat.conf.erb"
                mode 0777
                owner "#{node['1-click-deploy']['tomcat_user']}"
                group "#{node['1-click-deploy']['tomcat_group']}"
		path '/etc/init/tomcat.conf'
                variables(
                                :JAVA_HOME => "#{node['1-click-deploy']['JAVA_HOME']}",
                                :CATALINA_HOME => "#{node['1-click-deploy']['CATALINA_HOME']}",
				:USERID => "#{node['1-click-deploy']['tomcat_user']}",
				:GROUPID => "#{node['1-click-deploy']['tomcat_group']}"
                )
end

template "Configure tomcat web management interface" do
		source "tomcat-users.xml.erb"
		mode 0777
		owner "#{node['1-click-deploy']['tomcat_user']}"
		group "#{node['1-click-deploy']['tomcat_group']}"
		path '/opt/tomcat/conf/tomcat-users.xml'
		force_unlink true
		variables(
				:user => "#{node['1-click-deploy']['tomcat_adminuser']}",
				:password => "#{node['1-click-deploy']['tomcat_adminpwd']}"
		)

end

remote_file 'Downloading sample war file' do
  source 'https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war'
  path '/opt/tomcat/webapps/sample.war'
  owner "#{node['1-click-deploy']['tomcat_user']}"
  group "#{node['1-click-deploy']['tomcat_group']}"
  mode '0777'
end

execute 'sudo initctl reload-configuration'

#service 'tomcat' do
#  action [:start, :enable]
#end

execute 'sudo initctl restart tomcat'
