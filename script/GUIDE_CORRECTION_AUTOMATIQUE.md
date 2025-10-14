# Guide d'Utilisation du Script de Correction Automatique

**Script** : `fix_ansible_files.py`  
**Version** : 1.0  
**Date** : 14 octobre 2025

---

## 📋 Description

Le script `fix_ansible_files.py` corrige automatiquement les fichiers Ansible YAML du dépôt SHA-Toolbox en appliquant les bonnes pratiques suivantes :

1. **Correction de l'indentation** : Utilise systématiquement 2 espaces
2. **Ajout des préfixes `ansible.builtin`** : Préfixe tous les modules natifs Ansible
3. **Ajout de `changed_when: false`** : Pour les commandes en lecture seule (cat, grep, systemctl status, etc.)

---

## 🚀 Installation

### Prérequis

- Python 3.6 ou supérieur
- Module PyYAML (optionnel, pour validation)

```bash
# Installation de PyYAML (optionnel)
pip3 install pyyaml
```

### Téléchargement

Le script est fourni dans l'archive `SHA-Toolbox-Audit-Complet.tar.gz` ou peut être téléchargé directement.

```bash
# Rendre le script exécutable
chmod +x fix_ansible_files.py
```

---

## 📖 Utilisation

### Syntaxe de base

```bash
python3 fix_ansible_files.py <répertoire> [options]
```

### Options disponibles

| Option | Description |
|--------|-------------|
| `--dry-run` | Mode simulation : affiche les corrections sans modifier les fichiers |
| `--verbose` ou `-v` | Affichage détaillé des corrections appliquées |
| `--no-backup` | Ne pas créer de fichiers de sauvegarde (`.backup`) |

---

## 💡 Exemples d'Utilisation

### 1. Mode Dry-Run (Simulation)

**Recommandé pour la première exécution** : Vérifier les corrections sans modifier les fichiers.

```bash
# Simulation sur tout le dépôt
python3 fix_ansible_files.py /path/to/SHA-Toolbox --dry-run --verbose

# Simulation sur un seul rôle
python3 fix_ansible_files.py /path/to/SHA-Toolbox/roles/ips_toolbox_system --dry-run
```

**Sortie attendue** :
```
🔧 Correction automatique des fichiers Ansible
📁 Répertoire: /path/to/SHA-Toolbox
🔍 Mode: DRY-RUN (simulation)

[12:03:17] INFO: Scan du répertoire: /path/to/SHA-Toolbox
[12:03:17] INFO: Fichiers YAML trouvés: 200
[12:03:17] INFO: [DRY-RUN] Fichier à modifier: roles/ips_toolbox_system/tasks/main.yml (5 corrections)
...

======================================================================
RÉSUMÉ DES CORRECTIONS
======================================================================
Fichiers traités:              200
Fichiers modifiés:             50
Corrections d'indentation:     150
Préfixes ajoutés:              75
changed_when ajoutés:          25
Erreurs:                       0
======================================================================

⚠️  MODE DRY-RUN: Aucune modification n'a été effectuée.
   Relancez sans --dry-run pour appliquer les corrections.
```

---

### 2. Correction avec Sauvegarde (Recommandé)

**Mode par défaut** : Crée une sauvegarde `.backup` de chaque fichier modifié.

```bash
# Correction de tout le dépôt avec sauvegarde
python3 fix_ansible_files.py /path/to/SHA-Toolbox --verbose

# Correction d'un seul rôle
python3 fix_ansible_files.py /path/to/SHA-Toolbox/roles/ips_toolbox_illumio
```

**Résultat** :
- Fichiers originaux sauvegardés avec l'extension `.backup`
- Fichiers corrigés en place
- Rapport détaillé des corrections

---

### 3. Correction sans Sauvegarde

**Attention** : Aucune sauvegarde ne sera créée. Assurez-vous d'avoir un commit Git propre avant.

```bash
# Correction sans sauvegarde
python3 fix_ansible_files.py /path/to/SHA-Toolbox --no-backup
```

---

### 4. Correction d'un Rôle Spécifique

