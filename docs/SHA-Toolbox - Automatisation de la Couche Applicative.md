# SHA-Toolbox - Automatisation de la Couche Applicative

**Version** : 4.0  
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
├── main_playbook.yml                            # Playbook principal
├── check_playbook.yml                           # Playbook de vérification
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
ansible-playbook main_playbook.yml --syntax-check

# 3. Exécuter en mode check (dry-run)
ansible-playbook main_playbook.yml -i inventories/prod/hosts --check

# 4. Exécuter en production
ansible-playbook main_playbook.yml -i inventories/prod/hosts
```

---

## 📝 Configuration via Survey AAP2

### Variables Obligatoires (3 uniquement)

Le Survey AAP2 ne demande que **3 variables essentielles**. Toutes les autres utilisent les valeurs par défaut.

#### Variable 1 : Hostname

| Paramètre | Description | Exemple |
|-----------|-------------|---------|
| **Variable** | `Hostname` | `s02vl9942814` ou `S02VL9942814` |
| **Type** | Texte | Casse libre |
| **Obligatoire** | ✅ Oui | - |

#### Variable 2 : CodeAP (5 chiffres uniquement)

| Paramètre | Description | Exemple |
|-----------|-------------|---------|
| **Variable** | `CodeAP` | `12345` |
| **Type** | Texte (5 chiffres) | **PAS de préfixe "AP"** |
| **Validation** | Regex: `^[0-9]{5}$` | - |
| **Obligatoire** | ✅ Oui | - |

**Exemples** :
- ✅ **Correct** : `12345`
- ❌ **Incorrect** : `AP12345` (pas de préfixe "AP")

#### Variable 3 : code5car

| Paramètre | Description | Exemple |
|-----------|-------------|---------|
| **Variable** | `code5car` | `ABCDE` ou `abcde` ou `Ab12E` |
| **Type** | Texte (5 alphanum) | Casse libre |
| **Validation** | Regex: `^[A-Za-z0-9]{5}$` | - |
| **Obligatoire** | ✅ Oui | - |

**Exemples** :
- ✅ **Correct** : `ABCDE`, `abcde`, `Ab12E`
- ❌ **Incorrect** : `ABC-E` (caractère spécial non autorisé)

### Valeurs par Défaut (Non Demandées dans le Survey)

| Variable | Valeur par Défaut | Description |
|----------|-------------------|-------------|
| `system_vgName` | `vg_apps` | Volume Group |
| `system_lvSize` | `1024` | Taille des LV (Mo) |
| `system_iis` | `01` | Identifiant instance |
| `environnement` | `HORSPROD` | Environnement |
| `system_uptime_limit` | `90` | Limite uptime (jours) |
| `illumio_enforcement_mode` | `enforced` | Mode Illumio |

**Ces valeurs ne sont PAS demandées dans le Survey** et sont automatiquement utilisées.

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
  lv=lv_ABCDE:10,lv_ABCDE_ti:10,...
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
Environnement: HORSPROD
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

**Détection automatique** : Le rôle `app_environment_builder` détecte les middlewares installés.

---

### 4. `ips_toolbox_dynatrace` - Configuration Dynatrace

**Fonction** : Vérification et démarrage de l'agent Dynatrace OneAgent

**Actions** :
1. ✅ Vérification de l'installation
2. ✅ Vérification de la version
3. ✅ Vérification du statut
4. ✅ **Démarrage automatique si arrêté**
5. ✅ Vérification du mode (FullStack attendu)

**Commandes utilisées** :
```bash
/apps/dynatrace/oneagent/agent/tools/oneagentctl --version
/apps/dynatrace/oneagent/agent/tools/oneagentctl status
/apps/dynatrace/oneagent/agent/tools/oneagentctl start      # Si arrêté
```

---

### 5. `ips_toolbox_illumio` - Configuration Illumio

**Fonction** : Vérification et passage en mode Enforced de l'agent Illumio VEN

**Actions** :
1. ✅ Vérification de l'installation
2. ✅ Vérification de la version
3. ✅ Vérification du statut
4. ✅ **Démarrage automatique si arrêté**
5. ✅ Vérification du mode actuel
6. ✅ **Passage en mode Enforced si nécessaire**

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
1. ✅ Vérification du client TSM
2. ✅ Vérification de la version
3. ✅ Vérification du daemon dsmcad
4. ✅ **Démarrage automatique du service si arrêté**
5. ✅ **Activation au démarrage (systemctl enable)**
6. ✅ Vérification de la connectivité au serveur TSM

**Commandes utilisées** :
```bash
/opt/tivoli/tsm/client/ba/bin/dsmc -version
systemctl status dsmcad
systemctl start dsmcad                                       # Si arrêté
systemctl enable dsmcad                                      # Activation auto
```

---

## 📊 Workflow d'Exécution

### Phase 1 : Détection et Audit Système

1. Collecte des facts Ansible
2. Détection du système d'exploitation
3. Détection des middlewares installés
4. Vérification de la Toolbox IPS

### Phase 2 : Arborescence et FileSystems

1. Vérification des variables `CodeAP` et `code5car`
2. **Appel du script Toolbox** `exploit_arbo-app.ksh`
3. Vérification de la création des filesystems
4. Enregistrement des résultats

### Phase 3 : Vérifications Système et Conformité

1. Vérification de l'uptime (< 90 jours)
2. **Dynatrace** : Vérification et démarrage agent
3. **Illumio** : Vérification et passage en mode Enforced

### Phase 4 : Sauvegarde et TSM

1. **TSM** : Vérification et démarrage service dsmcad
2. Configuration Autosys
3. Lancement sauvegarde initiale

### Phase 5 : Logs et Maintenance

1. Configuration purge automatique des logs
2. Création des timers systemd

### Phase 6 : Middlewares et Services

1. Configuration WebSphere (si détecté)
2. Configuration Oracle (si détecté)
3. Configuration IHS (si détecté)

### Phase 7 : Finalisation

1. Création bannières `/etc/motd`, `/etc/issue`
2. Création utilisateurs techniques
3. Génération du rapport de conformité

---

## ✅ Tests et Validation

### Test 1 : Vérification de la Syntaxe

```bash
ansible-playbook main_playbook.yml --syntax-check
```

**Résultat attendu** : `playbook: main_playbook.yml` (sans erreur)

### Test 2 : Exécution en Mode Check (Dry-Run)

```bash
ansible-playbook main_playbook.yml -i inventories/prod/hosts --check \
  -e "Hostname=s02vl9942814" \
  -e "CodeAP=12345" \
  -e "code5car=ABCDE"
