#
# Cookbook Name:: consul
# Recipe:: default
# Installs Consul and configures consul user and data directory
# Copyright 2018,
#
# Author : Sweeti Bharti


#require 'chef/log'
#Chef::Log.level = :debug
#Chef::Log.level = :info

include_recipe 'tcloudwatch'
package "unzip"

remote_file 'download_consul_release' do
  source node['consul']['package_url']
  path "#{node['consul']['installation_dir']}/pakage.zip"
  action :create
end

execute "apt-get update"

package "python2.7"
package "python-pip"

execute 'install boto3' do
  command 'pip install boto3'
  action :run
end

execute 'unzip_consul_package' do
  command 'unzip -o *.zip && rm *.zip'
  cwd node['consul']['installation_dir']
  action :run
end

consul = Chef::EncryptedDataBagItem.load('consuluser', 'consul')

user 'consul' do
  username consul['id']
  password consul['password']
  supports :manage_home => true
  comment  consul['id']
end

directory 'consul_data_directory' do
  path 			node['consul']['data_dir']
  owner 		consul['id']
  group 		consul['id']
  mode 			'0777'
  recursive 	true
  action 		:create
end