```bash
# Corriger uniquement le rôle ips_toolbox_dynatrace
python3 fix_ansible_files.py /path/to/SHA-Toolbox/roles/ips_toolbox_dynatrace --verbose

# Corriger uniquement le rôle ips_toolbox_backup
python3 fix_ansible_files.py /path/to/SHA-Toolbox/roles/ips_toolbox_backup
```

---

## 🔍 Détails des Corrections

### 1. Correction de l'Indentation

**Avant** :
```yaml
- name: Test
  shell: |
   echo "test"
    cat file.txt
```

**Après** :
```yaml
- name: Test
  ansible.builtin.shell: |
    echo "test"
    cat file.txt
```

---

### 2. Ajout des Préfixes `ansible.builtin`

**Modules concernés** :
- `shell`, `command`, `copy`, `file`, `template`
- `lineinfile`, `blockinfile`, `stat`, `set_fact`
- `debug`, `fail`, `assert`, `include_tasks`, `include_role`
- `systemd`, `service`, `user`, `group`, `package`
- Et 20+ autres modules natifs

**Avant** :
```yaml
- name: Vérifier le fichier
  stat:
    path: /etc/motd
  register: motd_check

- name: Copier le fichier
  copy:
    src: banner.txt
    dest: /etc/motd
```

**Après** :
```yaml
- name: Vérifier le fichier
  ansible.builtin.stat:
    path: /etc/motd
  register: motd_check

- name: Copier le fichier
  ansible.builtin.copy:
    src: banner.txt
    dest: /etc/motd
```

---

### 3. Ajout de `changed_when: false`

**Commandes en lecture seule détectées** :
- `cat`, `grep`, `awk`, `sed -n`
- `head`, `tail`, `ls`, `find`, `stat`
- `df`, `du`, `ps`, `uptime`, `hostname`
- `systemctl status`, `systemctl is-active`, `systemctl is-enabled`
- `which`, `whereis`, `echo`, `date`, `uname`
- Commandes avec `--version`, `--get-*`, `--check`
- Pipes avec `| grep`, `| awk`, `| sed`, etc.

**Avant** :
```yaml
- name: Vérifier le statut du service
  ansible.builtin.shell: |
    systemctl status dynatrace-oneagent
  register: dynatrace_status
```

**Après** :
```yaml
- name: Vérifier le statut du service
  ansible.builtin.shell: |
    systemctl status dynatrace-oneagent
  changed_when: false
  register: dynatrace_status
```

**Commandes EXCLUES** (modifient le système) :
- `rm`, `mkdir`, `touch`, `cp`, `mv`
- `chmod`, `chown`, `ln`, `tar -c`
- `systemctl start|stop|restart|enable|disable`
- `yum|apt|dnf install|remove|update`
- Redirections `>`, `>>`, `tee`

---

## 📊 Rapport de Correction

Après chaque exécution, le script affiche un rapport détaillé :

```
======================================================================
RÉSUMÉ DES CORRECTIONS
======================================================================
Fichiers traités:              200
Fichiers modifiés:             50
Corrections d'indentation:     150
Préfixes ajoutés:              75
changed_when ajoutés:          25
Erreurs:                       0
======================================================================

✅ Corrections appliquées avec succès!
   Les fichiers originaux ont été sauvegardés avec l'extension .backup
```

---

## ⚠️ Recommandations

### Avant d'exécuter le script

1. **Créer un commit Git propre** :
   ```bash
   cd /path/to/SHA-Toolbox
   git add .
   git commit -m "Avant correction automatique"
   ```

2. **Exécuter en mode dry-run** :
   ```bash
   python3 fix_ansible_files.py /path/to/SHA-Toolbox --dry-run --verbose
   ```

3. **Vérifier les corrections proposées** dans le rapport

### Après l'exécution

1. **Vérifier les modifications** :
   ```bash
   git diff
   ```

2. **Tester les playbooks** :
   ```bash
   ansible-playbook check_playbook.yml --syntax-check
   ansible-lint roles/
   ```

3. **Valider les corrections** :
   ```bash
   git add .
   git commit -m "Correction automatique: indentation, préfixes, changed_when"
   ```

### En cas de problème

1. **Restaurer depuis les sauvegardes** :
   ```bash
   # Restaurer tous les fichiers .backup
   find /path/to/SHA-Toolbox -name "*.backup" -exec bash -c 'mv "$0" "${0%.backup}"' {} \;
   ```

