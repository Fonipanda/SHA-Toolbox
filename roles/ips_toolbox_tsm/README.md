ips_toolbox_tsm
===============

role for action over TSM client product

Requirements
============

ips_toolbox_set_results role

Synopsis
========

**tsm_operation** | **OS** | ***Comments***
----------------- |:------:| --------
check             |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Check installation and version of TSM Client*
list-class        |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *List normalized archive classes and gives information about default backup class*

Operation Parameters
====================
check
-----

Check installation and version of TSM Client

=> No additional parameter

list-class
-----

List normalized archive classes and gives information about default backup class

=> No additional parameter

Dependencies
------------

None

Example
=======

```
#Check the tsm backup client installation and version  
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_tsm
      vars:
        tsm_operation: "check"
        
```

