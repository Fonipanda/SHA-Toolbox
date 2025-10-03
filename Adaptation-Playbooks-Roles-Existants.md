# Adaptation des playbooks pour vos rôles ips_toolbox_* existants

## Analyse de votre playbook 02_playbook.yml

Votre playbook actuel est **fonctionnel mais monolithique**. Il contient 8 phases dans un seul fichier de 31KB, ce qui le rend difficile à maintenir et déboguer. Voici l'adaptation recommandée pour une structure modulaire avec vos rôles existants.

## Problèmes identifiés dans 02_playbook.yml

❌ **Structure monolithique** : 8 phases dans un seul fichier  
❌ **Gestion d'erreurs limitée** : pas de rescue/block robuste  
❌ **Difficile à déboguer** : impossible d'exécuter une phase isolée  
❌ **Variables mélangées** : logique métier et variables dans le même fichier  
❌ **Pas de rollback** : en cas d'échec, pas de nettoyage automatique  

## Structure cible recommandée

```
├── playbook.yml                    # Job Template unique AAP2
├── group_vars/all.yml              # Variables globales
├── inventories/
│   ├── dev/hosts
│   ├── qual/hosts
│   └── prod/hosts
└── playbooks/
    ├── operating.yml               # Phases 1-5 de votre playbook
    ├── web.yml                     # Gestion WebSphere/IHS  
    ├── database.yml                # Oracle/SQL Server
    ├── backup.yml                  # TSM/backup
    └── common.yml                  # Tâches communes
```

## 1. playbook.yml - Job Template unique

Adaptez votre playbook principal pour la détection automatique et l'orchestration :

