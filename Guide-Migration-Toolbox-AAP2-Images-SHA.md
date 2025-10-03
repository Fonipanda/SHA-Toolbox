# Guide de Migration Toolbox vers AAP2

## Vue d'ensemble

Ce document présente la procédure complète pour adapter le dépôt Toolbox à votre environnement Ansible Automation Platform 2 (AAP2) existant. Cette Toolbox est conçue pour fonctionner avec les **images SHA (Socle d'Hébergement Applicatif)** standardisées de votre organisation, qui contiennent les OS et middlewares pré-installés.

## Architecture des images SHA

### Images SHA standardisées
Les machines cibles utilisent des **images SHA pré-configurées** contenant :
- **OS standardisé** : RHEL avec configuration organisationnelle
- **Middlewares pré-installés** : WebSphere, Oracle, TSM, Nimsoft, CFT, MQ, etc.
- **Structure de répertoires** : Arborescence SHA standardisée
- **Utilisateurs et permissions** : Configuration `sesu` organisationnelle

### Configuration actuelle détectée
```yaml
# Votre ansible.cfg
[defaults]
stdout_callback = yaml
bin_ansible_callbacks = True

# Vos inventaires
Environnements: dev (HORSPROD), qual (ISOPROD), prod (PROD)
Serveurs: sXXvlXXXXXXX.fr.net.intra
Élévation: ansible_become_method: sesu, ansible_become_flags: "-"
```

## Workflow technique - Job Template unique

[56]

Le Job Template unique **"Toolbox - Workflow Complet"** exécute automatiquement :

1. **Détection automatique** des middlewares installés sur l'image SHA
2. **Sélection dynamique** des modules selon les composants détectés
3. **Exécution conditionnelle** des rôles appropriés
4. **Gestion d'erreurs** avec rollback automatique
5. **Logging centralisé** dans AAP2 Activity Stream

## Éléments à supprimer (Références AI et composants non pertinents)

### ❌ Suppression obligatoire

#### 1. Configuration Bolt.new (AI)
```bash
# Supprimer complètement le dossier .bolt/
rm -rf .bolt/
```

#### 2. Intégration Supabase complète
```bash
# Fichiers et dossiers à supprimer
rm -rf supabase/
rm -rf src/
rm -f package.json package-lock.json
rm -f tsconfig*.json
rm -f vite.config.ts postcss.config.js tailwind.config.js
rm -f eslint.config.js
rm -f index.html
rm -rf Streamlit/
```

#### 3. Scripts et documentation non pertinents
```bash
# Supprimer
rm -f GET_STARTED.sh
rm -f PROJECT_SUMMARY.txt
```

## Configuration adaptée pour AAP2

### 1. ansible.cfg fusionné

Créer un nouveau `ansible.cfg` combinant vos paramètres et les optimisations Toolbox :

```ini
[defaults]
# Vos paramètres existants
stdout_callback = yaml
bin_ansible_callbacks = True

# Optimisations Toolbox adaptées
inventory = inventories/dev/hosts
host_key_checking = False
retry_files_enabled = False
log_path = ./logs/ansible.log
gathering = smart
fact_caching = jsonfile
fact_caching_connection = ./facts_cache
fact_caching_timeout = 86400
roles_path = ./roles
timeout = 30
forks = 10

# Adaptation pour vos images SHA
remote_user = ansible
become = True
become_method = sesu
become_user = root
become_ask_pass = False
become_flags = "-"

[privilege_escalation]
become = True
become_method = sesu
become_user = root
become_ask_pass = False
become_flags = "-"

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no
pipelining = True
control_path = /tmp/ansible-ssh-%%h-%%p-%%r

[diff]
always = False
context = 3
```

### 2. group_vars/all.yml adapté aux images SHA

```yaml
---
# Variables globales Toolbox pour images SHA standardisées
# SUPPRIMÉ: Toutes références supabase_url, supabase_anon_key

# SHA Standard Paths (présents dans l'image)
sha_base_path: /apps
sha_toolbox_path: /apps/toolboxes
sha_exploit_path: /apps/exploit
sha_applis_path: /applis
sha_applis_logs_path: /applis/logs
sha_applis_delivery_path: /applis/delivery

# Volume Groups (présents dans l'image SHA)
vg_rootvg: rootvg
vg_apps: vg_apps

# Filesystem Defaults (pour extensions)
fs_default_sizes:
  toolbox: 5
  exploit: 2
  appli_base: 1
  appli_transfer_in: 1
  appli_transfer_out: 1
  appli_tmp: 1
  appli_archives: 1
  shared: 1
  shared_tmp: 1
  shared_archives: 1
  logs: 1
  logs_shared: 1
  delivery: 2
  delivery_shared: 2

# Application Code Patterns (standards SHA)
codeap_pattern: '^\\d{5}$'
codescar_pattern: '^[A-Z0-9]{5}$'
id_pattern: '^[A-Z0-9]{2}$'

# Standard Application Directories (image SHA)
standard_appli_dirs:
  - conf
  - scripts
  - shared
  - tmp
  - archives
  - transfer/in
  - transfer/out

# Standard Exploit Directories (image SHA)
standard_exploit_dirs:
  - autosys
  - conf
  - logs
  - scripts
  - tmp
  - delivery

# WebSphere Types (pré-installés dans image SHA)
websphere_types:
  - was
  - wlc
  - wlb

# Middleware Detection Paths (image SHA standardisée)
middleware_paths:
  cft: /opt/axway/cft
  mqseries: /opt/mqm
  oracle: /etc/oratab
  tsm: /opt/tivoli/tsm/client
  nimsoft: /opt/nimsoft
  illumio: /opt/illumio_ven
  bigfix: /opt/BESClient
  vormetric: /opt/vormetric
  websphere: /opt/IBM/WebSphere
  ihs: /opt/IBM/HTTPServer

# Logging Configuration (adapté pour AAP2)
logging:
  enabled: true
  log_to_supabase: false  # DÉSACTIVÉ
  log_level: INFO
  retention_days: 90
  use_aap2_logging: true  # NOUVEAU

# Security Settings (image SHA)
security:
  validate_rootvg_protection: true
  require_sudo: true
  audit_changes: true
  sha_compliance: true  # NOUVEAU

# Configurations middleware (paths image SHA)
backup:
  tsm_client_path: /opt/tivoli/tsm/client/ba/bin
  backup_script: btsauve.ksh
  log_path: /apps/toolboxes/backup_restore/logs

oracle:
  oratab_path: /etc/oratab
  base_path: /u01/app/oracle

websphere:
  profile_root: /opt/IBM/WebSphere/AppServer/profiles
  ihs_root: /opt/IBM/HTTPServer
  plugin_root: /opt/IBM/WebSphere/Plugins

nimsoft:
  robot_path: /opt/nimsoft/robot
  probe_path: /opt/nimsoft/probes

illumio:
  ven_path: /opt/illumio_ven
  workload_path: /var/lib/illumio-ven

vormetric:
  agent_path: /opt/vormetric/DataSecurityExpert
  config_path: /etc/vormetric

bigfix:
  client_path: /opt/BESClient
  config_path: /var/opt/BESClient

cft:
  install_path: /opt/axway/cft
  runtime_path: /opt/axway/cft/runtime
  conf_path: /opt/axway/cft/conf

mqseries:
  install_path: /opt/mqm
  data_path: /var/mqm

# Execution Modes
execution_mode: production
dry_run: false
validate_before_execute: true
rollback_on_failure: true
sha_image_compliance: true  # NOUVEAU

# Notification Settings (adapté pour AAP2)
notifications:
  enabled: false
  smtp_server: ""
  admin_email: ""
  use_aap2_notifications: true  # NOUVEAU
```

### 3. Inventaires adaptés pour images SHA

#### inventories/dev/hosts
```ini
[sha_servers]
server1 ansible_ssh_host=sXXvlXXXXXXX.fr.net.intra

[all:vars]
env=HORSPROD
environment_name=dev
ansible_become_method=sesu
ansible_become_flags="-"
sha_image_type=standard
sha_version=current
```

#### inventories/qual/hosts
```ini
[sha_servers]
server1 ansible_ssh_host=sXXvlXXXXXXX.fr.net.intra

[all:vars]
env=ISOPROD
environment_name=qual
ansible_become_method=sesu
ansible_become_flags="-"
sha_image_type=standard
sha_version=current
```

#### inventories/prod/hosts
```ini
[sha_servers]
server1 ansible_ssh_host=sXXvlXXXXXXX.fr.net.intra

[all:vars]
env=PROD
environment_name=prod
ansible_become_method=sesu
ansible_become_flags="-"
sha_image_type=standard
sha_version=current
```

## Playbook principal adapté pour Job Template unique

### playbook.yml - Workflow complet
```yaml
---
# Playbook principal Toolbox pour images SHA
# Job Template unique exécutant tout le workflow
- name: Toolbox - Workflow Complet pour Images SHA
  hosts: "{{ target_hosts | default('all') }}"
  gather_facts: yes
  become: yes
  
  vars:
    # Module par défaut si non spécifié
    toolbox_module: "{{ toolbox_module | default('auto') }}"
    
  pre_tasks:
    - name: Display execution information
      debug:
        msg:
          - "=========================================="
          - "Toolbox Ansible pour Images SHA"
          - "=========================================="
          - "Target: {{ inventory_hostname }}"
          - "Module: {{ toolbox_module }}"
          - "Environment: {{ env }}"
          - "SHA Image: {{ sha_image_type | default('standard') }}"
          - "User: {{ ansible_user }}"
          - "=========================================="

    - name: Validate target is not production without confirmation
      pause:
        prompt: "You are targeting PRODUCTION environment. Continue? (yes/no)"
      when:
        - env == 'PROD'
        - not (force_prod | default(false) | bool)
      register: prod_confirm

    - name: Abort if production not confirmed
      fail:
        msg: "Production execution aborted by user"
      when:
        - env == 'PROD'
        - prod_confirm.user_input | default('no') != 'yes'
        - not (force_prod | default(false) | bool)

    - name: Detect installed middleware on SHA image
      stat:
        path: "{{ item.value }}"
      loop: "{{ middleware_paths | dict2items }}"
      register: middleware_detection

    - name: Set detected middleware facts
      set_fact:
        detected_middleware: "{{ middleware_detection.results | 
          selectattr('stat.exists', 'equalto', true) | 
          map(attribute='item.key') | list }}"

    - name: Display detected middleware
      debug:
        msg: "Middleware détectés sur image SHA: {{ detected_middleware }}"

    - name: Auto-select modules based on detected middleware
      set_fact:
        selected_modules: |
          {%- set modules = [] -%}
          {%- if toolbox_module == 'auto' -%}
            {%- set modules = modules + ['operating'] -%}
            {%- if 'websphere' in detected_middleware or 'ihs' in detected_middleware -%}
              {%- set modules = modules + ['web'] -%}
            {%- endif -%}
            {%- if 'oracle' in detected_middleware -%}
              {%- set modules = modules + ['database'] -%}
            {%- endif -%}
            {%- if 'tsm' in detected_middleware -%}
              {%- set modules = modules + ['backup'] -%}
            {%- endif -%}
          {%- else -%}
            {%- set modules = [toolbox_module] -%}
          {%- endif -%}
          {{ modules }}

    - name: Display selected modules
      debug:
        msg: "Modules sélectionnés: {{ selected_modules }}"

  tasks:
    - name: Execute Operating module
      include_tasks: playbooks/operating.yml
      when: "'operating' in selected_modules"
      tags:
        - operating

    - name: Execute Web module  
      include_tasks: playbooks/web.yml
      when: "'web' in selected_modules"
      tags:
        - web

    - name: Execute Database module
      include_tasks: playbooks/database.yml
      when: "'database' in selected_modules"
      tags:
        - database

    - name: Execute Backup module
      include_tasks: playbooks/backup.yml
      when: "'backup' in selected_modules"
      tags:
        - backup

  post_tasks:
    - name: Display execution summary
      debug:
        msg:
          - "=========================================="
          - "Exécution terminée avec succès"
          - "Host: {{ inventory_hostname }}"
          - "Modules exécutés: {{ selected_modules }}"
          - "Middleware détectés: {{ detected_middleware }}"
          - "Environment: {{ env }}"
          - "=========================================="

  rescue:
    - name: Global error handler
      debug:
        msg:
          - "ERREUR GLOBALE dans le workflow Toolbox"
          - "Host: {{ inventory_hostname }}"
          - "Task: {{ ansible_failed_task.name | default('Unknown') }}"
          - "Error: {{ ansible_failed_result.msg | default('Unknown error') }}"

    - name: Trigger rollback if configured
      debug:
        msg: "Rollback automatique activé"
      when: rollback_on_failure | default(true) | bool
```

## Configuration AAP2 - Job Template unique

### Job Template principal

```yaml
Nom: Toolbox - Workflow Complet
Description: Exécution complète de la Toolbox sur images SHA standardisées
Projet: Toolbox
Playbook: playbook.yml
Type de job: Run
Inventaire: <sélectionner inventaire>

Variables Extra:
  # Mode automatique par défaut (détecte les middlewares)
  toolbox_module: auto
  
  # Variables optionnelles selon les besoins
  # operation_type: info|filesystem|arborescence|application
  # filesystem_action: create|extend|delete
  # codeap: "12345"
  # codescar: "APP01"
  # server_action: list|start|stop|restart
  # backup_operation: check|execute|restore

Options:
  [x] Permettre lancement avec limite
  [x] Permettre lancement avec variables extra
  [x] Permettre lancement avec tags
  [x] Mode check au lancement
  [x] Mode diff au lancement

Survey (optionnel):
  Question 1:
    - Nom variable: operation_type
    - Question: Type d'opération?
    - Type: Multiple choice
    - Choix: info, filesystem, arborescence, application, web, database, backup
    - Défaut: info
    - Requis: Non

  Question 2:
    - Nom variable: target_action
    - Question: Action spécifique?
    - Type: Text
    - Défaut: ""
    - Requis: Non

  Question 3:
    - Nom variable: codeap
    - Question: Code AP (5 chiffres)?
    - Type: Text
    - Défaut: ""
    - Requis: Non
    - Validation: ^\d{5}$

  Question 4:
    - Nom variable: codescar
    - Question: Code SCAR (5 caractères)?
    - Type: Text
    - Défaut: ""
    - Requis: Non
    - Validation: ^[A-Z0-9]{5}$

Tags utilisables:
  - info (informations système)
  - filesystem (gestion filesystems)
  - arborescence (création structure)
  - application (gestion apps)
  - web (WebSphere/IHS)
  - database (Oracle)
  - backup (TSM)
  - operating (module système complet)

Notifications:
  - En cas de succès: <équipe-ops>
  - En cas d'échec: <équipe-ops>
  - En cas d'approbation: <équipe-lead>
```

## Exemples d'utilisation du Job Template unique

### 1. Scan complet automatique
```yaml
# Lance la détection automatique et exécute tous les modules pertinents
Job: Toolbox - Workflow Complet
Variables: 
  toolbox_module: auto
  operation_type: info
Limit: server1
Tags: (tous)
```

### 2. Création environnement application
```yaml
# Crée un environnement applicatif complet
Job: Toolbox - Workflow Complet
Variables:
  toolbox_module: operating
  operation_type: arborescence
  codeap: "12345"
  codescar: "APP01"
  create_filesystems: true
Limit: server1
Tags: arborescence, filesystem
```

### 3. Gestion WebSphere spécifique
```yaml
# Opérations WebSphere uniquement
Job: Toolbox - Workflow Complet
Variables:
  toolbox_module: web
  server_action: list
  was_variant: core
Limit: was-server
Tags: web
```

### 4. Opérations de backup
```yaml
# Backup et vérifications TSM
Job: Toolbox - Workflow Complet
Variables:
  toolbox_module: backup
  backup_operation: execute
  backup_type: INCR_APPLI
Limit: server1
Tags: backup
```

### 5. Mode dry-run complet
```yaml
# Test complet sans modification
Job: Toolbox - Workflow Complet
Variables:
  toolbox_module: auto
Mode: Check activé
Diff: Activé
Limit: server1
```

## Procédure de migration

### Étape 1: Préparation
```bash
# Cloner le repository
git clone https://github.com/Fonipanda/SHA-Toolbox.git
cd SHA-Toolbox

# Garder seulement le dossier ansible-sha-toolbox
cp -r ansible-sha-toolbox/ /tmp/toolbox-clean/
cd /tmp/toolbox-clean/

# Supprimer les éléments non utiles
rm -rf ../supabase/ ../src/ ../Streamlit/ ../.bolt/
rm -f ../package*.json ../tsconfig*.json ../vite.config.ts
rm -f ../postcss.config.js ../tailwind.config.js ../eslint.config.js
rm -f ../index.html ../GET_STARTED.sh ../PROJECT_SUMMARY.txt

# Renommer les références SHA-Toolbox en Toolbox
find . -type f -name "*.yml" -o -name "*.md" | xargs sed -i 's/SHA-Toolbox/Toolbox/g'
find . -type f -name "*.yml" -o -name "*.md" | xargs sed -i 's/SHA Toolbox/Toolbox/g'
```

### Étape 2: Adaptation des fichiers
```bash
# Modifier ansible.cfg
vi ansible.cfg

# Nettoyer group_vars/all.yml
vi group_vars/all.yml

# Adapter les inventaires avec vos serveurs réels
vi inventories/dev/hosts
vi inventories/qual/hosts  
vi inventories/prod/hosts

# Modifier le playbook principal pour le workflow unique
vi playbook.yml
```

### Étape 3: Modification des rôles
```bash
# Supprimer les tâches de logging Supabase
find roles/ -name "log_to_supabase.yml" -delete

# Modifier les main.yml des rôles pour supprimer les appels Supabase
for role in roles/*/tasks/main.yml; do
  sed -i '/log_to_supabase/d' "$role"
  sed -i '/supabase/d' "$role"
done

# Modifier les playbooks pour supprimer les rescue Supabase
for playbook in playbooks/*.yml; do
  sed -i '/log.*supabase/d' "$playbook"
done
```

### Étape 4: Tests sur images SHA
```bash
# Test de connectivité
ansible all -i inventories/dev/hosts -m ping

# Test scan automatique (dry-run)
ansible-playbook playbook.yml \
  -i inventories/dev/hosts \
  -e "toolbox_module=auto" \
  -e "operation_type=info" \
  --limit server1 \
  --check

# Test création arborescence (dry-run) 
ansible-playbook playbook.yml \
  -i inventories/dev/hosts \
  -e "toolbox_module=operating" \
  -e "operation_type=arborescence" \
  -e "codeap=12345" \
  -e "codescar=TEST1" \
  --limit server1 \
  --check

# Test détection middleware
ansible-playbook playbook.yml \
  -i inventories/dev/hosts \
  -e "toolbox_module=auto" \
  --limit server1 \
  --tags info \
  --check
```

### Étape 5: Intégration AAP2
```bash
# Commit du code nettoyé
git add .
git commit -m "Adaptation Toolbox pour AAP2 et images SHA"
git push origin main

# Dans AAP2 Controller:
# 1. Créer le projet Toolbox
# 2. Créer le Job Template unique
# 3. Configurer les inventaires
# 4. Tester l'exécution
```

## Avantages spécifiques aux images SHA

### 1. Compatibilité garantie
- **Middlewares pré-installés** : Détection automatique des composants disponibles
- **Paths standardisés** : Configuration adaptée aux emplacements SHA
- **Permissions configurées** : Support natif de `sesu` et des politiques organisationnelles

### 2. Workflow intelligent
- **Détection automatique** : Scan des middlewares installés sur l'image
- **Exécution conditionnelle** : Seuls les modules pertinents sont exécutés
- **Job Template unique** : Une seule interface pour toutes les opérations

### 3. Conformité SHA
- **Standards respectés** : Arborescence et naming conventions SHA
- **Protection rootvg** : Validation automatique des opérations
- **Audit complet** : Traçabilité dans AAP2 Activity Stream

## Monitoring et maintenance

### Logs AAP2 spécifiques
- **Activity Stream** : Toutes les exécutions Toolbox
- **Job Output** : Détails par middleware détecté
- **Dashboard** : Statistiques d'utilisation par image SHA
- **Notifications** : Alertes configurables par module

### Maintenance des images SHA
```bash
# Vérification compatibilité nouvelle image
ansible-playbook playbook.yml \
  -e "toolbox_module=auto" \
  -e "operation_type=info" \
  --check

# Test détection middleware nouvelle version
ansible all -m setup -a "filter=ansible_mounts"
ansible all -m find -a "paths=/opt file_type=directory"
```

## Conclusion

Cette migration permet de :
- **Exploiter pleinement** les images SHA standardisées
- **Détecter automatiquement** les middlewares installés
- **Exécuter** un workflow complet via un Job Template unique
- **Maintenir** la conformité aux standards organisationnels
- **Supprimer** toutes les références AI et dépendances externes
- **Bénéficier** de l'interface AAP2 pour le pilotage et la supervision

La Toolbox devient ainsi parfaitement intégrée à votre environnement AAP2 et optimisée pour les images SHA de votre organisation.