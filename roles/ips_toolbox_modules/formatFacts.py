#!/usr/bin/python

from ansible.module_utils.basic import *

def main():

    module_args = dict(
      name      = dict(type='str', required=True, choices=["results","rules"]),
      state     = dict(type='str', required=False),
      item      = dict(type='str', required=False),
      value     = dict(type='str', required=False),
      component = dict(type='str', required=False),
      status    = dict(type='str', required=False, choices=["KO","OK"]),
      test      = dict(type='str', required=False),
      itrule    = dict(type='str', required=False),
      product   = dict(type='str', required=False)
    )

    module = AnsibleModule(
        argument_spec=module_args,
        required_if=(
          ['name','results',['state','item','value','component','status']],
          ['name','rules',['test','item','itrule','product','status']]
        ),
        supports_check_mode=False
    )
    
    if module.params['name'] == "results":
        facts  = {
            "state"     : module.params["state"],
            "item"      : module.params["item"],
            "value"     : module.params["value"],
            "component" : module.params["component"],
            "status"    : module.params["status"]
        }
    elif module.params['name'] == "rules":
        facts = {
            "item"    : module.params["item"],
            "test"    : module.params["test"],
            "itrule"  : module.params["itrule"],
            "product" : module.params["product"],
            "status"  : module.params["status"]
        }
    
    module.exit_json(changed=False, ansible_facts={ module.params['name']: facts })


#########
# START #
#########

if __name__ == '__main__':
    main()
