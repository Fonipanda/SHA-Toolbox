# Analyse Révisée - Utilisation Maximale de la Toolbox Existante

**Date** : 16 octobre 2025  
**Version** : 3.0 - Révision basée sur la Toolbox existante  
**Analyste** : Manus AI Agent

---

## 🔍 Découverte Importante

Après réanalyse approfondie, j'ai identifié que **la Toolbox IPS est déjà présente sur le serveur** et contient de nombreux scripts prêts à l'emploi que les rôles doivent utiliser.

---

## 📦 Structure de la Toolbox Existante

### Arborescence de `/apps/toolboxes`

```
/apps/toolboxes/
├── version                                      # Fichier de version (format: nom|18.2.0)
├── exploit/                                     # Scripts d'exploitation
│   └── bin/
│       ├── exploit_arbo-app.ksh                 # ✅ Création arborescence applicative
│       └── exploit_app.ksh                      # ✅ Gestion des applications (start/stop/status)
├── backup_restore/                              # Scripts de sauvegarde
│   └── scripts/
│       ├── verif_backup.ksh                     # ✅ Vérification des sauvegardes
│       └── btsauve.ksh                          # ✅ Lancement sauvegarde (INCR_APPLI)
└── scheduler/                                   # Scripts ordonnanceurs
    ├── autosys/
    │   ├── menu_autosys/
    │   │   └── include/
    │       └── toolboxFunctions.ksh             # ✅ Fonctions Autosys
    │   └── script/
    │       ├── autosys_pres_toolbox             # ✅ Présentation Autosys
    │       ├── autosys_pres_toolbox_en          # ✅ Version anglaise
    │       └── autosys_pres_toolbox_fr          # ✅ Version française
    └── controlm/
        └── .profile_toolboxes                   # ✅ Profile Control-M
```

---

## 🎯 Scripts Toolbox Utilisés par les Rôles

### 1. Script `exploit_arbo-app.ksh`

**Utilisé par** : `roles/ips_toolbox_system/tasks/create-directory_Linux_system.yml`

**Fonction** : Création automatique de l'arborescence applicative complète

**Syntaxe** :
```bash
/apps/toolboxes/exploit/bin/exploit_arbo-app.ksh \
  codeAP=<CODE_AP> \
  code5car=<CODE_5CAR> \
  [id=<ID>] \
  [vg=<VG_NAME>] \
  [lv=<LV_SPEC>] \
  [exclude=<EXCLUDE_LIST>] \
  [user=<USER>:<GROUP>,<NNN>]
```

**Paramètres** :
- `codeAP` : Code application (ex: AP12345)
- `code5car` : Code 5 caractères (ex: ABCDE)
- `id` : Identifiant instance (défaut: 01)
- `vg` : Volume Group (défaut: vg_apps)
- `lv` : Spécification des LV avec tailles
- `exclude` : Liste des LV à exclure
- `user` : Utilisateur:Groupe,NNN

**Arborescence créée** :
```
/applis/
├── <codeAP>-<code5car>-<id>/
│   ├── transfer/in/
│   ├── transfer/out/
│   ├── tmp/
│   └── archives/
├── shared/
│   ├── tmp/
│   └── archives/
├── logs/
│   ├── <codeAP>-<code5car>-<id>/
│   └── shared/
└── delivery/
    ├── <codeAP>-<code5car>-<id>/
    └── shared/
```

---

### 2. Script `exploit_app.ksh`

**Utilisé par** : `roles/ips_toolbox_appli/tasks/*`

**Fonction** : Gestion des applications (démarrage, arrêt, statut)

**Syntaxe** :
```bash
/apps/toolboxes/exploit/bin/exploit_app.ksh <action> <appli_name>
```

**Actions disponibles** :
- `start` : Démarrage de l'application
- `stop` : Arrêt de l'application
- `status` : Statut de l'application
- `restart` : Redémarrage de l'application

---

### 3. Script `btsauve.ksh`

**Utilisé par** : `roles/ips_toolbox_backup/tasks/run_incr_*_backup.yml`

