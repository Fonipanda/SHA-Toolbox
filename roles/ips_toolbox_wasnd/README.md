ips_toolbox_wasnd
=================

- Role for operation on WAS ND :

        This role allows to you to :
            - stop, start,restart, check status and list JVM, nodeagent, DMGR, logical cluster or Entreprise application on the product WebSphere ND.
            - check installation and version of WebSphere ND
            - deploy application


Requirements
============

- The naming of the component (JVM and logical cluster)  must respect the standard group naming and the application must be deployed under the file system application to be managed by this role.
- Toolbox script files (for cluster and applications)
- Toolbox version 19.2.0 minimum to deploy application
- ips_toolbox_set_results role 


Synopsis
========

**wasnd_operation** | **OS** | ***Comments***
--------------------|:------:| --------
start_jvm           |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Start jvm*
start_cluster       |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Start cluster*
start_applis        |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Start application*
start_nodeagent     |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Start nodeagent*
start_dmgr          |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Start dmgr*
stop_jvm            |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Stop jvm*
stop_cluster        |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Stop cluster* 
stop_applis         |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Stop application*
stop_nodeagent      |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Stop nodeagent*
stop_dmgr           |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Stop dmgr*
restart_jvm         |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Restart jvm*
restart_nodeagent   |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Restart nodeagent*
restart_dmgr        |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Restart dmgr*
status_jvm          |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Status of jvm*
status_nodeagent    |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Status of nodeagent*
status_dmgr         |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Status of dmgr*
list_jvm            |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *List jvm*
list_cluster        |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *List cluster*
list_applis         |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *List application*
check               |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Check installation and version of WAS ND*
list-env-fs               |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *List WAS ND environnement (in /applis)*
delete-env-fs             |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Delete a full standalone WAS ND environment and its file systems*
deploy-app                |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Deploy a war/ear application*

Operation Parameters
====================
start_[jvm/cluster/applis/nodeagent/dmgr]
--------------------------

Start jvm (application server)

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
wasnd_item       | - sa-xxxxx_yyyyy /all_sa   | `yes`     | *name of the application server jvm, all_sa to start all application servers*
wasnd_ref        | - yes /`no`                   | no            | *if set to 'yes', start the element only if reference status is not 'stopped'*

Start the cluster or application WebSphere ND

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
wasnd_item          |         | `yes`         | *name of the cluster or application WebSphere ND*
wasnd_was_vi        | -`85`                  | no            | *instance WebSphere (85, 85i2, ...)*

Start nodeagent or dmgr

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
wasnd_ref        | - yes /`no`                   | no            | *if set to 'yes', start the element only if reference status is not 'stopped'*


stop_[jvm/cluster/applis/nodeagent/dmgr]
-------------------------

Stop jvm (application server)

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
wasnd_item       | - sa-xxxxx_yyyyy /all_sa   | `yes`     | *name of the application server jvm, all_sa to stop all application servers*

Stop the cluster or application WebSphere ND

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
wasnd_item          |                             | `yes`         | *name of the jvm, cluster or application WebSphere ND*
wasnd_was_vi        | -`85`<br>                   | no            | *instance WebSphere (85, 85i2, ...)*

Stop nodeagent or dmgr
 
 => No additional parameter

restart_[jvm/nodeagent/dmgr]
-------------------------

Restart jvm (application server)

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
wasnd_item       | - sa-xxxxx_yyyyy /all_sa   | `yes`     | *name of the application server jvm, all_sa to restart all application servers*


Restart nodeagent or dmgr
 
 => No additional parameter

status_[jvm/nodeagent/dmgr]
------

Status jvm

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
wasnd_item       | - sa-xxxxx_yyyyy /all_sa   | `yes`     | *name of the application server jvm, all_sa to get status of all application servers*
wasnd_ref        | - yes /`no`                   | no            | *if set to 'yes', set the current status as the reference status*

Status nodeagent or dmgr

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
wasnd_ref        | - yes /`no`                   | no            | *if set to 'yes', set the current status as the reference status*

list_[jvm/cluster/applis]
-------------------------

List jvm (application server)

 => No additional parameter
 
List cluster or application WebSphere ND

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
wasnd_was_vi        | -`85`<br>                   | no            | *instance WebSphere (85, 85i2, ...)*

check
-----

Check installation and version of WebSphere ND

 => No additional parameter

list-env-fs
-----

List the available WAS ND environment found in /applis

 => No additional parameter
 
delete-env-fs 
--------------------------------------------------------------

Delete a Full WAS ND environment (Standalone only) and also the 2 associated filesystems: ( /applis/wasnd_appli and /applis/logs/wasnd_appli )

`Warning: There is no way to recover the filesystems after deletion but restore with TSM if a backup has been done.` 

**Parameter**     | **Choices/`Default`**       | **Mandatory** | ***Comments***
----------------- | --------------------------- | ------------- | --------------
wasnd_appli |                     		| `yes`         | *The environment in /applis/ (You can use the list-env-fs task to help you select the environment and fs to delete)*

deploy-app 
--------------------------------------------------------------

Deploy an application (ear/war)

**Parameter**                 | **Choices/`Default`**       | **Mandatory** | ***Comments***
----------------------------- | --------------------------- | ------------- | --------------
wasnd_xml_filename      |                     		| `yes`         | *The xlm file name (with extension)*
wasnd_archive_filename  |                     		| `yes`         | *The archive file name (with extension)*
wasnd_xml_src_path      |                     		| `yes`         | *The xml source path*
wasnd_archive_src_path  | `= wasnd_xml_src_path parameter`    | no            | *The archive source path (only if different of the xml source path)*
wasnd_dest_path         | `/apps/toolboxes/web/ManageDeployEarWas/DeployEarWas/livrables`                    		| no            | *The destination path on the target for xml and archive files*
wasnd_force_deploy      | `no`/yes                    | no            | *Force deployment even if source archive file is the same on the dest path*

Dependencies
============

None

Example
=======

```
#start the JVM sa-12345_test1-prez-1  
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_wasnd
      vars:
        wasnd_operation: "start_jvm"
        wasnd_item: "sa-12345_test1-prez-1"
        
```
