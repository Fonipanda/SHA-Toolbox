#!/usr/bin/python
# -*- coding: utf-8 -*-

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'Toolbox'
}

DOCUMENTATION = '''
---
module: cft

short_description: cft management

version_added: "2.5"

description:
    - "module to manage cft"

options:
    action:
        description:
            - Action to perform on cft
        required: True

author:
    - NAVARRO Wilfried - toolbox team
'''

EXAMPLES = '''
# check if CFT is installed, give the version and list of partners
- name: Check CFT
  cft:
    action: check
    
# get status of CFT 
- name: CFT status
  cft:
    action: status  
  become: true
  become_user: cft
  become_method: su

# start CFT
- name: Start CFT
  cft:
    action: start
  become: true
  become_user: cft
  become_method: su

# List partners
- name: receive and send partners' list
  cft:
    action: list
'''

RETURN = '''
action:
    description: used action
    type: str

state:
    description: state of the process (stopped/started)
    type: str
    
check:
    description: information about cft installation, version, and partners
    type: dict

installed:
    description: indicates if CFT is installed or not
    type: str

version:
    description: give the version of CFT installed
    type: str

list:
    description: give receive and send partners' list
    type: dict

receive_partners:
    description: give the list of receiving partners:
    type: list

send_partners:
    description: give the list of sending partners:
    type: list
'''

import subprocess
import re

from ansible.module_utils.basic import AnsibleModule


##########
# Command execution
#################

def launch_command(executable_path,args):
    result = dict()

    result['returnedObject'] = subprocess.Popen(". ~cft/.profile;"+executable_path+" "+args,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
    stdout, stderr = result['returnedObject'].communicate()
    result['stdout'] = stdout
    result['stderr'] = stderr
    result['returncode'] = result['returnedObject'].wait()
    return result


def perform_action(action):
    return_action = dict()
    result_action = launch_command('cft', action)

    if action == 'stop' and "stopped correctly" in result_action['stdout']:
        return_action['changed'] = True
        return_action['state'] = 'stopped'
    elif action == 'stop' and "already" in result_action['stdout']:
        return_action['changed'] = False
        return_action['state'] = 'stopped'
    elif action == 'start' and "started correctly" in result_action['stdout']:
        return_action['changed'] = True
        return_action['state'] = 'started'
    elif action == 'start' and "already" in result_action['stdout']:
        return_action['changed'] = False
        return_action['state'] = 'started'
    elif action == 'status' and result_action['returncode'] == 0:
        return_action['changed'] = False
        return_action['state'] = 'started'
    elif action == 'status' and result_action['returncode'] == 1:
        return_action['changed'] = False
        return_action['state'] = 'stopped'
    else:
        raise Exception("action "+action+" in error")

    return return_action


##########
# Check user in /etc/passwd
#################

def check_user(user):
    userpresence = False
    passwdfile = open("/etc/passwd", "r")
    listusers = passwdfile.readline()
    while listusers:
        if re.search('^'+user+':.*', listusers):
            passwdfile.close()
            userpresence = True
            break
        else:
            listusers = passwdfile.readline()

    passwdfile.close()
    return userpresence


##########
# Check connected user
#################

def check_con_user(user):
    con_user = launch_command('whoami', '')['stdout']
    if re.sub('\n', '', con_user) == user:
        return True
    else:
        return False


##########
# Get version
#################

def get_version():
    command = launch_command('cftutil', 'about')
    par_cft = False
    cft_version = ''

    for line in command['stdout'].split('\n'):
        if 'CFT information' in line:
            par_cft = True

        if par_cft and 'version' in line:
            cft_version = line.split(' = ')[1]
            break

    return cft_version


##########
# List partners
#################

def list_partners():
    command = launch_command('cftutil', 'LISTPART')

    receive_partners = []
    send_partners = []

    for line in command['stdout'].split('\n'):
        if 'NSPART' in line and re.sub('[ ]+', '', line.split(' = ')[1]) not in send_partners:
            send_partners.append(re.sub('[ ]+', '', line.split(' = ')[1]))
        if 'NRPART' in line and re.sub('[ ]+', '', line.split(' = ')[1]) not in receive_partners:
            receive_partners.append(re.sub('[ ]+', '', line.split(' = ')[1]))

    return receive_partners, send_partners


##########
# Main
#################

def run_module():
    # define the available arguments/parameters that a user can pass to
    # the module
    module_args = dict(
        action=dict(type='str', required=True),
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

        if module.params['action'] == 'check':
            result['check'] = {}
            if check_user('cft'):
                result['check']['installed'] = 'yes'
                result['check']['version'] = get_version()
                result['check']['receive_partners'], result['check']['send_partners'] = list_partners()
            else:
                result['check']['installed'] = 'no'
        else:
            if not check_user('cft'):
                raise Exception("user cft does not exist")

            if module.params['action'] in ('start', 'stop', 'status'):
                if not check_con_user('cft'):
                    raise Exception("you need to be cft for "+module.params['action']+" action")

                command = perform_action(module.params['action'])

                result['state'], result['changed'] = command['state'], command['changed']

            if module.params['action'] == 'list':
                result['list'] = {}
                result['list']['receive_partners'], result['list']['send_partners'] = list_partners()

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
