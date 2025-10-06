ips_toolbox_backup
===================

role used to perform operations over TSM backup

Requirements
============
- toolbox script files
- ips_toolbox_set_results role

Synopsis
========

**backup_operation** | **OS** | ***Comments***
-------------------- |:------:| --------
chk_bkp_appli        |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Check the lasts applicative backup state*
chk_bkp_sys          |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Check the lasts system backup state*
chk_bkp_oracle       |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Check the lasts instance backup (RMAN+TSM) state*
run_incr             |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Perform a one shot standard incremental backup*
chk_local_mksysb     |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Check if a local mksysb was generated*
refresh_orabkp_state |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Refresh the oracle backup state*

Operation Parameters
====================
chk_bkp_appli
-------------

Check the lasts applicative backup state

**Parameter**  | **Choices/`Default`** | **Mandatory** | ***Comments***
-------------- | --------------------- | ------------- | --------------
backup_depth   | - number of days / `7`| no            |*To choose how many past days the check for applicative backup will be done*

chk_bkp_sys
-----------

Check the lasts system backup state

=> No additional parameter

chk_bkp_oracle
--------------

Check the lasts instance backup (RMAN+TSM) state

**Parameter**       | **Choices/`Default`** | **Mandatory** | ***Comments***
------------------- | --------------------- | ------------- | --------------
backup_instance     |                       | `yes`         | *instance name*
backup_depth        | - number of days / `7`| no            |*To choose how many past days the check for oracle backup will be done*
backup_refresh_orastate | - `yes` / no          | no            | Refresh the oracle backup state prior to the check 

run_incr
--------

Perform a one shot standard incremental backup

=> No additional parameter

chk_local_mksysb
----------------

Check if a local mksysb was generated

**Parameter**           | **Choices/`Default`** | **Mandatory** | ***Comments***
----------------------- | --------------------- | ------------- | --------------
backup_mksysb_age_limit | - number of days / `7`| no            | *To choose how many past days the check for the local mksysb will be done* 

refresh_orabkp_state
--------

Refresh the oracle backup state

**Parameter**    | **Choices/`Default`** | **Mandatory** | ***Comments***
---------------- | --------------------- | ------------- | --------------
backup_instance |                       | `yes`         | *Instance name ('all' for all instances)*


Dependencies
============

None

Example
=======

```
#Check the lasts applicative backup state in the last two days  
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_backup
      vars:
        backup_operation: "chk_bkp_appli"
        backup_depth: "2"

```


