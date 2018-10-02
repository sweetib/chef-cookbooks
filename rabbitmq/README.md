rabbitmq Cookbook
==================
This cookbook installs latest version of RabbitMQ-Server, RabbitMQ Management Console and configures RabbitMQ-Server Cluster.

Requirements
------------
Supported Platforms:
- Ubuntu 12.04, 14.04

Attributes
----------
#### rabbitmq::default
|    Key							      |    Type  |  Description		|	Default     |
|-----------------------------------------|----------|------------------|--------------|
|['rabbitmq']['repo_url'] 		          |String| rabbitmq repo url	|"http://www.rabbitmq.com/debian/"|
|['rabbitmq']['source_list_path']        |String| repo source list filepath| '/etc/apt/sources.list.d/rabbitmq.list'|
|['rabbitmq']['certificate_url']         |String| rabbitmq certificate url |'http://www.rabbitmq.com/rabbitmq-signing-key-public.asc'|
|['rabbitmq']['erlang_cookie_filepath']  |String| erlang cookie file path |'/var/lib/rabbitmq/.erlang.cookie' |
|['rabbitmq']['erlang_cookie']      	  |String| randomly geerate cookie |'XXXXXXXYYYYYYYZZZZZZ'|
|['rabbitmq']['custom_python_module']    |String| location of custom scripts |  '/home' |
|['rabbitmq']['nodes_ip']                |List| List of other nodes in cluster| [] |
|['rabbitmq']['web_ui_user']             |String| rabbitmq management console username | 'rabbitmq' |
|['rabbitmq']['web_ui_userpasswd']       |String| rabbitmq management console user password | 'rabbitmq' |
|['rabbitmq']['rabbitmq_port']           |Integer| rabbitmq port | 5672 |
|['rabbitmq']['rabbitmq_ui_port']        |Integer| rabbitmq management console port | 15672 |

Recipes
----------
- **rabbitmq::default** - Installs and configures rabbitmq-server cluster and rabbitmq-management-console

Templates
----------
#### template/default

| Templates | Description|
|-----------|------------|
|rabbitmq_cluster_nodes.py.erb| used for fetching already existing rabbitmq cluster node ip if any|

Usage
-----

Just include `rabbitmq` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[rabbitmq]"
  ]
}
```

License and Authors
-------------------
Author: Sweeti Bharti