```

**Résultat attendu** : Simulation des changements sans modification du système

### Test 3 : Exécution Réelle

```bash
ansible-playbook main_playbook.yml -i inventories/prod/hosts \
  -e "Hostname=s02vl9942814" \
  -e "CodeAP=12345" \
  -e "code5car=ABCDE"
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
- `codeAP=<CODE>` : Code application (obligatoire, ex: AP12345)
- `code5car=<CODE>` : Code 5 caractères (obligatoire, ex: ABCDE)
- `id=<ID>` : Identifiant instance (défaut: 01)
- `vg=<VG>` : Volume Group (défaut: vg_apps)
- `lv=<SPEC>` : Spécification des LV avec tailles

**Exemple** :
```bash
/apps/toolboxes/exploit/bin/exploit_arbo-app.ksh \
  codeAP=AP12345 \
  code5car=ABCDE \
  id=01 \
  vg=vg_apps \
  lv=lv_ABCDE:10,lv_ABCDE_ti:10,lv_ABCDE_to:10
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

### Erreur : "Variables Survey AAP2 invalides"

**Cause** : Les variables `CodeAP` ou `code5car` ne respectent pas le format attendu

**Solution** :
1. **CodeAP** : Vérifier que vous avez saisi exactement 5 chiffres (ex: `12345`)
2. **code5car** : Vérifier que vous avez saisi exactement 5 caractères alphanumériques (ex: `ABCDE`)
3. **Ne PAS ajouter le préfixe "AP"** au CodeAP (il sera ajouté automatiquement)

---

## 📞 Support

Pour toute question ou problème :

- **Documentation** : Consulter les README dans le dépôt
- **Logs** : Vérifier les logs Ansible dans `/tmp/ansible_reports/`
- **Équipe** : Contacter l'équipe d'automatisation SHA

---

## 📜 Licence

Ce projet est propriété de l'organisation et est destiné à un usage interne uniquement.

---

## 🔄 Historique des Versions

### Version 4.0 (16 octobre 2025)

- ✅ **Simplification du Survey AAP2** : 3 variables uniquement (Hostname, CodeAP, code5car)
- ✅ **CodeAP** : 5 chiffres uniquement (pas de préfixe "AP")
- ✅ **Casse libre** : Hostname et code5car acceptent toutes les casses
- ✅ **Valeurs par défaut** : Toutes les autres variables utilisent les defaults des rôles
- ✅ **Cohérence complète** : Vérification de la cohérence entre playbook, rôles et README

### Version 3.0 (16 octobre 2025)

- ✅ Révision complète pour utiliser au maximum la Toolbox IPS existante
- ✅ Correction de la syntaxe YAML dans `create-directory_Linux_system.yml`
- ✅ Ajout des rôles `ips_toolbox_banner` et `ips_toolbox_users`

### Version 2.0 (14 octobre 2025)

- Corrections initiales et analyse du projet

### Version 1.0 (Date antérieure)

- Version initiale du projet

---

**Auteur** : Équipe Automatisation SHA  
**Contact** : automation-sha@internal.com  
**Date de dernière mise à jour** : 16 octobre 2025

