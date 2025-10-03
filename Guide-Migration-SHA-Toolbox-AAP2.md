# Guide de Migration SHA-Toolbox vers AAP2

## Vue d'ensemble

Ce document présente la procédure complète pour adapter le dépôt SHA-Toolbox à votre environnement Ansible Automation Platform 2 (AAP2) existant. L'analyse du dépôt révèle que **51% des éléments sont directement utiles** pour AAP2, mais nécessitent des adaptations spécifiques.

## Architecture de votre environnement AAP2

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

## Éléments à supprimer (Références AI et composants non pertinents)

### ❌ Suppression obligatoire

#### 1. Configuration Bolt.new (AI)
```bash
# Supprimer complètement
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

Créer un nouveau `ansible.cfg` combinant vos paramètres et les optimisations SHA-Toolbox :

```ini
[defaults]
# Vos paramètres existants
stdout_callback = yaml
bin_ansible_callbacks = True

# Optimisations SHA-Toolbox adaptées
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

# Adaptation pour votre environnement
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

### 2. group_vars/all.yml nettoyé

Supprimer toutes les références Supabase et adapter :

```yaml
---
# Variables globales SHA Toolbox pour AAP2
# SUPPRIMÉ: Toutes références supabase_url, supabase_anon_key

# SHA Standard Paths (conservés)
sha_base_path: /apps
sha_toolbox_path: /apps/toolboxes
sha_exploit_path: /apps/exploit
sha_applis_path: /applis
sha_applis_logs_path: /applis/logs
sha_applis_delivery_path: /applis/delivery

# Volume Groups (conservés)
vg_rootvg: rootvg
vg_apps: vg_apps

# Filesystem Defaults (conservés)
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

# Application Code Patterns (conservés)
codeap_pattern: '^\\d{5}$'
codescar_pattern: '^[A-Z0-9]{5}$'
id_pattern: '^[A-Z0-9]{2}$'

# Standard Application Directories (conservés)
standard_appli_dirs:
  - conf
  - scripts
  - shared
  - tmp
  - archives
  - transfer/in
  - transfer/out

# Standard Exploit Directories (conservés)
standard_exploit_dirs:
  - autosys
  - conf
  - logs
  - scripts
  - tmp
  - delivery

# WebSphere Types (conservés)
websphere_types:
  - was
  - wlc
  - wlb

# Middleware Detection Paths (conservés)
middleware_paths:
  cft: /opt/axway/cft
  mqseries: /opt/mqm
  oracle: /etc/oratab
  tsm: /opt/tivoli/tsm/client
  nimsoft: /opt/nimsoft
  illumio: /opt/illumio_ven
  bigfix: /opt/BESClient
  vormetric: /opt/vormetric

# Logging Configuration (adapté pour AAP2)
logging:
  enabled: true
  log_to_supabase: false  # DÉSACTIVÉ
  log_level: INFO
  retention_days: 90
  use_aap2_logging: true  # NOUVEAU

# Security Settings (conservés)
security:
  validate_rootvg_protection: true
  require_sudo: true
  audit_changes: true

# Configurations middleware (conservées)
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

# Execution Modes (conservés)
execution_mode: production
dry_run: false
validate_before_execute: true
rollback_on_failure: true

# Notification Settings (adapté pour AAP2)
notifications:
  enabled: false
  smtp_server: ""
  admin_email: ""
  use_aap2_notifications: true  # NOUVEAU
```

### 3. Inventaires adaptés

#### inventories/dev/hosts
```ini
[default]
server1 ansible_ssh_host=sXXvlXXXXXXX.fr.net.intra

[all:vars]
env=HORSPROD
environment_name=dev
ansible_become_method=sesu
ansible_become_flags="-"
```

#### inventories/qual/hosts
```ini
[default]
server1 ansible_ssh_host=sXXvlXXXXXXX.fr.net.intra

[all:vars]
env=ISOPROD
environment_name=qual
ansible_become_method=sesu
ansible_become_flags="-"
```

#### inventories/prod/hosts
```ini
[default]
server1 ansible_ssh_host=sXXvlXXXXXXX.fr.net.intra

[all:vars]
env=PROD
environment_name=prod
ansible_become_method=sesu
ansible_become_flags="-"
```

