#!/usr/bin/python
# -*- coding: utf-8 -*-


ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}



DOCUMENTATION = r'''
---
module: win_ara
version_added: '2.5'
short_description: Nolio agent management.
description:
- Management of Nolio agent.
- Check installation
- Change Status of nolioagent service
options:
  action:
    description:
    - Check, start, stop or restart.
    type: string
    required: true
    version_added: "2.5"
notes:
- Only for windows target.
author:
- Videau Nicolas
'''

EXAMPLES = r'''
- name: Check nolioagent
  win_ara:
    action: check

- name: Start nolioagent
  win_ara:
    action: start

- name: Stop nolioagent
  win_ara:
    action: stop

- name: Restart nolioagent
  win_ara:
    action: restart
'''

RETURN = r'''
check:
    description: information on Nolio installation
    returned: on demand
    type: dict
    sample: {
        "Installed": "yes",
        "ServiceName": "nolioagent2",
        "Version": "5.5.2.191",
        "state": "started"
    }
'''