**Fonction** : Lancement des sauvegardes applicatives

**Syntaxe** :
```bash
/apps/toolboxes/backup_restore/scripts/btsauve.ksh backup <TYPE>
```

**Types de sauvegarde** :
- `INCR_APPLI` : Sauvegarde incrémentale applicative
- `FULL_APPLI` : Sauvegarde complète applicative

---

### 4. Script `verif_backup.ksh`

**Utilisé par** : `roles/ips_toolbox_backup/tasks/chk_bkp_oracle_*_backup.yml`

**Fonction** : Vérification de l'état des sauvegardes

**Syntaxe** :
```bash
/apps/toolboxes/backup_restore/scripts/verif_backup.ksh
```

---

## ✅ Révision de la Stratégie

### Principe Fondamental

**Les rôles Ansible ne doivent PAS réinventer la roue** mais :

1. ✅ **Vérifier** que la Toolbox est installée et à jour
2. ✅ **Utiliser** les scripts existants de la Toolbox
3. ✅ **Compléter** uniquement ce que la Toolbox ne fait pas

### Ce que la Toolbox FAIT DÉJÀ

| Fonctionnalité | Script Toolbox | Rôle Ansible |
|----------------|----------------|--------------|
| Création arborescence `/applis` | ✅ `exploit_arbo-app.ksh` | `ips_toolbox_system` |
| Gestion applications (start/stop) | ✅ `exploit_app.ksh` | `ips_toolbox_appli` |
| Sauvegarde applicative | ✅ `btsauve.ksh` | `ips_toolbox_backup` |
| Vérification sauvegardes | ✅ `verif_backup.ksh` | `ips_toolbox_backup` |
| Fonctions Autosys | ✅ `toolboxFunctions.ksh` | `ips_toolbox_autosys` |

### Ce que la Toolbox NE FAIT PAS (à implémenter dans Ansible)

| Fonctionnalité | À implémenter | Rôle Ansible |
|----------------|---------------|--------------|
| Création bannière `/etc/motd` | ❌ | `ips_toolbox_banner` |
| Création utilisateurs techniques | ❌ | `ips_toolbox_users` |
| Démarrage agent Dynatrace | ❌ | `ips_toolbox_dynatrace` |
| Mode Enforced Illumio | ❌ | `ips_toolbox_illumio` |
| Démarrage service TSM dsmcad | ❌ | `ips_toolbox_backup` |

---

## 🔧 Corrections Révisées

### 1. ✅ Correction `create-directory_Linux_system.yml`

**Stratégie** : Corriger uniquement la syntaxe YAML, **conserver l'appel au script Toolbox**

Le fichier utilise déjà correctement le script `/apps/toolboxes/exploit/bin/exploit_arbo-app.ksh`.

**Corrections à apporter** :
- ✅ Corriger la syntaxe `assert`
- ✅ Améliorer la gestion des variables
- ✅ **CONSERVER** l'appel au script Toolbox

---

### 2. ✅ Rôle Banner (NOUVEAU)

**Stratégie** : Créer un rôle simple car la Toolbox ne gère pas les bannières

**Fichiers à créer** :
- `roles/ips_toolbox_banner/tasks/create_Linux_banner.yml`
- `roles/ips_toolbox_banner/templates/motd.j2`
- `roles/ips_toolbox_banner/templates/issue.j2`

**Pourquoi** : La Toolbox ne contient pas de scripts pour gérer `/etc/motd` ou `/etc/issue`.

---

### 3. ✅ Rôle Users (NOUVEAU)

**Stratégie** : Créer un rôle pour les utilisateurs techniques car la Toolbox ne les gère pas

**Fichier à créer** :
- `roles/ips_toolbox_users/tasks/create_Linux_users.yml`

**Pourquoi** : La Toolbox ne contient pas de scripts pour créer les utilisateurs `oracle`, `wasadmin`, `liberty`, `cft`.

---

### 4. ✅ Amélioration Dynatrace

