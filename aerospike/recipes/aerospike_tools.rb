#installing Aerospike Tool
remote_file 'download_amc_package' do
  source node['aerospike']['aerospike_tools_url']
  path "#{node['aerospike']['package_dir']}/aerospike_tool_pakage.tgz"
  action :create
end

#untar the tool
execute 'Untar the Aerospike Tools' do
  command 'tar -xvf aerospike_tool_pakage.tgz'
  cwd node['aerospike']['package_dir']
  action :run
end

execute 'Install Aerospike tools' do
  command 'cd aerospike-tool* && ./asinstall'
  cwd node['aerospike']['package_dir']
  action :run
end
