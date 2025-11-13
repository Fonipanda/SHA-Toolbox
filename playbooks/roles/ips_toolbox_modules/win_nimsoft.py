#!/usr/bin/python
# -*- coding: utf-8 -*-


ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}



DOCUMENTATION = r'''
---
module: win_nimsoft
version_added: '2.5'
short_description: nimsoft management.
description:
- Allow Nimsoft management and check.
- For non-Windows targets, use the M(nimsoft) module instead.
options:
  action:
    description:
    - action to perform.
    - check, status, stop, start, ...
    type: string
    required: true
    version_added: "2.5"
  policy:
    description:
    - policy to add or remove
    required: false
    type: string
    version_added: "2.5"
notes:
- For non-Windows targets, use the M(nimsoft) module instead.
author:
- Videau Nicolas
'''

EXAMPLES = r'''
- name: check Nimsoft install
  win_nimsoft:
    action: check

- name: start Nimsoft
  win_nimsoft:
    action: start

- name: get policies
  win_nimsoft:
    action: get

- name: add policies
  win_nimsoft:
    action: add

'''

RETURN = r'''
check:
    description: check of nimsoft install
    returned: when asked
    type: dict
    sample:  {
        "Agent packages deployment": {
            "_BP2I_EXPLOITATION_WINDOWS": "DEPLOYED"
        },
        "Installed": "yes",
        "Prerequisites": {
            "C:\\Programs\\Nimsoft exists": "OK",
            "C:\\Programs\\Nimsoft\\robot\\robot.cfg exists": "OK",
            "C:\\Programs\\Nimsoft\\robot\\robot.cfg is not empty": "OK",
            "Main server IP address": "10.244.214.112",
            "No robotip in 'C:\\Programs\\Nimsoft\\robot\\robot.cfg'": "INFO"
        },
        "Processes": {
            "Global status": "OK",
            "RUNNING": "11",
            "STOPPED": "0",
            "cdm.exe": "OK",
            "controller.exe": "OK",
            "dirscan.exe": "OK",
            "hdb.exe": "OK",
            "logmon.exe": "OK",
            "nimbus.exe": "OK",
            "ntevl.exe": "OK",
            "ntperf.exe": "OK",
            "ntservices.exe": "OK",
            "processes.exe": "OK",
            "spooler.exe": "OK"
        },
        "Service": {
            "Nimsoft Robot Watcher": "RUNNING"
        },
        "Version": "7.70"
    }

policy:
  description: policy informations
  returned: when needed
  type: array
  sample: [
        "AI_AP07821_CTMAGENT_8_WINDOWS",
        "M_AP03568_MCAFEE_ENS_WINDOWS",
        "M_NIMSOFT-AGENT-WINDOWS-CONF-BASE"
    ]

'''
