#
# Cookbook:: Docker_test
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
# https://medium.com/@vi1996ash/steps-to-build-apache-web-server-docker-image-1a2f21504a8e
include_recipe 'apt'

docker_service 'default' do
  action [:create, :start]
end
##################################################################
# Pull latest image
#docker_image 'mysql/mysql-server' do
#  tag 'latest'
#  action :pull
#end

# Run container exposing ports
#docker_container 'mysql1' do
#  repo 'mysql/mysql-server'
#  tag 'latest'
#  action :run
#  port '80:80'
#  binds [ '/some/local/files/:/etc/nginx/conf.d' ]
#  host_name 'www'
#  domain_name 'computers.biz'
#  ENV 'fOO=bar'
#  subscribes :redeploy, 'docker_image[nginx]'
#end
######################################################################

######################################################################
# Building Apache Webserver Docker Image			     #
######################################################################

directory '/test' do
  owner "root"
  mode  "0777"
end

cookbook_file '/test/index.html' do
  owner "root"
  mode  "0777"
  source "index.html"
end

cookbook_file "/test/Dockerfile" do
  owner "root"
  mode  "0777"
  source "Dockerfile"
end

docker_image 'httpd-image1' do 
  tag 'httpd-image1'
  source '/test/Dockerfile'
  action :build_if_missing
end

# Run container exposing ports
docker_container 'httpd-image1' do
#  repo 'mysql/mysql-server'
  tag 'httpd-image1'
  action :run
  port '80:80'
#  binds [ '/some/local/files/:/etc/nginx/conf.d' ]
#  host_name 'www'
#  domain_name 'computers.biz'
#  ENV 'fOO=bar'
#  subscribes :redeploy, 'docker_image[nginx]'
end

#execute 'sudo docker run –p 80:80 -d httpd-image1'

