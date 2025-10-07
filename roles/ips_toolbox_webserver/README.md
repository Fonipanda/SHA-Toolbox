ips_toolbox_webserver
=====================

- role used to perform operations over WebServer and IHS :

        This role allows to you to :
            - check Webserver installation and version.
            - stop, start, restart, check status and list IHS on the WebServer product.
            - Generate a certificate request file (csr) and import a certificate into the kdb (For IHS only)
            - List and check certificates expiration date in a kdb

Requirements
============
- For IHS operation, the IHS must respect the standard group naming.
- WebSphere binaries on the target server
- ansible role ips_toolbox_set_results

Synopsis
========

**webserver_operation** | **OS** | ***Comments***
----------------------- |:------:| --------
check                   |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Check Webserver installation and version*
start_ihs               |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Start ihs instance(s)*
stop_ihs                |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Stop ihs instance(s)*
list_ihs                |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *List ihs instances*
status_ihs              |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Status of ihs instance(s)*
restart_ihs                |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Restart ihs instance(s)*
generate-csr            |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Generate the certificate request file(csr file)*
insert-cert             |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Import a certificate into a kdb*
info-certif             |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *list and check certificates expiration date in a kdb*


Operation Parameters
====================
check
-----

Check installation and version of WebServer

 => No additional parameter

start_ihs
---------

Start one or all ihs

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
webserver_item          |                             | `yes`         | *IHS name ("all" to start all ihs)*
webserver_ref        | - yes/`no`<br>                   | no            | *to start ihs only if the reference status is "started"*

stop_ihs
--------

Stop one or all ihs 

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
webserver_item          |                             | `yes`         | *IHS name ("all" to stop all ihs)*


list_ihs
--------

List ihs instances

=> No additional parameter


status_ihs
----------

status of one or all ihs

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
webserver_item          |                             | `yes`         | *IHS name ("all" to get status of all ihs)*
webserver_ref        | - yes/`no`<br>                   | no            | *to set the current status as the reference status of the ihs*


restart_ihs
--------

Restart one or all ihs

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
webserver_item          |                             | `yes`         | *IHS name ("all" to restart all ihs)*


generate-csr
----------

Generate the certificate request file(csr file)

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
webserver_url          |                             | `yes`         | *url name (ex:demo.group.echonet)*
webserver_kdb_pwd      |                             | `yes`         | *The password to set on the kdb (8 characters minimum and use a mix of Numbers, Capital Letters, and Lower-Case Letters)*
webserver_ou           |                             | `yes`         | *Organisation unit (ex:OPS_FGAT)*
webserver_force        | - force / `no`<br>           | no         | *overwrite previous kdb and csr generated with the same url*


insert-cert
----------

import a certificate into a kdb

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
webserver_kdb_path          |                             | `yes`         | *Full path to kdb file (example: /apps/toolboxes/web/ManageCertificates/generatecert/myapp.group.echonet//myapp.group.echonet.kdb)*
webserver_crt_file     |                             | `yes`         | *Full local path to the crt file provided by Certis and to be copied on the target server (ex: /var/tmp/myapp.group.echonet.crt)*
webserver_grp_type     | INTERNAL/EXTERNAL/EXTERNAL_EV  | `yes`         | *Type of the group certificates to insert (INTERNAL if certificate stands for internal website, EXTERNAL if certificate stands for Standard external SSL, EXTERNAL_EV stands for External SSL with Extended Validation)*
webserver_kdb_pwd      |                             | no         | *The password of the kdb if stash file is not set*


info-certif
----------

list and check certificates expiration date in a kdb

**Parameter** | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------- | --------------------------- | ------------- | --------------
webserver_kdb_path          |                             | `yes`         | *Full path to kdb file (example: /apps/toolboxes/web/ManageCertificates/generatecert/myapp.group.echonet//myapp.group.echonet.kdb)*
webserver_kdb_pwd      |                             | no         | *The password of the kdb if stash file is not set*


Dependencies
============

None

Example
=======

```
#start the IHS sw-12345_abc_cde_fgh-prez-1  
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_webserver
      vars:
        webserver_operation: "start_ihs"
        webserver_item: "sw-12345_abc_cde_fgh-prez-1"
        
```

