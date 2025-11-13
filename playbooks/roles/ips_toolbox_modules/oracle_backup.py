#!/usr/bin/python
# -*- coding: utf-8 -*-

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'Toolbox'
}

DOCUMENTATION = '''
---
module: oracle_backup

short_description: Manage Oracle backup (TSM)

version_added: "2.5"

description:
    - "module to manage Oracle backup"

options:
    action:
        description:
            - Action to perform
        required: True
    
    instanceName:
        description:
            - Name of the backed up instance
        required: False
    
    retention:
        description:
            - TSM retention (days for archive/BKP for backup)
        required: False
    
    keyword:
        description:
            - keyword present in ENVOI_TSM.in to send on TSM
        required: False

author:
    - NAVARRO Wilfried - toolbox team
'''

EXAMPLES = '''
# Send all oracle backupsets according to ENVOI_TSM.in/ENVOI_TSM.out
- name: Send everything to TSM
  oracle_backup:
    - action: tsm-backup

# Send every retention of SYS1FRX0's backupsets on TSM according to ENVOI_TSM.in/ENVOI_TSM.out
- name: Send everything to TSM
  oracle_backup:
    - action: tsm-backup
    - instanceName: SYS1FRX0
    
# Send SYS1FRX0's backupsets with retention 90J on TSM according to ENVOI_TSM.in/ENVOI_TSM.out
- name: Send everything to TSM
  oracle_backup:
    - action: tsm-backup
    - instanceName: SYS1FRX0
    - retention: 90

# Send backupsets with keyword SYS1FRX0_BKP on TSM according to ENVOI_TSM.in/ENVOI_TSM.out
- name: Send everything to TSM
  oracle_backup:
    - action: tsm-backup
    - keyword: SYS1FRX0_BKP
   
# Configure bt_sauvegarde.conf file to allow backup of SYS1FRX0 with retention of 30 days on TSM
- name: Configure backup for instance SYS1FRX0
  oracle_backup:
    - action: configure
    - instanceName: SYS1FRX0
    - retention: 30
    
# Configure bt_sauvegarde.conf file to allow backup of SYS1FRX0 and backup backupsets on TSM
- name: Configure backup for instance SYS1FRX0
  oracle_backup:
    - action: configure
    - instanceName: SYS1FRX0
    - retention: BKP

'''

RETURN = '''
action:
    description: used action
    type: str

message:
    description: information about TSM command
    type: liste
'''

import subprocess, shlex
import re
import fileinput
import shutil
from datetime import datetime


from ansible.module_utils.basic import AnsibleModule

btsauve_path = "/apps/toolboxes/backup_restore/scripts/"
btsauve_script = btsauve_path + "btsauve.ksh"

file_envoi_in = '/apps/orafra/ENVOI_TSM.in'
file_envoi_out = '/apps/orafra/ENVOI_TSM.out'
file_btsauvegarde = '/apps/toolboxes/backup_restore/conf/bt_sauvegarde.conf'

##########
# Command execution
#################

def launch_oracle_command(executable_path, args):
    result = dict()

    result['returnedObject'] = subprocess.Popen(". ~oracle/.profile;" + executable_path + " " + args,
                                                shell=True,
                                                stdout=subprocess.PIPE,
                                                stderr=subprocess.PIPE)
    stdout, stderr = result['returnedObject'].communicate()
    result['stdout'] = stdout
    result['stderr'] = stderr
    result['returncode'] = result['returnedObject'].wait()
    return result


def launch_root_script(executable_path, args):
    result = dict()

    result['returnedObject'] = subprocess.Popen(shlex.split(executable_path + " " + args),
                                                stdout=subprocess.PIPE,
                                                stderr=subprocess.PIPE)
    stdout, stderr = result['returnedObject'].communicate()
    result['stdout'] = stdout
    result['stderr'] = stderr
    result['returncode'] = result['returnedObject'].wait()
    return result


def launch_root_command(executable_path, args):
    result = dict()

    result['returnedObject'] = subprocess.Popen(executable_path + " " + args,
                                                shell=True,
                                                stdout=subprocess.PIPE,
                                                stderr=subprocess.PIPE)
    stdout, stderr = result['returnedObject'].communicate()
    result['stdout'] = stdout
    result['stderr'] = stderr
    result['returncode'] = result['returnedObject'].wait()
    return result

def verif_param(instanceName, keyword, retention):
    new_keyword = None
    if instanceName != None:
        if instanceName == "all":
            instanceName = None

        if keyword != None:
            raise Exception("You can't specify both instanceName and keyword parameters")

        if retention == "BKP":
            new_keyword = instanceName + "_" + retention
        elif retention != None and re.match("(7|30|90|180|365|730|1095|1460|1825|3650)$", retention):
            new_keyword = instanceName + "_" + retention + "J"
        elif retention != None and not re.match("(7|30|90|180|365|730|1095|1460|1825|3650|BKP)$", retention):
            raise Exception("Invalid retention parameter " + retention)
        elif retention == None:
            new_keyword = instanceName
    else:
        if keyword != None and retention != None:
            raise Exception("You can't specify both keyword and retention parameters")
        elif keyword == None and retention != None:
            raise Exception("You can't specify retention parameter without instanceName parameter")
        elif keyword != None and retention == None:
            new_keyword = keyword

    return new_keyword