**Stratégie** : Ajouter uniquement le démarrage de l'agent (la Toolbox ne le fait pas)

**Fichier à modifier** :
- `roles/ips_toolbox_dynatrace/tasks/check_Linux_dynatrace.yml`

**Ajouts** :
- Vérification du statut de l'agent
- Démarrage si arrêté
- Vérification du mode FullStack

---

### 5. ✅ Amélioration Illumio

**Stratégie** : Ajouter le passage en mode Enforced (la Toolbox ne le fait pas)

**Fichier à modifier** :
- `roles/ips_toolbox_illumio/tasks/check_Linux_illumio.yml`

**Ajouts** :
- Vérification du mode actuel
- Passage en mode Enforced si nécessaire

---

### 6. ✅ Amélioration TSM

**Stratégie** : Ajouter la vérification et le démarrage du service dsmcad

**Fichier à modifier** :
- `roles/ips_toolbox_backup/tasks/check_Linux_tsm.yml`

**Ajouts** :
- Vérification du service systemd `dsmcad`
- Démarrage et activation si arrêté

---

### 7. ❌ PAS DE RÔLE `install_toolboxes`

**Stratégie** : La Toolbox est déjà présente, pas besoin d'installation

**Raison** : Le log montre que `/apps/toolboxes` existe déjà avec la version 18.2.0+.

**Action** : Vérifier uniquement la version, pas d'installation automatique.

---

## 📋 Variables du Survey AAP2

### Variables Obligatoires

```yaml
# === IDENTIFICATION SERVEUR ===
hostname: "s02vl9942814"                         # Nom du serveur cible

# === IDENTIFICATION APPLICATION ===
codeAP: "AP12345"                                # Code application (APxxxxx)
code5car: "ABCDE"                                # Code 5 caractères
system_iis: "01"                                 # Identifiant instance (01, 02, etc.)

# === ENVIRONNEMENT ===
environnement: "PRODUCTION"                      # PRODUCTION, QUALIFICATION, DEVELOPPEMENT

# === FILESYSTEM ===
system_vgName: "vg_apps"                         # Volume Group (défaut: vg_apps)
system_lvSize: "10"                              # Taille des LV en Go (défaut: 10)

# === EXCLUSIONS FILESYSTEM (OPTIONNEL) ===
system_lvEx: ""                                  # LV à exclure (ex: lv_shared_tmp,lv_shared_arch)
system_lvEx1: ""                                 # Exclusions supplémentaires 1
system_lvEx2: ""                                 # Exclusions supplémentaires 2

# === UTILISATEUR APPLICATIF (OPTIONNEL) ===
system_username: ""                              # Nom utilisateur (ex: oracle, wasadmin)
system_group: ""                                 # Groupe (ex: dba, wasadm)
system_NNN: ""                                   # NNN (ex: 755)
```

### Variables Optionnelles

```yaml
# === MIDDLEWARE (DÉTECTÉ AUTOMATIQUEMENT) ===
# Ces variables sont renseignées automatiquement par la détection
detected_middlewares: []                         # Liste des middlewares détectés
detected_services: []                            # Liste des services détectés

# === UTILISATEURS SUPPLÉMENTAIRES ===
app_user: ""                                     # Utilisateur applicatif générique
app_group: ""                                    # Groupe applicatif générique

# === TOOLBOX ===
toolbox_min_version: "1820"                      # Version minimale requise (18.2.0)
```

---

## 📝 Questionnaire Survey AAP2

### Section 1 : Identification du Serveur

| Question | Variable | Type | Obligatoire | Exemple |
|----------|----------|------|-------------|---------|
| Nom du serveur cible | `hostname` | Texte | ✅ Oui | s02vl9942814 |

### Section 2 : Identification de l'Application

| Question | Variable | Type | Obligatoire | Exemple |
|----------|----------|------|-------------|---------|
| Code Application (APxxxxx) | `codeAP` | Texte | ✅ Oui | AP12345 |
| Code 5 caractères | `code5car` | Texte | ✅ Oui | ABCDE |
| Identifiant instance | `system_iis` | Texte | ✅ Oui | 01 |

