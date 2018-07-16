#
# Cookbook:: WISA
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights 

include_recipe 'wisa::lcm'
include_recipe 'wisa::web'
include_recipe 'wisa::database'
