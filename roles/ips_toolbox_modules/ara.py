#!/usr/bin/python
# -*- coding: utf-8 -*-

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'Toolbox'
}

DOCUMENTATION = '''
---
module: ara

short_description: ara management 

version_added: "2.5"

description:
    - "module to manage ara"

options:
    action:
        description:
            - Action to perform on ARA
        required: True

author:
    - NAVARRO Wilfried - toolbox team
'''

EXAMPLES = '''
#get status and version of ARA
- name: get information
  ara:
    action: check

#start agent ARA
- name: start ARA
  ara:
    action: start

#stop agent ARA
- name: stop ARA
  ara:
    action: stop
'''


RETURN = '''
check:
    description: installed/java/wrapper/pid/state/version
    type: dict
       state:
           description: global status of ARA agent
           type: str
       installed:
           description: indicates if ARA is installed or not
           type: str
       java:
           description: status of the process
           type: str
       wrapper:
           description: status of the process
           type: str
       version:
           description: version of ARA agent
           type: str
rc:
    description: return code of the script used to perform action
    type: int
'''

import os
import os.path
import subprocess, shlex
import re
import math

from ansible.module_utils.basic import AnsibleModule

araDirectory = "/apps/LISA/"
araScriptPath = araDirectory + "nolio_agent.sh"
araScriptVersionPath = araDirectory + "version.ksh"

tmpFileList=list()
tmpFileList=['files_cache','files_registry','files_temp','persistency']

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
        changed=False
    )

    try:
        # if the user is working with this module in only check mode we do not
        # want to make any changes to the environment, just return the current
        # state with no modifications
        if module.check_mode:
            return result

        result['failed'] = False

        if module.params['action'] == 'check':
            result['check']=dict()

            if os.path.exists(araDirectory):
                 result['check']['installed'] = 'yes'
            else:
                 result['check']['installed'] = 'no'

        if module.params['action'] in ('stop','start'):
            command = launch_command(araScriptPath,module.params['action'])

            result['rc'] = command['returncode']

            if result['rc'] == 0 and module.params['action'] == 'start':
                result['changed'] = True
            elif result['rc'] != 0 and module.params['action'] == 'start':
                if "already" not in command['stdout']:
                    result['failed'] = True

            if result['rc'] == 0 and module.params['action'] == 'stop':
                if "was not running" not in command['stdout']:
                    result['changed'] = True
                    for directory in tmpFileList:
                         if os.path.exists(araDirectory + directory):
                             for filename in os.listdir(araDirectory + directory):
                                 os.remove(araDirectory + directory + "/" + filename)
            elif result['rc'] != 0 and module.params['action'] == 'stop':
                result['failed'] = True

        if module.params['action'] == 'check':
            if os.path.exists(araDirectory):
                command = launch_command(araScriptPath,'status')
                
                result['rc'] = command['returncode']
                if result['rc'] != 0 and "is not running" in command['stdout']:
                    result['check']['state'] = 'stopped' 
                elif result['rc'] != 0 and "is not running" not in command['stdout']:
                    result['failed'] = True
                    result['check']['state'] = 'undefined'
                    result['msg'] = command['stdout']
                if result['rc'] == 0:
                    result['check']['state'] = 'started'
                    Beginning,Wrapper,Java = command['stdout'].split(",")
                    nolio,pid,pid_value = Beginning.split(":")
                    wrapper,wrapper_value = Wrapper.split(":")
                    java,java_value = Java.split(":")
                    result['check']['pid'] = pid_value
                    result['check']['wrapper'] = wrapper_value
                    result['check']['java'] = re.sub('\n','', java_value)

                command2 = launch_command(araScriptVersionPath,"")
                result['check']['version'] = re.sub('\n','', command2['stdout'])




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