def Keywordtosend(keyword=None):
    ENVOITSMIN = open(file_envoi_in, "r")
    list_envoi = []

    for linesin in ENVOITSMIN.readlines():
        presence = False
        ENVOITSMOUT = open(file_envoi_out, "r")
        for linesout in ENVOITSMOUT.readlines():
            if re.match("^" + re.sub('\n', '', linesin) + ".*;OK$", re.sub('\n', '', linesout)):
                presence = True
                ENVOITSMOUT.close()
                continue

        if presence == False and re.sub('\n', '', linesin.split(";")[-1]) not in list_envoi:
            if keyword != None and "_" not in keyword and re.match("^" + keyword + "_.*", re.sub('\n', '', linesin.split(";")[-1])):
                list_envoi.append(re.sub('\n', '', linesin.split(";")[-1]))
            elif keyword != None and "_" in keyword and re.match("^" + keyword, re.sub('\n', '', linesin.split(";")[-1])):
                list_envoi.append(keyword)
            elif keyword == None:
                list_envoi.append(re.sub('\n', '', linesin.split(";")[-1]))

    ENVOITSMIN.close()
    return list_envoi

def Checkbtsauvegarde(instance, retention):
    BtConfFile = open(file_btsauvegarde, "r")

    presence = False
    for linesin in BtConfFile.readlines():
        if re.match("(7|30|90|180|365|730|1095|1825|3650)$", retention):
            keyword = instance + "_" + retention + "J"
            if re.match("^archive;ListOra;" + instance + "_" + retention + "J.*", linesin):
                presence = True
                BtConfFile.close()
                break
        elif retention == 'BKP':
            keyword = instance + "_" + retention
            if re.match("^backup_rep;ListOra;" + instance + "_" + retention + ";.*", linesin):
                presence = True
                BtConfFile.close()
                break
        else:
            BtConfFile.close()
            raise Exception("Invalid retention parameter " + retention)

    BtConfFile.close()
    return presence, linesin, keyword


def replaceArchClass(instance, DefArchClass, ArchClass):
    changed = False
    DATE = datetime.now()
    shutil.copy("/apps/toolboxes/backup_restore/conf/bt_sauvegarde.conf", "/apps/toolboxes/backup_restore/conf/bt_sauvegarde.conf_TBXNG_" + str(DATE.strftime("%d%m%Y_%I%M%S")) )
    try:
        for line in fileinput.input("/apps/toolboxes/backup_restore/conf/bt_sauvegarde.conf", inplace=True):
            if DefArchClass in line and instance in line:
                changed = True
                print "%s" % (re.sub(DefArchClass, ArchClass, re.sub('\n', '', line)))
            else:
                print "%s" % (re.sub('\n', '', line))
    except Exception as err:
        shutil.move("/apps/toolboxes/backup_restore/conf/bt_sauvegarde.conf_TBXNG_" + str(DATE.strftime("%d%m%Y_%I%M%S")), "/apps/toolboxes/backup_restore/conf/bt_sauvegarde.conf")
        raise err
    else:
        return changed

def addconfigline(retention, keyword, dict_Arch):
    BtConfFile = open("/apps/toolboxes/backup_restore/conf/bt_sauvegarde.conf", "a")
    DATE = datetime.now()
    shutil.copy("/apps/toolboxes/backup_restore/conf/bt_sauvegarde.conf", "/apps/toolboxes/backup_restore/conf/bt_sauvegarde.conf_TBXNG_" + str(DATE.strftime("%d%m%Y_%I%M%S")) )
    try:
        if retention == 'BKP':
            BtConfFile.write("backup_rep;ListOra;" + keyword + ";verbose;defaut;defaut;defaut;defaut\n")
        else:
            ArchClassExist = dict_Arch[retention]
            BtConfFile.write("archive;ListOra;" + keyword + ";defaut;defaut;" + ArchClassExist + ";defaut;defaut\n")
    except Exception as err:
        shutil.move("/apps/toolboxes/backup_restore/conf/bt_sauvegarde.conf_TBXNG_" + str(DATE.strftime("%d%m%Y_%I%M%S")), "/apps/toolboxes/backup_restore/conf/bt_sauvegarde.conf")
        raise err
    finally:
        BtConfFile.close()


def CheckTSMBinaries():
    absent = False
    cmd = launch_root_command('dsmc', "qu mgmt")

    if cmd['returncode'] == 127:
        absent = True

    return absent


