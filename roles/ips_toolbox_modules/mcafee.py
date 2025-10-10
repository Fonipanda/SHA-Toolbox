#!/usr/bin/python
# -*- coding: utf-8 -*-

ANSIBLE_METADATA = {
  'metadata_version': '1.1',
  'status': ['preview'],
  'supported_by': 'Toolbox'
}

DOCUMENTATION = '''
---
module: McAfee

short_description: McAfee management 

version_added: "2.5"

description:
    - "module to manage McAfee"

options:
  action:
      description:
          - Action to perform on McAfee
      required: True

author:
    - NAVARRO Wilfried - toolbox team
'''

EXAMPLES = '''
#get status and version of McAfee
- name: get information
  mcafee:
    action: check 

- name: get status
  mcafee:
    action: status
'''

RETURN = '''
action:
    description: used action
    type: str

check:
    description: installed/version/informations/DAT Info
    type: dict
       installed:
           description: indicates if McAfee is installed or not
           type: str
       version:
           description: version of McAfee agent
           type: str
       DAT Info:
           description: information about McAfee signature
           type: dict

processes:
    description: status of mcafee's processes (macmnsvc/macompatsvc/masvc)
    type: dict

state:
    description: status of mcafee
    type: string
'''

import os
import os.path
import subprocess, shlex
import re
import xml.etree.ElementTree

from ansible.module_utils.basic import AnsibleModule

McAfeeDirectory = "/opt/McAfee/agent/bin/"
McAfeeInformationScriptPath = McAfeeDirectory + "cmdagent"


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
# Action check
#################

def check_command():
    check=dict()

    if os.path.exists(McAfeeDirectory):
        check['Installed'] = 'yes'
        command = launch_command(McAfeeInformationScriptPath,"-i")
        command_result = command['stdout'].split(' \n')

        for line in command_result:
            if ':' in line:
                dict_name,dict_value = line.split(': ')
                check[dict_name]=dict()
                if '|' in dict_value:
                    check[dict_name]=dict_value.split('|')
                else:
                    check[dict_name]=dict_value
    else:
        check['Installed'] = 'no'

    return check

##########
# get DAT information
#################

def get_dat_info():
    dat_info=dict()

    if os.path.exists("/opt/isec/ens/threatprevention/var/prefs.xml"):
        tree = xml.etree.ElementTree.parse('/opt/isec/ens/threatprevention/var/prefs.xml')

        dat_info['engine version'] = tree.findall('*/IncrementalUpdateEngineVersion')[0].text
       
        Major_DAT_Version = tree.findall('*/MajorDATVersion')[0].text 
        Minor_DAT_Version = tree.findall('*/MinorDATVersion')[0].text
        dat_info['content version'] = Major_DAT_Version+"."+Minor_DAT_Version

        DATReleaseYear = tree.findall('*/DATReleaseYear')[0].text
        DATReleaseMonth = tree.findall('*/DATReleaseMonth')[0].text
        if re.match("^[0-9][0-9]$",DATReleaseMonth):
            DAT_Month = DATReleaseMonth
        else:
            DAT_Month = "0"+DATReleaseMonth
        DATReleaseDay = tree.findall('*/DATReleaseDay')[0].text
        if re.match("^[0-9][0-9]$",DATReleaseDay):
            DAT_day = DATReleaseDay
        else:
            DAT_day = "0"+DATReleaseDay

        dat_info['content date'] = DATReleaseYear+DAT_Month+DAT_day

        DATUpdateTime = tree.findall('*/DATUpdateTime')[0].text
        dat_info['content update time'] = DATUpdateTime.replace("T","")

    return dat_info


##########
# Processes status commands
#################

def process_status(process):
     
     ProcessScriptPath = McAfeeDirectory + process
     message = launch_command(ProcessScriptPath,"status")

     if 'Process is running' in message['stderr']:
         return "OK"
     elif 'Process is not running' in message['stderr']:
         return "KO"
     else:
         return "Undefined"
     
def mcafee_status():
     status=dict()
     status['processes']=dict()
     status['state'] = "started"

     for process in ('macmnsvc','masvc','macompatsvc'):
         status['processes'][process] = process_status(process)

         if status['processes'][process] != "OK":
             status['state'] = "stopped"

     return status

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
            result['check'] = check_command()

            DAT_Info = get_dat_info()
            if DAT_Info != {}:
                result['check']['DAT Info'] = DAT_Info

        if module.params['action'] == 'status':
            result['state'] = mcafee_status()['state']
            result['processes'] = mcafee_status()['processes']
                     
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
