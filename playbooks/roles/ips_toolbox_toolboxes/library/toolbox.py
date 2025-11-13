#!/usr/bin/python
# -*- coding: utf-8 -*-

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'check': ['preview'],
    'supported_by': 'Toolbox'
}

DOCUMENTATION = '''
---
module: Toolbox

short_description: Toolbox management 

version_added: "2.5"

description:
    - "module to manage Toolbox"

options:
  action:
      description:
          - Action to perform on Toolbox
      required: True

  version:
      description:
          - Version to compare to current installed version
      required: False

author:
    - NAVARRO Wilfried - toolbox team
'''

EXAMPLES = '''
#get versions of Toolboxes
- name: get information
  toolbox:
    action: check 

#verify if current installed version is greater than 19.1.0
- name: get information
  toolbox:
    action: compare
    version: 19.1.0

'''

RETURN = '''
action:
    description: used action
    type: str

check:
    description: installed/version
    type: dict
       installed:
           description: indicates if Toolbox is installed or not
           type: str
       version:
           description: version of Toolbox
           type: str

greater:
    description: indicates if current installed version of toolbox is greater or not to parameter version
    type: boolean

compared_version
    description: minimum version of toolbox required
    type: str

installed_version
    description: version of installed Toolbox
    type: str

'''

import os
import os.path
import subprocess, shlex
import re

from pkg_resources import parse_version
from ansible.module_utils.basic import AnsibleModule

ToolboxDirectory = "/apps/toolboxes/"
ToolboxVersionPath = ToolboxDirectory + "version"
ToolboxOperatingVersionPath = ToolboxDirectory + "exploit/version"
ToolboxOracleVersionPath = ToolboxDirectory + "sgbd/oracle/version"
ToolboxSchedulerVersionPath = ToolboxDirectory + "scheduler/version"
ToolboxBackupRestoreVersionPath = ToolboxDirectory + "backup_restore/version"
ToolboxWebVersionPath = ToolboxDirectory + "web/version"

##########
# Command execution
#################

def launch_command(executable_path,args):
    result = dict()

    result['returnedObject'] = subprocess.Popen(shlex.split(executable_path + " " + args),
        stdout=subprocess.PIPE, 
        stderr=subprocess.PIPE)
    stdout,stderr = result['returnedObject'].communicate()
    result['stdout'] = stdout 
    result['stderr'] = stderr
    result['returncode'] = result['returnedObject'].wait()
    return result

##########
# Get version tbx
#################

def get_version_tbx(fichier):
    if os.path.exists(fichier):
        line = open(fichier,"r").readline()
        value = line.split('|')[1]

        return value


##########
# Action check
#################

def check_command():
    check=dict()

    if os.path.exists(ToolboxVersionPath):
        check['Installed'] = 'yes'
        check['Version'] = get_version_tbx(ToolboxVersionPath)
    else:
        check['Installed'] = 'no'

    return check

##########
# Action test
#################

def compare_command(tbx_test):

    if os.path.exists(ToolboxVersionPath):
       Tbx_version = get_version_tbx(ToolboxVersionPath)
       
       return parse_version(Tbx_version) >= parse_version(tbx_test)


def run_module():
    # define the available arguments/parameters that a user can pass to
    # the module
    module_args = dict(
        action=dict(type='str', required=True),
        version=dict(type='str', required=False)
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=False
    )

    # seed the result dict in the object
    # we primarily care about changed and state
    # change is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    result = dict(
        changed=False,
        action=module.params['action']
    )

    try:
        # if the user is working with this module in only check mode we do not
        # want to make any changes to the environment, just return the current
        # state with no modifications
        if module.check_mode:
            return result

        if module.params['action'] == 'check':
            result['check'] = check_command()

        if module.params['action'] == 'compare':
            if module.params['version'] is not None and re.match("^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)|([0-9]+\.[0-9]+\.[0-9]+)$",module.params['version']):
                result['greater'] = compare_command(module.params['version'])
                result['installed_version'] = get_version_tbx(ToolboxVersionPath)
                result['compared_version'] = module.params['version']
            else:
                result['failed']=True
                result['msg']="Invalid format for parameter version"


        # during the execution of the module, if there is an exception or a 
        # conditional state that effectively causes a failure, run
        # AnsibleModule.fail_json() to pass in the message and the result
        # if module.params['name'] == 'fail me':
        #     module.fail_json(msg='You requested this to fail', **result)

        # in the event of a successful module execution, you will want to
        # simple AnsibleModule.exit_json(), passing the key/value results
    except Exception as e:
        module.fail_json(msg=str(e), **result)

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()
