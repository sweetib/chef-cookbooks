consul Cookbook
================
This cookbook installs and configures consul agent in server mode and client mode


Requirements
------------
Depends on aws and nssm cookbook for configuring custom cloudwatch metrics.

The recipe works on the following tested platforms:

* Ubuntu 12.04, 14.04 (as consul client and server nodes)
* Windows R2 2012 (as consul client nodes)

Attributes
----------

#### consul::default
|    Key							      |    Type  |  Description		|	Default     |
|-----------------------------------------|----------|------------------|---------------|
|['consul']['package_url']|String|Consul Package url|'https://releases.hashicorp.com/consul/0.6.4/consul_0.6.4_linux_amd64.zip'|
|['consul']['installation_dir']|String|Consul installation directory|'/usr/local/bin'|
|['consul']['data_dir']|String|Consul data directory|'/var/consul'|
|['consul']['consul_user']|String|Consul username|'consul'|
|default['consul']['upstart_dir']|String|Consul upstart directory|'/etc/init'|
|['consul']['nodes_ip']|List|Consul node ip address|[]|
|['consul']['aws_region']|String|AWS region|'us-east-1'|

#### consul::server
|    Key							      |    Type  |  Description		|	Default     |
|-----------------------------------------|----------|------------------|---------------|
|['server']['datacenter']|String|Consul datacenter name|'test'|
|['server']['server_config_dir']|String|Consul server config directory|'/etc/consul.d/server'|
|['server']['bootstrap_expect']|Integer|bootstrap expect count|3|
|['server']['custom_script_path']|String|custom script location|'/home'|

#### consul::client
|    Key							      |    Type  |  Description		|	Default     |
|-----------------------------------------|----------|------------------|---------------|
|['client']['client_config_dir']|String|Consul client config directory|'/etc/consul.d/client'|
|['client']['datacenter']|String|Consul datacenter name|'test'|
|['client']['custom_script_path']|String|custom script location|'/home'|

#### consul::windowsclient
|    Key							      |    Type  |  Description		|	Default     |
|-----------------------------------------|----------|------------------|---------------|
|['consul']['windows']['package_url'] | String | Consul package url | 'https://releases.hashicorp.com/consul/0.6.4/consul_0.6.4_windows_amd64.zip' |
|['consul']['windows']['installation_dir'] | String | Installation directory |'C:\\Consul-Client'|
|['consul']['windows']['data_dir'] | String | Consul Data directory |'C:\\Consul-Data'|
|['consul']['windows_client_config']['data_dir'] | String | Consul client config data directory |'C:\\Consul-Data'|
|['client']['windows']['client_config_dir'] | String | Consul client config directory |'C:\\Consul-Config'
|['client']['windows']['custom_script_path'] | String | Custom script path |'C:\\Consul-Scripts'|
|['client']['windows']['python'] | String | Python Installer for windows msi package|'https://www.python.org/ftp/python/2.7.9/python-2.7.9.msi'|

Recipes
----------
- **consul::default** - Installs Consul and configures consul user and data directory
- **consul::server** - Configure consul agent to run in server mode
- **consul::client** - Configure consul agent to run in client mode
- **consul::windowsclient** - Configure consul agent to run in client mode on Windows node

Templates
----------
#### template/default

| Templates | Description|
|-----------|------------|
|consul.conf.erb|Consul Server config file|
|consul_client.conf.erb|Consul Clinet config file|
|get_consul_node_ip.py.erb|Python script to find already existing servers in consul cluster|
|client.json.erb|Json config file for service monitoring of consul client|
|server.json.erb|Json config file for service monitoring of consul server|
|start-consul.sh.erb| Startup script for consul service on linux|
|win_get_consul_node_ip.py.erb| Python script to find already existing servers in consul cluster and joining the cluster as client |
|windowsclient.json.erb| Json config file for service monitoring of consul client on Windows node|



Usage
-----
#### consul::default

Just include `consul` in your node's `run_list` for installing consul:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[consul]"
  ]
}
```
This will install configure consul service. In order to configure Consul agent as Server include `consul::server` in your node's `run_list` and for configuring Consul agent as client inclue `consul::client` in your node's `run_list`


License and Authors
-------------------
Author: Sweeti Bharti
