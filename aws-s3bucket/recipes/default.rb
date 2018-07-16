#
# Cookbook:: aws-s3bucket
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

#require 'chef/provisioning/aws_driver'
#with_driver 'aws'



#aws_s3_bucket 'bhaskar_759812' do
#  region 'ap-south-1'
#  enable_website_hosting false
#  versioning false
#  options({ :acl => 'private' })
#  action :create
#end
include_recipe 'aws'

aws = data_bag_item('aws', 'main')

aws_s3_bucket 'bhaskar759812' do
#  aws_access_key aws['AKIAIFBSHM2WY4SJ3BGA']
#  aws_secret_access_key aws ['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']
  aws_access_key aws['aws_access_key_id']
  aws_access_key aws['aws_secret_access_key']
  versioning true
  region 'ap-south-1'
  action :create
end
