#installing AMC
remote_file 'download_amc_package' do
  source node['aerospike']['amc_package_url']
  path "#{node['aerospike']['package_dir']}/aerospike_amc_pakage.deb"
  action :create
end

package "python-dev"
package "gcc"
package "python-pip"
package "libffi-dev"


execute 'install python libraries' do
  command 'pip install markupsafe paramiko cffi ecdsa bcrypt'
  action :run
end

execute 'install python libraries' do
  command 'pip install markupsafe paramiko cffi ecdsa bcrypt'
  action :run
end

execute 'install amc' do
  command 'dpkg -i aerospike_amc_pakage.deb' 
  cwd 	  node['aerospike']['package_dir']
  action :run
end

#start AMC service
execute 'start AMC service' do
  command '/etc/init.d/amc start'
  action :run
end


