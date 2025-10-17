# Analyse de Cohérence - SHA-Toolbox

**Date** : 16 octobre 2025  
**Version** : 4.0 - Analyse de cohérence complète  
**Analyste** : Manus AI Agent

---

## 🔍 Découvertes Importantes

### 1. Variables du Survey dans le Playbook Principal

**Fichier** : `main_playbook.yml`

**Variables attendues du Survey AAP2** :
```yaml
vars:
  code_ap: "{{ CodeAP }}"          # Variable Survey: CodeAP (5 chiffres uniquement)
  code5car: "{{ code5car }}"        # Variable Survey: code5car (5 caractères alphanum)
  hostname_target: "{{ Hostname }}" # Variable Survey: Hostname
```

**Validation dans le playbook** :
```yaml
- name: "[HORSPROD] Validation des variables obligatoires du Survey AAP2"
  ansible.builtin.assert:
    that:
      - CodeAP is defined and CodeAP != ""
      - code5car is defined and code5car != ""
      - Hostname is defined and Hostname != ""
      - CodeAP | regex_search('^[0-9]{5}$')           # 5 chiffres uniquement
      - code5car | regex_search('^[A-Za-z0-9]{5}$')   # 5 alphanum (casse libre)
    fail_msg: "Variables Survey AAP2 invalides. CodeAP (5 chiffres) et code5car (5 alphanum) requis"
```

---

## ✅ Variables du Survey AAP2 (Simplifiées)

### Variables Obligatoires (3 uniquement)

| Variable Survey | Description | Format | Regex Validation | Exemple |
|-----------------|-------------|--------|------------------|---------|
| `Hostname` | Nom du serveur cible | Texte libre | *(aucune)* | `s02vl9942814` ou `S02VL9942814` |
| `CodeAP` | Code application (5 chiffres uniquement) | 5 chiffres | `^[0-9]{5}$` | `12345` |
| `code5car` | Code 5 caractères | 5 alphanum | `^[A-Za-z0-9]{5}$` | `ABCDE` ou `abcde` ou `Ab12E` |

**Note importante** :
- ✅ `Hostname` : Peu importe la casse (accepte `s02vl9942814` ou `S02VL9942814`)
- ✅ `CodeAP` : **5 chiffres uniquement** (pas de préfixe "AP")
- ✅ `code5car` : Peu importe la casse (accepte `ABCDE` ou `abcde`)

---

## 📋 Enchaînement des Phases dans le Playbook

### Phase 1 : Détection et Audit Système

| N° | Tâche | Rôle | Opération | Tags |
|----|-------|------|-----------|------|
| 01 | Mise à jour Facts | `app_environment_builder` | `detect_os` | `facts`, `detection` |
| 02 | Banner | *(à implémenter)* | - | `banner` |
| 03 | Users | *(à implémenter)* | - | `users` |
| 04 | Toolbox | `ips_toolbox_toolboxes` | `verify` | `toolbox` |
| - | Détection middleware | `app_environment_builder` | `detect_middleware` | `detection`, `middleware` |

### Phase 2 : Arborescence et FileSystems

| N° | Tâche | Rôle | Opération | Variables |
|----|-------|------|-----------|-----------|
| 05 | Arborescence | `ips_toolbox_system` | `create-directory` | `system_codeAP`, `system_code5car`, `system_vgName`, `system_lvSize` |
| 06 | FileSystems | `ips_toolbox_system` | `create-fs` | - |

### Phase 3 : Vérifications Système et Conformité

| N° | Tâche | Rôle | Opération | Variables |
|----|-------|------|-----------|-----------|
| 07 | NTP (Uptime) | `ips_toolbox_system` | `uptime` | `system_uptime_limit` |
| 08 | Dynatrace | `ips_toolbox_dynatrace` | `check` | `dynatrace_fullstack_required`, `dynatrace_oracle_monitoring` |
| 09 | Illumio | `ips_toolbox_illumio` | `configure` | `illumio_ven_status`, `illumio_ven_enforcement` |

### Phase 4 : Sauvegarde et TSM

| N° | Tâche | Rôle | Opération |
|----|-------|------|-----------|
| 11 | Sauvegarde TSM/netBackup | `ips_toolbox_backup` | `run_incr` |
| 12 | Backup applicatif | `ips_toolbox_autosys` | `configure` |
| 13 | Backup système | `ips_toolbox_tsm` | `configure` |

### Phase 5 : Logs et Maintenance

| N° | Tâche | Rôle | Opération |
|----|-------|------|-----------|
| 14 | Purge logs | `ips_toolbox_logs` | `configure` |

### Phase 6 : Middlewares et Services