## Modification des rôles

### 1. Désactiver le logging Supabase

Dans tous les rôles, modifier les tâches `log_to_supabase.yml` :

#### roles/ips_toolbox_system/tasks/main.yml
```yaml
---
# Main tasks for ips_toolbox_system role
- name: Include OS-specific variables
  include_vars: "{{ ansible_os_family }}.yml"
  when: ansible_os_family in ['RedHat', 'Windows']

- name: Gather system information
  include_tasks: gather_info.yml
  tags:
    - info
    - system_info

- name: Manage filesystems
  include_tasks: manage_filesystem.yml
  when: filesystem_action is defined
  tags:
    - filesystem
    - fs

- name: Create application arborescence
  include_tasks: create_arborescence.yml
  when: create_arborescence | default(false) | bool
  tags:
    - arborescence
    - create_app

- name: Manage log rotation
  include_tasks: log_rotation.yml
  when: manage_log_rotation | default(false) | bool
  tags:
    - logs
    - rotation

- name: Server reboot management
  include_tasks: reboot.yml
  when: server_action in ['reboot', 'shutdown']
  tags:
    - reboot
    - shutdown

# SUPPRIMÉ: Log execution to Supabase
# Remplacé par logging AAP2 natif via Activity Stream
```

### 2. Modifier playbooks/operating.yml

Supprimer les références au logging Supabase :

```yaml
---
# Operating Module Playbook
# System operations, filesystem management, application management
- name: Operating Module Tasks
  block:
    - name: Gather system information
      include_role:
        name: ips_toolbox_system
      vars:
        gather_info: true
      when: operation_type | default('info') == 'info'
      tags:
        - info

    - name: Manage filesystems
      include_role:
        name: ips_toolbox_system
      when: operation_type == 'filesystem'
      tags:
        - filesystem

    - name: Create application arborescence
      include_role:
        name: ips_toolbox_system
      vars:
        create_arborescence: true
      when: operation_type == 'arborescence'
      tags:
        - arborescence

    - name: Manage applications
      include_role:
        name: ips_toolbox_appli
      when: operation_type == 'application'
      tags:
        - application

    - name: Manage monitoring (Nimsoft)
      include_role:
        name: ips_toolbox_nimsoft
      when:
        - operation_type == 'monitoring'
        - "'nimsoft' in middleware_paths"
      tags:
        - monitoring
        - nimsoft

    - name: Manage CFT
      include_role:
        name: ips_toolbox_cft
      when:
        - operation_type == 'cft'
        - "'cft' in middleware_paths"
      tags:
        - cft

    - name: Manage MQSeries
      include_role:
        name: ips_toolbox_mq
      when:
        - operation_type == 'mq'
        - "'mqseries' in middleware_paths"
      tags:
        - mq

    - name: Manage Vormetric
      include_role:
        name: ips_toolbox_vormetric
      when:
        - operation_type == 'vormetric'
        - "'vormetric' in middleware_paths"
      tags:
        - vormetric

    - name: Manage Illumio
      include_role:
        name: ips_toolbox_illumio
      when:
        - operation_type == 'illumio'
        - "'illumio' in middleware_paths"
      tags:
        - illumio

    - name: Manage BigFix
      include_role:
        name: ips_toolbox_bigfix
      when:
        - operation_type == 'bigfix'
        - "'bigfix' in middleware_paths"
      tags:
        - bigfix

  rescue:
    - name: Operating module error handler
      debug:
        msg:
          - "Error occurred in Operating module"
          - "Task: {{ ansible_failed_task.name }}"
          - "Error: {{ ansible_failed_result.msg | default('Unknown error') }}"
      
    # SUPPRIMÉ: Log error to Supabase
    # Les erreurs sont automatiquement loggées dans AAP2 Activity Stream
```

## Configuration AAP2

### 1. Création du projet AAP2

```bash
# Dans l'interface AAP2 Controller
Nom du projet: SHA-Toolbox
SCM Type: Git
SCM URL: <votre-repo-git>
SCM Branch: main
Répertoire de projet: ansible-sha-toolbox/
```

