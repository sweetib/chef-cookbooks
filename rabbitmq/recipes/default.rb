#
# Cookbook Name:: rabbitmq
# Recipe:: default
#
# Copyright 2018, sweeti bharti

# Add the official rabbitmq source to your apt-get sources.list
execute "add RabbitMQ repo" do
  command "sh -c \"echo 'deb #{node['rabbitmq']['repo_url']} testing main' > #{node['rabbitmq']['source_list_path']}\""
  action :run
end

# Install the certificate
execute "Install the RabbitMQ certificate" do
  command "wget #{node['rabbitmq']['certificate_url']} && apt-key add rabbitmq-signing-key-public.asc && rm rabbitmq-signing-key-public.asc"
  action :run
end

# Now install the latest rabbitmq
execute "install the latest RabbitMQ" do
  command "apt-get -y update && apt-get -y install rabbitmq-server"
  action :run
end

#copy the custom erlang cookie
execute "copy cookie" do
  command "echo -n '#{node['rabbitmq']['erlang_cookie']}' > #{node['rabbitmq']['erlang_cookie_filepath']}"
  action :run
end
#in order to avoid start-up failure kill the background erlang processess

execute "kill erlang process" do
  command "ps -ef | grep rabbitmq | grep -v grep | awk '{print $2}' | xargs -r kill -9"
  ignore_failure true
  action :run
end


#start rabbitmq-sever
execute "start rabbitmq-sever" do
  command "service rabbitmq-server start"
  action :run
end


#Stop RabbitMQ App
execute "stop RabbitMQ App" do
  command "rabbitmqctl stop_app"
  action :run
end


script_path = "#{node['rabbitmq']['custom_python_module']}/rabbitmq_cluster_nodes.py"
template script_path do
  source "rabbitmq_cluster_nodes.py.erb"
  mode 755
end

package 'python-pip'

execute 'install boto3' do
  command "pip install boto3"
  action :run
end

#fetch seed node ip if any
ruby_block "fetch rabbitmq cluster node ip's" do
  block do
    seed_ip_list = []
    ip_list=`python #{script_path} | tr -d '[],' `
	node_ip = ["#{node['ipaddress']}"]
	pvt_dns =  "ip-" + node_ip[0].tr(".","-").tr("/'","")
	print pvt_dns
	dns = ["#{pvt_dns}"]
	print dns
	ip_list = ip_list.tr("'\"", "")
	ip_list = ip_list.split(' ')
	ip_list = ip_list - dns
	print ip_list
	ip_list.each do |item|
		seed_ip_list << item.tr("/'","")
	end
	print seed_ip_list
	node.set['rabbitmq']['nodes_ip'] = seed_ip_list
  end
end

if node['rabbitmq']['nodes_ip'] != []
  node['rabbitmq']['nodes_ip'].each do |mem|
	  execute "join other rabbitmq members" do
		command "rabbitmqctl join_cluster rabbit@#{mem}"
		action :run
		ignore_failure true
	  end
  end
end

#Start the RabbitMQ App
execute "start RabbitMQ App" do
  command "rabbitmqctl start_app"
  action :run
end

#Install the Management Console plugin for RabbitMQ.
execute "Install RabbitMQ Management Console" do
  command "rabbitmq-plugins enable rabbitmq_management"
  action :run
end

#restart the RabbitMQ Service
execute "restart the RabbitMQ Server" do
  command "service rabbitmq-server restart"
  action :run
end

username = node['rabbitmq']['web_ui_user']
password = node['rabbitmq']['web_ui_userpasswd']
#create web-ui user
bash "create web-ui user" do
  code <<-EOH
	rabbitmqctl add_user #{username} #{password}
	rabbitmqctl set_permissions -p / #{username} ".*" ".*" ".*"
	rabbitmqctl set_user_tags #{username} administrator
	EOH
  action :run
end
  
