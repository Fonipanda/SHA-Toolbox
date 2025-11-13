ips_toolbox_libertybase 
========================

- role used to perform operations over Liberty Base :

        This role allows you to :
            - stop, start, restart, check status and list JVM.
            - check installation and version of Liberty Base
            - create Liberty Base environment
            - deploy application


Requirements
============
- The naming of the JVM must respect the standard group naming and the application must be deployed under the file system application to be managed by this role.
- Toolbox script files (to create or delete components)
- Toolbox version 19.2.0 minimum to create all environment and deploy application
- ips_toolbox_set_results role

Synopsis
========


**libertybase_operation** | **OS** | ***Comments***
------------------------- |:------:| --------
start_jvm                 |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Start application server jvm*
stop_jvm                  |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Stop application server jvm*
restart_jvm               |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Restart application server jvm*
list_jvm                  |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *List application server jvm*
status_jvm                |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Status of application server jvm*
check                     |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Check Libertybase installation and version*
create_all                |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create Liberty Base all environment*
create_fs                 |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create Liberty Base filesystem*
create_jvm                |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create Liberty Base application server*
create_ihs                |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create Liberty Base IHS*
create_dsora              |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create Liberty Base datasource Oracle*
create_dsybase            |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create Liberty Base datasource Sybase*
create_ressharelib        |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create Liberty Base resource sharelib*
create_resurl             |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create Liberty Base URL*
create_resentrie          |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create Liberty Base resource entry*
list-env-fs               |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *List Liberty Base environnement (in /applis)*
delete-env-fs             |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Delete a full Liberty Base environment and its file systems*
deploy-app                |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Deploy a war/ear application*

Operation Parameters
====================
start_jvm
------------------

Start jvm (application server)

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
libertybase_item       | - sa-xxxxx_yyyyy /all_sa   | `yes`     | *name of the application server jvm, all_sa to start all application servers*
libertybase_ref        | - yes /`no`                   | no            | *if set to 'yes', start the element only if reference status is not 'stopped'*


stop_jvm
------------------

Stop jvm (application server)

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
libertybase_item       | - sa-xxxxx_yyyyy /all_sa   | `yes`     | *name of the application server jvm, all_sa to stop all application servers*

restart_jvm
------------------

Restart jvm (application server)

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
libertybase_item       | - sa-xxxxx_yyyyy /all_sa   | `yes`     | *name of the application server jvm, all_sa to restart all application servers*

list_jvm
-----------------

List jvm (application server)

 => No additional parameter


status_jvm
------

Status of jvm (application server)

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
libertybase_item       | - sa-xxxxx_yyyyy /all_sa   | `yes`     | *name of the application server jvm, all_sa to get status of all application servers*
libertybase_ref        | - yes /`no`                   | no            | *if set to 'yes', set the current status as the reference status*


check
-----

Check installation and version of Liberty Base

 => No additional parameter
 
create_[all/fs/jvm/ihs/dsora/dsybase/ressharelib/resurl/resentrie] 
--------------------------------------------------------------

Create LibertyBase environment

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
libertybase_layer         | - prez<br> - biz<br>		| `yes`                      | *Layer environment WAS*
libertybase_xml_file      | 					    	| `yes`                      | *The PropertieEnv.xml file with absolute path*


list-env-fs
-----

List the available LibertyBase environment found in /applis

 => No additional parameter
 
delete-env-fs 
--------------------------------------------------------------

Delete a Full LibertyBase environment and also the 2 associated filesystems: ( /applis/libertybase_appli and /applis/logs/libertybase_appli )

`Warning: There is no way to recover the filesystems after deletion but restore with TSM if a backup has been done.` 

**Parameter**     | **Choices/`Default`**       | **Mandatory** | ***Comments***
----------------- | --------------------------- | ------------- | --------------
libertybase_appli |                     		| `yes`         | *The environment in /applis/ (You can use the list-env-fs task to help you select the environment and fs to delete)*

deploy-app 
--------------------------------------------------------------

Deploy an application (ear/war)

**Parameter**                 | **Choices/`Default`**       | **Mandatory** | ***Comments***
----------------------------- | --------------------------- | ------------- | --------------
libertybase_xml_filename      |                     		| `yes`         | *The xlm file name (with extension)*
libertybase_archive_filename  |                     		| `yes`         | *The archive file name (with extension)*
libertybase_xml_src_path      |                     		| `yes`         | *The xml source path*
libertybase_archive_src_path  | `= libertybase_xml_src_path parameter`    | no            | *The archive source path (only if different of the xml source path)*
libertybase_dest_path         | `/apps/toolboxes/web/ManageDeployEarWas/DeployEarWas/livrables`                    		| no            | *The destination path on the target for xml and archive files*
libertybase_force_deploy      | `no`/yes                    | no            | *Force deployment even if source archive file is the same on the dest path*

Dependencies
============

None

Example
=======

```
#start libertybase JVM sa-12345_test1-prez-1  
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_libertybase
      vars:
        libertybase_operation: "start_jvm"
        libertybase_item: "sa-12345_test1-prez-1"
        
```

