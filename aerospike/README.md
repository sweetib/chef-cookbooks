Aerospike Chef Cookbook
===================
This cookbook installs and configures Aerospike cluster.

Requirements
------------
Supported Platforms:
- Ubuntu 14.04

Depends on Cookbook:
- tconsul

Attributes
----------

#### aerospike::default
|    Key							      |    Type  |  Description		|	Default     |
|-----------------------------------------|----------|------------------|---------------|
|['aerospike']['package_url']|String| Aerospike package url|'http://aerospike.com/download/server/latest/artifact/ubuntu14'|
|['aerospike']['package_dir']|String|Directory where package will be downloaded|'/home/ubuntu'|
|['aerospike']['conf_dir']|String|Aerospike config directory|'/etc/aerospike'|
|['aerospike']['pid_location']|String|Aerospike pid file location|'/var/run/aerospike/asd.pid'|
|['aerospike']['log_location']|String|Aerospike log location|'/var/log/aerospike/aerospike.log'|
|['aerospike']['data_dir']|String|Aerospike data directory|'/opt/aerospike/data/'|
|['aerospike']['metadata_dir']|String|Aerospike metadata directory|'/opt/aerospike/var/smd/'|
|['aerospike']['mod_lua']['system_path']|String|Aerospike mod_lua system path|'/opt/aerospike/share/udf/lua'|
|['aerospike']['mod_lua']['user_path']|String|Aerospike mod_lua user path|'/opt/aerospike/var/udf/lua'|
|['aerospike']['amc_package_url']|String|Aerospike AMC package url|'http://www.aerospike.com/artifacts/aerospike-amc-community/3.6.8/aerospike-amc-community-3.6.8.all.x86_64.deb'|
|['aerospike']['aerospike_tools_url']|String|Aerospike tool package url|'http://www.aerospike.com/artifacts/aerospike-tools/3.8.0/aerospike-tools-3.8.0-ubuntu14.04.tgz'|
|['aerospike']['mesh_seed']['ip_address']|String|Aerospike mesh seed ip address| [] |
|['aerospike']['custom_script_path']|String|Custom script location|'/home/ubuntu'|
|['aerospike']['aws_region']|String|AWS Region|'us-east-1'|
|['aerospike']['consul_service_dir']|String|Consul client config directory|'/etc/consul.d/client'|

Recipes
----------
- **aerospike::default** - Installs and Configure Aerospike cluster, AMC and Aerospike Tool
- **aerospike::amc** - Installs  and Configure AMC
- **aerospike::aerospike_tools** - Installs  aerospike tools

Templates
----------
#### template/default

| Templates | Description|
|-----------|------------|
|aerospike.conf.erb| Aerospike configuration file|
|get_aerospike_server_ip.py.erb|Python script used to find already existing aerospike mesh nodes|


Usage
-----
#### aerospike::default

Just include `aerospike` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[aerospike]"
  ]
}
```

License and Authors
-------------------
Author: Sweeti Bharti
