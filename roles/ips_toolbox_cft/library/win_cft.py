#!/usr/bin/python
# -*- coding: utf-8 -*-


ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}



DOCUMENTATION = r'''
---
module: win_cft
version_added: '2.5'
short_description: Allow request of information from cft utils.
description:
- Can be used to provide multiple informations about CFT installation.
- Check if CFT is installed and provide config.
- Provide CFT partners list.
- Get the status of CFT.
options:
  action:
    description:
    - action to perform (check, list or status).
    type: string
    required: true
    version_added: "2.5"  
notes:
- This module is only for windows targets.
author:
- Videau Nicolas
'''

EXAMPLES = r'''
- name: check if cft is intalled and provide the config
  win_cft:
    action: check

- name: get the list of partners
  win_cft:
    action: list

- name: get the status of cft installation
  win_cft:
    action: status
'''

RETURN = r'''
action:
    description: action requested
    returned: always
    type: string
    sample: check
partners:
    description: partners list
    returned: when using list action
    type: list
    sample: ["partner1", "partner2"]
check:
    description: presence or config of CFT
    returned: when using check action
    type: dict
    sample: {
        "Installed": "no"
    }
'''
