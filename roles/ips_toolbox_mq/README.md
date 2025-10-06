 ips_toolbox_mq
===============

role used to perform operations over MQ

Requirements
============

- ips_toolbox_set_results role

Synopsis
========

**mq_operation** | **OS** | ***Comments***
---------------- |:------:| --------
check            |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Check installation and version of MQ*

Operation Parameters
====================
check
-----

Check installation and version of MQ

=> No additional parameter

Dependencies
============

None

Example
=======

```
#Check the MQ installation and version  
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_mq
      vars:
        mq_operation: "check"
        
```


