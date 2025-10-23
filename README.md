# Create Socle - Automatisation de la Couche Applicative

**Version** : 3.1  
**Date** : 23 octobre 2025  
**Statut** : ✅ Production Ready  
**Score de Complétude** : 93.8%

[![Ansible](https://img.shields.io/badge/Ansible-2.9%2B-red)](https://www.ansible.com/)
[![Python](https://img.shields.io/badge/Python-3.11%2B-blue)](https://www.python.org/)
[![License](https://img.shields.io/badge/License-Internal-green)]()

---

## 📋 Table des Matières

- [Vue d'Ensemble](#-vue-densemble)
- [Fonctionnalités](#-fonctionnalités)
- [Systèmes Supportés](#-systèmes-supportés)
- [Architecture du Projet](#-architecture-du-projet)
- [Configuration Survey AAP2](#-configuration-survey-aap2)
- [Workflow d'Exécution](#-workflow-dexécution)
- [Installation](#-installation)
- [Utilisation](#-utilisation)
- [Dashboard Monitoring](#-dashboard-monitoring)

---

## 🎯 Vue d'Ensemble

### Descriptif du Projet

**Create Socle** est une solution d'automatisation Ansible conçue pour la **création, configuration et gestion de la couche applicative** sur des VM/VSI Linux ou Windows.

### But de Create Socle

Le projet **orchestre et utilise au maximum les scripts existants** de la **Toolbox IPS**.

1. **🚀 Automatiser** - Créer automatiquement l'arborescence applicative standard (`/applis`, `/apps`) avec filesystems
2. **⚙️ Configurer** - Déployer et configurer middlewares et services système
3. **✅ Vérifier** - Assurer la conformité selon normes IT Rules
4. **📏 Standardiser** - Garantir déploiements homogènes et reproductibles

---

## ✨ Fonctionnalités

### Les 13 Étapes d'Automatisation

| # | Étape | Description                                                     |
|---|-------|-----------------------------------------------------------------|
| 01 | **Facts Système** | Collecte informations OS, détection middleware automatique      |
| 02 | **Bannières** | Création bannières connexion (Linux / Windows)                  |
| 03 | **Utilisateurs** | Création utilisateurs techniques selon middleware détecté       |
| 04 | **Toolbox IPS** | Vérification, installation, mise à jour automatique             |
| 05 | **Arborescence** | Création `/applis`, `/apps` avec permissions 775                |
| 06 | **Filesystems** | Création LV, FS, montage, persistance /etc/fstab                |
| 07 | **NTP/Uptime** | Vérification Uptime < 90j, Chrony actif                         |
| 08 | **Dynatrace** | Configuration agent OneAgent (FullStack sauf Oracle)            |
| 09 | **Illumio** | Configuration agent VEN en mode Enforced                        |
| 10 | **TSM + REAR** | 5 checks TSM + sauvegarde REAR + envoi TSM                      |
| 11 | **Autosys** | Configuration backup applicatif                                 |
| 12 | **Backup Système** | Vérification et export TSM                                      |
| 13 | **Purge Logs** | Configuration automatique (service+timer systemd, Dimanche 20h) |

---

## 💻 Systèmes Supportés

| OS | Versions | Statut |
|----|----------|--------|
| **RHEL** | 9.x | ✅ |
| **Windows** | 2019, 2022 | ✅ |

---

## 🏗️ Architecture du Projet

### Arborescence Complète

```
SHA-Toolbox/
├── README.md                    # Documentation principale
├── main_playbook.yml            # Playbook principal (13 étapes)
├── check_playbook.yml           # Vérification conformité
├── ansible.cfg
├── inventories/                 # dev/qual/prod
├── group_vars/all.yml           # Variables globales
├── roles/                       # 30 rôles Ansible
│   ├── app_environment_builder/ # Détection OS/middleware
│   ├── ips_toolbox_system/      # Gestion filesystem
│   ├── ips_toolbox_banner/      # Bannières
│   ├── ips_toolbox_users/       # Utilisateurs techniques
│   ├── ips_toolbox_toolboxes/   # Gestion Toolbox IPS
│   ├── ips_toolbox_dynatrace/   # Agent Dynatrace
│   ├── ips_toolbox_illumio/     # Agent Illumio
│   ├── ips_toolbox_backup/      # TSM + REAR
│   ├── ips_toolbox_logs/        # Purge logs
│   └── ... (21 autres)
├── ips_toolbox_modules/         # 33 modules Python/PowerShell
├── templates/                   # Templates Jinja2
├── Streamlit/                   # Dashboard monitoring
│   └── local_dashboard.py
└── docs/                        # Documentation extensive
```

---

## 📝 Configuration Survey AAP2

### Variables du Survey (3 questions obligatoires)

| Variable | Description   | Format | Validation | Exemple               |
|----------|---------------|--------|------------|-----------------------|
| **`Hostname`** | Serveur cible | Libre | Aucune | `sXXvlXXXXXXX` |
| **`CodeAP`** | CodeAP        | 5 chiffres | `^[0-9]{5}$` | `12345`               |
| **`code5car`** | Code5car      | 5 alphanum | `^[A-Za-z0-9]{5}$` | `MYAPP`               |

**Exemple d'interface Survey** :
```
┌─────────────────────────────────────────────────────────┐
│  Création Socle Applicatif                              │
├─────────────────────────────────────────────────────────┤
│  1. Nom du serveur cible                                │
│     ┌────────────────────────────────────┐              │
│     │ sXXvlXXXXXXX                       │              │
│     └────────────────────────────────────┘              │
│                                                         │
│  2. CodeAP (5 chiffres)                                 │
│     ┌────────────────────────────────────┐              │
│     │ 12345                              │              │
│     └────────────────────────────────────┘              │
│                                                         │
│  3. Code5car                                            │
│     ┌────────────────────────────────────┐              │
│     │ MYAPP                              │              │
│     └────────────────────────────────────┘              │
│                                                         │
│                [Cancel]  [Next >]                       │
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 Workflow d'Exécution

### Flowchart Complet

```
                    ┌─────────────────────────────┐
                    │   SURVEY AAP2 - 3 Inputs    │
                    │  Hostname, CodeAP, code5car │
                    └──────────────┬──────────────┘
                                   │
                                   ▼
    ╔════════════════════════════════════════════════════╗
    ║       PHASE 1: DÉTECTION ET AUDIT SYSTÈME          ║
    ╚════════════════════════════════════════════════════╝
                                   │
                ┌──────────────────┼──────────────────┐
                │                  │                  │
                ▼                  ▼                  ▼
    ┌──────────────────┐ ┌─────────────────┐ ┌──────────────────┐
    │  01 - Facts OS   │ │  02 - Bannières │ │  03 - Users      │
    │  Détection MW    │ │     Linux/Win   │ │  oracle,wasadmin │
    └──────────────────┘ └─────────────────┘ └──────────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │  04 - Toolbox IPS           │
                    │  Vérif/Install/MAJ auto     │
                    └──────────────┬──────────────┘
                                   │
                                   ▼
    ╔════════════════════════════════════════════════════╗
    ║      PHASE 2: ARBORESCENCE ET FILESYSTEMS          ║
    ╚════════════════════════════════════════════════════╝
                                   │
                ┌──────────────────┴──────────────────┐
                │                                     │
                ▼                                     ▼
    ┌──────────────────────────┐       ┌──────────────────────────┐
    │  05 - Arborescence       │       │  06 - FileSystems        │
    │  /applis/{AP}-{5car}/    │       │  LV, mkfs, mount, fstab  │
    └──────────────────────────┘       └──────────────────────────┘
                                   │
                                   ▼
    ╔════════════════════════════════════════════════════╗
    ║   PHASE 3: VÉRIFICATIONS SYSTÈME ET CONFORMITÉ     ║
    ╚════════════════════════════════════════════════════╝
                                   │
                ┌──────────────────┼──────────────────┐
                │                  │                  │
                ▼                  ▼                  ▼
    ┌──────────────────┐ ┌─────────────────┐ ┌──────────────────┐
    │  07 - NTP/Uptime │ │  08 - Dynatrace │ │  09 - Illumio    │
    │  Uptime<90j      │ │  FullStack mode │ │  Enforced mode   │
    └──────────────────┘ └─────────────────┘ └──────────────────┘
                                   │
                                   ▼
    ╔════════════════════════════════════════════════════╗
    ║          PHASE 4: SAUVEGARDE ET TSM                ║
    ╚════════════════════════════════════════════════════╝
                                   │
                ┌──────────────────┼──────────────────┐
                │                  │                  │
                ▼                  ▼                  ▼
    ┌──────────────────┐ ┌─────────────────┐ ┌──────────────────┐
    │ 10 - TSM + REAR  │ │ 11 - Autosys    │ │ 12 - Backup Sys  │
    │ 5 Checks + Ops   │ │ Config backup   │ │ Vérif + Export   │
    └──────────────────┘ └─────────────────┘ └──────────────────┘
                                   │
                                   ▼
    ╔════════════════════════════════════════════════════╗
    ║       PHASE 5: LOGS ET MAINTENANCE                 ║
    ╚════════════════════════════════════════════════════╝
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │  13 - Purge Logs Auto       │
                    │  Service+Timer (Dim 20h)    │
                    └──────────────┬──────────────┘
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │  ✅ EXÉCUTION TERMINÉE      │
                    │  Rapports : /tmp/ansible... │
                    └─────────────────────────────┘
```

### Description Détaillée des Phases

#### Phase 1 : Détection et Audit (Étapes 01-04)

**01 - Facts Système**
- Collecte facts Ansible étendus (OS, version, hardware)
- Détection automatique middlewares (WebSphere, Oracle, Liberty, etc.)
- Support Linux/RHEL, Windows

**02 - Bannières**
- Génération bannières personnalisées `/etc/motd`, `/etc/issue` (Linux)
- Configuration Registry Windows + `C:\Windows\System32\banner.txt`
- Affichage : hostname, OS, code app, middlewares

**03 - Utilisateurs Techniques**
- Création automatique selon middleware : oracle, wasadmin, liberty, sqladmin, cft
- Configuration sudo, home directories, SSH

**04 - Toolbox IPS**
- Vérification présence `/apps/toolboxes`
- Installation si absent
- Mise à jour automatique si version < dernière
- Version minimale requise : 18.2.0

#### Phase 2 : Arborescence et FS (Étapes 05-06)

**05 - Création Arborescence**
```
/applis/
├── {CodeAP}-{code5car}-01/
│   ├── transfer/in/   (755)
│   ├── transfer/out/  (755)
│   ├── tmp/           (777)
│   └── archives/      (755)
├── shared/
├── logs/
└── delivery/

/apps/ (structure middleware-spécifique)
```

**06 - Filesystems**
- Création Logical Volumes (LV)
- mkfs sur chaque LV
- Montage filesystems
- Ajout /etc/fstab (persistence)

#### Phase 3 : Vérifications (Étapes 07-09)

**07 - NTP/Uptime**
- Vérification Uptime < 90 jours (warning si >)
- Redémarrage Chrony/NTP si nécessaire
- Vérification synchronisation horaire

**08 - Dynatrace**
- Vérification agent OneAgent installé
- Démarrage si arrêté
- Mode FullStack (sauf si Oracle détecté)

**09 - Illumio**
- Vérification agent VEN installé
- Démarrage si arrêté
- Passage mode Enforced automatique

#### Phase 4 : Sauvegarde (Étapes 10-12)

**10 - TSM + REAR (Complet)**

*5 Checks TSM :*
1. Chemin installation (`/opt/tivoli/tsm/client`)
2. Binaire `dsmc`
3. Daemon `dsmcad`
4. Fichiers config (`dsm.sys`, `dsm.opt`)
5. Résumé installation

*5 Opérations REAR+TSM :*
1. Lancement REAR (`/apps/sys/admin/rear-bp2i.sh` ou `rear -v mkbackup`)
2. Vérification connexion TSM (`dsmc query session`)
3. Envoi REAR sur TSM (`dsmc archive`)
4. Vérification présence sur TSM (`dsmc query archive`)
5. Activation service `dsmcad`

**11 - Autosys**
- Configuration backup applicatif
- Vérification scheduler

**12 - Backup Système**
- Vérification présence backup
- Export TSM si nécessaire

#### Phase 5 : Maintenance (Étape 13)

**13 - Purge Logs Automatique**

Configuration complète :
```yaml
Fichier config : /apps/toolboxes/exploit/conf/exploit_rotate-log.conf
  └─ 5+ répertoires par défaut

Service systemd : /etc/systemd/system/purge_logs.service
  └─ Type oneshot, purge fichiers > 7 jours

Timer systemd : /etc/systemd/system/purge_logs.timer
  └─ OnCalendar=Sun *-*-* 20:00:00 (Dimanche 20h)

Activation : systemctl enable/start purge_logs.timer
```

---

## 💡 Vérification Conformité

```bash
# Exécuter check_playbook
ansible-playbook check_playbook.yml \
  -i inventories/prod/hosts \
  -e "hostname=sXXvlXXXXXXX"

# Consulter rapport
cat /tmp/ansible_checks/compliance_report_*.json
```

---

## 📚 Documentation

### Fichiers de Documentation

| Fichier             | Description | Lignes           |
|---------------------|-------------|------------------|
| **README.md**       | Documentation principale | lien du playbook |
| **STREAMLIT_MyRUN** | Dashboard | -                |
| **CONFLUENCE**      | Documentation extensive | lien confluence  |

---

## 💬 Support

### Contacts

- **Email** : Team Toolin
- **Repository** : lien du dépôt GitLab

### FAQ

**Q: Exécuter uniquement certaines étapes ?**  
R: Oui, utiliser `--tags "banner,users"`

**Q: Support Windows ?**  
R: Oui, Windows Server 2019/2022. Nécessite ansible.windows.

---

**Version** : 3.1  
**Date** : 23 octobre 2025  
**Statut** : ✅ Production Ready  
**Score** : 93.8%

---