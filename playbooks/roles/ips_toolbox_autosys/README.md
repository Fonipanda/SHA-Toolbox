ips_toolbox_autosys
===================

role used to perform operations over Autosys

Requirements
============

- toolbox script files
- ips_toolbox_set_results role

Synopsis
========


**autosys_operation** | **OS** | ***Comments***
--------------------- | ------ | --------
check                 |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *Check installation and version of Autosys agent*

Operation Parameters
====================
check
-----

Check installation and version of Autosys agent

=> No additional parameter

Dependencies
============

None

Example
=======

```
#Check the autosys agent installation and version  
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_autosys
      vars:
        autosys_operation: "check"
        
```