def CheckArchClass():
    dict_BAA1 = {'90': 'BAA_3M'}
    dict_BAA2 = {'90': 'BAA_3M', '180': 'BAA_6M'}
    dict_BAA3 = {'90': 'BAA_3M', '180': 'BAA_6M', '365': 'BAA_1Y'}
    dict_ARCH_reg = {'7': 'ARCH01W', '30': 'ARCH01M', '90': 'ARCH03M', '180': 'ARCH06M', '365': 'ARCH01Y', '730': 'ARCH02Y',
                     '1095': 'ARCH03Y', '1825': 'ARCH05Y', '3650': 'ARCH10Y'}
    dict_ARCH_bas = {'7': 'ARCH01W', '30': 'ARCH01M', '90': 'ARCH03M', '180': 'ARCH06M', '365': 'ARCH01Y'}

    result_command = launch_root_command('dsmc', "qu mgmt | awk -F ': ' '{print $2}' | grep -E '^ARCH|^BAA_' | grep -E '[A-Z]$' | grep -Ev 'ARCH.*_|AN'")

    if 'BAA_3M' in result_command['stdout'].split('\n'):
        if 'BAA_1Y' in result_command['stdout'].split('\n'):
            dictArch = dict_BAA3
        elif 'BAA_1Y' not in result_command['stdout'].split('\n') and 'BAA_6M' in result_command['stdout'].split('\n'):
            dictArch = dict_BAA2
        else:
            dictArch = dict_BAA1
    else:
        if 'ARCH10Y' in result_command['stdout'].split('\n'):
            dictArch = dict_ARCH_reg
        else:
            if 'ARCH01M' in result_command['stdout'].split('\n'):
                dictArch = dict_ARCH_bas
            else:
                raise Exception("Unable to find TSM management class") 

    return dictArch


def CheckInstance(instance):
    oratab = open("/etc/oratab", "r")
    presence = False

    try:
        for linesin in oratab.readlines():
            if re.match("^" + instance + ":.*:.*", linesin):
                    presence = True
                    oratab.close()
                    break
        oratab.close()
    except Exception:
        oratab.close()
        raise Exception("Error while checking instance " + instance + " in /etc/oratab")

    if not presence:
        raise Exception("No instance " + instance + " in /etc/oratab")


##########
# Main
#################

def run_module():
    # define the available arguments/parameters that a user can pass to
    # the module

    module_args = dict(
        action=dict(type='str', required=True),
        keyword=dict(type='str', required=False, default=None),
        instanceName=dict(type='str', required=False, default=None),
        retention=dict(type='str', required=False, default=None)
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

        if CheckTSMBinaries():
            raise Exception("No TSM binaries")

        if module.params['action'] == 'tsm-backup':
            newkeyword = verif_param(module.params['instanceName'], module.params['keyword'], module.params['retention'])

            list_keyword = []
            message = []

            for keyword in Keywordtosend(newkeyword):
                if re.match(".*_BKP", keyword):
                    list_keyword.append("backup_rep " + keyword)
                elif re.match(".*_(7|30|90|180|365|730|1095|1825|3650)J", keyword):
                    list_keyword.append("archive " + keyword)
                else:
                    raise Exception("Invalid keyword " + keyword)

            if list_keyword != []:
                for args in list_keyword:
                    result_command = launch_root_script(btsauve_script, args)
                    result['changed'] = True
                    if result_command['returncode'] != 0:
                        result['failed'] = True
                        message.append("btsauve.ksh " + args + " command : KO (CR=" + str(result_command['returncode']) +")")
                    else:
                        message.append("btsauve.ksh " + args + " command : OK (CR=" + str(result_command['returncode']) + ")")
                result['message'] = message
            else:
                result['message'] = "Nothing to send on TSM"

        if module.params['action'] == 'configure':
            CheckInstance(module.params['instanceName'])
            presence, line, keyword = Checkbtsauvegarde(module.params['instanceName'], module.params['retention'])
            dict_Arch = CheckArchClass()

            if module.params['retention'] != 'BKP' and module.params['retention'] not in dict_Arch.keys():
                raise Exception("No archive class for retention " + module.params['retention'] + " on this server")

            if presence:
                if module.params['retention'] != 'BKP':

                    ArchClassExist = dict_Arch[module.params['retention']]
                    ArchClassDefine = line.split(';')[5]

                    if ArchClassDefine != ArchClassExist:
                        result['changed'] = replaceArchClass(module.params['instanceName'], ArchClassDefine, ArchClassExist)
                        result['message'] = "replace " + ArchClassDefine + " by " + ArchClassExist + " in bt_sauvegarde.conf file for instance " + module.params['instanceName'] + " and retention " + module.params['retention']
                    else:
                        result['message'] = "bt_sauvegarde.conf file already configured for instance " + module.params['instanceName'] + " and retention " + module.params['retention']
                else:
                    result['message'] = "bt_sauvegarde.conf file already configured for instance " + module.params['instanceName'] + " and retention " + module.params['retention']
            else:
                result['changed'] = True
                addconfigline(module.params['retention'], keyword, dict_Arch)
                result['message'] = "Add configuration line in bt_sauvegarde.conf file for instance " + module.params['instanceName'] + " and retention " + module.params['retention']

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
