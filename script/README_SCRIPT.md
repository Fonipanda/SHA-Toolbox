# Script de Correction Automatique Ansible

## 🎯 Objectif

Ce script Python corrige automatiquement les fichiers Ansible YAML pour respecter les bonnes pratiques :

1. ✅ **Indentation à 2 espaces** (corrige les indentations incorrectes)
2. ✅ **Préfixes `ansible.builtin`** (ajoute les préfixes manquants)
3. ✅ **`changed_when: false`** (pour les commandes en lecture seule)

---

## 📦 Contenu de l'Archive

```
Script-Correction-Automatique.tar.gz
├── fix_ansible_files.py              # Script Python de correction
├── GUIDE_CORRECTION_AUTOMATIQUE.md   # Guide d'utilisation complet
└── README_SCRIPT.md                  # Ce fichier
```

---

## 🚀 Démarrage Rapide

### Installation

```bash
# Extraire l'archive
tar -xzf Script-Correction-Automatique.tar.gz

# Rendre le script exécutable
chmod +x fix_ansible_files.py
```

### Utilisation Simple

```bash
# 1. Test en mode dry-run (simulation)
python3 fix_ansible_files.py /path/to/SHA-Toolbox --dry-run --verbose

# 2. Application des corrections avec sauvegarde
python3 fix_ansible_files.py /path/to/SHA-Toolbox --verbose
```

---

## 📊 Exemple de Résultat

### Avant Correction

```yaml
- name: Check status
   shell: systemctl status sshd
  register: result

- name: Copy file
   copy:
     src: file.txt
     dest: /tmp/
```

### Après Correction

```yaml
- name: Check status
  ansible.builtin.shell: systemctl status sshd
  changed_when: false
  register: result

- name: Copy file
  ansible.builtin.copy:
    src: file.txt
    dest: /tmp/
```

---

## 📈 Statistiques Attendues sur SHA-Toolbox

D'après l'audit du dépôt :

| Métrique | Valeur Estimée |
|----------|----------------|
| Fichiers YAML à traiter | ~200 |
| Fichiers à modifier | ~50 |
| Corrections d'indentation | ~200 |
| Préfixes à ajouter | ~100 |
| `changed_when` à ajouter | ~30 |

---

## ⚠️ Recommandations

### Avant d'exécuter

1. **Créer un commit Git** :
   ```bash
   git add . && git commit -m "Avant correction automatique"
   ```

2. **Tester en dry-run** :
   ```bash
   python3 fix_ansible_files.py /path/to/SHA-Toolbox --dry-run
   ```

### Après l'exécution

1. **Vérifier les modifications** :
   ```bash
   git diff
   ```

2. **Valider la syntaxe** :
   ```bash
   ansible-playbook check_playbook.yml --syntax-check
   ```

3. **Commiter les changements** :
   ```bash
   git add . && git commit -m "Correction automatique: indentation, préfixes, changed_when"
   ```

---

## 📖 Documentation Complète

Consultez le fichier **`GUIDE_CORRECTION_AUTOMATIQUE.md`** pour :

- 📋 Description détaillée des corrections
- 💡 Exemples d'utilisation avancés
- 🔍 Détails techniques des transformations
- 🐛 Dépannage et résolution de problèmes
- 🔧 Workflow recommandé

---

## ✅ Fonctionnalités

- ✅ **Idempotent** : Peut être exécuté plusieurs fois sans problème
- ✅ **Sauvegarde automatique** : Crée des fichiers `.backup`
- ✅ **Mode dry-run** : Simulation sans modification
- ✅ **Verbose** : Affichage détaillé des corrections
- ✅ **Rapport détaillé** : Statistiques complètes après exécution
- ✅ **Détection intelligente** : Identifie les commandes en lecture seule
- ✅ **Multi-OS** : Fonctionne sur Linux, macOS, Windows

---

## 🔧 Options du Script

```bash
python3 fix_ansible_files.py <répertoire> [options]

Options:
  --dry-run         Simulation sans modification
  --verbose, -v     Affichage détaillé
  --no-backup       Pas de sauvegarde .backup
```

---

## 📞 Support

Pour toute question :

1. Consultez le **GUIDE_CORRECTION_AUTOMATIQUE.md**
2. Consultez le rapport d'audit **audit_detaille.md**
3. Exécutez avec `--verbose` pour plus de détails

---

## 📝 Notes

- Le script **ne modifie pas** les commentaires
- Les sauvegardes `.backup` ne sont **pas écrasées**
- Le script **ignore** les fichiers non-YAML
- Toujours **tester** après correction

---

**Version** : 1.0  
**Date** : 14 octobre 2025  
**Auteur** : Manus AI Agent

