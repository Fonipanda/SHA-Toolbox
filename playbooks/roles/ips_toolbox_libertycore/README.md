ips_toolbox_libertycore 
========================

- role used to perform operations over Liberty Core :

        This role allows you to :
            - stop, start, restart, check status and list JVM and Entreprise application on the product LibertyCore.
            - check installation and version of LibertyCore
            - create LibertyCore environment
            - deploy application


Requirements
============
- The naming of the JVM must respect the standard group naming and the application must be deployed under the file system application to be managed by this role.
- Toolbox script files (to create or delete components)
- Toolbox version 19.2.0 minimum to create all environment and deploy application
- ips_toolbox_set_results role

Synopsis
========

**libertycore_operation** | **OS** | ***Comments***
------------------------- |:------:| --------
start_jvm                 |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Start application server jvm*
stop_jvm                  |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Stop application server jvm*
restart_jvm               |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Restart application server jvm*
list_jvm                  |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *List application server jvm*
list_applis               |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *List applications*
status_jvm                |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Status of application server jvm*
check                     |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Check Libertycore installation and version*
create_all                |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create Liberty Core all environment*
create_fs                 |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create Liberty Core filesystem*
create_jvm                |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create Liberty Core application server*
create_ihs                |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create Liberty Core IHS*
create_dsora              |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create Liberty Core datasource Oracle*
create_dsybase            |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create Liberty Core datasource Sybase*
create_ressharelib        |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create Liberty Core resource sharelib*
create_resurl             |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create Liberty Core URL*
create_resentrie          |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create Liberty Core resource entry*
delete_jvm                |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Delete Liberty Core JVM*
delete_res                |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Delete Liberty Core resource*
list-env-fs               |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *List Liberty Core environnement (in /applis)*
delete-env-fs             |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Delete a full Liberty Core environment and its file systems*
deploy-app                |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Deploy a war/ear application*

Operation Parameters
====================
start_jvm
------------------

Start jvm (application server)

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
libertycore_item       | - sa-xxxxx_yyyyy /all_sa   | `yes`     | *name of the application server jvm, all_sa to start all application servers*
libertycore_ref        | - yes /`no`                   | no            | *if set to 'yes', start the element only if reference status is not 'stopped'*

stop_jvm
------------------

Stop jvm (application server)

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
libertycore_item       | - sa-xxxxx_yyyyy /all_sa   | `yes`     | *name of the application server jvm, all_sa to stop all application servers*

restart_jvm
------------------

Restart jvm (application server)

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
libertycore_item       | - sa-xxxxx_yyyyy /all_sa   | `yes`     | *name of the application server jvm, all_sa to restart all application servers*

list_[jvm/applis]
-----------------

List jvm (application server)

 => No additional parameter

List application

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
libertycore_was_vi        | -`85`<br>                   | no            | *instance Liberty (85, 85i2, ...)*

status_jvm
------

Status of jvm (application server)

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
libertycore_item       | - sa-xxxxx_yyyyy /all_sa   | `yes`     | *name of the application server jvm, all_sa to get status of all application servers*
libertycore_ref        | - yes /`no`                   | no            | *if set to 'yes', set the current status as the reference status*


check
-----

Check installation and version of LibertyCore

 => No additional parameter
 
create_[all/fs/jvm/ihs/dsora/dsybase/ressharelib/resurl/resentrie] 
--------------------------------------------------------------

Create environment LibertyCore

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
libertycore_layer         | - prez<br> - biz<br>		| `yes`                      | *Layer environment WAS*
libertycore_xml_file      | 					    	| `yes`                      | *The PropertieEnv.xml file with absolute path*

delete_[jvm/res]
----------------

Delete jvm or resource LibertyCore

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
libertycore_item          |                             | `yes`         | *name of the jvm*
libertycore_res_name      |								| `yes for delete_res` | *The LibertyCore resource name*
libertycore_was_vi        | -`85`<br>                   | no            | *instance Liberty (85, 85i2, ...)*

list-env-fs
-----

List the available LibertyCore environment found in /applis

 => No additional parameter
 
delete-env-fs 
--------------------------------------------------------------

Delete a Full LibertyCore environment and also the 2 associated filesystems: ( /applis/libertycore_appli and /applis/logs/libertycore_appli )

`Warning: There is no way to recover the filesystems after deletion but restore with TSM if a backup has been done.` 

**Parameter**     | **Choices/`Default`**       | **Mandatory** | ***Comments***
----------------- | --------------------------- | ------------- | --------------
libertycore_appli |                     		| `yes`         | *The environment in /applis/ (You can use the list-env-fs task to help you select the environment and fs to delete)*

deploy-app 
--------------------------------------------------------------

Deploy an application (ear/war)

**Parameter**                 | **Choices/`Default`**       | **Mandatory** | ***Comments***
----------------------------- | --------------------------- | ------------- | --------------
libertycore_xml_filename      |                     		| `yes`         | *The xlm file name (with extension)*
libertycore_archive_filename  |                     		| `yes`         | *The archive file name (with extension)*
libertycore_xml_src_path      |                     		| `yes`         | *The xml source path*
libertycore_archive_src_path  | `= libertycore_xml_src_path parameter`    | no            | *The archive source path (only if different of the xml source path)*
libertycore_dest_path         | `/apps/toolboxes/web/ManageDeployEarWas/DeployEarWas/livrables`                    		| no            | *The destination path on the target for xml and archive files*
libertycore_force_deploy      | `no`/yes                    | no            | *Force deployment even if source archive file is the same on the dest path*


Dependencies
============

None

Example
=======

```
#start libertycore JVM sa-12345_test1-prez-1  
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_libertycore
      vars:
        libertycore_operation: "start_jvm"
        libertycore_item: "sa-12345_test1-prez-1"
        
```
