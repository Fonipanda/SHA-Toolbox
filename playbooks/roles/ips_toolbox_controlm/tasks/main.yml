---

- set_fact:
    controlm_component: "{{ role_name.split('_')[-1] }}"
    controlm_role_name: "{{ role_name }}"

- name: include tasks operation

  block:

  - local_action: stat path={{ role_path }}/tasks/{{ controlm_task_file_name }}
    become: no
    register: statResult
    failed_when: statResult.stat.exists == false

  - include_tasks: "{{ controlm_task_file_name }}"
    when: statResult.stat.exists

  rescue:

  - name: set result failed operation
    include_role:
      name: ips_toolbox_set_results
    vars:
      set_results_state: "info"
      set_results_item: ""
      set_results_component: "{{ controlm_component }}"
      set_results_operation: "{{ controlm_operation }}"
      set_results_role_name: "{{ controlm_role_name }}"
      set_results_status: "KO"
      set_results_value: "\

        {% if statResult.stat.exists == false %}\

          task {{ controlm_task_file_name }} does not exist\

        {% else %}\

          task execution error\

        {% endif %}"
