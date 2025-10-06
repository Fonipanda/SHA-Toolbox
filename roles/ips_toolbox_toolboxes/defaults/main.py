---

toolboxes_component: ""
toolboxes_operation: ""
toolboxes_task_file_name: "{{ toolboxes_operation }}_{{ ansible_system }}_{{ toolboxes_component }}.yml"
toolboxes_script_mode: false
toolboxes_result_name: ""
toolboxes_tmp_directory: "/tmp/{{ toolboxes_version }}"
toolboxes_install_directory: "{{ toolboxes_install_dir | default('/apps/Deploy') }}"
toolboxes_tmp_zip: "{{ toolboxes_tmp_directory }}/toolboxes.zip"
toolboxes_zip: "{{ hostvars[inventory_hostname].ansible_env.TEMP }}\\toolboxes.zip"
toolboxes_tmp_ps1: "{{ toolboxes_tmp_directory }}/setup.ps1"
toolboxes_ps1: "{{ hostvars[inventory_hostname].ansible_env.TEMP }}\\setup.ps1"
toolboxes_json: "{{ hostvars[inventory_hostname].ansible_env.TEMP }}\\toolboxes_{{ hostvars[inventory_hostname].ansible_date_time.date }}_{{ hostvars[inventory_hostname].ansible_date_time.time | replace(':', '') }}.json"
toolboxes_tmp_powershell_version_ge_4: "{% if hostvars[inventory_hostname].ansible_powershell_version >= 4 %}true{% else %}false{% endif %}"
toolboxes_powershell_version_ge_4: "{{ toolboxes_tmp_powershell_version_ge_4 | bool }}"
toolboxes_task_continue: true
toolboxes_repo_url: ""
toolboxes_version: ""

