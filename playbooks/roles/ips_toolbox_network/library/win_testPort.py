#!/usr/bin/python
# -*- coding: utf-8 -*-


ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}



DOCUMENTATION = r'''
---
module: win_testPort
version_added: '2.5'
short_description: Test connection between the host and a destination point.
description:
- Module testing TCP connection between the host and one or more destination.
- Can use a single port, multiple Ports or a range
- For non-Windows targets, use the M(testPort) module instead.
options:
  destination:
    description:
    - Ip or name of one or more asset to reach.
    - Use comma to separate multiple destination
    type: string
    required: true
    version_added: "2.5"
  port:
    description:
    - one or more ports or a range to test for connection.
    - use comma for multiple ports
    - use dash as separator for a range
    type: string
    default: '80'
    version_added: "2.5"
notes:
- For non-Windows targets, use the M(testPort) module instead.
- Currently win_testPort does not support UDP connection
author:
- Videau Nicolas
'''

EXAMPLES = r'''
- name: check if port 80 is open with server1
  win_testPort:
    destination: server1

- name: check if port 22 is open with server1 and server2
  win_testPort:
    destination: server1, server2
    port: 22

- name: check if port 22 and 443 are open with server1
  win_testPort:
    destination: server1
    port: 22,443


- name: check if ports on range 80 to 85 are open with server1
  win_testPort:
    destination: server1
    port: 80-85
'''

RETURN = r'''
destination:
    description: destination(s) provided for the test
    returned: always
    type: string
    sample: server1
port:
    description: port(s) used for the test
    returned: always
    type: string
    sample: 80
results:
    description: object containing all tests details
    returned: always
    type: string
    sample: [
        {
            "Destination": "s00v09943796",
            "Port 80": "False",
            "Port 82": "False"
        },
        {
            "Destination": "s00vl9925220",
            "Port 80": "True",
            "Port 82": "False"
        }
    ]
'''
