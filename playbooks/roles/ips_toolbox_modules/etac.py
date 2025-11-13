#!/usr/bin/python
# -*- coding: utf-8 -*-

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'check': ['preview'],
    'supported_by': 'Toolbox'
}

DOCUMENTATION = '''
---
module: etac

short_description: etac management 

version_added: "2.5"

description:
    - "module to manage eTAC"

options:
  action:
      description:
          - Action to perform on eTAC
      required: True

author:
    - NAVARRO Wilfried - toolbox team
'''

EXAMPLES = '''
#get status and version of eTAC
- name: get information
  etac:
    action: check 

- name: get status
  etac:
    action: status
'''

RETURN = '''
action:
    description: used action
    type: str

check:
    description: installed/daemons/global status/version
    type: dict
       installed:
           description: indicates if eTAC is installed or not
           type: str
       daemons:
           description: state and PID of processes agent/security/selogrd/serevu/watchdog
           type: str
       global status:
           description: state of eTAC agent according to daemons states
           type: str
       version:
           description: version of eTAC agent
           type: str

daemons:
    description: state/pid of etac's daemons
    type: dict

status:
    description: global status of etac
    type: str
'''


import os
import os.path
import subprocess, shlex
import re
import math

from ansible.module_utils.basic import AnsibleModule

etacDirectory = "/apps/eTAC/bin/"

etacVersionScriptPath = etacDirectory + "seversion"
etacStateScriptPath = etacDirectory + "issec"


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

        if module.params['action'] in ('check','status'):
            check=dict()
            if os.path.exists(etacDirectory):
                check['installed'] = 'yes'
                command = launch_command(etacVersionScriptPath,etacDirectory + "seosd")
    
                if command['returncode'] == 0:
                    for line in command['stdout'].split('\n'):
                        if re.search('Version',line):
                            parameter,value = re.sub(' +','',line).split(':')
    
                    check['version'] = value
                else:
                    result['failed'] = True
                    msg = command['stderr']
                    raise Exception(msg)
    
                command = launch_command(etacStateScriptPath,'')
                check["daemons"]=dict()
    
                check["global status"] = 'OK'
                for line in command['stdout'].split('\n'):
                    if re.search('security|watchdog|agent|serevu|selogrd',line):
                         if 'is not running' in line:
                             CA,control,process_name,daemon,verb,nt,running = line.split(" ")
                             check["daemons"][process_name]=dict()
                             check["daemons"][process_name]["pid"]="NA"
                             check["daemons"][process_name]['state']="KO"
                             check["global status"] = 'KO'                   
                         else:
                             begin_line,end_line = line.split(",")
                             CA,ControlMinder,process_name,daemon,verb,running = begin_line.split(" ")
                             pid_info,end = end_line.split(" (") 
                             pid,pid_value = pid_info.split("=")
                             check["daemons"][process_name]=dict()
                             check["daemons"][process_name]["pid"]=pid_value
                             check["daemons"][process_name]['state']="OK"
            else:
                check['installed'] = 'no'
                     
            if module.params['action'] == 'check':
                result['check']=dict()
                result['check']=check

            if module.params['action'] == 'status':
                result['status']=dict()
                result['daemons']=check["daemons"]
                result['status']=check["global status"]


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
