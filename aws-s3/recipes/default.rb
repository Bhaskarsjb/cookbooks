#
# Cookbook:: aws-s3
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

require 'chef/provisioning/aws_driver'
with_driver 'aws::ap-south-1'

#aws_s3_bucket '7598123' do
#  action :create
#end


machine 'mysql_redhat-test' do
  action :stop
end
