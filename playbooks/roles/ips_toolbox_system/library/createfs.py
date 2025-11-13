#!/usr/bin/python
# -*- coding: utf-8 -*-

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'check': ['preview'],
    'supported_by': 'Toolbox'
}

DOCUMENTATION = '''
---
module: createfs

short_description:  

version_added: "2.5"

description:
    - "module to create filesystem and create guardpoint"

options:
    file:
        description:
            - Path and filename to configure for filesystem creation

author:
    - NAVARRO Wilfried - toolbox team
'''

EXAMPLES = '''

#create fs accordiong to /apps/toolboxes/exploit/conf/exploit_create-fs.conf
- name: create filesystems
  createfs:
    file: "/apps/toolboxes/exploit/conf/exploit_create-fs.conf"
'''

RETURN = '''
file:
    description: file used to create filesystems
    type: str
list_fs:
    description: list of filesystem to be created
    type: list
state:
    description: information about the status of filesystems
    type: dict
       creation:
           description: indicates if filesystem was created or not
           type: str
       guard point:
           description: indicates if filesystem was guraded or not
           type: str
message:
    description: information about tbx version and warning information
    type: str or list
'''


import os
import os.path
import subprocess, shlex
import re
import math

from distutils.version import StrictVersion
from ansible.module_utils.basic import AnsibleModule

vormetricDirectory = "/apps/vormetric/"
toolboxBinDirectory = "/apps/toolboxes/exploit/bin/"
CreatefsScript = toolboxBinDirectory + "exploit_create-fs.ksh"

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


def launch_createfs_script(conf_file):
    command = dict()
    command = launch_command(CreatefsScript, "conf=" + conf_file)

    return command


##########
# Get version tbx
#################

def version_tbx():
    fichier = "/apps/toolboxes/version"
    value = "1.2.3"

    if os.path.exists(fichier):
        line = open(fichier,"r").readline()
        value = line.split('|')[1]

    return StrictVersion(value) >= StrictVersion('19.1.2')

##########
# guarded directory
#################

def guarded_fs(file):
    read_file = open(file, "r")
    info = False
    tbx_version_min = True

    if ':DATA' in read_file.read() or ':LOG' in read_file.read():
        info = True
        if not version_tbx():
            tbx_version_min = False

    read_file.close()

    return info,tbx_version_min


##########
# check guarpoint
#################

def isguarded(fs):
    value = "not guarded"

    try:
        cmd = launch_command('secfsd', "-status guard -v")

        for paraf in cmd['stdout'].split('\n\n'):
            if paraf != "":
                if 'Directory:' in paraf and fs + '\n' in paraf: 
                    for line in paraf.split('\n'):
                        if 'Status:' in line:
                            value = line.split(':')[1].strip()

    except Exception:
        pass

    finally:
        return value


##########
# fs creation information
#################

def fs_creation(fs,output,vorminfo):

    result = dict()
    changed = False
    result['creation'] = "not created"

    for line in output.split('\n'):
        if "-I- FS " + fs + " guarded" in line:
            changed = True
        if "-I- Creation du FS " + fs in line:
            if os.path.ismount(fs):
                changed = True

    if os.path.ismount(fs):
        result['creation'] = "created"

    if vorminfo:
        result['guard point'] = isguarded(fs)

    return changed,result


def run_module():
    # define the available arguments/parameters that a user can pass to
    # the module
    module_args = dict(
        file=dict(type='str', required=False)
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
        file=module.params['file']
    )

    try:
        # if the user is working with this module in only check mode we do not
        # want to make any changes to the environment, just return the current
        # state with no modifications
        if module.check_mode:
            return result

        confile = module.params['file']
        list_message = list()

        if not os.path.exists(confile):
            raise Exception("configuration file " + confile + " does not exist") 
    
        vorminfo,tbx_version = guarded_fs(confile)

        if vorminfo:
            if not os.path.exists(vormetricDirectory) and not tbx_version:
                list_message.append("No vormetric on server")
                list_message.append("Too low toolbox version to guard filesystems (19.1.2 required)")
            elif not os.path.exists(vormetricDirectory) and tbx_version:
                list_message.append("No vormetric on server")
            elif os.path.exists(vormetricDirectory) and not tbx_version:
                list_message.append("Too low toolbox version to guard filesystems (19.1.2 required)")

        result['state'] = dict()
        list_fs = list()
        list_changed = list()

        command = launch_createfs_script(confile)

        readconfile = open(confile, "r")

        for line in readconfile.readlines():
            fsname = line.split(':')[2]
            list_fs.append(fsname)
            changed,result['state'][fsname] = fs_creation(fsname,command['stdout'],vorminfo)
            list_changed.append(changed)

        readconfile.close()

        if True in list_changed:
            result['changed'] = True
        
        result['list_fs'] = list_fs

        if command['returncode'] != 0:

            for lines in command['stdout'].split('\n'):
                if '-E-' in lines:
                    message1 = re.compile(r'\x1b[^m]*m').sub('', lines)
                    message = re.sub('-E- ', '', message1)

                    raise Exception(message)
            
            raise Exception("Error while creating filesystems")

        else:
            previous_lines = ""
            for lines in command['stdout'].split('\n'):
                if '-W-' in lines and 'existe deja' not in previous_lines and 'deja' not in lines:
                    warnmessage1 = re.compile(r'\x1b[^m]*m').sub('', lines)
                    warnmessage = re.sub('-W- ', '', warnmessage1)
                    if warnmessage not in list_message:
                        list_message.append(warnmessage)
                previous_lines = lines

        if len(list_message) == 1:
            result['message'] = list_message[0]
        elif len(list_message) > 1:
            result['message'] = list_message
            

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

