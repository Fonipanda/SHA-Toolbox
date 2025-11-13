ips_toolbox_system
==================

role for operation over system

Requirements
============

- toolbox script files
- ips_toolbox_set_results role

Synopsis
========

**system_operation** | **OS** | ***Comments***
-------------------- |:------:| --------
status               |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *information about OS*
extend_fs            |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *add size to a lv `(unavailable for lv in rootvg vg)`*
uptime               |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *check the uptime of a server*
reboot               |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *reboot server*
sanity-check         |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *launch sanity-check for FS*
create-directory     |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *create-directory for codeAP*
create-fs            |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *create and guard filesystems `(unavailable for lv in rootvg vg)`* 
remove_fs            |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *remove a lv `(unavailable for lv in rootvg vg)`*
fstab_ctl            |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Check fstab order and syntax*

Operation Parameters
====================
status
------

information about OS

=> No additional parameter

extend_fs
---------

add size to a lv (unavailable for lv in rootvg vg)

**Parameter**   | **Choices/`Default`** | **Mandatory** | ***Comments***
--------------- | --------------------- | ------------- | --------------
system_lvname   |                       | `yes`         | *lv_name to extend `(unavailable for lv in rootvg vg)`*
system_addsize  |                       | `yes`         | *size + unity (in M, G or T) (ex : '1 G'). The minimum size depends of PE or PP Size defined on the Volume group*

uptime
------

check the uptime of a server

**Parameter**       | **Choices/`Default`** | **Mandatory** | ***Comments***
------------------- | --------------------- | ------------- | --------
system_uptime_limit | - `90`                | no            | *uptime limit to check (in Days)*

sanity-check
------------

launch sanity-check for FS

=> No additional parameter

create-directory
----------------

create the standard applicative filesystems and folder hierarchy for codeAP ( see itrules 85: Unix file system naming rules)

**Parameter**  | **Choices/`Default`** | **Mandatory**         | ***Comments***
-------------- | --------------------- | --------------------- | --------
system_codeAP   ![aix_linux_windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX_Linux_Windows.png) |                       | `yes`                        | *Application Code AP*
system_code5car ![aix_linux_windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX_Linux_Windows.png) |                       | `yes`                        | *Appplication Code 5 Car*
system_idappli  ![aix_linux_windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX_Linux_Windows.png) |                       | no                           | *Application id*
system_vgName   ![aix_linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX_Linux.png)                 | `vg_apps`             | no                           | *volume group used to create filesystem. rootvg volume_group is forbidden*
system_lvSize   ![aix_linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX_Linux.png)                 | `see itrules 85`      | no                           | *Size (`in Mb`) to apply to all lv that will be created. Note that already created lv will not be resized*
system_lvEx     ![aix_linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX_Linux.png)                 |                       | no                           | *Used to exclude the creation of a first lvname beyond the list (see itrules 85)*
system_lvEx1    ![aix_linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX_Linux.png)                 |                       | no                           | *Used to exclude the creation of a second lvname beyond the list (see itrules 85)*
system_lvEx2    ![aix_linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX_Linux.png)                 |                       | no                           | *Used to exclude the creation of a third lvname beyond the list (see itrules 85)*
system_username ![aix_linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX_Linux.png)                 |                       | no                           | *Used to set the owner of directories*
system_group    ![aix_linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX_Linux.png)                 |                       | if `system_username` defined | *Used to set the group owner of directories*
system_NNN      ![aix_linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX_Linux.png)                 |                       | if `system_username` defined | *Used to set the directories permissions. Example 644*
system_iis      ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png)                     | `False`  / True       | no                           | *Create IIS Application log folders*


create-fs
----------------

create and guard filesytems 

There are two ways to create filesystems:
<br>- with a configuration file (to create one or several filesystems)
<br>- with all parameters (only one filesystem will be created)
 
- **With a configuration file**

configuration file fields (see example):
<br>=> vgname:lvname:fsname:lvsize:username:groupname:filetype:middlewaretype

**Parameter**                | **Choices/`Default`** | **Mandatory** | ***Comments***
---------------------------- | --------------------- | ------------- | --------
system_create_filename       |                       | `yes`         | *The configuration file with absolute path (on ansible server)*

- **With parameters**

**Parameter**                | **Choices/`Default`** | **Mandatory** | ***Comments***
---------------------------- | --------------------- | ------------- | --------
system_create_vgname         | `vg_apps`             | no            | *Volume group used to create filesystem. rootvg volume_group is forbidden*
system_create_lvname         |                       | `yes`         | *Name of the logical volume (lv_xxx)*
system_create_fsname         |                       | `yes`         | *Name of the mount point*
system_create_lvsize         |                       | `yes`         | *Size (`in Mb`) to apply to lv that will be created. Note that already created lv will not be resized*
system_create_username       | `0 (root)`            | no            | *Used to set the owner of the directory. Note that rights on already created fs will not be changed*
system_create_groupname      | `0 (root/system)`     | no            | *Used to set the group owner of the directory. Note that rights on already created fs will not be changed*
system_create_filetype       | DATA/LOG              | no            | *Used to set the type of files (`to guard fs`). Note that policy on already guarded fs will not be changed*
system_create_middlewaretype | ORA/SQL/WAS/MQ/CFT    | no            | *Used to set the type of middleware (`to guard fs`). Note that policy on already guarded fs will not be changed*



reboot
------

reboot server

**Parameter**          | **Choices/`Default`**                     | **Mandatory** | ***Comments***
---------------------- |------------------------------------------ | ------------- | -------------- 
system_stop_timeout    | - time in seconds / `600`                 | no            | *Max number of seconds to wait for server to stop*
system_restart_timeout | - time in seconds / `600`                 | no            | *Max number of seconds to wait for server to restart*
system_uptime_max      | - time in minutes between 3 and 30 / `10` | no            | *Max uptime in minute after server restart*

remove_fs
---------

Remove a filesystem and perform a Nimsoft flush

**Parameter**  | **Choices/`Default`** | **Mandatory** | ***Comments***
-------------- | --------------------- | ------------- | --------------
system_lvname  |                       | `yes`         | *lv_name to remove `(unavailable for lv in rootvg vg)`*

fstab_ctl
------------

Check fs mount correct order in /etc/fstab, duplicate lines and fs ending with a slash /

=> No additional parameter


Dependencies
============

None

Example
=======

```
#Check uptime  
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_system
      vars:
        system_operation: "uptime"


#creation filesystem configuration file
vg_apps:lv_test1:/apps/test1:256:
vg_apps:lv_test2:/apps/test2:256:oracle:dba
vg_apps:lv_test3:/apps/test3:256:was:web:DATA:WAS
```