### 2. Execution Environment

Créer un fichier `execution-environment.yml` :

```yaml
---
version: 3

dependencies:
  galaxy: requirements.yml
  python: requirements.txt
  system: bindep.txt

images:
  base_image:
    name: 'quay.io/ansible/automation-hub-ee:latest'

additional_build_steps:
  prepend: |
    RUN whoami
    RUN cat /etc/os-release
  append:
    - RUN echo "SHA Toolbox Execution Environment ready"
```

### 3. Job Templates AAP2

#### Template 1: Informations système
```yaml
Nom: SHA-Toolbox - System Info
Projet: SHA-Toolbox
Playbook: playbook.yml
Inventaire: <votre-inventaire-dev>
Variables extra:
  toolbox_module: operating
  operation_type: info
Limiter: ""
Tags: info
Options: [x] Invite on Launch (Limit)
```

#### Template 2: Création arborescence
```yaml
Nom: SHA-Toolbox - Create App Environment
Projet: SHA-Toolbox
Playbook: playbook.yml
Inventaire: <votre-inventaire-dev>
Variables extra:
  toolbox_module: operating
  operation_type: arborescence
Survey: 
  - codeap (text, required, pattern: ^\d{5}$)
  - codescar (text, required, pattern: ^[A-Z0-9]{5}$)
  - create_filesystems (boolean, default: true)
Options: [x] Invite on Launch (Limit, Extra Variables)
```

#### Template 3: Gestion filesystems
```yaml
Nom: SHA-Toolbox - Filesystem Management
Projet: SHA-Toolbox
Playbook: playbook.yml
Inventaire: <votre-inventaire-dev>
Variables extra:
  toolbox_module: operating
  operation_type: filesystem
Survey:
  - filesystem_action (choice: create/extend/delete)
  - codeap (text, required when create)
  - codescar (text, required when create)
  - vg_name (text, default: vg_apps)
  - size (integer, default: 1)
Options: [x] Invite on Launch (Limit, Extra Variables)
```

#### Template 4: WebSphere Operations
```yaml
Nom: SHA-Toolbox - WebSphere Management
Projet: SHA-Toolbox
Playbook: playbook.yml
Inventaire: <votre-inventaire-dev>
Variables extra:
  toolbox_module: web
Survey:
  - server_action (choice: list/start/stop/restart/status)
  - server_name (text, required when not list)
  - was_variant (choice: core/base/nd)
Options: [x] Invite on Launch (Limit, Extra Variables)
```

### 4. Workflow Templates AAP2

#### Workflow: Déploiement application complète
```yaml
Nom: SHA-Toolbox - Full App Deployment
Description: Création complète environnement application

Nœuds:
1. System Info → 2. Create Environment → 3. Configure WebSphere
   ↓ (en cas d'échec)
   4. Rollback

Variables Workflow:
  - codeap
  - codescar  
  - target_env (dev/qual/prod)
```

## Procédure de migration

### Étape 1: Préparation
```bash
# Cloner le repository
git clone https://github.com/Fonipanda/SHA-Toolbox.git
cd SHA-Toolbox

# Garder seulement le dossier ansible-sha-toolbox
cp -r ansible-sha-toolbox/ /tmp/sha-toolbox-clean/
cd /tmp/sha-toolbox-clean/

# Supprimer les éléments non utiles
rm -rf ../supabase/ ../src/ ../Streamlit/ ../.bolt/
rm -f ../package*.json ../tsconfig*.json ../vite.config.ts
rm -f ../postcss.config.js ../tailwind.config.js ../eslint.config.js
rm -f ../index.html ../GET_STARTED.sh ../PROJECT_SUMMARY.txt
```

### Étape 2: Adaptation des fichiers
```bash
# Modifier ansible.cfg (voir section configuration)
vi ansible.cfg

# Nettoyer group_vars/all.yml (supprimer références Supabase)
vi group_vars/all.yml

# Adapter les inventaires avec vos serveurs réels
vi inventories/dev/hosts
vi inventories/qual/hosts  
vi inventories/prod/hosts
```

