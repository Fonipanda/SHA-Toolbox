---


oracle_component: ""
oracle_operation: ""
oracle_item: ""
oracle_tablespace: ""
oracle_tablespace_maxsize: ""
oracle_ref: "no"
oracle_task_file_name: "{{ oracle_operation }}_{{ ansible_system }}_{{ oracle_component }}.yml"
oracle_script_mode: false
oracle_result_name: "result"
oracle_type_backuporacle: "{{ oracle_type_bo | default('hot') }}"
oracle_retention_backuporacle: "{{ oracle_retention_bo | default('30') }}"
oracle_level_backuporacle: "{{ oracle_level_bo | default('0') }}"
oracle_archive_class: "{% if oracle_retention_backuporacle == '30' %}\

                        ARCH01M\

                       {% elif oracle_retention_backuporacle == '90' %}\

                        ARCH03M\

                       {% endif %}"

