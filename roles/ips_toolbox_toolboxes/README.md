ips_toolbox_toolboxes
=====================

role used to install/uninstall/update toolboxes on servers

Requirements
============

- ips_toolbox_set_results role
- For install operation: 
    - at least 700 MB free in the "toolboxes_install_dir" (default is /apps/Deploy/)
    - at least 10 MB free in /apps/Deploy/ for logs

Synopsis
========

**toolboxes_operation** | **OS** | ***Comments***
----------------------- |:------:| --------
install                 |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *install toolboxes*
uninstall               |![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *uninstall windows toolbox* 
check                   |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) ![windows](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/windows.png) | *Check if toolboxes are installed and give the version* 
versions-available      |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Check which toolbox package could be download (and installed)*
update-reports          |![aix](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/AIX.png) ![linux](https://gitlab-dogen.group.echonet/Production-mutualisee/IPS/toolbox_next_gen/toolbox_next_gen/ips_toolbox_launcher/raw/master/images/redhat.png) | *Generates toolboxes reports and send them to 'portail 360'*

Operation Parameters
====================
install
-------

install toolboxes


    Requirements:

    - at least 700 MB free in the "toolboxes_install_dir" (default is /apps/Deploy/)
    
    - at least 10 MB free in /apps/Deploy/ for log

**Parameter**         | **Choices/`Default`**                      | **Mandatory**     | ***Comments***
--------------------- | ------------------------------------------ | ----------------- | --------------
toolboxes_version     | `if not specified, install the last version`| no                | *Not available for Windows <br>For AIX/Linux, use the `versions-available` Ansible task to check which version is available*
toolboxes_install_dir | `/apps/Deploy`                             | no                | *Directory where to temporary download the latest AIX/Linux toolbox's package*
toolboxes_repo_url    | `if not specified use the BP²I nimprod repo`| no                | *repository url from where downloading the toolbox package*

uninstall
---------

uninstall windows toolbox

=> No additional parameter

check
-----

check if toolboxes are installed and give the version

=> No additional parameter

versions-available
-----

check which toolbox package could be download (and installed)

**Parameter**         | **Choices/`Default`**                        | **Mandatory**     | ***Comments***
--------------------- | -------------------------------------------- | ----------------- | --------------
toolboxes_repo_url    | `if not specified use the BP²I nimprod repo` | no                | *repository url from where checking the available toolbox packages*

update-reports
-----

Generates toolboxes reports and send them to 'portail 360'

=> No additional parameter


Dependencies
============

None

Example
=======

```
#install or update toolboxes
- hosts: servername
  tasks:
    - include_role:
        name: ips_toolbox_toolboxes
      vars:
        toolboxes_operation: "install"
        
```


