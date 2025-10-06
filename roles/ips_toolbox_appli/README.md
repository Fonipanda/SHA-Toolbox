ips_toolbox_appli 
=================

role used to perform operations over application scripts (without service)

Requirements
============

- toolbox 18.2 and over version 
- ips_toolbox_set_results role
- script app_[free] in /etc/local/ or app_[free] in D:\apps\exploit\scripts\

Synopsis
========

**appli_operation** | **OS** | ***Comments***
------------------- | ------ | --------
stop                |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *Stop appli*
start               |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *Start appli*
status              |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *Appli status*
ref_status          |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Check what is the status in nominal mode*

Operation Parameters
====================
stop
----

Stop appli

**Parameter**  | **Choices/`Default`** | **Mandatory** | ***Comments***
-------------- | --------------------- | ------------- | --------------
appli_item           |                       | `yes`         | *script app_[free] in /etc/local (Unix/Linux) or D:\apps\exploit\scripts\ (Windows)* 

start
-----

Start appli

**Parameter**  | **Choices/`Default`** | **Mandatory** | ***Comments***
-------------- | --------------------- | ------------- | --------------
appli_item           |                       | `yes`         | *script app_[free] in /etc/local (Unix/Linux) or D:\apps\exploit\scripts\ (Windows)*

status
------

Appli status

**Parameter**  | **Choices/`Default`** | **Mandatory** | ***Comments***
-------------- | --------------------- | ------------- | --------------
appli_item           |                       | `yes`         | *script app_[free] in /etc/local (Unix/Linux) or D:\apps\exploit\scripts\ (Windows)*
appli_ref            | - Yes/`No`            | no            | *used to register the appli status in nominal mode*

ref_status
----------

Check what is the status in nominal mode

**Parameter**  | **Choices/`Default`** | **Mandatory** | ***Comments***
-------------- | --------------------- | ------------- | --------------
appli_item           |                       | `yes`         | *script app_[free] in /etc/local*


Dependencies
============

None

Example
=======

```
#Start the application app_myapp  
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_appli
      vars:
        appli_operation: "start"
        appli_item: "app_myapp"
        
```