| Tâche | Rôle | Condition |
|-------|------|-----------|
| Configuration WebSphere WAS ND | `ips_toolbox_wasnd` | `'WebSphere_WAS_ND' in detected_middleware_list` |
| Configuration Oracle Database | `ips_toolbox_oracle` | `'Oracle' in detected_middleware_list` |
| Configuration IHS WebServer | `ips_toolbox_webserver` | `'IHS' in detected_middleware_list` |
| Configuration Autosys | `ips_toolbox_autosys` | - |

---

## 🔧 Corrections Nécessaires

### 1. Variables du Survey AAP2

**Problème** : Ma proposition précédente demandait trop de variables (13 questions)

**Solution** : Simplifier à **3 variables uniquement**

| Variable | Type | Obligatoire | Validation |
|----------|------|-------------|------------|
| `Hostname` | Texte | ✅ Oui | Aucune (casse libre) |
| `CodeAP` | Texte | ✅ Oui | Regex: `^[0-9]{5}$` |
| `code5car` | Texte | ✅ Oui | Regex: `^[A-Za-z0-9]{5}$` |

**Toutes les autres variables** (VG, tailles LV, utilisateurs, etc.) doivent utiliser les **valeurs par défaut** définies dans les rôles.

---

### 2. Rôle `ips_toolbox_system`

**Fichier** : `roles/ips_toolbox_system/tasks/create-directory_Linux_system.yml`

**Variables utilisées** :
```yaml
system_codeAP: "{{ code_ap }}"        # Provient de CodeAP du Survey
system_code5car: "{{ code5car }}"      # Provient de code5car du Survey
system_vgName: "vg_apps"               # Valeur par défaut (pas dans Survey)
system_lvSize: "1024"                  # Valeur par défaut (pas dans Survey)
```

**Script Toolbox appelé** :
```bash
/apps/toolboxes/exploit/bin/exploit_arbo-app.ksh \
  codeAP={{ system_Appli_Code }} \
  code5car={{ system_Appli_5_car }} \
  {{ system_Appli_id }} \
  {{ system_Appli_vg }} \
  {{ system_Appli_lv }} \
  {{ system_Appli_lvex }}{{ system_Appli_lvex1 }}{{ system_Appli_lvex2 }} \
  {{ system_Appli_user }}
```

**Problème** : Les variables `system_Appli_*` sont construites à partir des defaults du rôle

**Solution** : Vérifier que les defaults sont cohérents avec les 3 variables du Survey

---

### 3. Rôles Banner et Users

**Problème** : Le playbook indique "à implémenter"

**Solution** : Créer les rôles `ips_toolbox_banner` et `ips_toolbox_users`

**Intégration dans le playbook** :
```yaml
- name: "02 - Banner - Création bannière login"
  ansible.builtin.include_role:
    name: ips_toolbox_banner
  vars:
    banner_operation: "create"
  tags: [banner]
  ignore_errors: true

- name: "03 - Users - Création d'utilisateurs"
  ansible.builtin.include_role:
    name: ips_toolbox_users
  vars:
    users_operation: "create"
  tags: [users]
  ignore_errors: true
```

---

## 📊 Mapping Variables Survey → Rôles

### Flux des Variables

```
Survey AAP2
├── Hostname        → hostname_target (playbook)
├── CodeAP          → code_ap (playbook)
└── code5car        → code5car (playbook)

Playbook → Rôles
├── code_ap         → system_codeAP (ips_toolbox_system)
├── code5car        → system_code5car (ips_toolbox_system)
└── hostname_target → (utilisé pour hosts)

Rôle ips_toolbox_system → Script Toolbox
├── system_codeAP   → codeAP=<valeur>
├── system_code5car → code5car=<valeur>
├── system_vgName   → vg=<valeur> (défaut: vg_apps)
└── system_lvSize   → lv=<spec> (défaut: 1024)
```

---

## ✅ Cohérence avec les README

### README_1 : Phases d'Exécution

**Phases mentionnées** :
- Phase 0 : Initialisation
- Phase 1 : Validation Toolbox
- Phase 2 : Détection Automatique
- Phase 3 : Validation du Socle (SHA)
- Phase 4 : Configuration Système
- Phase 5 : Configuration WebServer
- Phase 6 : Configuration Spécifique
- Phase 7 : Déploiement Applicatif
- Phase 8 : Finalisation

**Playbook actuel** :
- Phase 1 : Détection et Audit Système ✅
- Phase 2 : Arborescence et FileSystems ✅
- Phase 3 : Vérifications Système et Conformité ✅
- Phase 4 : Sauvegarde et TSM ✅
- Phase 5 : Logs et Maintenance ✅
- Phase 6 : Middlewares et Services ✅

**Cohérence** : ✅ Les phases sont cohérentes, mais numérotées différemment

---

### README_2 : Rôles et Enchaînements

