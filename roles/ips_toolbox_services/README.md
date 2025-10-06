ips_toolbox_services 
==================

role used to perform operations over services (windows/Linux)

Requirements
=========

ips_toolbox_set_results role

Synopsis
========

**services_operation** | **OS** | ***Comments***
---------------------- |:------:|--------------
status                 |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *Status of a service*
start                  |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *Start a service*
stop                   |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *Stop a service*
enable                 |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *Enable a service*
disable                |![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *Disable a service*

Operation Parameters
====================
Status
------

Gives the status of the service and indicates if it is enabled or not
 
**Parameter**       | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------------- | --------------------------- | ------------- | --------------
services_item        |                             | `yes`         | *Service name*

Start
------

Start a service

**Parameter**       | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------------- | --------------------------- | ------------- | --------------
services_item        |                             | `yes`         | *Service name*

Stop
------

Stop a service

**Parameter**       | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------------- | --------------------------- | ------------- | --------------
services_item        |                             | `yes`         | *Service name*

Enable
------

Enable a service (Started at reboot)

**Parameter**       | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------------- | --------------------------- | ------------- | --------------
services_item        |                             | `yes`         | *Service name*

Disable
------

Disable a service (Not Started at reboot)

**Parameter**       | **Choices/`Default`**       | **Mandatory** | ***Comments***
------------------- | --------------------------- | ------------- | --------------
services_item        |                             | `yes`         | *Service name*


 
Dependencies
=========

None

Example
=========

```
# Start the service app_sw-07883_itlha_mob-prez-1-nossl.ksh.service
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_services
      vars:
        services_operation: "start"
        services_item: "app_sw-07883_itlha_mob-prez-1-nossl.ksh.service"

```

