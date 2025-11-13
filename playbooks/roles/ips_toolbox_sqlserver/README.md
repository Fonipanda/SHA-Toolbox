ips_toolbox_sqlserver
=====================

role used to perform operations over SQL Server

Requirements
============

ips_toolbox_set_results role

Synopsis
========

**sqlserver_operation** | **OS** | ***Comments***
----------------------- | ------ | --------------
check                   |![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *Check installation and version of SQL Server*

Operation Parameters
====================
check
-----

Check installation and version of SQL Server

=> No additional parameter

Dependencies
------------

None

Example
=======

```
#Check the sql server installation and version  
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_sqlserver
      vars:
        sqlserver_operation: "check"
        
```

