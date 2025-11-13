ips_toolbox_vormetric
===============

role used to perform operations over vormetric

Requirements
============

- ips_toolbox_set_results role

Synopsis
========

**vormetric_operation** | **OS** | ***Comments***
------------------ | ------ | --------
check              |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Check installation and vormetric's version*
status             |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Give vormetric's state and information about vormetric*
list               |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Give the list of the guardpoints*

Operation Parameters
====================
check
-----

Check installation and version of vormetric

=> No additional parameter

status
-----

Give vormetric's state and information about vormetric

=> No additional parameter

list
-----

Give the list of the guardpoints

=> No additional parameter

Dependencies
============

None

Example
=======

```
#Check the vormetric installation and version
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_vormetric
      vars:
        vormetric_operation: "check"
        
```

