# Installs Consul and configures consul user and data directory
# Copyright 2018,
#
# Author : Sweeti Bharti


#require 'chef/log'
#Chef::Log.level = :debug
#Chef::Log.level = :info

include_recipe 'nssm'

directory node['consul']['windows']['installation_dir'] do
  mode      '0777'
  recursive true
  action    :create
end


remote_file 'download_consul_release' do
  source node['consul']['windows']['package_url']
  path "#{node['consul']['windows']['installation_dir']}/package.zip"
  action :create
end

windows_zipfile node['consul']['windows']['installation_dir'] do
    source    "#{node['consul']['windows']['installation_dir']}/package.zip"
    overwrite true
    action    :unzip
    not_if do ::File.exists?("#{node['consul']['windows']['installation_dir']}/consul.exe") end
  end


directory 'consul_data_directory' do
  path 	        node['consul']['windows']['data_dir']
  mode			'0777'
  recursive     true
  action  	    :create
end

windows_package 'Python27' do
  source node['client']['windows']['python']
  action :install
  not_if do ::File.exists?('C:\\Python27') end
end

execute 'install boto3' do
  cwd 'C:\\Python27\\Scripts'
  command 'pip install boto3'
  only_if do ::File.exists?('C:\\Python27\\Scripts') end
end

directory 'consul_config_directory' do
  path		node['client']['windows']['client_config_dir']
  recursive     true
  action	:create
end

directory 'consul_script_directory' do
  path		node['client']['windows']['custom_script_path']
  recursive     true
  action	:create
end


#create configuration files for client
file_path = "#{node['client']['windows']['client_config_dir']}/client.json"

template file_path do
  source 'windowsclient.json.erb'
end

#create consul service for windows
nssm 'ConsulClient' do
  program "#{node['consul']['windows']['installation_dir']}/consul.exe"
  args "agent -config-file=#{node['client']['windows']['client_config_dir']}/client.json"
  action :install
end


script_path = "#{node['client']['windows']['custom_script_path']}/win_get_consul_node_ip.py"
ec2_access_key = Chef::EncryptedDataBagItem.load('aws_credentials', 'ec2_keys')
template script_path do
  source 'win_get_consul_node_ip.py.erb'
  mode '0755'
  action :create
end

ruby_block "fetch consul servers ip" do
  block do
    seed_ip_list = []
    ip_list=`C:\\Python27\\python #{script_path} | tr -d '[],' `
        node_ip = ["\'#{node['ipaddress']}\'"]
        ip_list.tr("'\"", "")
        ip_list = ip_list.split(' ')
        ip_list = ip_list - node_ip
        ip_list.each do |item|
            seed_ip_list << item.tr("/'","")
		end
    node.set['consul']['nodes_ip'] = seed_ip_list
	consul_exe_path = "#{node['consul']['windows']['installation_dir']}\\consul.exe"
	node['consul']['nodes_ip'].each do |server_node|
		`#{consul_exe_path} join #{server_node}`
	end
  end
end
