ips_toolbox_oracle 
==================

role used to perform operations over oracle

Requirements
=========

ips_toolbox_set_results role

Some operations need toolbox scripts on target

Synopsis
========
**oracle_operation**                                    | **OS** | ***Comments***
------------------------------------------------------- |:------:| --------
backup            |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *"RMAN + TSM" backup*
tsm-backup        |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Send backupsets created by BackupOracle.ksh script on TSM*
configure-backup  |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Configure bt_sauvegarde.conf file to allow backup with BackupOracle.ksh and btsauve.ksh scripts*
check             |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *Check installation and version of oracle*
start             |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Start an oracle instance*
stop              |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Stop  an oracle instance*
status            |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Give the status of an oracle instance*
start_blackout    |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Start OEM supervision blackout (stop alerting)*
status_blackout    |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Gives the status of an instance OEM supervision blackout (blacked out or not)*
stop_blackout     |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Stop OEM supervision blackout (start alerting)* 
list              |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *List oracle instances of /etc/oratab*
list_tablespace   |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *List tablespaces of an oracle instance*
create_tablespace |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Create a permanent tablespace*
extend_tablespace |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Extend permanent tablespaces to unlimited and undo/temp file to a maximum size (between 2048 and 32748M)*
size_tablespace   |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Modify the maximum maxsize of a tablespace and add datafiles if needed*
status-listener   |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Gives informations about configured oracle listeners*

Operation Parameters
====================
backup
------

"RMAN + TSM" backup
 
**Parameter**       | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------------- | --------------------------- | ------------- | --------------
oracle_item         |                             | `yes`         | *Intance name*
oracle_type_bo      | - `hot`<br>- cold<br>- arch |  no           | *Hot full backup<br>Cold full backup<br>Archives backup*
oracle_retention_bo | - `30`<br>- 90<br>- BKP     |  no           | *Archive retention of backupsets in days<br><br>Allow to perform a TSM backup (since 19.2.1 tbx version)*
oracle_level_bo     | - `0`<br>- 1                |  no           | *Level of backup (with hot or cold)*

tsm-backup
------

TSM backup/archive of backupsets created by BackupOracle.ksh script (ie: according to ENVOI_TSM.in)
 
**Parameter**       | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------------- | --------------------------- | ------------- | --------------
oracle_item         |                             | `yes`         | *Intance name ('all' for all instances)*

configure-backup
------

Configure bt_sauvegarde.conf file to allow backup with BackupOracle.ksh and btsauve.ksh scripts
 
**Parameter**       | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------------- | --------------------------- | ------------- | --------------
oracle_item         |                             | `yes`         | *Intance name*
oracle_retention_bo | - `30`<br>- 90<br>- BKP     |  no           | *Archive retention of backupsets in days<br><br>Allow to perform a TSM backup (since 19.2.1 tbx version)*

check
------

Check installation and version of oracle

 => No additional parameter

start
------

Start an oracle instance
 
**Parameter**  | **Choices/`Default`** | **Mandatory** | ***Comments***
-------------- | --------------------- | ------------- | --------------
oracle_item    |                       | `yes`         | *Intance name ('all' for all instances)*

stop
------

Stop an oracle instance
 
**Parameter**  | **Choices/`Default`** | **Mandatory** | ***Comments***
-------------- | --------------------- | ------------- | --------------
oracle_item    |                       | `yes`         | *Intance name ('all' for all instances)*

status
------

Give the status of an oracle instance

**Parameter**  | **Choices/`Default`** | **Mandatory** | ***Comments***
-------------- | --------------------- | ------------- | --------------
oracle_item    |                       | `yes`         | *Intance name ('all' for all instances)*
oracle_ref     | `no`/yes              | no            | *Used to register the instance status in nominal mode*

start_blackout
--------------

Start OEM supervision blackout (stop alerting)
 
**Parameter**  | **Choices/`Default`** | **Mandatory** | ***Comments***
-------------- | --------------------- | ------------- | --------------
oracle_item    |                       | `yes`         | *Intance name*

stop_blackout
-------------

Stop OEM supervision blackout (start alerting)
 
**Parameter**  | **Choices/`Default`** | **Mandatory** | ***Comments***
-------------- | --------------------- | ------------- | --------------
oracle_item    |                       | `yes`         | *Intance name*

status_blackout
-------------

Gives the status of an instance OEM supervision blackout (blacked out or not)

**Parameter**  | **Choices/`Default`** | **Mandatory** | ***Comments***
-------------- | --------------------- | ------------- | --------------
oracle_item    |                       | `yes`         | *Intance name*

list
------

List oracle instances present in /etc/oratab file.

 => No additional parameter
 
list_tablespace
-------------

List tablespaces of an oracle instance
 
**Parameter**  | **Choices/`Default`** | **Mandatory** | ***Comments***
-------------- | --------------------- | ------------- | --------------
oracle_item    |                       | `yes`         | *Intance name*

create_tablespace
-------------

Create a permanent tablespace (not undo nor temporary)
 
**Parameter**     | **Choices/`Default`** | **Mandatory** | ***Comments***
----------------- | --------------------- | ------------- | --------------
oracle_item       |                       | `yes`         | *Intance name*
oracle_tablespace |                       | `yes`         | *Tablespace name*

extend_tablespace
-------------

Extend a tablespace 
 - unlimited for permanent tablespaces
 - 'oracle_datafile_maxsize' for undo and temporary tablespaces (2048M by default)
 

**Parameter**           | **Choices/`Default`** | **Mandatory** | ***Comments***
----------------------- | --------------------- | ------------- | --------------
oracle_item             |                       | `yes`         | *Intance name*
oracle_tablespace       |                       | `yes`         | *Tablespace name*
oracle_datafile_maxsize | 'size in Mo'/`2048`   | no            | *Maxsize of tablespace's datafiles in Mo (only for non permanent tablespaces)*

size_tablespace
-------------

Modify the maxsize of the specified tablespace and add datafile(s) if needed

 

**Parameter**             | **Choices/`Default`** | **Mandatory** | ***Comments***
------------------------- | --------------------- | ------------- | --------------
oracle_item               |                       | `yes`         | *Intance name*
oracle_tablespace         |                       | `yes`         | *Tablespace name*
oracle_tablespace_maxsize | 'size in Mo'          | `yes`         | *Maxsize of the specified tablespace in Mo<br> - automatically resized to upper multiple of 32G for permanent tablespaces*
 
status-listener
-------------

Gives informations about configured oracle listeners

 => No additional parameter


Dependencies
=========

None

Example
=========

```
# Start the P12345AP10 Oracle instance
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_oracle
      vars:
        oracle_operation: "start"
        oracle_item: "P12345AP10"

```


