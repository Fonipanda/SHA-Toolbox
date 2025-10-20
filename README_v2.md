# SHA-Toolbox - Automatisation de la Couche Applicative

## 📋 Vue d'Ensemble

Le projet **SHA-Toolbox** est une solution d'automatisation Ansible professionnelle pour la création et la configuration de la couche applicative sur des serveurs virtuels (VM/VSI) dans l'environnement SHA (Système d'Hébergement Applicatif).

### Objectifs Principaux

- 🎯 **Automatiser** la création de l'arborescence applicative standard
- ⚙️ **Configurer** les middlewares et services système  
- ✅ **Vérifier** la conformité des serveurs
- 📏 **Standardiser** les déploiements applicatifs

### Systèmes Supportés

- ✅ **Linux** : Red Hat Enterprise Linux 9.x
- ✅ **AIX** : AIX 7.x  
- ✅ **Windows** : Windows Server 2019/2022

## 🔄 Workflow d'Exécution Ansible

### Architecture du Workflow

Le workflow SHA-Toolbox s'exécute selon une séquence logique et structurée en **5 phases distinctes**, orchestrées par le playbook principal `main_playbook.yml`.

![Workflow AAP2](flowchart_aap2_workflow.png)

### Phase 0 : Initialisation et Survey AAP2

#### 📋 Collecte des Variables via Survey

Le job AAP2 commence par la collecte des variables obligatoires via l'interface Survey (questionnaire) :

```yaml
# Variables obligatoires collectées via Survey AAP2
- CodeAP: "12345"           # Code application (5 chiffres)
- code5car: "ABCDE"         # Code 5 caractères alphanumérique
- Hostname: "s02vl9942814"  # Nom du serveur cible
- environnement: "PRODUCTION" # Environnement cible
```

#### ✅ Validation des Variables

```yaml
- name: "[HORSPROD] Validation des variables obligatoires du Survey AAP2"
  ansible.builtin.assert:
    that:
      - CodeAP is defined and CodeAP != ""
      - code5car is defined and code5car != ""
      - Hostname is defined and Hostname != ""
      - CodeAP | regex_search('^[0-9]{5}$')
      - code5car | regex_search('^[A-Za-z0-9]{5}$')
    fail_msg: "Variables Survey AAP2 invalides"
```

### Phase 1 : Détection et Audit Système

#### 🔍 Collecte des Facts Système

```yaml
- name: "01 - Mise à jour Facts - Collecte des facts système étendus"
  ansible.builtin.include_role:
    name: app_environment_builder
    tasks_from: detect_os
```

**Actions réalisées :**
- Collecte des informations système (OS, version, architecture)
- Détection automatique des middlewares installés
- Identification de l'environnement d'exécution

#### 🏷️ Création de la Bannière de Connexion

```yaml
- name: "02 - Banner - Création bannière login"
  ansible.builtin.include_role:
    name: ips_toolbox_banner
  vars:
    banner_operation: "create"
    banner_environment: "{{ environment_type }}"
    banner_hostname: "{{ ansible_hostname }}"
    banner_codeAP: "{{ code_ap }}"
```

**Fichiers créés :**
- `/etc/motd` : Message Of The Day
- `/etc/issue` : Bannière pre-login console
- `/etc/issue.net` : Bannière pre-login SSH

#### 👥 Création des Utilisateurs Techniques

```yaml
- name: "03 - Users - Création d'utilisateurs techniques"
  ansible.builtin.include_role:
    name: ips_toolbox_users
  vars:
    users_operation: "create"
    users_middlewares: "{{ detected_middlewares | default([]) }}"
```

**Utilisateurs créés automatiquement selon le middleware détecté :**

| Middleware | Utilisateur | Groupe | Sudo |
|------------|-------------|---------|------|
| Oracle     | `oracle`    | `dba`   | ✅ Oui |
| WebSphere  | `wasadmin`  | `wasadm`| ✅ Oui |
| Liberty    | `liberty`   | `liberty`| ✅ Oui |
| CFT        | `cft`       | `cft`   | ❌ Non |

#### 🔧 Vérification de la Toolbox

```yaml
- name: "04 - Toolbox - Vérification interface Toolbox"
  ansible.builtin.include_role:
    name: ips_toolbox_toolboxes
  vars:
    toolboxes_operation: "verify"
    toolboxes_environment: "{{ environment_type }}"
```

### Phase 2 : Création Arborescence et Filesystems

#### 📁 Création de l'Arborescence Applicative

```yaml
- name: "05 - Arborescence - Création /applis + /apps"
  ansible.builtin.include_role:
    name: ips_toolbox_system
  vars:
    system_operation: "create-directory"
    system_codeAP: "{{ code_ap }}"
    system_code5car: "{{ code5car }}"
    system_vgName: "vg_apps"
    system_lvSize: "1024"
    system_iis: "01"
```

**Script Toolbox utilisé :**
```bash
/apps/toolboxes/exploit/bin/exploit_arbo-app.ksh \
  codeAP=12345 \
  code5car=ABCDE \
  id=01 \
  vg=vg_apps \
  lv=lv_ABCDE:1024,lv_ABCDE_ti:1024,...
```

**Arborescence créée :**
```
/applis/
├── 12345-ABCDE-01/
│   ├── transfer/in/
│   ├── transfer/out/
│   ├── tmp/
│   └── archives/
├── shared/
│   ├── tmp/
│   └── archives/
├── logs/
│   ├── 12345-ABCDE-01/
│   └── shared/
└── delivery/
    ├── 12345-ABCDE-01/
    └── shared/
```

#### 💾 Création des Filesystems

```yaml
- name: "06 - FileSystems - Création automatique"
  ansible.builtin.include_role:
    name: ips_toolbox_system
  vars:
    system_operation: "create-fs"
    system_codeAP: "{{ code_ap }}"
    system_code5car: "{{ code5car }}"
    system_vgName: "vg_apps"
    system_lvSize: "1024"
```

### Phase 3 : Vérifications Système et Conformité

#### ⏰ Vérification NTP et Uptime

```yaml
- name: "07 - NTP (Uptime) - Vérifier et redémarrer Chrony"
  ansible.builtin.include_role:
    name: ips_toolbox_uptime
  vars:
    uptime_operation: "check"
    uptime_limit_days: "{{ system_uptime_limit }}"
```

#### 🔍 Configuration Dynatrace

```yaml
- name: "08 - Dynatrace - Agent fullstack configuré"
  ansible.builtin.include_role:
    name: ips_toolbox_dynatrace
  vars:
    dynatrace_operation: "check"
    dynatrace_fullstack_required: "{{ dynatrace_required }}"
```

**Actions Dynatrace :**
1. Vérification de l'installation (`/apps/dynatrace/oneagent/agent/tools/oneagentctl`)
2. Vérification de la version et du statut
3. **Démarrage automatique si arrêté**
4. Vérification du mode FullStack
5. Test de connectivité au serveur

#### 🛡️ Configuration Illumio

```yaml
- name: "09 - Illumio - Check statut Full/Enforced"
  ansible.builtin.include_role:
    name: ips_toolbox_illumio
  vars:
    illumio_operation: "check"
    illumio_enforcement_mode: "{{ illumio_enforcement_mode }}"
```

**Actions Illumio :**
1. Vérification de l'installation (`/opt/illumio_ven/illumio-ven-ctl`)
2. Vérification de la version et du statut
3. **Démarrage automatique si arrêté**
4. **Passage en mode Enforced si nécessaire**
5. Test de connectivité au PCE

### Phase 4 : Configuration Sauvegarde et TSM

#### 💾 Configuration TSM

```yaml
- name: "11 - Sauvegarde TSM/netBackup - Démarrage sauvegarde"
  ansible.builtin.include_role:
    name: ips_toolbox_backup
  vars:
    backup_operation: "run_incr"
    backup_type: "system"
```

**Actions TSM :**
1. Vérification du client TSM (`/opt/tivoli/tsm/client/ba/bin/dsmc`)
2. Vérification du daemon dsmcad
3. **Démarrage automatique du service si arrêté**
4. **Activation au démarrage** (`systemctl enable`)
5. Vérification de la connectivité
6. Test du scheduler TSM

#### 🤖 Configuration Autosys

```yaml
- name: "12 - Backup applicatif - Config via Autosys"
  ansible.builtin.include_role:
    name: ips_toolbox_autosys
  vars:
    autosys_operation: "check"
```

### Phase 5 : Configuration Logs et Maintenance

#### 📝 Gestion des Logs

```yaml
- name: "14 - Purge logs - Nettoyage FS /applis/logs"
  ansible.builtin.include_role:
    name: ips_toolbox_logs
  vars:
    logs_operation: "purge"
    logs_directory: "/applis/logs"
```

## 🔧 Gestion d'Erreurs et Robustesse

### Blocs Rescue et Always

Chaque phase du workflow est protégée par des blocs `rescue` pour la gestion d'erreurs :

```yaml
tasks:
  - name: "[HORSPROD] Exécution du workflow complet"
    block:
      # Toutes les phases d'exécution
      
    rescue:
      - name: "[HORSPROD] Gestion des erreurs du workflow"
        ansible.builtin.debug:
          msg:
            - "Une erreur s'est produite lors de l'exécution du workflow"
            - "Consultez les logs dans {{ report_dir }}"
    
    always:
      - name: "[HORSPROD] Finalisation du rapport d'exécution"
        ansible.builtin.lineinfile:
          path: "{{ report_dir }}/execution_{{ execution_id }}.log"
          line: |
            ===============================================
            FIN D'EXÉCUTION: {{ ansible_date_time.iso8601 }}
            ===============================================
```

### Validation Continue

Chaque rôle intègre des validations :

```yaml
- name: "Vérification que la version est suffisante"
  ansible.builtin.assert:
    that:
      - "tbxcheck.matched | int > 0"
      - "tbxversion.stdout_lines[0] | int >= 1820"
    fail_msg: |
      ❌ Toolbox non trouvée ou version insuffisante
      Version actuelle: {{ tbxversion.stdout_lines[0] | default('N/A') }}
      Version minimale: 1820 (18.2.0)
```

## 📊 Reporting et Traçabilité

### Génération de Rapports

Le workflow génère automatiquement des rapports d'exécution :

```yaml
vars:
  execution_timestamp: "{{ ansible_date_time.iso8601 }}"
  execution_id: "{{ ansible_date_time.epoch }}"
  report_dir: "/tmp/ansible_reports"
```

### Métriques de Conformité

Le playbook `check_playbook.yml` fournit un audit complet avec scoring :

```yaml
- name: "Calcul du score de conformité"
  ansible.builtin.set_fact:
    compliance_percentage: "{{ ((passed_checks | int) * 100 / (total_checks | int)) | round(2) if total_checks | int > 0 else 0 }}"
```

## 🚀 Exécution du Workflow

### Prérequis

1. **Ansible** : Version 2.9+
2. **Accès SSH** : Clés SSH configurées pour les serveurs cibles
3. **Privilèges** : Accès sudo/root sur les serveurs cibles
4. **Toolbox IPS** : Présente sur le serveur cible (version >= 18.2.0)

### Commandes d'Exécution

```bash
# 1. Vérification de la syntaxe
ansible-playbook main_playbook.yml --syntax-check

# 2. Exécution en mode check (dry-run)
ansible-playbook main_playbook.yml -i inventories/prod/hosts --check

# 3. Exécution en production
ansible-playbook main_playbook.yml -i inventories/prod/hosts

# 4. Vérification de conformité
ansible-playbook check_playbook.yml -i inventories/prod/hosts
```

### Variables Survey AAP2

| Variable | Description | Type | Exemple |
|----------|-------------|------|---------|
| `CodeAP` | Code application (5 chiffres) | Texte | `12345` |
| `code5car` | Code 5 caractères | Texte | `ABCDE` |
| `Hostname` | Nom du serveur cible | Texte | `s02vl9942814` |
| `environnement` | Environnement cible | Choix | `PRODUCTION` |

## 🔍 Monitoring et Dashboard

### Dashboard Streamlit

Le projet inclut un dashboard de monitoring avancé basé sur Streamlit :

```bash
# Installation des dépendances
pip install -r Streamlit/requirements-dashboard.txt

# Lancement du dashboard
streamlit run Streamlit/sha_toolbox_dashboard.py
```

**Fonctionnalités du Dashboard :**
- 📊 Vue d'ensemble temps réel des exécutions
- 🎯 Métriques de succès et d'échec
- 📈 Graphiques interactifs (timeline, distribution des rôles)
- 🏥 Santé des environnements
- 🚨 Alertes et gestion des échecs
- 📥 Export des logs et rapports

## 📁 Structure du Projet

```
SHA-Toolbox/
├── README.md                    # Ce fichier
├── main_playbook.yml           # Playbook principal
├── check_playbook.yml          # Playbook de vérification
├── ansible.cfg                 # Configuration Ansible
├── inventories/                # Inventaires par environnement
│   ├── dev/
│   ├── qual/
│   └── prod/
├── roles/                      # 29 rôles Ansible
│   ├── app_environment_builder/
│   ├── ips_toolbox_system/
│   ├── ips_toolbox_banner/
│   ├── ips_toolbox_users/
│   ├── ips_toolbox_dynatrace/
│   ├── ips_toolbox_illumio/
│   ├── ips_toolbox_backup/
│   └── ...
├── Streamlit/                  # Dashboard de monitoring
│   ├── sha_toolbox_dashboard.py
│   ├── sha_toolbox_reporter.py
│   └── requirements-dashboard.txt
├── templates/                  # Templates Jinja2
└── docs/                      # Documentation complète
```

## 🎯 Statut du Projet

- **Version** : 3.0 (16 octobre 2025)
- **Statut** : ✅ **PRODUCTION READY**
- **Score de Complétude** : **89.0%**
- **Commits** : 858+ commits actifs
- **Support** : Multi-OS (Linux, AIX, Windows)
- **Intégration** : AAP2, Jenkins, Kubernetes

## 📞 Support et Maintenance

Pour toute question ou problème :

- 📖 **Documentation** : Consulter les README dans le dépôt
- 📊 **Dashboard** : Utiliser l'interface Streamlit pour le monitoring
- 📝 **Logs** : Vérifier les logs Ansible dans `/tmp/ansible_reports/`
- 🔧 **Dépannage** : Guide de troubleshooting disponible dans la documentation

---

*Projet maintenu par l'équipe d'automatisation SHA - Dernière mise à jour : 17 octobre 2025*