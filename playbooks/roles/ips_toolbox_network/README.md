ips_toolbox_network 
===================

role for operation over network

Requirements
============

- toolbox script files
- ips_toolbox_set_results role
- file in role

Synopsis
========

**network_operation** | **OS** | ***Comments***
--------------------- |:------:| --------
checkport             |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *check outgoing network traffic open*

Operation Parameters
====================
checkport
---------

check outgoing network traffic open

**Parameter**  | **Choices/`Default`** | **Mandatory** | ***Comments***
-------------- | --------------------- | ------------- | --------------
network_remote_hostname|                       | `yes`         | *ip(s) or hostname(s) (if more than one,use ',' as separator)* 
network_remote_port    |       `80`            | no         | *port(s) number or range (if more than one, use ',' as separator or '-' if you want to specify a range)*



Dependencies
============

None


Example
=======

```
#Check outgoing network traffic open to server1 and server2 on port 22 and 80
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_network
      vars:
        network_operation: "checkport"
        network_remote_hostname: "server1,server2"
        network_remote_port: "22,80"

#Check outgoing network traffic open to server2 on range port 80 to 85
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_network
      vars:
        network_operation: "checkport"
        network_remote_hostname: server2"
        network_remote_port: "80-85"

        
```