**Rôles mentionnés** :
- `filesystem` : Création de filesystems
- `ntp` : Configuration NTP
- `services` : Configuration services (dynatrace, illumio, tsm, rear)
- `toolbox` : Vérification Toolbox
- `logs` : Purge logs
- `update.facts` : Mise à jour facts
- `create.banner` : Création bannière
- `create.user` : Création utilisateurs

**Playbook actuel** :
- `ips_toolbox_system` : Création arborescence et filesystems ✅
- `ips_toolbox_dynatrace` : Configuration Dynatrace ✅
- `ips_toolbox_illumio` : Configuration Illumio ✅
- `ips_toolbox_backup` : Configuration TSM ✅
- `ips_toolbox_toolboxes` : Vérification Toolbox ✅
- `ips_toolbox_logs` : Purge logs ✅
- `app_environment_builder` : Détection OS et middleware ✅
- *(manquant)* : Banner
- *(manquant)* : Users

**Cohérence** : ⚠️ Les noms de rôles sont différents, mais les fonctionnalités sont présentes

---

### README_3 : Rôle `fs` (filesystem)

**Variables mentionnées** :
- `fs_action` : "create"
- `fs_applis` : true/false
- `fs_apcode` : Code application
- `fs_code5cars` : Code 5 caractères
- `fs_vgname` : Volume Group
- `fs_size` : Tailles des LV

**Playbook actuel** :
- Utilise le rôle `ips_toolbox_system` avec `system_operation: "create-directory"`
- Variables : `system_codeAP`, `system_code5car`, `system_vgName`, `system_lvSize`

**Cohérence** : ⚠️ Le rôle `filesystem` n'existe pas, remplacé par `ips_toolbox_system`

---

### README_4 : Workflow AAP VM Standard

**Workflow mentionné** :
1. Création FS selon règles IT
2. Configuration agents supervision
3. Mise à jour Reftec
4. Illumio en mode "enforced"
5. Démarrage sauvegarde TSM
6. Purge logs
7. Configuration agent orchestrateur
8. Ajout VM à VIP existante

**Playbook actuel** :
1. ✅ Création arborescence (Phase 2)
2. ✅ Configuration Dynatrace (Phase 3)
3. ❌ Mise à jour Reftec (non mentionné)
4. ✅ Illumio en mode "enforced" (Phase 3)
5. ✅ Sauvegarde TSM (Phase 4)
6. ✅ Purge logs (Phase 5)
7. ✅ Configuration Autosys (Phase 4 et 6)
8. ❌ Ajout VM à VIP (non mentionné)

**Cohérence** : ✅ La plupart des étapes sont présentes

---

## 🎯 Recommandations Finales

### 1. Simplifier le Survey AAP2

**3 variables uniquement** :
- `Hostname` (texte libre, casse libre)
- `CodeAP` (5 chiffres uniquement, regex: `^[0-9]{5}$`)
- `code5car` (5 alphanum, casse libre, regex: `^[A-Za-z0-9]{5}$`)

### 2. Utiliser les Valeurs par Défaut

Toutes les autres variables doivent utiliser les valeurs par défaut des rôles :
- `system_vgName`: `vg_apps`
- `system_lvSize`: `1024`
- `system_iis`: `01`
- `environnement`: `HORSPROD`

### 3. Créer les Rôles Manquants

- ✅ `ips_toolbox_banner` : Création bannières
- ✅ `ips_toolbox_users` : Création utilisateurs

### 4. Corriger le Rôle `ips_toolbox_system`

- ✅ Corriger la syntaxe YAML
- ✅ Conserver l'appel au script Toolbox `exploit_arbo-app.ksh`
- ✅ Utiliser les variables du Survey (`system_codeAP`, `system_code5car`)

---

## 📝 Résumé des Incohérences

| Élément | README | Playbook Actuel | Cohérence |
|---------|--------|-----------------|-----------|
| Nom des rôles | `filesystem`, `ntp`, `services` | `ips_toolbox_*` | ⚠️ Différent |
| Variables Survey | Non spécifié | `Hostname`, `CodeAP`, `code5car` | ✅ OK |
| Phases d'exécution | 8 phases (0-8) | 6 phases (1-6) | ✅ Cohérent |
| Rôle Banner | Mentionné | À implémenter | ❌ Manquant |
| Rôle Users | Mentionné | À implémenter | ❌ Manquant |
| Script Toolbox | Mentionné | Utilisé | ✅ OK |

---

**Conclusion** : Le projet est globalement cohérent, mais nécessite :
1. ✅ Simplification du Survey à 3 variables
2. ✅ Création des rôles Banner et Users
3. ✅ Correction de la syntaxe YAML dans `create-directory_Linux_system.yml`

