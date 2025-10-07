ips_toolbox_wasbase
===================

- role used to perform operations over WAS Base :

        This role allows you to :
            - stop, start, restart, check status and list JVM, application and admserver on the product WebSphere BASE.
            - check installation and version of WebSphere Base
            - deploy application


Requirements
============

- The naming of the JVM must respect the standard group naming and the application must be deployed under the file system application to be managed by this role.
- Toolbox script files (for application)
- Toolbox version 19.2.0 minimum to deploy application
- ips_toolbox_set_results role

Synopsis
========

**wasbase_operation** | **OS** | ***Comments***
--------------------- |:------:| --------
start_jvm             |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Start jvm*
start_applis          |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Start application*
start_admserver       |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Start admserver*
stop_jvm              |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Stop jvm*
stop_applis           |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Stop application*
stop_admserver        |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Stop admserver*
restart_jvm           |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Restart jvm*
restart_admserver     |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Restart admserver*
status_jvm            |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Status of jvm*
status_admserver      |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Status of admserver*
list_jvm              |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *List jvm*
list_applis           |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *List applications*
check                 |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Check installation and version of WAS Base*
list-env-fs               |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *List WAS Base environnement (in /applis)*
delete-env-fs             |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Delete a full WAS Base environment and its file systems*
deploy-app                |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Deploy a war/ear application*

Operation Parameters
====================
start_[jvm/applis/admserver]
------------------

Start jvm (application server)

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
wasbase_item       | - sa-xxxxx_yyyyy /all_sa   | `yes`     | *name of the application server jvm, all_sa to start all application servers*
wasbase_ref        | - yes /`no`                   | no            | *if set to 'yes', start the element only if reference status is not 'stopped'*


Start application

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
wasbase_item          |                             | `yes`         | *name of the jvm or application WebSphere Base*
wasbase_was_vi        | -`85S`<br>                   | no            | *instance WebSphere (85, 85i2, ...)*

Start admserver

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
wasbase_ref        | - yes /`no`                   | no            | *if set to 'yes', start the admserver only if reference status is not 'stopped'*

stop_[jvm/applis/admserver]
------------------

Stop jvm (application server)

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
wasbase_item       | - sa-xxxxx_yyyyy /all_sa   | `yes`     | *name of the application server jvm, all_sa to stop all application servers*

Stop application

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
wasbase_item          |                             | `yes`         | *name of the jvm or application WebSphere Base*
wasbase_was_vi        | -`85S`<br>                   | no            | *instance WebSphere (85, 85i2, ...)*

Stop admserver

 => No additional parameter

restart_[jvm/admserver]
------

Restart jvm (application server)

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
wasbase_item       | - sa-xxxxx_yyyyy /all_sa   | `yes`     | *name of the application server jvm, all_sa to restart all application servers*

Status admserver

 => No additional parameter

status_[jvm/admserver]
------

Status of jvm (application server)

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
wasbase_item       | - sa-xxxxx_yyyyy /all_sa   | `yes`     | *name of the application server jvm, all_sa to get status of all application servers*
wasbase_ref        | - yes /`no`                   | no            | *if set to 'yes', set the current status as the reference status*

Status admserver

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
wasbase_ref        | - yes /`no`                   | no            | *if set to 'yes', set the current status as the reference status*

list_[jvm/applis]
-----------------

List jvm

=> No additional parameter


List applications

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
wasbase_was_vi        | -`85S`<br>                   | no            | *instance WebSphere (85, 85i2, ...)*

check
-----

Check installation and version of WebSphere Base

 => No additional parameter

list-env-fs
-----

List the available WAS Base environment found in /applis

 => No additional parameter
 
delete-env-fs 
--------------------------------------------------------------

Delete a Full WAS Base environment and also the 2 associated filesystems: ( /applis/wasbase_appli and /applis/logs/wasbase_appli )

`Warning: There is no way to recover the filesystems after deletion but restore with TSM if a backup has been done.` 

**Parameter**     | **Choices/`Default`**       | **Mandatory** | ***Comments***
----------------- | --------------------------- | ------------- | --------------
wasbase_appli |                     		| `yes`         | *The environment in /applis/ (You can use the list-env-fs task to help you select the environment and fs to delete)*

deploy-app 
--------------------------------------------------------------

Deploy an application (ear/war)

**Parameter**                 | **Choices/`Default`**       | **Mandatory** | ***Comments***
----------------------------- | --------------------------- | ------------- | --------------
wasbase_xml_filename      |                     		| `yes`         | *The xlm file name (with extension)*
wasbase_archive_filename  |                     		| `yes`         | *The archive file name (with extension)*
wasbase_xml_src_path      |                     		| `yes`         | *The xml source path*
wasbase_archive_src_path  | `= wasbase_xml_src_path parameter`    | no            | *The archive source path (only if different of the xml source path)*
wasbase_dest_path         | `/apps/toolboxes/web/ManageDeployEarWas/DeployEarWas/livrables`                    		| no            | *The destination path on the target for xml and archive files*
wasbase_force_deploy      | `no`/yes                    | no            | *Force deployment even if source archive file is the same on the dest path*

Dependencies
============

None

Example
=======

```
#start the JVM sa-01234_test1-prez-1  
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_wasbase
      vars:
        wasbase_operation: "start_jvm"
        wasbase_item: "sa-01234_test1-prez-1"
        
```

