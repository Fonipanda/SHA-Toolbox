#!/usr/bin/python
# -*- coding: utf-8 -*-

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'Toolbox'
}

DOCUMENTATION = '''
---
module: oracle_tablespace

short_description: oracle tablespace's management 

version_added: "2.5"

description:
    - "module to manage oracle tablespaces, using oracle toolbox's scripts"

options:
    action: 
        description:
            - Action to perform on oracle tablespaces
        required: True
    instanceName:
        description:
            - Instance Name, owner of the tablespaces
        required: True
    tablespaceName:
        description:
            - Tablespace Name on which action will be performed
        required: False 

author:
    - NAVARRO Wilfried - toolbox team
'''

EXAMPLES = '''
#get information on all tablespaces
- name: get information
  oracle_tablespace:
    action: get
    instanceName: <instance_name>

#get information on one tablespace
- name: get information on specified tablespace
  oracle_tablespace:
    action: get
    instanceName: <instance_name>
    tablespaceName: <tablespace_name>

#create a tablespace
- name: create specified tablespace
  oracle_tablespace:
    action: create
    instanceName: <instance_name>
    tablespaceName: <tablespace_name>

#extend tablespace's datafiles
- name: create specified tablespace
  oracle_tablespace:
    action: extend
    instanceName: <instance_name>
    tablespaceName: <tablespace_name>
    dtfMaxSize: int
  
#add datafile to a tablespace
- name: add datafile to specified tablespace
  oracle_tablespace:
    action: add
    instanceName: <instance_name>
    tablespaceName: <tablespace_name>

#size a tablespace
- name: change maxsize of the specified tablespace
  oracle_tablespace:
    action: size
    instanceName: <instance_name>
    tablespaceName: <tablespace_name>
    tbsMaxSize: int
'''

RETURN = '''
action:
    description: used action
    type: str
tablespaces:
    description: depends of the action, get returns tablespaces information, create extend and add returns tablespace name
    type: dict/str
rc:
    description: return code of the script used to perform action
    type: int
message:
    description: information about the action performed
    type: str
'''

import os
import os.path
import subprocess, shlex
import re
import math

from ansible.module_utils.basic import AnsibleModule

oracleDirectory = "/apps/toolboxes/sgbd/oracle/"

tbsinfoScriptPath = oracleDirectory + "information/tbs_info.ksh"
tbsexploitScriptPath = oracleDirectory + "exploitation/tablespace/tbs_exploit.ksh"

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

##########
# Manage tablespace
################

def manage_tablespace(action,instanceName,tablespaceName,dtfMaxSize):
    if action == 'create':
        option = ' -c '
    elif action == 'extend':
        option = ' -e '
    elif action == 'size':
        option = ' -a '
    elif action == 'add':
        option = ' -a '

    if int(dtfMaxSize) != 2048 and action in ('extend','size'):
        optionextend = " -m "+str(dtfMaxSize)
    else:
        optionextend = " "

    return launch_command(tbsexploitScriptPath,"-s "+instanceName+option+tablespaceName+optionextend)

##########
# Get Tablespace's informations
#################

def get_all_info(instanceName):
    return launch_command(tbsinfoScriptPath,"-s "+instanceName+" -a")

##########
# Format stdout for tablespace's exploitation
#################

def format_expl(action,instanceName,tablespaceName,size):

    command = manage_tablespace(action,instanceName,tablespaceName,size)
    
    rc = command['returncode']
    verif_max_size = False

    messageori = re.sub('\\033\[[01];3[0123456789]m','', command['stdout'])
    frombegining,tohead = messageori.split(" tbs_exploit.ksh   ")
    if 'Syntax:' in tohead:
        tohead,rest = tohead.split("Syntax:")

    messageheadfree = re.sub('.* Version .*\n\n.*exploitation.*\n','',tohead)
    message = re.sub('\n','', messageheadfree)

    if rc == 0 and action == 'create':
        message = "Tablespace created"

    if rc == 0 and action == 'extend':
        if ' UNDO ' in message or ' TEMPORARY' in message:
           verif_max_size = True
        message = "Tablespace extended"

    if rc == 0 and action == 'add':
        if ' UNDO ' in message or ' TEMPORARY' in message:
           verif_max_size = True
        message = "Datafile added"

    if rc != 0 and 'already' in message:
        rc = 0

    return message,rc,verif_max_size

