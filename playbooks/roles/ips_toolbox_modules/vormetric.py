#!/usr/bin/python
# -*- coding: utf-8 -*-

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'check': ['preview'],
    'supported_by': 'Toolbox'
}

DOCUMENTATION = '''
---
module: vormetric

short_description: vormetric management 

version_added: "2.5"

description:
    - "module to manage vormetric"

options:
  action:
      description:
          - Action to perform on vormetric
      required: True

author:
    - NAVARRO Wilfried - toolbox team
'''

EXAMPLES = '''
#get status and version of vormetric
- name: get information
  vormetric:
    action: check 

- name: get status
  vormetric:
    action: status

#list guardpoint
- name: get guarpoints list
  vormetric:
    action: list
'''

RETURN = '''
action:
    description: used action
    type: str

check:
    description: installed/information/global status/version
    type: dict
       installed:
           description: indicates if vormetric is installed or not
           type: str
       information:
           description: gives information about vormetric's processes
           type: dict
       global status:
           description: state of vormetric agent according to information state
           type: str
       version:
           description: version of vormetric agent
           type: str

list:
    description: gives information about guardpoints
    type: dict
'''


import os
import os.path
import subprocess, shlex
import re
import math

from ansible.module_utils.basic import AnsibleModule

vormetricDirectory = "/apps/vormetric/"
vormetricBinDirectory = "/apps/vormetric/DataSecurityExpert/agent/vmd/bin/"
vormetricHealthScript = vormetricBinDirectory + "agenthealth"

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


def AgentHealth():
    cmd = launch_command(vormetricHealthScript, "")

    ListStatus = dict()
    for line in cmd['stdout'].split('\n'):
        if '.' in line:
            if 'echonet' not in line and 'intra' not in line:
                if 'Time' in line:
                    keylist=re.sub(' $', '', line.split('.')[0])
                    valuelist=re.sub('^ ', '', line.split('.')[-2])
                else:
                    keylist=re.sub(' $', '', line.split('.')[0])
                    valuelist=re.sub('^ ', '', line.split('.')[-1])

                ListStatus[keylist]=valuelist

    if ListStatus['VMD is running'] == "OK" and ListStatus['Can communicate to at least one server'] == "OK" and ListStatus['SECFSD is running'] == "OK":
        GlobalStatus = 'OK'
    else:
        GlobalStatus = 'KO'

    return ListStatus,GlobalStatus 


def listguardpoint():
    cmd = launch_command('secfsd', "-status guard -v")
    index = 0
    list = dict()

    for paraf in cmd['stdout'].split('\n\n'):
        if paraf != "":
            index = index + 1

            list["GuardPoint" + str(index)] = dict()
            for line in paraf.split('\n'):
                if ':' in line and 'GUARD POINT' not in line:
                    key2,value2 = line.split(':')
                    list["GuardPoint" + str(index)][re.sub('^\t', '', key2)] = re.sub('^ +', '', value2)
    
    return list


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

        if module.params['action'] in ('check','status'):
            check=dict()
            if os.path.exists(vormetricDirectory):
                check['installed'] = 'yes'
                command = launch_command('secfsd'," -v")
    
                if command['returncode'] == 0:
                    for line in command['stdout'].split('\n'):
                        if re.search('version',line):
                            value = re.sub(' +','',line).split(':')[-1]
    
                    check['version'] = value
                else:
                    result['failed'] = True
                    msg = command['stderr']
                    raise Exception(msg)
    
            else:
                check['installed'] = 'no'
                     

            result['check'] = check

            if module.params['action'] == 'status':
                if check['installed'] == 'yes':
                    cmd = AgentHealth()
                    result['check']['information'],result['check']['global status'] = cmd
                else:
                    raise Exception("Vormetric not installed")

        if module.params['action'] == 'list':
            if os.path.exists(vormetricDirectory):
                cmd = listguardpoint()
                result['list'] = cmd
            else:
                raise Exception("Vormetric not installed")


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

