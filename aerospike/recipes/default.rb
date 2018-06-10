# Cookbook Name:: aerospike
# Recipe:: default
# Author:: Sweeti Bharti
# Copyright 2018
#
# All rights reserved - Do Not Redistribute

#require 'chef/log'
#Chef::Log.level = :debug
#Chef::Log.level = :info


execute 'Fetch the Aerospike Package' do
  command "wget -O aerospike.tgz #{node['aerospike']['package_url']}"
  cwd node['aerospike']['package_dir']
  action :run
end

execute 'untar the Aerospike package' do
  command "tar -xvf aerospike.tgz"
  cwd node['aerospike']['package_dir']
  action :run
end

execute 'Install the Aerospike .deb packages' do
  command "cd aerospike-server-community-*-ubuntu* && ./asinstall "
  cwd  node['aerospike']['package_dir']
  action :run
end

directories = [node['aerospike']['mod_lua']['system_path'],
                node['aerospike']['mod_lua']['user_path'],
                node['aerospike']['metadata_dir'],
                node['aerospike']['data_dir'],
                node['aerospike']['backup_dir']]

directories.each do |dir|
  directory dir do
    mode      '0755'
    recursive true
    action    :create
  end
end

execute 'apt-get update'
package "python2.7"
package "python-pip"


execute 'install boto3' do
  command 'pip install boto3'
  action :run
end

execute 'install awscli' do
  command 'pip install awscli'
  action :run
end

script_path = "#{node['aerospike']['custom_script_path']}/get_aerospike_server_ip.py"
ec2_access_key = Chef::EncryptedDataBagItem.load('aws_credentials', 'ec2_keys')
template script_path do
  source 'get_aerospike_server_ip.py.erb'
  variables(
  :access_key => "\'#{ec2_access_key['AccessKey']}\'",
  :secret_key => "\'#{ec2_access_key['SecretAccessKey']}\'"
  )
  mode '0755'
  action :create
end

ruby_block "fetch aerospike server ip's" do
  block do
    seed_ip_list = []
    ip_list=`python #{script_path} | tr -d '[],' `
	node_ip = ["\'#{node['ipaddress']}\'"]
	ip_list.tr("'\"", "")
	ip_list = ip_list.split(' ')
	ip_list = ip_list - node_ip
	ip_list.each do |item|
		seed_ip_list << item.tr("/'","")
	end
	node.set['aerospike']['mesh_seed']['ip_address'] = seed_ip_list
  end
end


Chef::Log.info("aerospike cluster members ips: #{node['aerospike']['mesh_seed']['ip_address']}")

conf_path = "#{node['aerospike']['conf_dir']}/aerospike.conf"

template conf_path do
  source 'aerospike.conf.erb'
end


execute 'Start the Aerospike service' do
  command "service aerospike start"
  action :run
end

include_recipe 'aerospike::amc'
include_recipe 'aerospike::aerospike_tools'

#configuring backup for aerospike
template '/root/asbackup.sh' do
  source 'asbackup.sh.erb'
end

execute 'chmod a+x /root/asbackup.sh'

cron 'Aerospike_backup' do
 hour '12'
 minute '0'
 command "bash /root/asbackup.sh  >> /root/backup.log"
end

cron 'Sync_backup_to_s3' do
 hour '12'
 minute '0'
 command "aws s3 sync #{node['aerospike']['backup_dir']} #{node['aerospike']['s3_bucket']}"
end