##########
# Format stdout for tablespace's informations
#################

def format_info(inst,table):

    tablespaces = dict()

    command = get_all_info(inst)

    rc = command['returncode']

    if rc != 0:
        messageori = re.sub('\\033\[[01];3[0123456789]m','', command['stdout'])
        frombegining,tohead = messageori.split(" tbs_info.ksh")
        messageheadfree = re.sub('.* Version .*\n\n.*information.*\n','',tohead)
        message = re.sub('\n','', messageheadfree)

        return tablespaces,rc,message

    command_result = re.sub('\\033\[[01];3[0123456789]m','', command['stdout'].replace('\t',' '))

    #Splitting of sdtout in order to get information according to type of data

    frombegining,infoFromTbs = command_result.split("*** Tablespace")
    tbsInfo,infoFromDatafiles = infoFromTbs.split("*** Datafiles ")
    datafilesInfo,tillEnd = infoFromDatafiles.split("*** Information about")

    #Retrieving tablespace's information

    for line in tbsInfo.split('\n'):
         if re.search('[0123456789]+',line) and 'Sum' not in line:
             if ' YES ' in line or ' NO ' in line:
                 if table is None:
                     tablespaceName,autoextend,totalTbsSpace,totalUsedSpace,totalFreeSpace,totalUsedPct,totalFreePct,tbsMaxSize,totalMaxUsedPct,totalMaxFreePct = re.sub(' +',' ',line).split(' ')
                     tablespaces[tablespaceName] = dict(
                         Autoextend=autoextend,
                         Total_tbs_space_MB=totalTbsSpace,
                         Total_used_space_MB=totalUsedSpace,
                         Total_used_pct=totalUsedPct,
                         Tbs_max_size_MB=tbsMaxSize,
                         Total_max_free_pct=totalMaxFreePct)
                 elif table is not None and re.match("^"+table+"[ ]+",line): 
                     tablespaceName,autoextend,totalTbsSpace,totalUsedSpace,totalFreeSpace,totalUsedPct,totalFreePct,tbsMaxSize,totalMaxUsedPct,totalMaxFreePct = re.sub(' +',' ',line).split(' ')
                     tablespaces[tablespaceName] = dict(
                         Autoextend=autoextend,
                         Total_tbs_space_MB=totalTbsSpace,
                         Total_used_space_MB=totalUsedSpace,
                         Total_used_pct=totalUsedPct,
                         Tbs_max_size_MB=tbsMaxSize,
                         Total_max_free_pct=totalMaxFreePct)
             else:
                 if table is None:
                     tablespaceName,totalTbsSpace= re.sub(' +',' ',line).split(' ')
                     tablespaces[tablespaceName] = dict(
                         Total_tbs_space_MB=totalTbsSpace)
                 elif table is not None and re.match("^"+table+"[ ]+",line):
                     tablespaceName,totalTbsSpace= re.sub(' +',' ',line).split(' ')
                     tablespaces[tablespaceName] = dict(
                         Total_tbs_space_MB=totalTbsSpace)

    #Retrieving datafile's information for each tablespace

    previoustablespaceName = ''
    flag = 'open'
    index = 0

    for line in datafilesInfo.split('\n'):
         if ' Status ' in line:
             flag = 'mounted'
          
         if re.search('[0123456789]+',line) and 'Sum' not in line:
             if flag == 'open' and table is None:
                 tablespaceName,datafiles,size,autoextend,maxsize,blocksize,bigfile = re.sub(' +',' ',line).split(' ')
                 if previoustablespaceName == tablespaceName:
                     index = index + 1
                 else:
                     index = 1
                 tablespaces[tablespaceName]["datafile"+str(index)] = dict(
                     File=datafiles,
                     Size_MB=size,
                     Autoextend=autoextend,
                     Maxsize_MB=maxsize,
                     Block_size_KB=blocksize,
                     Bigfile=bigfile)
                 previoustablespaceName = tablespaceName
             elif flag == 'open' and table is not None:
                 if re.match("^"+table+"[ ]+",line):
                     tablespaceName,datafiles,size,autoextend,maxsize,blocksize,bigfile = re.sub(' +',' ',line).split(' ')
                     if previoustablespaceName == tablespaceName:
                         index = index + 1
                     else:
                         index = 1
                     tablespaces[tablespaceName]["datafile"+str(index)] = dict(
                         File=datafiles,
                         Size_MB=size,
                         Autoextend=autoextend,
                         Maxsize_MB=maxsize,
                         Block_size_KB=blocksize,
                         Bigfile=bigfile)
                     previoustablespaceName = tablespaceName
             elif flag == 'mounted' and table is None:
                 tablespaceName,datafiles,size,status,blocksize,bigfile = re.sub(' +',' ',line).split(' ')
                 if previoustablespaceName == tablespaceName:
                     index = index + 1
                 else:
                     index = 1
                 tablespaces[tablespaceName]["datafile"+str(index)] = dict(
                     File=datafiles,
                     Size_MB=size,
                     Block_size_KB=blocksize,
                     Bigfile=bigfile)
                 previoustablespaceName = tablespaceName
             elif flag == 'mounted' and table is not None:
                 if re.match("^"+table+"[ ]+",line):
                     tablespaceName,datafiles,size,status,blocksize,bigfile = re.sub(' +',' ',line).split(' ')
                     if previoustablespaceName == tablespaceName:
                         index = index + 1
                     else:
                         index = 1
                     tablespaces[tablespaceName]["datafile"+str(index)] = dict(
                         File=datafiles,
                         Size_MB=size,
                         Block_size_KB=blocksize,
                         Bigfile=bigfile)
                     previoustablespaceName = tablespaceName

    message = "Information retrieved"

    return tablespaces,rc,message,int(index)

