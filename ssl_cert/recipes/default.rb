#
# Cookbook:: ssl_cert
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
include_recipe "ssl_certificate"

ssl_certificate "webapp1" do
  action :create
#  namespace node["webapp1"] # optional but recommended
end
