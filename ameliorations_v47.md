# AMÉLIORATIONS v4.7 - SHA-Toolbox

## Date: 2025-10-28
## Améliorations demandées implémentées

---

## ✅ 1. VALIDATION CODEAP (5 OU 6 CHIFFRES)

### Ancienne validation:
- Acceptait seulement 5 chiffres

### Nouvelle validation:
```yaml
- name: "Validation format CodeAP (5 ou 6 chiffres)"
  ansible.builtin.assert:
    that:
      - CodeAP | string | regex_search('^[0-9]{5,6}$')
```

**Exemples**:
- ✅ `12345` (5 chiffres)
- ✅ `123456` (6 chiffres)
- ❌ `1234` (trop court)
- ❌ `1234567` (trop long)
- ❌ `12A45` (contient des lettres)

---

## ✅ 2. VALIDATION CODE5CAR (5 CARACTÈRES OU TRIGRAMME+00)

### Nouvelle validation:
```yaml
- name: "Validation format Code5car"
  ansible.builtin.assert:
    that:
      - code5car | string | regex_search('^[A-Z0-9]{5}$')
```

**Formats acceptés**:

**Format 1**: 5 caractères alphanumériques
- ✅ `ABC12`
- ✅ `TEST1`
- ✅ `XYZ99`

**Format 2**: Trigramme + 2 zéros
- ✅ `ABC00`
- ✅ `XYZ00`
- ✅ `TST00`

**Rejetés**:
- ❌ `ABCD` (trop court)
- ❌ `ABCDEF` (trop long)
- ❌ `abc12` (minuscules non acceptées - convertir en majuscules)

---

## ✅ 3. VÉRIFICATION SYSTEMD

### Nouvelle tâche ajoutée:
```yaml
- name: "Vérification que systemd est disponible"
  ansible.builtin.command: systemctl --version
  register: systemd_check

- name: "Validation systemd"
  ansible.builtin.assert:
    that:
      - systemd_check.rc == 0
      - "'systemd' in systemd_check.stdout"
    fail_msg: "❌ systemd n'est pas disponible"
    success_msg: "✅ systemd disponible"
```

**Vérifications**:
- ✅ systemd est installé
- ✅ systemd fonctionne
- ✅ Version systemd affichée

**Fichier**: `main_playbook.yml` ligne 59-73

---

## ✅ 4. EXCLUSION TSM SI NETBACKUP DÉTECTÉ

### Logique implémentée:
```yaml
- name: "Détection du type de client de sauvegarde"
  ansible.builtin.set_fact:
    netbackup_detected: "{{ backup_clients.files | ... | selectattr('path', 'search', 'bplist') | ... }}"
    tsm_detected: "{{ backup_clients.files | ... | selectattr('path', 'search', 'dsmc') | ... }}"

- name: "Affichage des clients détectés"
  ansible.builtin.debug:
    msg:
      - "📦 CLIENTS DE SAUVEGARDE DÉTECTÉS:"
      - "   • Netbackup: {{ '✅ OUI' if netbackup_detected else '❌ NON' }}"
      - "   • TSM: {{ '✅ OUI' if tsm_detected else '❌ NON' }}"
      - "⚠️ RÈGLE: Si Netbackup est détecté, TSM ne sera PAS configuré"
```

### Règle d'exclusion:
```yaml
- name: "Vérification TSM si présent ET Netbackup absent"
  block:
    - name: "Information: Netbackup détecté, TSM ignoré"
      when: netbackup_detected
    
    - name: "Test de la commande TSM"
      when: not netbackup_detected
```

**Priorité**:
1. Netbackup détecté → **TSM IGNORÉ**
2. Netbackup absent + TSM détecté → **TSM CONFIGURÉ**
3. Aucun détecté → **Aucune configuration**

**Fichier**: `roles/ips_toolbox_backup/tasks/main.yml` lignes 1-60

---

## ✅ 5. PURGE LOGS À 01:00 AVEC RÉTENTION VIA SURVEY

### Nouveau Survey:
```yaml
Variable: log_purge_days
Type: Integer
Default: 30
Min/Max: 1/365
Description: "Log purge retention (number of days)"
```

### Timer systemd modifié:
**Avant**:
```ini
[Timer]
OnCalendar=daily
RandomizedDelaySec=3600
```

**Après**:
```ini
[Timer]
OnCalendar=*-*-* 01:00:00
Persistent=true
```

**Changements**:
- ✅ Heure fixe: **01:00** (au lieu de aléatoire dans la journée)
- ✅ Format précis: `*-*-* 01:00:00` (tous les jours à 01h00)
- ✅ Supprimé: `RandomizedDelaySec` (plus de délai aléatoire)

### Service modifié:
```ini
[Service]
ExecStart=/apps/toolboxes/exploit/bin/exploit_rotate_log.ksh {{ log_purge_retention_days }}
```

**Passage du paramètre**:
- Le nombre de jours de rétention est passé au script
- Variable: `{{ log_purge_retention_days }}`
- Provient du Survey: `log_purge_days`

### Configuration:
```bash
# Rétention en jours (nombre de jours à conserver)
RETENTION_DAYS={{ log_purge_retention_days }}
```

**Fichier**: `roles/ips_toolbox_logs/tasks/main.yml` lignes 1-110

---

## ✅ 6. SURVEYS AAP2 COMPLETS (25 TOTAL)