### Section 3 : Environnement

| Question | Variable | Type | Obligatoire | Exemple |
|----------|----------|------|-------------|---------|
| Environnement cible | `environnement` | Choix | ✅ Oui | PRODUCTION |

**Choix disponibles** :
- PRODUCTION
- QUALIFICATION
- DEVELOPPEMENT

### Section 4 : Configuration Filesystem

| Question | Variable | Type | Obligatoire | Exemple |
|----------|----------|------|-------------|---------|
| Volume Group | `system_vgName` | Texte | ❌ Non | vg_apps |
| Taille des LV (Go) | `system_lvSize` | Nombre | ❌ Non | 10 |
| LV à exclure | `system_lvEx` | Texte | ❌ Non | lv_shared_tmp |

**Note** : Si non renseigné, les valeurs par défaut sont utilisées.

### Section 5 : Utilisateur Applicatif (Optionnel)

| Question | Variable | Type | Obligatoire | Exemple |
|----------|----------|------|-------------|---------|
| Nom utilisateur | `system_username` | Texte | ❌ Non | oracle |
| Groupe | `system_group` | Texte | ❌ Non | dba |
| Permissions (NNN) | `system_NNN` | Texte | ❌ Non | 755 |

**Note** : Laisser vide pour création automatique selon middleware détecté.

---

## 🎯 Workflow Révisé

### Phase 1 : Vérification Toolbox

1. ✅ Vérifier présence `/apps/toolboxes`
2. ✅ Lire version actuelle
3. ✅ Vérifier version >= 18.2.0
4. ❌ **PAS d'installation** (Toolbox déjà présente)

### Phase 2 : Création Arborescence

1. ✅ Vérifier variables `codeAP` et `code5car`
2. ✅ **Appeler script Toolbox** `exploit_arbo-app.ksh`
3. ✅ Vérifier création des filesystems
4. ✅ Enregistrer résultats

### Phase 3 : Création Bannière

1. ✅ Générer bannière `/etc/motd` via template Jinja2
2. ✅ Générer bannière `/etc/issue` via template Jinja2
3. ✅ Configurer SSH pour afficher la bannière

### Phase 4 : Création Utilisateurs

1. ✅ Détecter middlewares installés
2. ✅ Créer utilisateurs selon middleware (oracle, wasadmin, liberty, cft)
3. ✅ Configurer groupes et permissions
4. ✅ Configurer sudo si nécessaire

### Phase 5 : Configuration Services

1. ✅ Dynatrace : Vérifier et démarrer agent
2. ✅ Illumio : Vérifier et passer en mode Enforced
3. ✅ TSM : Vérifier et démarrer service dsmcad

---

## 📊 Résumé des Fichiers à Fournir

### Fichiers à Corriger (1)

1. ✅ `roles/ips_toolbox_system/tasks/create-directory_Linux_system.yml` (syntaxe YAML)

### Fichiers à Créer (6)

1. ✅ `roles/ips_toolbox_banner/tasks/create_Linux_banner.yml`
2. ✅ `roles/ips_toolbox_banner/templates/motd.j2`
3. ✅ `roles/ips_toolbox_banner/templates/issue.j2`
4. ✅ `roles/ips_toolbox_banner/handlers/main.yml`
5. ✅ `roles/ips_toolbox_users/tasks/create_Linux_users.yml`
6. ✅ `roles/ips_toolbox_users/defaults/main.yml`

### Fichiers à Améliorer (3)

1. ✅ `roles/ips_toolbox_dynatrace/tasks/check_Linux_dynatrace.yml` (+ restart)
2. ✅ `roles/ips_toolbox_illumio/tasks/check_Linux_illumio.yml` (+ mode Enforced)
3. ✅ `roles/ips_toolbox_backup/tasks/check_Linux_tsm.yml` (+ service dsmcad)

### Documentation (1)

1. ✅ `README.md` (complet et actualisé)

---

**Total** : 11 fichiers à fournir

