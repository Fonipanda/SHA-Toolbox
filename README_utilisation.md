# Guide d'utilisation des playbooks SHA Automation
# Pour Ansible AAP2 UI

## Vue d'ensemble

Cette suite de playbooks automatise la construction d'environnements applicatifs sur des serveurs avec un Socle d'Hébergement Applicatif (SHA). Elle respecte les règles IT et utilise les rôles SHA-Toolbox pour les opérations.

## Prérequis

### Serveurs cibles
- **AIX** : Version 7.x avec toolbox BP21 installée
- **Linux RHEL** : Version 7/8/9 avec toolbox BP21 installée  
- **Windows** : 2016/2019/2025 avec toolbox BP21 installée

### Variables obligatoires
```yaml
codeAP: "12345"           # Code application (5 chiffres)
code5car: "TEST1"         # Code SCAR (5 caractères alphanumériques)
environment: "dev"        # Environnement (dev/qual/prod)
os_type: "Linux"         # Type OS (AIX/Linux/Windows)
middleware_type: "WAS"    # Type middleware
```

### Variables optionnelles
```yaml
idappli: "01"            # Identifiant application (2 caractères)
vg_name: "vg_apps"       # Volume group (défaut: vg_apps)
filesystem_sizes:        # Tailles des filesystems en MB
  appli: "2048"
  logs: "1024"
```

## Structure des playbooks

### Playbook principal
- **03_playbook_sha_automation.yml** : Orchestrateur principal qui exécute toutes les phases

### Playbooks spécialisés
1. **01_preparation.yml** : Collecte des facts, vérifications préalables
2. **02_system_base.yml** : Configuration système de base (bannière, utilisateurs, NTP)
3. **03_filesystem.yml** : Création arborescence et filesystems selon règles IT
4. **04_middleware.yml** : Configuration middleware (WebSphere, Oracle, SQL Server, MQ)
5. **05_agents.yml** : Installation agents (Dynatrace, Illumio, Autosys, Control-M)
6. **06_backup.yml** : Configuration sauvegardes (TSM, politiques, rotation logs)
7. **07_integration.yml** : Intégration écosystème (Reftec, ServiceNow, VIP, certificats)
8. **08_validation.yml** : Tests et validation finale, génération rapport

## Utilisation dans Ansible AAP2

### 1. Exécution complète

```bash
# Via UI AAP2 - Job Template
Name: "SHA Automation Complete"
Playbook: 03_playbook_sha_automation.yml
Inventory: Production/Dev/Qual
Credentials: SSH/WinRM selon OS
Extra Variables:
  codeAP: "12345"
  code5car: "TEST1"
  environment: "prod"
  middleware_type: "WAS_BASE"
```

### 2. Exécution par phases

```bash
# Phase 1 uniquement - Préparation
ansible-playbook 01_preparation.yml --tags "phase1"

# Phases système (1-3)  
ansible-playbook 03_playbook_sha_automation.yml --tags "phase1,phase2,phase3"

# Phase middleware uniquement
ansible-playbook 03_playbook_sha_automation.yml --tags "phase4"
```

### 3. Tags disponibles

```yaml
# Par phase
- phase1, phase2, phase3, phase4, phase5, phase6, phase7, phase8

# Par fonction
- preparation, system_base, filesystem, middleware
- agents, backup, integration, validation

# Spécifiques
- facts, uptime, filesystems, websphere, oracle
- dynatrace, illumio, autosys, tsm, reftec
```

### 4. Variables d'environnement AAP2

```yaml
# Dans AAP2 - Extra Variables
---
codeAP: "12345"
code5car: "MYAPP"
idappli: "01"
environment: "prod"
os_type: "Linux"
middleware_type: "WAS_BASE"

# Tailles personnalisées
filesystem_sizes:
  appli: "4096"
  logs: "2048"
  tmp: "1024"
  archives: "2048"

# Configuration middleware
install_ihs: true
ihs_port: "8080"
oracle_instance: "P12345AP10"

# Activation/désactivation agents
dynatrace_enabled: true
illumio_enabled: true
autosys_enabled: true
```

## Exemples d'utilisation

### Exemple 1: Application WebSphere en production

```yaml
# Job Template AAP2
Extra Variables:
  codeAP: "54321"
  code5car: "WEBAPP" 
  environment: "prod"
  os_type: "Linux"
  middleware_type: "WAS_ND"
  install_ihs: true
  ihs_port: "8080"
  ihs_ssl_port: "8443"
  filesystem_sizes:
    appli: "4096"
    logs: "2048"
    archives: "4096"
  vip_integration_enabled: true
  vip_name: "prod-webapp-vip"
```