### 3 Surveys OBLIGATOIRES:
1. **Hostname** - Target server
2. **CodeAP** - 5 ou 6 chiffres
3. **code5car** - 5 alphanum OU trigramme+00

### 22 Surveys OPTIONNELS:

**Infrastructure** (2):
- `id` - Instance ID (01, 02, etc.)
- `log_purge_days` - Rétention logs (1-365 jours)

**Filesystems** (15):
- `fs_apcode`, `fs_code5cars`, `fs_suffix`
- `fs_size4apps`, `fs_size4apps_ti`, `fs_size4apps_to`
- `fs_size4apps_tmp`, `fs_size4apps_arch`
- `fs_size4shared`, `fs_size4shared_tmp`, `fs_size4shared_arch`
- `fs_size4log_apps`, `fs_size4log_shared`
- `fs_size4div_apps`, `fs_size4div_shared`

**Middlewares** (5):
- `configure_webserver` - IHS (true/false)
- `configure_java` - JVM (true/false)
- `configure_oracle_db` - Oracle DB (true/false)
- `oracle_instance_name` - Nom instance Oracle
- `configure_cft` - Axway CFT (true/false)

**Fichier**: `SURVEY_AAP2_COMPLETE.md`

---

## 📋 RÉSUMÉ DES VALIDATIONS

| Variable | Format | Regex | Exemple |
|----------|--------|-------|---------|
| `CodeAP` | 5-6 digits | `^[0-9]{5,6}$` | `12345`, `123456` |
| `code5car` | 5 alphanum | `^[A-Z0-9]{5}$` | `ABC12`, `XYZ00` |
| `id` | 2 digits | `^[0-9]{2}$` | `01`, `02` |
| `log_purge_days` | Integer | 1-365 | `30`, `60` |
| `fs_size*` | Size format | `^[0-9]+[MGT]$` | `1G`, `500M` |
| `oracle_instance_name` | 1-8 alphanum | `^[A-Z0-9]{1,8}$` | `ORCL1` |

---

## 🔧 FICHIERS MODIFIÉS

### 1. `main_playbook.yml`
- Lignes 29-57: Validations CodeAP (5-6) et code5car (5 alphanum)
- Lignes 59-73: Vérification systemd

### 2. `roles/ips_toolbox_backup/tasks/main.yml`
- Lignes 19-30: Détection Netbackup/TSM/NetWorker
- Lignes 48-60: Exclusion TSM si Netbackup détecté

### 3. `roles/ips_toolbox_logs/tasks/main.yml`
- Lignes 1-10: Variable `log_purge_retention_days` depuis Survey
- Ligne 38: Description service avec rétention
- Ligne 44: Passage paramètre au script
- Lignes 66-68: Timer à 01:00 précis
- Ligne 91: Variable RETENTION_DAYS dans config

### 4. `SURVEY_AAP2_COMPLETE.md` (NOUVEAU)
- Documentation complète des 25 Surveys
- Validations regex détaillées
- Exemples et notes d'utilisation

---

## ✅ TESTS À EFFECTUER

### Test 1: Validation CodeAP
```bash
# Test avec 5 chiffres
-e "CodeAP=12345"  # ✅ OK

# Test avec 6 chiffres
-e "CodeAP=123456"  # ✅ OK

# Test invalide
-e "CodeAP=1234"  # ❌ Erreur: trop court
-e "CodeAP=12A45"  # ❌ Erreur: contient lettres
```

### Test 2: Validation code5car
```bash
# Test alphanumérique
-e "code5car=ABC12"  # ✅ OK

# Test trigramme+00
-e "code5car=XYZ00"  # ✅ OK

# Test invalide
-e "code5car=ABCD"  # ❌ Erreur: trop court
```

### Test 3: Vérification systemd
```bash
# Sur le serveur cible
systemctl --version
# Doit retourner: systemd 239 (ou supérieur)
```

### Test 4: Exclusion Netbackup/TSM
```bash
# Si Netbackup installé
ls /usr/openv/netbackup/bin/bplist
# → TSM ne doit PAS être configuré

# Si seulement TSM
ls /opt/tivoli/tsm/client/ba/bin/dsmc
# → TSM doit être configuré
```

### Test 5: Timer purge logs
```bash
# Vérifier le timer
systemctl cat purge_logs.timer
# Doit contenir: OnCalendar=*-*-* 01:00:00

# Vérifier prochaine exécution
systemctl list-timers purge_logs.timer
# Doit montrer: ... 01:00:00 ...

# Tester avec rétention custom
-e "log_purge_days=60"
# Le service doit passer 60 au script
```

---

## 📊 COMPATIBILITÉ

### Systèmes supportés:
- ✅ RHEL 7+ (systemd 219+)
- ✅ RHEL 8 (systemd 239+)
- ✅ RHEL 9 (systemd 252+)
- ✅ CentOS 7+
- ⚠️ RHEL 6 (pas de systemd) - Non supporté

### Clients de sauvegarde:
- ✅ TSM (Tivoli Storage Manager)
- ✅ Netbackup (Veritas)
- ✅ NetWorker (EMC)

---

**Date de création**: 2025-10-28  
**Auteur**: AI Engineer (Emergent)  
**Version**: 4.7  
**Type de modifications**: Validations + Exclusions + Surveys complets
