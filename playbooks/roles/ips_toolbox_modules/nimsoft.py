#!/usr/bin/python
# -*- coding: utf-8 -*-

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'Toolbox'
}

DOCUMENTATION = '''
---
module: nimsoft

short_description: nimsoft management

version_added: "2.5"

description:
    - "Module to manage Nimsoft, using bp2i scripts installed in the SHA"

options:
    action:
        description:
            - Action to perform with nimsoft
        required: true
    policy:
        description:
            - Policy or policies to use according to the action given
        required: false

author:
    - Nicolas Videau - toolbox team
'''

EXAMPLES = '''
# get policies
- name: get current policies
  nimsoft:
    action: get

# add policies
- name: add policies
  nimsoft:
    action: add
    policy: policy1, policy2

# remove policies
- name: remove policies
  nimsoft:
    action: remove
    policy: policy1, policy2

# check agent status
- name: get a check of nimsoft agent status
  nimsoft: check
    action: check

# start nimsoft agent
- name: start the agent
  nimsoft: start

# stop nimsoft agent
- name: stop the agent
  nimsoft: stop

# restart nimsoft agent
- name: restart the agent
  nimsoft: restart
  
'''

RETURN = '''
action: 
    description: used action
    type: str
policy:
    description: depends of the action, get returns curent policies, add and remove return policies added or removed
    type: list
check:
    description: status of agent Nimsoft installation and services 
    type: list
Message:
    description: information about the action performed
    type: list
'''

import os
import os.path
import subprocess, shlex
import re

from ansible.module_utils.basic import AnsibleModule

nimsoftDirectory = "/apps/nimsoft/custo/scripts/exploitation/"
tbxDirectory = "/apps/toolboxes/exploit/bin/"

policyGroupManageScript_Path = nimsoftDirectory + "PolicyGroupManage.ksh"
repairNimsoftAgent_Path = nimsoftDirectory + "RepairNimsoftAgent.ksh"
listprofile_Path = nimsoftDirectory + "ListProfile.ksh"
TbxScript = tbxDirectory + "exploit_nimsoft.ksh"

def launch_command(executable_path,args):
    result = dict()

    result['returnedObject'] = subprocess.Popen(shlex.split(executable_path + " " + args),
        stdout=subprocess.PIPE, 
        stderr=subprocess.PIPE)
    stdout,stderr = result['returnedObject'].communicate()
    result['stdout'] = stdout.split('\n')
    result['stderr'] = stderr.split('\n')
    return result

def get_policies():
    result = list()
    command = launch_command( policyGroupManageScript_Path,"-a get")
    
    for line in command['stdout']:
        if "GROUP: " in line:
            result.append(line.replace("GROUP: ",""))
    return result

def upgrade():
    result = dict()

    if os.path.exists(TbxScript):
        command = launch_command( TbxScript, "deploy") 

        message = ",".join(command['stdout'])

        if 'Scripts and probes were already up to date' in message:
            result['message'] = "Scripts and probes were already up to date"
            result['update'] = False
            result['state'] = True
        elif 'Scripts have been updated successfully' in message and 'Probes were already up to date' in message:
            result['message'] = "Scripts have been updated successfully. Probes were already up to date"
            result['update'] = True
            result['state'] = True
        elif 'Probes have been updated successfully' in message and 'Scripts were already up to date' in message:
            result['message'] = "Probes have been updated successfully. Scripts were already up to date"
            result['update'] = True
            result['state'] = True   
        elif 'Scripts and probe have been updated successfully' in message:
            result['message'] = "Scripts and probe have been updated successfully"
            result['update'] = True
            result['state'] = True
        elif 'Error encountered' in message and 'You should contact and open an incident to BP2I Nimsoft team' in message:
            result['message'] = "Error encountered. You should contact and open an incident to BP2I Nimsoft team"
            result['update'] = False
            result['state'] = False
        else:
            result['message'] = "Undetermined error"
            result['update'] = False
            result['state'] = False
    else:
        result['message'] = "Error encountered. Script " + TbxScript + " not found"
        result['update'] = False
        result['state'] = False

    return result
        

def get_profiles():
    result = dict()
    command = launch_command( listprofile_Path, " ")

    previous_typep = ""

    for line in command['stdout']:
        if ";" in line:
            typep,valuep=line.split(';')
            if previous_typep == typep:
                valueP.append(valuep) 
            else:
                valueP = list()
                valueP.append(valuep)

            previous_typep = typep
            result[typep] = valueP

    return result

def manage_policies(action,policy):
    return launch_command( policyGroupManageScript_Path,"-a "+action+" -g "+policy)

