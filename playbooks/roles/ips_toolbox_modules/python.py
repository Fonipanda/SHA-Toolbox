#!/usr/bin/python
# -*- coding: utf-8 -*-

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'Toolbox'
}

DOCUMENTATION = '''
---
module: python

short_description: python management 

version_added: "2.5"

description:
    - "module to manage python"

options:
    action:
        description:
            - Action to perform on python
        required: True

author:
    - NAVARRO Wilfried - toolbox team
'''

EXAMPLES = '''
#get versions of python
- name: get information
  python:
    action: check
'''


RETURN = '''
action:
    description: used action
    type: str

version:
    description: versions of python
    type: list
'''

import subprocess, shlex
import re

from ansible.module_utils.basic import AnsibleModule


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
        changed = False,
        action = module.params['action']
    )

    try:
        # if the user is working with this module in only check mode we do not
        # want to make any changes to the environment, just return the current
        # state with no modifications

        if module.params['action'] == 'check':
            list_version = list()
 
            for i in range(2, 4):
                verifcommand = launch_command('which','python'+ str(i)) 
                if verifcommand['returncode'] == 0:
                    command = launch_command('python' + str(i),'-c "import platform;print(platform.python_version())"')
                    list_version.append(re.sub('\n','',command['stdout']))

            result['version'] = list_version


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
