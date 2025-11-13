#!/usr/bin/python
# -*- coding: utf-8 -*-

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'check': ['preview'],
    'supported_by': 'Toolbox'
}

DOCUMENTATION = '''
---
module: illumio

short_description: illumio management 

version_added: "2.5"

description:
    - "module to manage Illumio"

options:
  action:
      description:
          - Action to perform on Illumio
      required: True

author:
    - NAVARRO Wilfried - toolbox team
'''

EXAMPLES = '''
#verify installation and get version of Illumio
- name: get information
  illumio:
    action: check 
'''

RETURN = '''
action:
    description: used action
    type: str

check:
    description: installed/version
    type: dict
       installed:
           description: indicates if Illumio is installed or not
           type: str
       version:
           description: version of Illumio
           type: str
'''


import os
import os.path
import subprocess, shlex
import re
import math

from ansible.module_utils.basic import AnsibleModule

illumioDirectory = "/opt/illumio_ven/"
illumioVersionBinPath = illumioDirectory + "illumio-ven-ctl"


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


def run_module():
    # define the available arguments/parameters that a user can pass to
    # the module
    module_args = dict(
        action=dict(type='str', required=True)
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
            result['check']=dict()
            if os.path.exists(illumioDirectory):
                result['check']['installed'] = 'yes'
                command = launch_command(illumioVersionBinPath,"version")
    
                if command['returncode'] == 0:
                     result['check']['version'] = command['stdout'].replace('\n','')
                else:
                    result['failed'] = True
                    msg = command['stderr']
                    raise Exception(msg)
    
            else:
                result['check']['installed'] = 'no'

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