2. **Restaurer depuis Git** :
   ```bash
   git reset --hard HEAD
   ```

---

## 🔧 Workflow Recommandé

### Correction Progressive (Recommandé)

```bash
# 1. Tester sur un seul rôle
python3 fix_ansible_files.py /path/to/SHA-Toolbox/roles/ips_toolbox_banner --dry-run

# 2. Appliquer sur ce rôle
python3 fix_ansible_files.py /path/to/SHA-Toolbox/roles/ips_toolbox_banner

# 3. Vérifier et tester
ansible-playbook check_playbook.yml --syntax-check
git diff

# 4. Si OK, appliquer sur tous les rôles
python3 fix_ansible_files.py /path/to/SHA-Toolbox/roles --verbose

# 5. Vérifier l'ensemble
ansible-lint roles/
git add .
git commit -m "Correction automatique de tous les rôles"
```

### Correction Globale (Avancé)

```bash
# 1. Créer un commit de sauvegarde
git add . && git commit -m "Avant correction automatique globale"

# 2. Dry-run global
python3 fix_ansible_files.py /path/to/SHA-Toolbox --dry-run > corrections_preview.txt

# 3. Vérifier le rapport
cat corrections_preview.txt

# 4. Appliquer les corrections
python3 fix_ansible_files.py /path/to/SHA-Toolbox --verbose

# 5. Vérifier les modifications
git diff --stat
ansible-playbook check_playbook.yml --syntax-check

# 6. Valider ou annuler
git add . && git commit -m "Correction automatique globale"
# OU
git reset --hard HEAD  # Annuler si problème
```

---

## 📈 Résultats Attendus

### Sur le Dépôt SHA-Toolbox Complet

D'après l'audit, le script devrait corriger :

| Catégorie | Nombre de Corrections Estimées |
|-----------|-------------------------------|
| **Fichiers à traiter** | ~200 fichiers YAML |
| **Fichiers à modifier** | ~50 fichiers |
| **Corrections d'indentation** | ~200 corrections |
| **Préfixes à ajouter** | ~100 préfixes |
| **changed_when à ajouter** | ~30 ajouts |

### Rôles les Plus Impactés

1. **ips_toolbox_system** : ~20 fichiers, ~50 corrections
2. **ips_toolbox_backup** : ~14 fichiers, ~30 corrections
3. **ips_toolbox_controlm** : ~15 fichiers, ~40 corrections
4. **ips_toolbox_libertybase** : ~10 fichiers, ~25 corrections
5. **ips_toolbox_illumio** : ~5 fichiers, ~10 corrections

---

## 🐛 Dépannage

### Erreur : "Module yaml not found"

```bash
pip3 install pyyaml
```

### Erreur : "Permission denied"

```bash
chmod +x fix_ansible_files.py
# OU
python3 fix_ansible_files.py /path/to/SHA-Toolbox
```

### Les corrections ne s'appliquent pas

- Vérifier que vous n'êtes **pas en mode dry-run**
- Vérifier les permissions d'écriture sur les fichiers
- Vérifier que les fichiers ne sont pas en lecture seule

### Trop de corrections proposées

- Utiliser `--verbose` pour voir les détails
- Corriger rôle par rôle au lieu de tout le dépôt
- Vérifier le rapport de dry-run avant d'appliquer

---

## 📞 Support

Pour toute question ou problème :

1. Vérifier ce guide d'utilisation
2. Consulter le rapport d'audit détaillé (`audit_detaille.md`)
3. Exécuter en mode `--verbose` pour plus de détails

---

## 📝 Notes Importantes

- ✅ Le script est **idempotent** : peut être exécuté plusieurs fois sans problème
- ✅ Les sauvegardes `.backup` ne sont **pas écrasées** si elles existent déjà
- ✅ Le script **ignore les commentaires** et ne les modifie pas
- ⚠️ Le script **ne valide pas la syntaxe YAML** après correction (utiliser `ansible-playbook --syntax-check`)
- ⚠️ Toujours **tester les playbooks** après correction

---

**Fin du guide d'utilisation**

