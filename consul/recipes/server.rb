#
# Cookbook Name:: consul
# Recipe:: server
# configures consul server and start the service and joins the cluster
# Copyright 2018,
#
# Author : Sweeti Bharti

#create configuration directory for consul server
include_recipe 'consul::default'
directory 'consul_config_directory' do
  path 			node['server']['server_config_dir']
  recursive 	true
  action 		:create
end


#create configuration files for server
file_path = "#{node['server']['server_config_dir']}/server.json"

template file_path do
  source 'server.json.erb'
end

#create upstart directory for consul service
upstart_config_path = "#{node['consul']['upstart_dir']}/consul.conf"
template upstart_config_path do
  source 'consul.conf.erb'
end

service 'consul' do
  action :start
  supports :status => true, :start => true, :stop => true, :restart => true
end

#custom python script for fetching consul servers address in order to join cluster
script_path = "#{node['server']['custom_script_path']}/get_consul_node_ip.py"
template script_path do
  source 'get_consul_node_ip.py.erb'
  mode '0755'
  action :create
end

upstart_config_path = "#{node['consul']['upstart_dir']}/start-consul.sh"
cookbook_file  upstart_config_path do
  source 'start-consul.sh'
end

execute "chmod +x #{node['consul']['upstart_dir']}/start-consul.sh"
execute "sh #{node['consul']['upstart_dir']}/start-consul.sh"

ruby_block "fetch consul server ip's" do
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
	node.set['consul']['nodes_ip'] = seed_ip_list
	node['consul']['nodes_ip'].each do |mem|
		`consul join -rpc-addr=#{node['ipaddress']}:8400 #{mem}`
	end
  end

end