def check_nimsoft():
    result = dict()
    command = launch_command(repairNimsoftAgent_Path,"-check")

    flag = False
    index = 0
    for line in command['stdout']:       
        if "Step : " in line:
            step = line.replace("Step : Check Nimsoft ","")
            result[step] = dict()
        if " ....... " in line:
            check = line.split(" ....... ")
            checkValue = check[0].replace('[ ','').replace(' ]','').replace('FAIL','KO')
            checkTitle = check[1].replace('Nimsoft ','') 

            if step == "Agent processes":
                checkTitle = checkTitle.replace("The ","")
                if checkTitle == "All processes are UP":
                    result[step]["Global status"] = checkValue
                if "There is " in checkTitle:
                    processesDetail = checkTitle.replace("There is ","").replace(' process(es)','').split(", ")
                    processesDetail.append('')
                    processesDetail[1],processesDetail[2] = processesDetail[1].split(" and ")
                    for p in processesDetail:
                        value,status = p.split(' ')
                        result[step][status.capitalize()] = int(value)
            elif step == "Prerequisites":                
                if "/apps/nimsoft/robot/robot.cfg exists" in checkTitle:
                    checkTitle = checkTitle.replace("The file ","").replace("and it is not empty","and not empty")
                elif "robotip" in checkTitle:
                    checkTitle = checkTitle.replace("There is no robotip parameter specified in","No robotip in")
                    checkTitle = checkTitle.replace(" file","")
                elif "network card" in checkTitle:
                    checkTitle = checkTitle.replace("There is only","Only")
                elif "is equal or over" in checkTitle:
                    checkTitle = checkTitle.replace("The filesystem ","")
                    checkTitle = checkTitle.replace("is equal or over",">=")
                    secondTitle = checkTitle.split(" >=")[0] + " size" 
                    checkTitle,secondValue = checkTitle.split(" with ")
                    result[step][secondTitle] = secondValue
                elif "used space" in checkTitle:
                    checkTitle = checkTitle.replace("The u","U")
                    checkTitle,secondValue = checkTitle.split(' filesystem is : ')
                    checkTitle = checkTitle.replace("of the","in")
                    secondTitle =  checkTitle.replace("space","space %")
                    result[step][secondTitle] = secondValue
                elif "volume" in checkTitle:
                    checkTitle = checkTitle.replace("The volume group for the filesystem ","")
                    checkTitle = checkTitle.replace("is ","volume group ")
                    checkTitle,checkValue = checkTitle.split(" : ")
                else:
                    checkTitle = checkTitle.replace("The directory ","")
                    checkTitle = checkTitle.replace("The script ","")
                    
                result[step][checkTitle] = checkValue
            else:
                checkTitle = checkTitle.replace("The ","")
                checkTitle = checkTitle.replace(' is DEPLOYED','').replace(' is not properly deployed','')
                checkTitle = checkTitle.replace('does not exist','presence').replace('exists','presence')
                checkTitle = checkTitle.replace('file ',"")
                checkTitle = checkTitle.replace('package ',"")
                result[step][checkTitle] = checkValue

    return result

def manage_nimsoft(action):
    result = dict(
        changed=False,
        failed=False
    )
   
    starting = False
    stopping = False
    command = launch_command(repairNimsoftAgent_Path,"-"+action)
    result['stdout'] = command['stdout']
    #result['debug'] = []

    for line in command['stdout']:
        
        if action in ('stop','restart'):
            #result['debug'].append()
            if "Stop Nimsoft Agent" in line:
                #result['debug'].append(line)
                result['changed'] = True
                stopping = True
            if (stopping and ("Stopping Nimsoft Agent" in line) and ("OK" not in line) ):
                #result['debug'].append(line)
                result['failed'] = True

        if action in ('start','restart'):
            #result['debug'].append()
            if "Start Nimsoft agent" in line:
                #result['debug'].append(line)
                result['changed'] = True
                starting = True
            
            if (starting and ("Starting Nimsoft Agent" in line) and ("OK" not in line) ):
                #result['debug'].append(line)
                result['failed'] = True
        
    return result



def run_module():
    # define the available arguments/parameters that a user can pass to
    # the module
    module_args = dict(
        action=dict(type='str', required=True),
        policy=dict(type='str', required=False)
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

        if module.params['action'] == "get":
            
            result['policy'] = get_policies()
            result['changed'] = False

        elif module.params['action'] == "get_profile":

            result['profile'] = get_profiles()
            result['changed'] = False

        elif module.params['action'] == "add" or module.params['action'] == "remove":
            
            if module.params['policy'] is not None:
                policy = module.params['policy'].replace(" ","")
                policyList = policy.split(',')
                result['policy'] = policyList
                currentPolicies = get_policies()
                actionTrigger = False
                if module.params['action'] == "add":
                    for listedPolicy in policyList:
                        if listedPolicy not in currentPolicies:
                            actionTrigger = True
                            break
                elif module.params['action'] == "remove":
                    for listedPolicy in policyList:
                        if listedPolicy in currentPolicies:
                            actionTrigger = True
                            break
                if actionTrigger:
                    PolicyManagement = manage_policies(module.params['action'],policy)
                    result['changed'] = True
        
        elif module.params['action'] == 'check':

            result['check'] = check_nimsoft()

        elif module.params['action'] in ('start','stop','restart'):
            manageNimsoft = manage_nimsoft(module.params['action'])
            result['changed'] = manageNimsoft['changed']
            if manageNimsoft['failed']:
                module.fail_json(msg='failed to '+module.params['action']+' nimsoft', **result)

        elif module.params['action'] == "upgrade":
            upgradeNimsoft = upgrade()
            result['changed'] = upgradeNimsoft['update']  
            result['message'] = upgradeNimsoft['message']
            result['state'] = upgradeNimsoft['state']


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