```yaml
---
- name: "Toolbox - Workflow Complet pour Images SHA"
  hosts: "{{ target_hostname | default('all') }}"
  gather_facts: yes
  become: yes
  
  collections:
    - community.general
  
  vars:
    # Conserver vos variables AAP2 Survey existantes
    ansible_display_skipped_hosts: false
    
    # Variables dérivées (conservées de votre playbook)
    application_code_ap: "{{ codeAP }}"
    application_code_Scar: "{{ codeScar }}"
    application_name: "{{ codeAP }}_{{ id }}"
    application_url: "{{ codeAP | lower }}.yourdomain.com"
    
    # Utilisateurs techniques (conservés)
    technical_user: "{{ codeAP | lower }}\\usr"
    technical_group: "{{ codeAP | lower }}\\grp"
    
    # Variables conditionnelles OS (conservées)
    filesystem_base_apps: "{{ '/apps' if ansible_os_family != 'Windows' else 'C:\\\\apps' }}"
    filesystem_base_shared: "{{ '/shared' if ansible_os_family != 'Windows' else 'C:\\\\shared' }}"
    filesystem_base_log: "{{ '/log' if ansible_os_family != 'Windows' else 'C:\\\\log' }}"
    filesystem_base_div: "{{ '/div' if ansible_os_family != 'Windows' else 'C:\\\\div' }}"
    
    # Module par défaut si non spécifié
    toolbox_module: "{{ toolbox_module | default('auto') }}"

  pre_tasks:
    # Conserver vos pre_tasks existantes
    - name: "0.1 - Gather detailed system information"
      ansible.builtin.setup:
        gather_subset: all
      tags: always

    - name: "0.2 - Display detailed environment information"
      ansible.builtin.debug:
        msg: |
          ================================
          TOOLBOX WORKFLOW COMPLET
          Target hostname: {{ target_hostname }}
          OS Family: {{ ansible_os_family }}
          Distribution: {{ ansible_distribution }} {{ ansible_distribution_version }}
          Application: {{ application_name }}
          Module: {{ toolbox_module }}
          ================================
      tags: always

    - name: "0.3 - Verify OS compatibility"
      ansible.builtin.assert:
        that:
          - ansible_os_family in ['RedHat', 'Windows', 'AIX']
        fail_msg: |
          ERROR: Unsupported OS detected: {{ ansible_os_family }}
          Supported OS: Linux (RedHat), Windows, AIX
        success_msg: "✅ OS {{ ansible_os_family }} supported by this playbook"
      tags: always

    # NOUVEAU: Détection automatique des middlewares avec vos rôles
    - name: "Auto-detect installed middleware"
      block:
        - name: "Detect WAS Base"
          ansible.builtin.include_role:
            name: ips_toolbox_wasbase
          vars:
            wasbase_operation: "check"
          register: wasbase_detected
          ignore_errors: yes

        - name: "Detect Liberty Core"
          ansible.builtin.include_role:
            name: ips_toolbox_libertycore
          vars:
            libertycore_operation: "check"
          register: libertycore_detected
          ignore_errors: yes

        - name: "Detect WAS ND"
          ansible.builtin.include_role:
            name: ips_toolbox_wasnd
          vars:
            wasnd_operation: "check"
          register: wasnd_detected
          ignore_errors: yes

        - name: "Detect WebServer"
          ansible.builtin.include_role:
            name: ips_toolbox_webserver
          vars:
            webserver_operation: "check"
          register: webserver_detected
          ignore_errors: yes

        - name: "Detect Oracle"
          ansible.builtin.include_role:
            name: ips_toolbox_oracle
          vars:
            oracle_operation: "check"
          register: oracle_detected
          ignore_errors: yes
          when: configure_oracle_db | default(false)

        - name: "Set detected middleware facts"
          set_fact:
            detected_middleware: |
              {%- set middlewares = [] -%}
              {%- if wasbase_detected.Status | default('') == 'SUCCESS' -%}
                {%- set middlewares = middlewares + ['wasbase'] -%}
              {%- endif -%}
              {%- if libertycore_detected.Status | default('') == 'SUCCESS' -%}
                {%- set middlewares = middlewares + ['libertycore'] -%}
              {%- endif -%}
              {%- if wasnd_detected.Status | default('') == 'SUCCESS' -%}
                {%- set middlewares = middlewares + ['wasnd'] -%}
              {%- endif -%}
              {%- if webserver_detected.Status | default('') == 'SUCCESS' -%}
                {%- set middlewares = middlewares + ['webserver'] -%}
              {%- endif -%}
              {%- if oracle_detected.Status | default('') == 'SUCCESS' -%}
                {%- set middlewares = middlewares + ['oracle'] -%}
              {%- endif -%}
              {{ middlewares }}

        - name: "Auto-select modules based on detected middleware"
          set_fact:
            selected_modules: |
              {%- set modules = ['operating'] -%}
              {%- if toolbox_module == 'auto' -%}
                {%- if 'wasbase' in detected_middleware or 'libertycore' in detected_middleware or 'wasnd' in detected_middleware or 'webserver' in detected_middleware -%}
                  {%- set modules = modules + ['web'] -%}
                {%- endif -%}
                {%- if 'oracle' in detected_middleware -%}
                  {%- set modules = modules + ['database'] -%}
                {%- endif -%}
                {%- set modules = modules + ['backup'] -%}
              {%- else -%}
                {%- set modules = [toolbox_module] -%}
              {%- endif -%}
              {{ modules }}

        - name: "Display detection summary"
          debug:
            msg: |
              ========================================
              MIDDLEWARE DETECTION SUMMARY
              Detected: {{ detected_middleware }}
              Selected modules: {{ selected_modules }}
              ========================================

  tasks:
    - name: "Execute Operating module"
      include_tasks: playbooks/operating.yml
      when: "'operating' in selected_modules"
      tags: ['operating', 'system']

    - name: "Execute Web module"
      include_tasks: playbooks/web.yml
      when: "'web' in selected_modules"
      tags: ['web', 'websphere']

    - name: "Execute Database module"
      include_tasks: playbooks/database.yml
      when: "'database' in selected_modules"
      tags: ['database', 'oracle']

    - name: "Execute Backup module"
      include_tasks: playbooks/backup.yml
      when: "'backup' in selected_modules"
      tags: ['backup', 'tsm']

  post_tasks:
    # Adapter votre post_task existant
    - name: "Final installation report"
      ansible.builtin.debug:
        msg: |
          ================================
          FINAL INSTALLATION REPORT
          Target: {{ target_hostname }}
          OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
          Middlewares detected: {{ detected_middleware }}
          Modules executed: {{ selected_modules }}
          Application: {{ application_name }}
          Status: ✅ COMPLETED
          ================================
      tags: always
```

## 2. playbooks/operating.yml - Phases 1-5

Extrayez les phases 1-5 de votre playbook :