### Étape 3: Modification des rôles
```bash
# Pour chaque rôle, supprimer/modifier les tâches log_to_supabase
find roles/ -name "log_to_supabase.yml" -delete

# Modifier les main.yml des rôles pour supprimer les appels Supabase
# (voir section modification des rôles)
```

### Étape 4: Tests locaux
```bash
# Test de connectivité
ansible all -i inventories/dev/hosts -m ping

# Test informations système
ansible-playbook playbook.yml \
  -i inventories/dev/hosts \
  -e "toolbox_module=operating" \
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
```

### Étape 5: Intégration AAP2
```bash
# Commit du code nettoyé
git add .
git commit -m "Adaptation SHA-Toolbox pour AAP2"
git push origin main

# Créer le projet dans AAP2 (via interface web)
# Créer les job templates (via interface web)
# Créer les workflow templates (via interface web)
```

## Utilisation dans AAP2

### Opérations courantes

#### 1. Informations système
```
Job Template: SHA-Toolbox - System Info
Limit: server1
```

#### 2. Création environnement application
```
Job Template: SHA-Toolbox - Create App Environment
Survey values:
  - codeap: 12345
  - codescar: APP01
  - create_filesystems: true
Limit: server1
```

#### 3. Gestion filesystem
```
Job Template: SHA-Toolbox - Filesystem Management
Survey values:
  - filesystem_action: create
  - codeap: 12345
  - codescar: APP01
  - size: 5
Limit: server1
```

#### 4. Opérations WebSphere
```
Job Template: SHA-Toolbox - WebSphere Management
Survey values:
  - server_action: list
  - was_variant: core
Limit: was-server
```

### Monitoring et logs

Dans AAP2, vous pouvez suivre :
- **Activity Stream** : Tous les jobs exécutés
- **Job Output** : Logs détaillés de chaque exécution
- **Dashboard** : Statistiques d'utilisation
- **Notifications** : Alertes en cas d'échec

## Bonnes pratiques AAP2

### 1. Sécurité
- Utiliser des **credentials** AAP2 pour l'authentification SSH
- Configurer des **permissions** par équipe/projet
- Activer l'**audit logging** AAP2

### 2. Gestion des environnements
- **Inventaires séparés** pour dev/qual/prod
- **Workflows** pour les déploiements complets
- **Surveys** pour la saisie sécurisée des paramètres

### 3. Maintenance
- **Versionner** le code dans Git
- **Tester** en dev avant qual/prod
- **Surveiller** les execution environments
- **Documenter** les modifications dans AAP2

## Avantages de la migration

### Avant (scripts shell)
- Exécution manuelle
- Pas de traçabilité
- Gestion d'erreurs limitée
- Pas d'interface graphique

### Après (AAP2 + SHA-Toolbox)
- Interface web intuitive
- Traçabilité complète dans Activity Stream
- Gestion d'erreurs robuste avec Ansible
- Workflows automatisés
- Permissions granulaires
- Surveys pour la saisie sécurisée
- Notifications automatiques
- Conformité aux standards SHA maintenue

## Support et dépannage

### Logs AAP2
- **Activity Stream** : Vue globale des exécutions
- **Job Details** : Logs détaillés par job
- **System Logs** : Logs système AAP2

### Debug Ansible
```bash
# Mode verbose
ansible-playbook playbook.yml -vvv

# Dry run
ansible-playbook playbook.yml --check --diff

# Limite à un serveur
ansible-playbook playbook.yml --limit server1
```

### Problèmes courants
1. **Connexion SSH** : Vérifier credentials AAP2
2. **Sudo/sesu** : Vérifier become_method dans inventaire
3. **Permissions filesystem** : Vérifier protection rootvg
4. **Variables manquantes** : Utiliser surveys AAP2

## Conclusion

Cette migration vous permet de :
- **Conserver** 100% des fonctionnalités SHA métier
- **Bénéficier** de l'interface et des fonctionnalités AAP2
- **Supprimer** toutes les références AI et dépendances externes
- **Maintenir** la conformité aux standards SHA
- **Améliorer** la traçabilité et la sécurité

Le projet SHA-Toolbox devient ainsi parfaitement intégré à votre environnement AAP2 existant, tout en conservant sa valeur métier pour la gestion de l'infrastructure applicative.