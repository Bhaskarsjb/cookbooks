#
# Cookbook:: aws-dhcp
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
require 'chef/provisioning/aws_driver'
with_driver 'aws::ap-south-1'

aws_dhcp_options 'ref-dhcp-options' do
#  domain_name 'example.com'
#  dhcp_options_id 'dopt-6a6bea02' # ------this was copied from aws management console
  domain_name 'example.com'  # ----changed from example.com to example.tk, did reflect in aws console
  domain_name_servers %w(8.8.8.8 8.8.4.4)
  netbios_name_servers %w(8.8.8.8 8.8.4.4)
  netbios_node_type 2
  aws_tags :chef_type => 'aws_dhcp_options'
end
