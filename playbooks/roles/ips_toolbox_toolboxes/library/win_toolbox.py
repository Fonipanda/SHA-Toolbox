#!/usr/bin/python
# -*- coding: utf-8 -*-

#!/usr/bin/python
# -*- coding: utf-8 -*-

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'check': ['preview'],
    'supported_by': 'Toolbox'
}

DOCUMENTATION = '''
---
module: Toolbox

short_description: Toolbox management

version_added: "2.5"

description:
    - "module to manage Toolbox"

options:
  action:
      description:
          - Action to perform on Toolbox
      required: True

  version:
      description:
          - Version to compare to current installed version
      required: False

author:
    - NAVARRO Wilfried - toolbox team
    - GRIVOT Sylvain - toolbox team
'''

EXAMPLES = '''
#get versions of Toolboxes
- name: get information
  toolbox:
    action: check

#verify if current installed version is greater than 19.1.0
- name: get information
  toolbox:
    action: compare
    version: 19.1.0

'''

RETURN = '''
action:
    description: used action
    type: str

check:
    description: installed/version
    type: dict
       installed:
           description: indicates if Toolbox is installed or not
           type: str
       version:
           description: version of Toolbox
           type: str

greater:
    description: indicates if current installed version of toolbox is greater or not to parameter version
    type: boolean

compared_version
    description: minimum version of toolbox required
    type: str

installed_version
    description: version of installed Toolbox
    type: str

'''
