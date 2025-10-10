#!/usr/bin/python
# -*- coding: utf-8 -*-

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'Toolbox'
}

DOCUMENTATION = '''
---
module: oracle_oem

short_description: oracle oem supervision management

version_added: "2.5"

description:
    - "module to manage oracle oem supervision, using bp2i's scripts"

options:
    action: 
        description:
            - Action to perform on oem supervision
        required: True
    instanceName:
        description:
            - Supervised (or not) Instance Name
        required: True

author:
    - NAVARRO Wilfried - toolbox team
'''

EXAMPLES = '''
#start blackout
- name: start blackout
  oracle_oem:
    action: start
    instanceName: <instance_name>

#stop blackout
- name: stop blackout
  oracle_oem:
    action: stop
    instanceName: <instance_name>

#status blackout
- name: status blackout
  oracle_oem:
    action: status
    instanceName: <instance_name>

'''

RETURN = '''
action:
    description: used action
    type: str
instanceName:
    description: Name of the supervised (or not) instance
    type: str
message:
    description: information about the action performed
    type: str
state:
    description: state of the blackout
    type: str
'''

import os
import os.path
import subprocess, shlex
import re

from ansible.module_utils.basic import AnsibleModule
from pwd import getpwuid

oracleExploitDirectory = "/apps/oracle/exploit/"
oracleKshDirectory = oracleExploitDirectory + "ksh/"

oraexploitblackoutoemScriptPath = oracleExploitDirectory + "ora_exploit_blackout_oem.ksh"
srvoraoemScriptPath = oracleKshDirectory + "srv_ora_oem.ksh"

##########
# Command execution
#################

def launch_command(executable_path,args):
    result = dict()

    result['returnedObject'] = subprocess.Popen(". ~oracle/.profile;"+executable_path+" "+args,
        shell=True,
        stdout=subprocess.PIPE, 
        stderr=subprocess.PIPE)
    stdout,stderr = result['returnedObject'].communicate()
    result['stdout'] = stdout 
    result['stderr'] = stderr
    result['returncode'] = result['returnedObject'].wait()
    return result


def actionblackout(instance, action):
    return launch_command(oraexploitblackoutoemScriptPath," -i " +instance+ " -" +action)


##########
# Format stdout
#################

def format_expl(output):
    for line in output.split('\n'):
        if re.search('FAILED', line):
            messageexist = True
            return re.sub('^ ', '', line.split('|')[-1].split(':')[0])

    if not messageexist:
        return "Error with script execution"


def run_module():
    # define the available arguments/parameters that a user can pass to
    # the module
    module_args = dict(
        action=dict(type='str', required=True),
        instanceName=dict(type='str', required=True)
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
        action=module.params['action'],
        instanceName=module.params['instanceName']
    )

    try:
        # if the user is working with this module in only check mode we do not
        # want to make any changes to the environment, just return the current
        # state with no modifications
        if module.check_mode:
            return result

        if module.params['action'] not in ('status','start','stop'):
            raise Exception("Invalid action parameter: " + module.params['action'])

        if os.path.isfile(srvoraoemScriptPath):

            command = actionblackout(module.params['instanceName'],module.params['action'])

            rc = command['returncode']
            stdout = command['stdout']

            if module.params['action'] == 'status':
                if rc == 1:
                    result['state'] = 'not blacked out'
                elif rc == 2:
                    result['state'] = 'not blacked out'
                    result['message'] = format_expl(stdout)
                else:
                    result['state'] = 'blacked out' 

            else:
                if rc == 0:
                    if module.params['action'] == 'start':
                        result['state'] = 'started'
                        result['changed'] = True
                    else:
                        result['state'] = 'stopped'
                        result['changed'] = True
                elif rc == 1:
                    if module.params['action'] == 'start' and 'deja en blackout' in stdout:
                        result['state'] = 'started'
                    elif module.params['action'] == 'stop' and 'Aucun blackout pour' in stdout:
                        result['state'] = 'stopped'
                    else:
                        result['state'] = 'unknow'
                        result['message'] = format_expl(stdout)
                elif rc == 2:
                    if 'pas monitoree par' in stdout:
                        if module.params['action'] == 'stop':
                            result['state'] = 'stopped'
                        else:
                            result['state'] = 'not started'
                        result['message'] = format_expl(stdout)
                    else:
                        result['state'] = 'unknow'
                        result['message'] = format_expl(stdout)
                else:
                    result['state'] = 'unknow'
                    result['message'] = format_expl(stdout)

        else:
            checkoemproc = launch_command('ps',' -eaf | grep "/bin/emwd.pl" | grep -v grep')
            if checkoemproc['returncode'] == 1:
                if module.params['action'] == 'start':
                    result['state'] = 'not started'
                elif module.params['action'] == 'stop':
                    result['state'] = 'stopped'
                else:
                    result['state'] = 'not blacked out'

                result['message'] = 'no oem monitoring'
            else:
                if not os.path.isfile(oraexploitblackoutoemScriptPath):
                    if module.params['action'] == 'start':
                        result['state'] = 'not started'
                    elif module.params['action'] == 'stop':
                        result['state'] = 'stopped'
                    else:
                        result['state'] = 'not blacked out'

                    raise Exception("No script " +oraexploitblackoutoemScriptPath)
 
                owner = getpwuid(os.stat(oraexploitblackoutoemScriptPath).st_uid).pw_name
                xrights = oct(os.stat(oraexploitblackoutoemScriptPath).st_mode)
 
                if owner == 'oracle' and xrights[4] in ('7','5','3','1'):
                    executable = True
                elif owner == 'root' and xrights[6] in ('7','5','3','1'):
                    executable = True
                else:
                    executable = False
                    if module.params['action'] == 'start':
                        result['state'] = 'not started'
                    elif module.params['action'] == 'stop':
                        result['state'] = 'stopped'
                    else:
                        result['state'] = 'not blacked out'

                    raise Exception("user oracle can not execute script" +oraexploitblackoutoemScriptPath)
 
                if executable:
                    command = actionblackout(module.params['instanceName'],'status')
                     
                    if module.params['action'] == 'start' and 'No Blackout registered' in command['stdout']:
                        execommand = actionblackout(module.params['instanceName'],'start')
                        if execommand['returncode'] == 0:
                            statuscommand = actionblackout(module.params['instanceName'],'status')
                            if 'No Blackout registered' in statuscommand['stdout']:
                                result['state'] = 'not started'
                            else:
                                result['changed'] = True
                                result['state'] = 'started'
                        else:
                            raise Exception 
                    elif module.params['action'] == 'start' and 'No Blackout registered' not in command['stdout']:
                        result['state'] = 'started'
                    elif module.params['action'] == 'stop' and 'No Blackout registered' not in command['stdout']:
                        execommand = actionblackout(module.params['instanceName'],'stop')
                        if execommand['returncode'] == 0:
                            statuscommand = actionblackout(module.params['instanceName'],'status')
                            if 'No Blackout registered' not in statuscommand['stdout']:
                                result['state'] = 'not stopped'
                            else:
                                result['changed'] = True
                                result['state'] = 'stopped'
                        else:
                            raise Exception   
                    elif module.params['action'] == 'stop' and 'No Blackout registered' in command['stdout']:
                        result['state'] = 'stopped'
                    elif module.params['action'] == 'stop' and 'No Blackout registered' in command['stdout']:
                        result['state'] = 'not blacked out'
                    elif module.params['action'] == 'stop' and 'No Blackout registered' not in command['stdout']:
                        result['state'] = 'blacked out'
                    else:
                        raise Exception
                

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
