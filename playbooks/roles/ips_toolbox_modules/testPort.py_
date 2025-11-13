#!/usr/bin/python
# -*- coding: utf-8 -*-

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'Toolbox'
}

DOCUMENTATION = '''
---
module: testPort

short_description: check port connectivity
version_added: "2.5"

description:
    - "Module allowing to test connectivity for multiple destination point and port"

options:
    Destination:
        description:
            - Ip or Name of one or multiple destination point to test
        required: true
    port:
        description:
            - port to test
        required: false

author:
    - Nicolas Videau - toolbox team
'''

EXAMPLES = '''
# test port 80 on srv1
- testPort:
    destination: srv1

# test port 80 on srv1,srv2 and srv3
- testPort:
    destination: srv1, srv2, srv3

# test port 22 on srv1 and srv2
- testPort:
    destination: srv1, srv2
    port: 22

# test port 443 and 139 on srv1 and srv2
- testPort:
    destination: srv1, srv2
    port: 443, 139

# test port range between 80 and 85 on srv1 and srv2
- testPort:
    destination: srv1, srv2
    port: 80-85
  
'''

RETURN = '''
destination: 
    description: ip or name of assets tested
    type: str
port:
    description: port or range of ports tested
    type: str
testPort:
    description: results of the test
    type: list

'''

import socket, re

from ansible.module_utils.basic import AnsibleModule

#function testing the connection
def test_portConnection(destination,port=None):
    result = []
    if isinstance(destination, str): 
        destination = destination.split(',')
    if port is None:
        port = 80
    
    if isinstance(port, str): 
        if re.search('^[0-9]+\-[0-9]+$',port):
            split = port.split("-")
            port = range(int(split[0]),int(split[1])+1)
        else:    
            port = port.split(',')
    elif isinstance(port, int): 
        port = [port]    
    for dest in destination:
        tempResult = dict()
        tempResult["destination"] = dest
        for p in port:
            if isinstance(p, str): p = int(p)
            s = socket.socket()
            try:
                connection = s.connect((dest,p))
                tempResult["port "+str(p)] = True
            except Exception as e:
                tempResult["port "+str(p)] = False
            finally:
                s.close()
        result.append(tempResult)
    return result



def run_module():
    # define the available arguments/parameters that a user can pass to
    # the module
    module_args = dict(
        destination=dict(type='str', required=True),
        port=dict(type='str', required=False)
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
        destination=module.params['destination']
        
    )

    try:
        # if the user is working with this module in only check mode we do not
        # want to make any changes to the environment, just return the current
        # state with no modifications
        if module.check_mode:
            return result

        destination = module.params['destination']

        if (module.params['port'] is None) or (module.params['port'] == ""):
            result['azer'] = 1
            result['testPort'] = test_portConnection(destination)
            
        else:
            result['azer'] = 2
            port = module.params['port']
            result['port'] = port
            result['testPort'] = test_portConnection(destination,port)
            
        

        

        
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