```yaml
---
# Phases 1-5 du playbook original
- name: "Operating Module Tasks"
  block:
    # Phase 1: Toolbox validation (conservée)
    - name: "Phase 1: Toolbox Validation and Update"
      tags: toolbox_validation
      block:
        - name: "1.1 - Check installed Toolbox version"
          ansible.builtin.include_role:
            name: ips_toolbox_toolboxes
          vars:
            toolboxes_operation: "check"
          register: toolbox_check
          ignore_errors: yes

        # Conserver le reste de votre Phase 1...

    # Phase 2: Auto-detection (déjà fait dans le main)
    - name: "Phase 2: Middleware detection results"
      debug:
        msg: "Middleware detection completed in main playbook"
      tags: auto_detection

    # Phase 3: SHA validation (conservée)
    - name: "Phase 3: Technical foundation (SHA) validation"
      tags: sha_validation
      block:
        - name: "3.1 - Validate TSM Client"
          ansible.builtin.include_role:
            name: ips_toolbox_tsm
          vars:
            tsm_operation: "check"
          register: tsm_check
          ignore_errors: yes

        # Conserver le reste de votre Phase 3...

    # Phase 4: Security validation (conservée)
    - name: "Phase 4: Security validation"
      tags: security_validation
      block:
        - name: "4.1 - Validate banner configuration"
          ansible.builtin.include_role:
            name: ips_toolbox_banner
          vars:
            banner_operation: "check"
          register: banner_config
          ignore_errors: yes

        # Conserver le reste de votre Phase 4...

    # Phase 5: Directory structure (conservée avec adaptation)
    - name: "Phase 5: Directory structure creation"
      tags: dir_structure
      block:
        # Conserver votre logique de création de répertoires
        - name: "Create app directories"
          file:
            path: "{{ item }}"
            state: directory
            owner: "{{ os_technical_user }}"
            group: "{{ os_technical_group }}"
          loop:
            - "{{ filesystem_base_apps }}/{{ fs_apcode }}"
            - "{{ filesystem_base_apps }}/{{ fs_apcode }}/ti"
            - "{{ filesystem_base_apps }}/{{ fs_apcode }}/to"
            - "{{ filesystem_base_apps }}/{{ fs_apcode }}/tmp"
            - "{{ filesystem_base_apps }}/{{ fs_apcode }}/arch"

        # Conserver le reste de votre Phase 5...

    # Phase 6: Filesystem creation (conservée)
    - name: "Phase 6: Filesystem creation"
      tags: fs_creation
      block:
        # Conserver votre logique de création filesystem
        - name: "Create logical volumes"
          community.general.lvol:
            vg: "{{ item.vgname }}"
            lv: "{{ item.lvname }}"
            size: "{{ item.lvsize }}"
          loop: "{{ filesystems_to_create }}"

        # Conserver le reste de votre Phase 6...

  rescue:
    - name: "Operating module error handler"
      debug:
        msg:
          - "Error occurred in Operating module"
          - "Task: {{ ansible_failed_task.name }}"
          - "Error: {{ ansible_failed_result.msg | default('Unknown error') }}"
```

## 3. playbooks/web.yml - Phase 7 WebSphere

```yaml
---
- name: "Web Module Tasks"
  block:
    - name: "7.1 Deploy application to detected middleware"
      block:
        - name: "Deploy to WAS ND"
          ansible.builtin.include_role:
            name: ips_toolbox_wasnd
          vars:
            wasnd_operation: "deploy-app"
            wasnd_xml_filename: "deploy_{{ application_name }}.xml"
            wasnd_archive_filename: "{{ application_name }}.war"
            wasnd_force_deploy: true
          register: wasnd_deploy
          when: "'wasnd' in detected_middleware"

        - name: "Deploy to WAS Base"
          ansible.builtin.include_role:
            name: ips_toolbox_wasbase
          vars:
            wasbase_operation: "deploy-app"
          register: wasbase_deploy
          when: "'wasbase' in detected_middleware"

        - name: "Deploy to Liberty Core"
          ansible.builtin.include_role:
            name: ips_toolbox_libertycore
          vars:
            libertycore_operation: "deploy-app"
          register: libertycore_deploy
          when: "'libertycore' in detected_middleware"

        - name: "Configure WebServer"
          ansible.builtin.include_role:
            name: ips_toolbox_webserver
          vars:
            webserver_operation: "configure"
          register: webserver_config
          when: "'webserver' in detected_middleware"

    - name: "Display deployment results"
      debug:
        msg: |
          ================================
          WEB MODULE DEPLOYMENT RESULTS
          WAS ND: {{ '✅ SUCCESS' if wasnd_deploy.Status | default('') == 'SUCCESS' else '❌ FAILED' }}
          WAS Base: {{ '✅ SUCCESS' if wasbase_deploy.Status | default('') == 'SUCCESS' else '❌ FAILED' }}
          Liberty Core: {{ '✅ SUCCESS' if libertycore_deploy.Status | default('') == 'SUCCESS' else '❌ FAILED' }}
          WebServer: {{ '✅ SUCCESS' if webserver_config.Status | default('') == 'SUCCESS' else '❌ FAILED' }}
          ================================

  rescue:
    - name: "Web module error handler"
      debug:
        msg:
          - "Error occurred in Web module"
          - "Task: {{ ansible_failed_task.name }}"
          - "Error: {{ ansible_failed_result.msg | default('Unknown error') }}"
```

