#!/usr/bin/python
# -*- coding: utf-8 -*-


ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}



DOCUMENTATION = r'''
---
module: win_mcafee
version_added: '2.5'
short_description: Mcafee checks.
description:
- Allow Mcafee installation checks.
- For non-Windows targets, use the M(mcafee) module instead.
options:
  action:
    description:
    - action to perform.
    - check, status, check-dat
    type: string
    version_added: "2.5"
notes:
- For non-Windows targets, use the M(mcafee) module instead.
author:
- Videau Nicolas
'''

EXAMPLES = r'''
- name: check Mcafee install
  win_mcafee:
    action: check

- name: check Mcafee dat
  win_mcafee:
    action: check-dat

- name: check Mcafee status
  win_mcafee:
    action: status

'''

RETURN = r'''
check:
    description: check of mcafee installation
    returned: when asked
    type: dict
    sample: {
        "DAT Info": {
            "content date": "20191029",
            "content time": "08:53:00",
            "content version": "3876.0",
            "engine version": "6010.8670"
        },
        "installed": "yes",
        "state": {
            "services": {
                "McAfeeFramework service": "Running"
            },
            "state": "started"
        },
        "thread prevention version": "10.6.1.1128",
        "version": "10.6.1.1068"
    }

check-dat:
    description: check dat of mcafee
    returned: when asked
    type: dict
    sample: {
        "content date": "20191029",
        "content time": "08:53:00",
        "content version": "3876.0",
        "engine version": "6010.8670"
    }
    
status:
    description: status of mcafee
    returned: when asked
    type: dict
    sample: {
        "services": {
            "McAfeeFramework service": "Running"
        },
        "state": "started"
    }
'''

