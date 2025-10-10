#!/usr/bin/python
# -*- coding: utf-8 -*-

ANSIBLE_METADATA = {
  'metadata_version': '1.1',
  'status': ['preview'],
  'supported_by': 'Toolbox'
}

DOCUMENTATION = '''
---
module: check_systemd

short_description: systemd management 

version_added: "2.5"

description:
    - "module to manage systemd services"

options:
  action:
      description:
          - Action to perform on systemd services
      required: True

author:
    - NAVARRO Wilfried - toolbox team
'''

EXAMPLES = '''
#get status of a service
- name: get information
  manage_systemd:
    action: status
    service_name: service
'''

RETURN = '''
action:
    description: used action
    type: str

service:
    description: service name to manage
    type: str

status:
    description: gives the status of the service and indicates if it is enabled or not
    type: dict
       enabled: 
           description: enabled or not
           type: boolean
       state:
           description: status of the service
           type: str
'''

import os
import os.path
import subprocess, shlex
import re
import xml.etree.ElementTree

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

##########
# Status command
#################

def status_service(service):
    
    cmd = launch_command("systemctl","status "+service)
    message = cmd['stdout'].split('\n')
    message_err = re.sub('\n','',cmd['stderr'])

    if cmd['returncode'] == 0:
       state = "started"
    elif cmd['returncode'] == 3:
       state = "stopped"

    if cmd['returncode'] == 0 or cmd['returncode'] == 3:
       for line in message:
          if re.search('Loaded:',line):
             reboot = line.split('; ')

       return cmd['returncode'],reboot[1],state
    else:
       return cmd['returncode'],message_err

def run_module():
    # define the available arguments/parameters that a user can pass to
    # the module
    module_args = dict(
        action=dict(type='str', required=True),
        service_name=dict(type='str', required=True)
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
        action=module.params['action'],
        service=module.params['service_name']
    )

    try:
        # if the user is working with this module in only check mode we do not
        # want to make any changes to the environment, just return the current
        # state with no modifications
        if module.check_mode:
            return result

        if module.params['action'] == 'status':
           command = status_service(module.params['service_name'])

           if int(command[0]) == 0 or int(command[0]) == 3:
              result['status'] = dict()
              if command[1] == "enabled":
                 result['status']['enabled'] = True
              else:
                 result['status']['enabled'] = False

              result['status']['state'] = command[2]
           else:
              result['rc'],result['msg'] = command
                     
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
