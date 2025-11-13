ips_toolbox_illumio
===============

role used to perform operations over Illumio

Requirements
============

- ips_toolbox_set_results role

Synopsis
========

**illumio_operation** | **OS** | ***Comments***
------------------ | ------ | --------
check              |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Check installation and version of Illumio*

Operation Parameters
====================
check
-----

Check installation and version of illumio

=> No additional parameter


Dependencies
============

None

Example
=======

```
#Check the illumio installation and version
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_illumio
      vars:
        illumio_operation: "check"
        
```

