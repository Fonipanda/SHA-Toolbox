# SHA-Toolbox - Automatisation de la Couche Applicative

**Version** : 3.0  
**Date** : 16 octobre 2025  
**Auteur** : Équipe Automatisation SHA  
**Statut** : ✅ Production Ready

---

## 📋 Vue d'Ensemble

Le projet **SHA-Toolbox** est une solution d'automatisation Ansible pour la création et la configuration de la couche applicative sur des serveurs virtuels (VM/VSI) dans l'environnement SHA (Système d'Hébergement Applicatif).

### Objectifs

1. **Automatiser** la création de l'arborescence applicative standard
2. **Configurer** les middlewares et services système
3. **Vérifier** la conformité des serveurs
4. **Standardiser** les déploiements applicatifs

### Systèmes Supportés

- ✅ **Linux** : Red Hat Enterprise Linux 9.x
- ✅ **AIX** : AIX 7.x
- ✅ **Windows** : Windows Server 2019/2022

---

## 🎯 Principes Fondamentaux

### Utilisation de la Toolbox IPS

Le projet **utilise au maximum les scripts existants** de la Toolbox IPS déjà présente sur les serveurs :

| Fonctionnalité | Script Toolbox | Rôle Ansible |
|----------------|----------------|--------------|
| Création arborescence `/applis` | ✅ `exploit_arbo-app.ksh` | `ips_toolbox_system` |
| Gestion applications (start/stop) | ✅ `exploit_app.ksh` | `ips_toolbox_appli` |
| Sauvegarde applicative | ✅ `btsauve.ksh` | `ips_toolbox_backup` |
| Vérification sauvegardes | ✅ `verif_backup.ksh` | `ips_toolbox_backup` |
| Fonctions Autosys | ✅ `toolboxFunctions.ksh` | `ips_toolbox_autosys` |

**Les rôles Ansible orchestrent les scripts Toolbox** plutôt que de réimplémenter les fonctionnalités.

---

## 📦 Structure du Projet

```
SHA-Toolbox/
├── README.md                                    # Ce fichier
├── check_playbook.yml                           # Playbook de vérification
├── main_playbook_prod.yml                       # Playbook principal production
├── inventories/                                 # Inventaires Ansible
│   ├── prod/
│   ├── qual/
│   └── dev/
├── roles/                                       # Rôles Ansible
│   ├── app_environment_builder/                 # Détection et construction environnement
│   ├── ips_toolbox_system/                      # ✅ Gestion système (arborescence)
│   ├── ips_toolbox_banner/                      # ✅ Création bannières
│   ├── ips_toolbox_users/                       # ✅ Création utilisateurs
│   ├── ips_toolbox_toolboxes/                   # Vérification Toolbox
│   ├── ips_toolbox_dynatrace/                   # ✅ Configuration Dynatrace
│   ├── ips_toolbox_illumio/                     # ✅ Configuration Illumio
│   ├── ips_toolbox_backup/                      # ✅ Configuration TSM/REAR
│   ├── ips_toolbox_autosys/                     # Configuration Autosys
│   ├── ips_toolbox_appli/                       # Gestion applications
│   └── ...
└── templates/                                   # Templates Jinja2
    ├── motd.j2
    ├── issue.j2
    └── ...
```

---

## 🚀 Démarrage Rapide

### Prérequis

1. **Ansible** : Version 2.9+
2. **Accès SSH** : Clés SSH configurées pour les serveurs cibles
3. **Privilèges** : Accès sudo/root sur les serveurs cibles
4. **Toolbox IPS** : Présente sur le serveur cible (version >= 18.2.0)

### Installation

```bash
# 1. Cloner le dépôt
git clone https://github.com/Fonipanda/SHA-Toolbox.git
cd SHA-Toolbox

# 2. Vérifier la syntaxe
ansible-playbook main_playbook_prod.yml --syntax-check

# 3. Exécuter en mode check (dry-run)
ansible-playbook main_playbook_prod.yml -i inventories/prod/hosts --check

# 4. Exécuter en production
ansible-playbook main_playbook_prod.yml -i inventories/prod/hosts
```

---

## 📝 Configuration via Survey AAP2

### Variables Obligatoires

Ces variables doivent être renseignées dans le **Survey (questionnaire)** de l'interface AAP2 (Ansible Automation Platform 2).

#### Section 1 : Identification du Serveur

| Variable | Description | Type | Exemple |
|----------|-------------|------|---------|
| `hostname` | Nom du serveur cible | Texte | `s02vl9942814` |

#### Section 2 : Identification de l'Application

| Variable | Description | Type | Exemple |
|----------|-------------|------|---------|
| `codeAP` | Code application (APxxxxx) | Texte | `AP12345` |
| `code5car` | Code 5 caractères | Texte | `ABCDE` |
| `system_iis` | Identifiant instance (01, 02, ...) | Texte | `01` |

#### Section 3 : Environnement

| Variable | Description | Type | Valeurs Possibles |
|----------|-------------|------|-------------------|
| `environnement` | Environnement cible | Choix | `PRODUCTION`, `QUALIFICATION`, `DEVELOPPEMENT` |

#### Section 4 : Configuration Filesystem (Optionnel)

| Variable | Description | Type | Défaut | Exemple |
|----------|-------------|------|--------|---------|
| `system_vgName` | Volume Group | Texte | `vg_apps` | `vg_apps` |
| `system_lvSize` | Taille des LV en Go | Nombre | `10` | `20` |
| `system_lvEx` | LV à exclure | Texte | `` | `lv_shared_tmp,lv_shared_arch` |

#### Section 5 : Utilisateur Applicatif (Optionnel)

| Variable | Description | Type | Exemple |
|----------|-------------|------|---------|
| `system_username` | Nom utilisateur | Texte | `oracle` |
| `system_group` | Groupe | Texte | `dba` |
| `system_NNN` | Permissions (NNN) | Texte | `755` |

**Note** : Si non renseigné, les utilisateurs sont créés automatiquement selon le middleware détecté.

---

## 🎨 Exemple de Survey AAP2

### Configuration du Questionnaire

```yaml
survey_spec:
  name: "SHA-Toolbox - Création Socle Applicatif"
  description: "Configuration de la couche applicative sur un serveur SHA"
  spec:
    # Section 1 : Serveur
    - question_name: "Nom du serveur cible"
      question_description: "Nom d'hôte du serveur (ex: s02vl9942814)"
      required: true
      type: "text"
      variable: "hostname"
      min: 1
      max: 64
      default: ""
    
    # Section 2 : Application
    - question_name: "Code Application (APxxxxx)"
      question_description: "Code application au format APxxxxx"
      required: true
      type: "text"
      variable: "codeAP"
      min: 7
      max: 7
      default: ""
    
    - question_name: "Code 5 caractères"
      question_description: "Code application sur 5 caractères"
      required: true
      type: "text"
      variable: "code5car"
      min: 5
      max: 5
      default: ""
    
    - question_name: "Identifiant instance"
      question_description: "Identifiant instance (01, 02, ...)"
      required: true
      type: "text"
      variable: "system_iis"
      min: 2
      max: 2
      default: "01"
    
    # Section 3 : Environnement
    - question_name: "Environnement"
      question_description: "Environnement cible"
      required: true
      type: "multiplechoice"
      variable: "environnement"
      choices:
        - "PRODUCTION"
        - "QUALIFICATION"
        - "DEVELOPPEMENT"
      default: "PRODUCTION"
    
    # Section 4 : Filesystem
    - question_name: "Volume Group"
      question_description: "Nom du Volume Group (défaut: vg_apps)"
      required: false
      type: "text"
      variable: "system_vgName"
      default: "vg_apps"
    
    - question_name: "Taille des LV (Go)"
      question_description: "Taille des Logical Volumes en Go (défaut: 10)"
      required: false
      type: "integer"
      variable: "system_lvSize"
      min: 1
      max: 1000
      default: 10
    
    - question_name: "LV à exclure"
      question_description: "Liste des LV à exclure (séparés par des virgules)"
      required: false
      type: "text"
      variable: "system_lvEx"
      default: ""
    
    # Section 5 : Utilisateur
    - question_name: "Nom utilisateur applicatif"
      question_description: "Nom utilisateur (laisser vide pour auto-détection)"
      required: false
      type: "text"
      variable: "system_username"
      default: ""
    
    - question_name: "Groupe applicatif"
      question_description: "Groupe (laisser vide pour auto-détection)"
      required: false
      type: "text"
      variable: "system_group"
      default: ""
```

---

## 🔧 Rôles Principaux

### 1. `ips_toolbox_system` - Gestion Système

**Fonction** : Création de l'arborescence applicative via le script Toolbox `exploit_arbo-app.ksh`

**Fichier principal** : `roles/ips_toolbox_system/tasks/create-directory_Linux_system.yml`

**Script Toolbox utilisé** :
```bash
/apps/toolboxes/exploit/bin/exploit_arbo-app.ksh \
  codeAP=AP12345 \
  code5car=ABCDE \
  id=01 \
  vg=vg_apps \
  lv=lv_ABCDE:10,lv_ABCDE_ti:10,... \
  user=oracle:dba,755
```

**Arborescence créée** :
```
/applis/
├── AP12345-ABCDE-01/
│   ├── transfer/in/
│   ├── transfer/out/
│   ├── tmp/
│   └── archives/
├── shared/
│   ├── tmp/
│   └── archives/
├── logs/
│   ├── AP12345-ABCDE-01/
│   └── shared/
└── delivery/
    ├── AP12345-ABCDE-01/
    └── shared/
```

---

### 2. `ips_toolbox_banner` - Création Bannières

**Fonction** : Génération des bannières de connexion personnalisées

**Fichiers créés** :
- `/etc/motd` : Message Of The Day (affiché après connexion)
- `/etc/issue` : Bannière pre-login (console locale)
- `/etc/issue.net` : Bannière pre-login (SSH)

**Template** : `roles/ips_toolbox_banner/templates/motd.j2`

**Exemple de bannière** :
```
================================================================================
SYSTÈME D'HÉBERGEMENT APPLICATIF (SHA)
================================================================================

Serveur: s02vl9942814
Système: RedHat 9.4
Environnement: PRODUCTION
Code Application: AP12345
Middlewares détectés: Oracle

ACCÈS RESTREINT - UTILISATEURS AUTORISÉS UNIQUEMENT

================================================================================
```

---

### 3. `ips_toolbox_users` - Création Utilisateurs

**Fonction** : Création automatique des utilisateurs techniques selon le middleware détecté

**Utilisateurs créés** :

| Middleware | Utilisateur | Groupe | Groupes Secondaires | Sudo |
|------------|-------------|--------|---------------------|------|
| Oracle | `oracle` | `dba` | `oinstall` | ✅ Oui |
| WebSphere | `wasadmin` | `wasadm` | - | ✅ Oui |
| Liberty | `liberty` | `liberty` | - | ✅ Oui |
| CFT | `cft` | `cft` | - | ❌ Non |

**Détection automatique** : Le rôle `app_environment_builder` détecte les middlewares installés et la variable `detected_middlewares` est utilisée pour créer les utilisateurs correspondants.

---

### 4. `ips_toolbox_dynatrace` - Configuration Dynatrace

**Fonction** : Vérification et démarrage de l'agent Dynatrace OneAgent

**Actions** :
1. ✅ Vérification de l'installation (`/apps/dynatrace/oneagent/agent/tools/oneagentctl`)
2. ✅ Vérification de la version
3. ✅ Vérification du statut
4. ✅ **Démarrage automatique si arrêté**
5. ✅ Vérification du mode (FullStack attendu)
6. ✅ Vérification de la connexion au serveur

**Commandes utilisées** :
```bash
/apps/dynatrace/oneagent/agent/tools/oneagentctl --version
/apps/dynatrace/oneagent/agent/tools/oneagentctl status
/apps/dynatrace/oneagent/agent/tools/oneagentctl start      # Si arrêté
/apps/dynatrace/oneagent/agent/tools/oneagentctl --get-mode
```

---

### 5. `ips_toolbox_illumio` - Configuration Illumio

**Fonction** : Vérification et passage en mode Enforced de l'agent Illumio VEN

**Actions** :
1. ✅ Vérification de l'installation (`/opt/illumio_ven/illumio-ven-ctl`)
2. ✅ Vérification de la version
3. ✅ Vérification du statut
4. ✅ **Démarrage automatique si arrêté**
5. ✅ Vérification du mode actuel
6. ✅ **Passage en mode Enforced si nécessaire**
7. ✅ Vérification de la connectivité au PCE

**Modes Illumio** :
- **Idle** : Agent inactif
- **Visibility** : Mode observation uniquement
- **Enforced** : Mode sécurité actif ✅ (attendu)

**Commandes utilisées** :
```bash
/opt/illumio_ven/illumio-ven-ctl version
/opt/illumio_ven/illumio-ven-ctl status
/opt/illumio_ven/illumio-ven-ctl start                      # Si arrêté
/opt/illumio_ven/illumio-ven-ctl set-mode enforced          # Si pas Enforced
```

---

### 6. `ips_toolbox_backup` - Configuration TSM/REAR

**Fonction** : Vérification et démarrage du client TSM (Tivoli Storage Manager)

**Actions** :
1. ✅ Vérification du client TSM (`/opt/tivoli/tsm/client/ba/bin/dsmc`)
2. ✅ Vérification de la version
3. ✅ Vérification du daemon dsmcad
4. ✅ **Démarrage automatique du service si arrêté**
5. ✅ **Activation au démarrage (systemctl enable)**
6. ✅ Lecture de la configuration `dsm.opt`
7. ✅ Vérification de la connectivité au serveur TSM
8. ✅ Vérification du scheduler TSM
9. ✅ Vérification du script REAR (`/apps/sys/admin/rear-bp2i.sh`)

**Commandes utilisées** :
```bash
/opt/tivoli/tsm/client/ba/bin/dsmc -version
systemctl status dsmcad
systemctl start dsmcad                                       # Si arrêté
systemctl enable dsmcad                                      # Activation auto
/opt/tivoli/tsm/client/ba/bin/dsmc query session
/opt/tivoli/tsm/client/ba/bin/dsmc query schedule
```

---

## 📊 Workflow d'Exécution

### Phase 0 : Initialisation

1. Collecte des facts Ansible
2. Détection du système d'exploitation
3. Détection des middlewares installés

### Phase 1 : Vérification Toolbox

1. Vérification de la présence `/apps/toolboxes`
2. Lecture de la version actuelle
3. Vérification version >= 18.2.0

### Phase 2 : Création Arborescence

1. Vérification des variables `codeAP` et `code5car`
2. **Appel du script Toolbox** `exploit_arbo-app.ksh`
3. Vérification de la création des filesystems
4. Enregistrement des résultats

### Phase 3 : Création Bannière

1. Génération bannière `/etc/motd` via template Jinja2
2. Génération bannière `/etc/issue` via template Jinja2
3. Configuration SSH pour afficher la bannière
4. Restart sshd si nécessaire

### Phase 4 : Création Utilisateurs

1. Détection des middlewares installés
2. Création des utilisateurs selon middleware (oracle, wasadmin, liberty, cft)
3. Configuration des groupes et permissions
4. Configuration sudo pour les utilisateurs admin
5. Déploiement des clés SSH (si disponibles)

### Phase 5 : Configuration Services

1. **Dynatrace** : Vérification et démarrage agent
2. **Illumio** : Vérification et passage en mode Enforced
3. **TSM** : Vérification et démarrage service dsmcad

### Phase 6 : Finalisation

1. Génération du rapport de conformité
2. Enregistrement des résultats
3. Notification de fin d'exécution

---

## ✅ Tests et Validation

### Test 1 : Vérification de la Syntaxe

```bash
ansible-playbook main_playbook_prod.yml --syntax-check
```

**Résultat attendu** : `playbook: main_playbook_prod.yml` (sans erreur)

### Test 2 : Exécution en Mode Check (Dry-Run)

```bash
ansible-playbook main_playbook_prod.yml -i inventories/prod/hosts --check
```

**Résultat attendu** : Simulation des changements sans modification du système

### Test 3 : Exécution Réelle

```bash
ansible-playbook main_playbook_prod.yml -i inventories/prod/hosts
```

**Résultat attendu** :
- ✅ Arborescence `/applis` créée
- ✅ Bannières créées (`/etc/motd`, `/etc/issue`)
- ✅ Utilisateurs créés (oracle, wasadmin, etc.)
- ✅ Dynatrace démarré
- ✅ Illumio en mode Enforced
- ✅ TSM démarré

---

## 📖 Documentation Complémentaire

### Scripts Toolbox Disponibles

#### 1. `exploit_arbo-app.ksh`

**Chemin** : `/apps/toolboxes/exploit/bin/exploit_arbo-app.ksh`

**Description** : Création automatique de l'arborescence applicative complète avec LV et filesystems

**Paramètres** :
- `codeAP=<CODE>` : Code application (obligatoire)
- `code5car=<CODE>` : Code 5 caractères (obligatoire)
- `id=<ID>` : Identifiant instance (défaut: 01)
- `vg=<VG>` : Volume Group (défaut: vg_apps)
- `lv=<SPEC>` : Spécification des LV avec tailles
- `exclude=<LIST>` : Liste des LV à exclure
- `user=<USER>:<GROUP>,<NNN>` : Utilisateur et groupe

**Exemple** :
```bash
/apps/toolboxes/exploit/bin/exploit_arbo-app.ksh \
  codeAP=AP12345 \
  code5car=ABCDE \
  id=01 \
  vg=vg_apps \
  lv=lv_ABCDE:10,lv_ABCDE_ti:10,lv_ABCDE_to:10,lv_ABCDE_tmp:10,lv_ABCDE_arch:10,lv_log_ABCDE:10,lv_shared:10,lv_shared_tmp:10,lv_shared_arch:10,lv_log_shared:10,lv_dlv_shared:10,lv_dlv_ABCDE:10 \
  user=oracle:dba,755
```

#### 2. `exploit_app.ksh`

**Chemin** : `/apps/toolboxes/exploit/bin/exploit_app.ksh`

**Description** : Gestion des applications (démarrage, arrêt, statut)

**Syntaxe** :
```bash
/apps/toolboxes/exploit/bin/exploit_app.ksh <action> <appli_name>
```

**Actions** :
- `start` : Démarrage de l'application
- `stop` : Arrêt de l'application
- `status` : Statut de l'application
- `restart` : Redémarrage de l'application

**Exemple** :
```bash
/apps/toolboxes/exploit/bin/exploit_app.ksh status myapp
/apps/toolboxes/exploit/bin/exploit_app.ksh start myapp
```

#### 3. `btsauve.ksh`

**Chemin** : `/apps/toolboxes/backup_restore/scripts/btsauve.ksh`

**Description** : Lancement des sauvegardes applicatives

**Syntaxe** :
```bash
/apps/toolboxes/backup_restore/scripts/btsauve.ksh backup <TYPE>
```

**Types** :
- `INCR_APPLI` : Sauvegarde incrémentale applicative
- `FULL_APPLI` : Sauvegarde complète applicative

**Exemple** :
```bash
/apps/toolboxes/backup_restore/scripts/btsauve.ksh backup INCR_APPLI
```

---

## 🐛 Dépannage

### Erreur : "Toolbox non trouvée"

**Cause** : Le répertoire `/apps/toolboxes` n'existe pas sur le serveur cible

**Solution** :
1. Vérifier que le serveur est bien un serveur SHA
2. Contacter l'équipe infrastructure pour installer la Toolbox
3. Vérifier les droits d'accès au répertoire

### Erreur : "Version Toolbox insuffisante"

**Cause** : La version de la Toolbox est inférieure à 18.2.0

**Solution** :
1. Mettre à jour la Toolbox sur le serveur cible
2. Contacter l'équipe infrastructure pour la mise à jour

### Erreur : "Variables obligatoires manquantes"

**Cause** : Les variables `codeAP` ou `code5car` ne sont pas renseignées dans le Survey

**Solution** :
1. Vérifier que le Survey AAP2 est correctement configuré
2. Renseigner les variables obligatoires avant l'exécution

### Erreur : "Agent Dynatrace non démarré"

**Cause** : L'agent Dynatrace n'a pas pu être démarré

**Solution** :
1. Vérifier que l'agent est installé : `/apps/dynatrace/oneagent/agent/tools/oneagentctl`
2. Vérifier les logs : `/var/log/dynatrace/`
3. Démarrer manuellement : `/apps/dynatrace/oneagent/agent/tools/oneagentctl start`

### Erreur : "Illumio non en mode Enforced"

**Cause** : L'agent Illumio n'a pas pu passer en mode Enforced

**Solution** :
1. Vérifier que l'agent est installé : `/opt/illumio_ven/illumio-ven-ctl`
2. Vérifier la connectivité au PCE
3. Passer manuellement en mode Enforced : `/opt/illumio_ven/illumio-ven-ctl set-mode enforced`

---

## 📞 Support

Pour toute question ou problème :

- **Documentation** : Consulter les README dans le dépôt
- **Logs** : Vérifier les logs Ansible dans `/tmp/ansible_checks/`
- **Équipe** : Contacter l'équipe d'automatisation SHA

---

## 📜 Licence

Ce projet est propriété de l'organisation et est destiné à un usage interne uniquement.

---

## 🔄 Historique des Versions

### Version 3.0 (16 octobre 2025)

- ✅ Révision complète pour utiliser au maximum la Toolbox IPS existante
- ✅ Correction de la syntaxe YAML dans `create-directory_Linux_system.yml`
- ✅ Ajout du rôle `ips_toolbox_banner` pour la création des bannières
- ✅ Ajout du rôle `ips_toolbox_users` pour la création des utilisateurs
- ✅ Amélioration du rôle `ips_toolbox_dynatrace` avec restart automatique
- ✅ Amélioration du rôle `ips_toolbox_illumio` avec passage en mode Enforced
- ✅ Amélioration du rôle `ips_toolbox_backup` avec gestion du service dsmcad
- ✅ Documentation complète du Survey AAP2

### Version 2.0 (14 octobre 2025)

- Corrections initiales et analyse du projet

### Version 1.0 (Date antérieure)

- Version initiale du projet

---

**Auteur** : Équipe Automatisation SHA  
**Contact** : automation-sha@internal.com  
**Date de dernière mise à jour** : 16 octobre 2025

