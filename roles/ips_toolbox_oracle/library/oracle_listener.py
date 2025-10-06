#!/usr/bin/python
# -*- coding: utf-8 -*-

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'Toolbox'
}

DOCUMENTATION = '''
---
module: oracle_listener

short_description: oracle listener management

version_added: "2.5"

description:
    - "module to manage oracle listeners"

options:
    action: 
        description:
            - Action to perform on oracle listeners
        required: True

author:
    - NAVARRO Wilfried - toolbox team
'''

EXAMPLES = '''

#status listeners
- name: status listeners
  oracle_listener:
    action: status
'''

RETURN = '''
action:
    description: used action
    type: str
information:
    description: information about the status of listeners (endpoints/parameters/services/message)
    type: dict
        endpoints:
           description: network description
           type: dict
        parameters:
           description: parameters and information about listeners
           type: dict
        services:
           description: status of supported services by instance
           type: dict
        message:
           description: indicates error of lsnrctl commands
           type: str or list
status:
    description: state of listeners
    type: dict
'''

import os
import os.path
import subprocess, shlex
import re

from ansible.module_utils.basic import AnsibleModule

tns_admin = "/apps/oracle/adm/network/"
listener_file = tns_admin + "listener.ora"

##########
# Command execution
#################

def launch_command(executable_path,args):
    result = dict()

    result['returnedObject'] = subprocess.Popen(executable_path+" "+args,
        shell=True,
        stdout=subprocess.PIPE, 
        stderr=subprocess.PIPE)
    stdout,stderr = result['returnedObject'].communicate()
    result['stdout'] = stdout 
    result['stderr'] = stderr
    result['returncode'] = result['returnedObject'].wait()
    return result


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
# Get started listeners
#################
def get_started_listeners():
    command = launch_command("ps -eo args | grep tnslsnr | grep -v grep | awk '{print $1\":\"$2}'", " " )

    output = command['stdout'].split('\n')

    return output

##########
# Get list listeners
#################
def list_listeners():
    if os.path.exists(listener_file):
        listener_file_r = open(listener_file, "r")
        list_listener=list()
        list_listener.append('LISTENER')
        
        try:
            for line in listener_file_r.readlines():
                if not re.match("^[#| ].*", line) and '=' in line:
                    listener_name = line.split('=')[0].strip()
                    if 'DESCRIPTION' in line: 
                        list_listener.append(listener_name)
                        continue
                else:
                    if not re.match("^#.*", line) and 'DESCRIPTION' in line:
                        list_listener.append(listener_name)
                        continue
            listener_file_r.close()

        except Exception:
            listener_file_r.close()
            raise Exception("Error with file " + tns_admin)
                
    else:
        raise Exception("No file 'listener.ora' in " + tns_admin)

    if list_listener == []:
        raise Exception("No listener configured in " + listener_file) 

    return sorted(set(list_listener))

##########
# Get status
#################

def get_status(oracle_home_bin,listener_name):
    oracle_home = os.path.dirname(oracle_home_bin)
    command = launch_command("export TNS_ADMIN="+tns_admin+";export ORACLE_HOME="+oracle_home+";", oracle_home_bin+"/lsnrctl status "+listener_name)

    if command['returncode'] != 0:
       message = "Error with lsnrctl command for listener: "+listener_name
    else:
       message = ''

    return command, message

##########
# Format stdout
#################

def format_expl(output, listener_name):
    resultline=dict()

    if 'STATUS of the LISTENER' not in output or 'Listening Endpoints Summary...' not in output:
        status_listener = 'KO'
        message = "Error with lsnrctl command for listener: "+listener_name
        return resultline, status_listener, message
    else:
        status_listener = 'OK'
        resultline['parameters'] = dict()
        resultline['endpoints']  = dict()
        message = ''

    begin = output.split('STATUS of the LISTENER')[1]
    status,part2 = begin.split('Listening Endpoints Summary...')

    for line in status.split('\n'):
        if not re.search('^-', line) and line != "":
            parameter = re.split(r' [ ]+',line)[0]
            value = re.split(r' [ ]+',line)[-1]
            resultline['parameters'][parameter] = value

    if 'Services Summary...' in output:
        endpoints,services = part2.split('Services Summary...')
    else:
        endpoints,services = part2.split('The listener supports no services')

    i=1
    for line in re.sub(r'[\(|\)]', ' ', endpoints.strip()).split('\n'):
        if line != "":
            resultline['endpoints']['ADRESS'+str(i)]=dict()
            for subline in re.split(r'[ ]+',line.strip()):
                parameter,value = subline.split('=')
                if parameter != "" and value != "":
                    resultline['endpoints']['ADRESS'+str(i)][parameter] = value
            i = i+1


    if 'Services Summary...' in output:
        resultline['services']   = dict()

        for line in services.split('Service')[1:]:
            servicename = re.sub('\\"', '', line.split('\n')[0]).strip().split(' ')[0]
            for subline in line.split('\n')[1:]:
                if subline != "" and 'nstance' in subline:
                    instancename = re.sub('\\"', '', subline.split(',')[0].strip()).split(' ')[1]
                    status = subline.split(',')[1].strip().split(' ')[1]
                    if not (instancename in resultline['services']):
                        resultline['services'][instancename]=dict()

                    resultline['services'][instancename][servicename] = status
    else:
        resultline['services'] = 'The listener supports no services'

    return resultline, status_listener, message


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

        if not check_user('oracle'):
            raise Exception("user oracle does not exist")

        if module.params['action'] != 'status':
            raise Exception("Invalid action parameter: " + module.params['action'])

        else:
            list_message = list()
            listlisteners = list_listeners()
            started_listeners = get_started_listeners()
            result['status'] = dict()

            for listener in listlisteners:
                if listener not in started_listeners:
                    result['status'][listener] = 'stopped'                    

            for line in started_listeners:
                if line != "":
                     oraclehome = os.path.dirname(line.split(':')[0])
                     listener = line.split(':')[1]
                     
                     command, message = get_status(oraclehome,listener)

                     if message != "":
                         list_message.append(message)
                         result['status'][listener] = 'KO'
                     else:
                         if not ('information' in result):
                             result['information'] = dict()

                         listener_info, status, message = format_expl(command['stdout'], listener)

                         if len(listener_info) > 0:
                             if not ('information' in result):
                                 result['information'] = dict()
                             result['information'][listener] = listener_info

                         result['status'][listener] = status

                         if message != "":
                             list_message.append(message)

        if len(list_message) == 1:
            result['failed'] = True
            result['information']['message'] = list_message[0]
        elif len(list_message) > 1:
            result['failed'] = True
            result['information']['message'] = list_message
              

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
