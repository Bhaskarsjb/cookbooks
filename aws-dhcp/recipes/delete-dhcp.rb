#
# Cookbook:: aws-dhcp
# Recipe:: delete-dhcp
#
# Copyright:: 2018, The Authors, All Rights Reserved.

require 'chef/provisioning/aws_driver'
with_driver 'aws::ap-south-1'

aws_dhcp_options 'ref-dhcp-options' do
  action :destroy
end