### Exemple 2: Base de données Oracle

```yaml
# Job Template AAP2  
Extra Variables:
  codeAP: "98765"
  code5car: "ORACLE"
  environment: "prod"
  os_type: "AIX"
  middleware_type: "Oracle"
  oracle_instance: "P98765AP10"
  oracle_backup_retention: "60"
  filesystem_sizes:
    appli: "8192"
    logs: "4096" 
    archives: "8192"
  generate_app_certificate: true
```

### Exemple 3: Application Windows SQL Server

```yaml
# Job Template AAP2
Extra Variables:
  codeAP: "13579"
  code5car: "SQAPP"
  environment: "dev"
  os_type: "Windows"  
  middleware_type: "SQLServer"
  filesystem_sizes:
    appli: "2048"
    logs: "1024"
  dynatrace_enabled: true
  illumio_enabled: false  # Non supporté sur Windows
```

## Inventaires

### Structure recommandée

```ini
# inventories/prod/hosts
[prod_linux]
prod-server01 codeAP=12345 code5car=APP01 middleware_type=WAS_BASE
prod-server02 codeAP=12345 code5car=APP01 middleware_type=Oracle

[prod_linux:vars]  
environment=prod
os_type=Linux
```

### Variables par groupe

```yaml
# group_vars/prod.yml
environment: prod
silo_contact: "prod.team@company.com"
autosys_server: "autosys-prod"
oracle_backup_retention: "30"
vip_integration_enabled: true
dns_integration_enabled: true
```

## Monitoring et logs

### Logs d'exécution
```bash
# Logs Ansible AAP2
/var/log/tower/job_events/

# Logs sur les serveurs cibles
/applis/logs/[codeAP]-[code5car]/ansible_execution.log
/apps/toolboxes/logs/
```

### Rapport final
Le playbook génère automatiquement un rapport détaillé :
```yaml
# Emplacement du rapport
/tmp/sha_automation_reports/[hostname]_[timestamp]_report.json

# Contenu
- État de chaque phase
- Filesystems créés
- Middleware configuré  
- Agents installés
- Tests effectués
- Métriques de performance
```

## Résolution de problèmes

### Erreurs courantes

1. **Variable obligatoire manquante**
```
FAILED: Variable obligatoire manquante: codeAP
```
Solution: Définir toutes les variables obligatoires

2. **code5car invalide**  
```
FAILED: code5car doit contenir exactement 5 caractères alphanumériques
```
Solution: Respecter le format [A-Za-z0-9]{5}

3. **Filesystem existe déjà**
```
WARNING: Filesystem /applis/12345-TEST1 already exists
```
Solution: Normal, le rôle vérifie l'existence avant création

4. **Middleware non trouvé**
```
ERROR: WebSphere installation not found
```
Solution: Vérifier que le middleware est installé sur le serveur

### Mode debug
```bash
# Exécution avec debug
ansible-playbook 03_playbook_sha_automation.yml -vvv

# Logs détaillés dans AAP2
Job Template > Enable Verbose Logging
```

## Sécurité

### Variables sensibles
Utiliser Ansible Vault pour :
```yaml
# Tokens API
dynatrace_api_token: !vault |
servicenow_auth_token: !vault |

# Mots de passe
oracle_sys_password: !vault |
```

### Permissions
- **Root/Administrateur** : Requis pour la plupart des opérations
- **Utilisateur Oracle** : Pour les opérations base de données
- **Utilisateur MQ** : Pour les opérations IBM MQ

## Maintenance

### Mise à jour des rôles SHA-Toolbox
```bash
# Dans AAP2 - Project
Source Control URL: https://github.com/Fonipanda/SHA-Toolbox.git
Source Control Branch: main
```

### Sauvegarde des configurations
```bash  
# Sauvegarde automatique des configurations
/apps/toolboxes/backup_restore/scripts/btsauve.ksh backup CONFIG
```

## Support

### Logs à fournir en cas de problème
1. Logs d'exécution Ansible AAP2
2. `/apps/toolboxes/logs/` sur le serveur cible  
3. `/applis/logs/[codeAP]-[code5car]/` 
4. Rapport JSON généré par le playbook
5. Variables utilisées (masquer les informations sensibles)

### Contacts
- **Équipe Platform** : platform.team@company.com
- **Support Toolbox** : toolbox.support@company.com