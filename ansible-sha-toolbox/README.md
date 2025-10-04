# Projet Create Socle: Standardisation VM & Toolbox

Ce dépôt Ansible permet de créer de manière *standardisée* des VM/VSI en s'appuyant uniquement sur des *toolboxes* préinstallées. Aucune installation externe n'est nécessaire.

## Structure du projet
create_socle/
├── ansible.cfg
├── group_vars/
│ └── all.yml
├── inventories/
│ ├── dev/
│ │ ├── hosts
│ │ └── group_vars/all.yml
│ ├── qual/
│ └── prod/
├── vars/
│ └── aap2_survey.yml
├── playbooks/
│ ├── operating.yml
│ ├── web.yml
│ ├── database.yml
│ └── backup.yml
├── roles/
│ ├── ips_toolbox_system/
│ ├── ips_toolbox_appli/
│ ├── ips_toolbox_nimsoft/
│ ├── ...
│ └── ips_toolbox_set_results/
├── 03_playbook.yml
└── README.md
