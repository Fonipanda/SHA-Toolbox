 ips_toolbox_controlm
=====================

role used to perform operations over Control-M/Agent

Requirements
============

- toolbox script files
- ips_toolbox_set_results role

Synopsis
========

**controlm_operation** | **OS** | ***Comments***
---------------------- |:------:| --------
check                  |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *Check installation and version of all Control-M/Agent*
list                   |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *List all Control-M/Agent*
list_jobs              |![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *List running jobs processes*
start                  |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *Start a Control-M/Agent*
status                 |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *Status of a Control-M/Agent*
stop                   |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *Stop a Control-M/Agent*

Operation Parameters
====================
check
-----

Check installation and version of all Control-M/Agent

=> No additional parameter

list
-----

List all Control-M/Agent

=> No additional parameter

list_jobs
-----

List running jobs processes on a Control-M/Agent

**Parameter**         | **Choices/`Default`** | **Mandatory** | ***Comments***
-------------------   | --------------------- | ------------- | --------------
controlm_agent_name   | `Default`             | no            | *Control-M/Agent Name `(only for windows)`*


start
-----

Start a Control-M/Agent

**Parameter**         | **Choices/`Default`** | **Mandatory** | ***Comments***
-------------------   | --------------------- | ------------- | --------------
controlm_agent_name   | `Default`             | no            | *Control-M/Agent Name `(only for windows)`*
controlm_agentaccount | `ctmagent`            | no            | *Control-M/Agent User `(only for unix)`*

status
-----

Status of a Control-M/Agent

**Parameter**         | **Choices/`Default`** | **Mandatory** | ***Comments***
-------------------   | --------------------- | ------------- | --------------
controlm_agent_name   | `Default`             | no            | *Control-M/Agent Name `(only for windows)`*
controlm_agentaccount | `ctmagent`            | no            | *Control-M/Agent User `(only for unix)`*

stop
-----

Stop a Control-M/Agent

**Parameter**         | **Choices/`Default`** | **Mandatory** | ***Comments***
-------------------   | --------------------- | ------------- | --------------
controlm_agent_name   | `Default`             | no            | *Control-M/Agent Name `(only for windows)`*
controlm_agentaccount | `ctmagent`            | no            | *Control-M/Agent User `(only for unix)`*

Dependencies
============

 None

Example
=======

```
#Stop the control-m agent s00v09988777_1  
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_controlm
      vars:
        controlm_operation: "stop"
        controlm_agent_name: "s00v09988777_1"
        
```