def run_module():
    # define the available arguments/parameters that a user can pass to
    # the module
    module_args = dict(
        action=dict(type='str', required=True),
        instanceName=dict(type='str', required=True),
        tablespaceName=dict(type='str', required=False),
        dtfMaxSize=dict(type='int', default=2048, required=False),
        tbsMaxSize=dict(type='int', required=False)
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
        instanceName=module.params['instanceName'],
        tablespaceName=module.params['tablespaceName'],
        message='',
    )

    try:
        # if the user is working with this module in only check mode we do not
        # want to make any changes to the environment, just return the current
        # state with no modifications
        if module.check_mode:
            return result

        noperm_changed = False
        perm_changed = False
        perm_add_file = False

        if module.params['action'] in ('get','extend','size'):
            get_changed,get_rc,message,get_index = format_info(module.params['instanceName'],module.params['tablespaceName'])

            if module.params['action'] == 'get':
                result['tablespaces'] = get_changed
                result['rc'] = get_rc
                if get_rc == 0:
                    result['message'] = ""
                elif get_rc != 0:
                    result['message'] = message

            if module.params['action'] == 'size' and get_changed != {}:
                dtfMaxSize = int(math.ceil(float(module.params['tbsMaxSize']) / int(get_index)))
                if dtfMaxSize > 32768:
                    dtfMaxSize = 32768
            elif module.params['action'] == 'extend' and module.params['dtfMaxSize'] is not None:
                dtfMaxSize = int(module.params['dtfMaxSize'])
 
            #do not display an error message if specified tablespace does not exist
            #if get_rc == 0 and get_changed == {}:
            #    result['failed'] = True
            #    result['message'] = "Tablespace "+module.params['tablespaceName']+" does not exist"
            #    result['rc'] = 2

            if module.params['action'] in ('extend','size'):
                if get_rc == 0 and get_changed != {}:
                    for key, value in get_changed[module.params['tablespaceName']].items():
                        if key == 'Tbs_max_size_MB':
                            ActualTbsMaxSize = int(value)
                        if isinstance(value, dict):
                            for sub_key, sub_value in value.items():
                                if sub_key == 'Autoextend' and sub_value == 'NO':
                                    result['changed'] = True
                                if sub_key == 'Size_MB':
                                    size_value = sub_value
                                if sub_key == 'Bigfile':
                                    if sub_value == 'YES':
                                        unlimitedValue = 33554432
                                    elif sub_value == 'NO':
                                        unlimitedValue = 32768
                                        perm_add_file = True
                                if sub_key == 'Maxsize_MB' and int(size_value) > int(dtfMaxSize) and int(sub_value) != int(size_value):
                                    noperm_changed = True
                                elif sub_key == 'Maxsize_MB' and int(size_value) < int(dtfMaxSize) and int(sub_value) != int(dtfMaxSize):
                                    noperm_changed = True
                                if sub_key == 'Maxsize_MB' and int(sub_value) < int(unlimitedValue):
                                    perm_changed = True

        if module.params['action'] in ('create','extend'):
            result['message'],result['rc'],get_verifmaxsize = format_expl(module.params['action'],module.params['instanceName'],module.params['tablespaceName'],module.params['dtfMaxSize'])

            if result['rc'] == 0 and module.params['action'] == 'create' and 'already' in result['message']:
                result['changed'] = False
                result['message'] = "Tablespace created"

            elif result['rc'] == 0 and module.params['action'] in ('create','add'):
                result['changed'] = True

            elif result['rc'] != 0 and module.params['action'] == 'extend':
                result['changed'] = False 

            elif noperm_changed and get_verifmaxsize:
                result['changed'] = True

            elif perm_changed and not get_verifmaxsize:
                result['changed'] = True

        if module.params['action'] == 'size' and get_rc == 0 and get_changed != {}:
            if perm_add_file:
                if ActualTbsMaxSize < int(module.params['tbsMaxSize']):
                    new_index = 0
                    result['failed'] = False
                    result['rc'] = 0
                    while get_index < int(math.ceil(float(float(module.params['tbsMaxSize']) / 32768))):
                        add_message,add_rc,add_verifmaxsize = format_expl('add',module.params['instanceName'],module.params['tablespaceName'],2048)
                        if add_rc != 0 and int(new_index) != 0:
                            result['changed'] = True
                            result['failed'] = True
                            if new_index == 1:
                                result['message'] = add_message+" "+str(new_index)+" file added"
                            else:
                                result['message'] = add_message+" "+str(new_index)+" files added"
                            result['rc'] = add_rc
                            break
                        elif add_rc != 0 and int(new_index) == 0:
                            result['failed'] = True
                            result['message'] = add_message+" No file added"
                            result['rc'] = add_rc
                            break
                        result['failed'] = False
                        result['changed'] = True
                        new_index = new_index + 1
                        get_index = get_index + 1

                    if not result['failed']:
                        NewTbsMaxSize = int(get_index) * 32768
                        result['message'] = "Tbs max size is "+str(NewTbsMaxSize)+"M"
                        dtfMaxSize = int(module.params['tbsMaxSize'] / int(get_index))
                        extend_message,result['rc'],get_verifmaxsize = format_expl('extend',module.params['instanceName'],module.params['tablespaceName'],int(dtfMaxSize))
                        
                        if result['rc'] != 0:
                            result['changed'] = False 
                            result['message'] = extend_message
                        elif noperm_changed and get_verifmaxsize:
                            result['changed'] = True
                            result['message'] = "Tbs max size is "+str(module.params['tbsMaxSize'])+"M"
                        elif perm_changed and not get_verifmaxsize:
                            result['changed'] = True
                            

                else:
                    result['rc'] = 0
                    result['message'] = "Tbs max size is "+str(ActualTbsMaxSize)+"M"
            else:
                result['message'] = "unable to add datafile to a bigfile tablespace"
                result['failed'] = True
                result['rc'] = 2
            
        elif module.params['action'] == 'size' and get_rc == 0 and get_changed == {}:
            result['failed'] = True
            result['rc'] = 2
            result['message'] = "Tablespace "+module.params['tablespaceName']+" does not exist! "


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