## 4. playbooks/database.yml

```yaml
---
- name: "Database Module Tasks"
  block:
    - name: "Check Oracle installation"
      ansible.builtin.include_role:
        name: ips_toolbox_oracle
      vars:
        oracle_operation: "check"
      register: oracle_check
      when: configure_oracle_db | default(false)

    - name: "Check SQL Server (Windows)"
      ansible.builtin.include_role:
        name: ips_toolbox_sqlserver
      vars:
        sqlserver_operation: "check"
      register: sqlserver_check
      when: ansible_os_family == "Windows"

  rescue:
    - name: "Database module error handler"
      debug:
        msg:
          - "Error occurred in Database module"
          - "Task: {{ ansible_failed_task.name }}"
```

## 5. playbooks/backup.yml

```yaml
---
- name: "Backup Module Tasks"
  block:
    - name: "Execute TSM operations"
      ansible.builtin.include_role:
        name: ips_toolbox_tsm
      vars:
        tsm_operation: "backup"
      register: tsm_backup

    - name: "Execute system backup"
      ansible.builtin.include_role:
        name: ips_toolbox_backup
      vars:
        backup_operation: "execute"
      register: system_backup

  rescue:
    - name: "Backup module error handler"
      debug:
        msg:
          - "Error occurred in Backup module"
          - "Task: {{ ansible_failed_task.name }}"
```

## Configuration AAP2

### Job Template unique dans AAP2

```yaml
Nom: Toolbox - Workflow Complet BCEE
Description: Automatisation complète environnement applicatif multi-OS
Projet: Toolbox
Playbook: playbook.yml
Type: Run

Variables Extra:
  # Conserver vos variables Survey existantes
  toolbox_module: auto
  auto_detect_middleware: true
  
Survey Questions:
  1. target_hostname (text, required)
  2. codeAP (text, required, pattern: ^\d{5}$)
  3. codeScar (text, required, pattern: ^[A-Z0-9]{5}$)
  4. id (text, default: "01")
  5. fs_size4apps (integer, default: 2)
  6. configure_webserver (boolean, default: false)
  7. configure_oracle_db (boolean, default: false)

Tags disponibles:
  - operating (phases 1-6)
  - web (phase 7)
  - database (Oracle/SQL)
  - backup (TSM)
  - toolbox_validation
  - sha_validation
  - security_validation
  - fs_creation
```

## Avantages de cette adaptation

✅ **Modularité** : Chaque module peut être exécuté indépendamment  
✅ **Maintenabilité** : Code séparé par responsabilité  
✅ **Debuggage** : Possibilité d'exécuter phase par phase  
✅ **Compatibilité** : Conserve tous vos rôles ips_toolbox_* existants  
✅ **Gestion d'erreurs** : Rescue blocks dans chaque module  
✅ **Tags AAP2** : Exécution sélective des phases  
✅ **Job Template unique** : Une seule interface AAP2  
✅ **Variables Survey** : Conservation de votre logique AAP2  

## Migration progressive

1. **Tester le playbook principal** avec détection automatique
2. **Migrer phase par phase** vers les playbooks modulaires  
3. **Valider chaque module** indépendamment
4. **Configurer le Job Template** AAP2 unique
5. **Former les équipes** sur la nouvelle structure

Cette adaptation respecte votre travail existant tout en apportant la modularité et la maintenabilité nécessaires pour AAP2.