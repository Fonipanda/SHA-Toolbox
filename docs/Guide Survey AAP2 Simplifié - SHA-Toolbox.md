# Guide Survey AAP2 Simplifié - SHA-Toolbox

**Version** : 4.0  
**Date** : 16 octobre 2025  
**Public** : Administrateurs AAP2

---

## 🎯 Vue d'Ensemble

Ce guide décrit la configuration du **Survey (questionnaire) simplifié** dans l'interface AAP2 pour le projet SHA-Toolbox.

**Simplification** : Le Survey ne demande que **3 variables essentielles**, toutes les autres utilisent les valeurs par défaut.

---

## 📝 Variables du Survey (3 uniquement)

### Variable 1 : Hostname

| Paramètre | Valeur |
|-----------|--------|
| **Question Name** | Nom du serveur cible |
| **Description** | Nom d'hôte du serveur (peu importe la casse, ex: s02vl9942814 ou S02VL9942814) |
| **Answer Variable Name** | `Hostname` |
| **Answer Type** | Text |
| **Required** | ✅ Yes |
| **Minimum Length** | 1 |
| **Maximum Length** | 64 |
| **Default Answer** | *(vide)* |

**Note** : La casse est libre (`s02vl9942814` ou `S02VL9942814` sont acceptés).

---

### Variable 2 : CodeAP (5 chiffres uniquement)

| Paramètre | Valeur |
|-----------|--------|
| **Question Name** | Code Application (5 chiffres) |
| **Description** | Code application sur 5 chiffres uniquement (ex: 12345, PAS de préfixe "AP") |
| **Answer Variable Name** | `CodeAP` |
| **Answer Type** | Text |
| **Required** | ✅ Yes |
| **Minimum Length** | 5 |
| **Maximum Length** | 5 |
| **Default Answer** | *(vide)* |

**Validation dans le playbook** : Regex `^[0-9]{5}$`

**Exemples** :
- ✅ **Correct** : `12345`
- ❌ **Incorrect** : `AP12345` (pas de préfixe "AP")
- ❌ **Incorrect** : `1234` (4 chiffres seulement)
- ❌ **Incorrect** : `123456` (6 chiffres)

---

### Variable 3 : code5car

| Paramètre | Valeur |
|-----------|--------|
| **Question Name** | Code 5 caractères |
| **Description** | Code application sur 5 caractères alphanumériques (peu importe la casse, ex: ABCDE ou abcde) |
| **Answer Variable Name** | `code5car` |
| **Answer Type** | Text |
| **Required** | ✅ Yes |
| **Minimum Length** | 5 |
| **Maximum Length** | 5 |
| **Default Answer** | *(vide)* |

**Validation dans le playbook** : Regex `^[A-Za-z0-9]{5}$`

**Note** : La casse est libre (`ABCDE`, `abcde`, `Ab12E` sont acceptés).

**Exemples** :
- ✅ **Correct** : `ABCDE`
- ✅ **Correct** : `abcde`
- ✅ **Correct** : `Ab12E`
- ❌ **Incorrect** : `ABCD` (4 caractères seulement)
- ❌ **Incorrect** : `ABCDEF` (6 caractères)
- ❌ **Incorrect** : `ABC-E` (caractère spécial non autorisé)

---

## 🔧 Configuration dans AAP2

### Étape 1 : Accès au Survey

1. Connectez-vous à l'interface AAP2
2. Naviguez vers **Resources** → **Templates**
3. Sélectionnez le template **"SHA-Toolbox - Création Socle Applicatif"**
4. Cliquez sur l'onglet **"Survey"**
5. Cliquez sur **"Add"** pour ajouter une question

---

### Étape 2 : Ajout de la Question 1 (Hostname)

**Remplissez les champs** :

```
Question Name: Nom du serveur cible
Description: Nom d'hôte du serveur (peu importe la casse, ex: s02vl9942814 ou S02VL9942814)
Answer Variable Name: Hostname
Answer Type: Text
Required: Yes
Minimum Length: 1
Maximum Length: 64
Default Answer: (vide)
```

Cliquez sur **"Save"**.

---

### Étape 3 : Ajout de la Question 2 (CodeAP)

**Remplissez les champs** :

```
Question Name: Code Application (5 chiffres)
Description: Code application sur 5 chiffres uniquement (ex: 12345, PAS de préfixe "AP")
Answer Variable Name: CodeAP
Answer Type: Text
Required: Yes
Minimum Length: 5
Maximum Length: 5
Default Answer: (vide)
```

Cliquez sur **"Save"**.

---

### Étape 4 : Ajout de la Question 3 (code5car)

**Remplissez les champs** :

```
Question Name: Code 5 caractères
Description: Code application sur 5 caractères alphanumériques (peu importe la casse, ex: ABCDE ou abcde)
Answer Variable Name: code5car
Answer Type: Text
Required: Yes
Minimum Length: 5
Maximum Length: 5
Default Answer: (vide)
```

Cliquez sur **"Save"**.

---

### Étape 5 : Activation du Survey

1. Cochez **"Survey Enabled"**
2. Cliquez sur **"Save"**

---

## ✅ Validation dans le Playbook

Le playbook `main_playbook.yml` valide automatiquement les variables du Survey :

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

**Si une variable est invalide**, le playbook s'arrête immédiatement avec un message d'erreur explicite.

---

## 📊 Valeurs par Défaut (Non Demandées dans le Survey)

Toutes les autres variables utilisent les **valeurs par défaut** définies dans les rôles :

| Variable | Valeur par Défaut | Rôle |
|----------|-------------------|------|
| `system_vgName` | `vg_apps` | `ips_toolbox_system` |
| `system_lvSize` | `1024` | `ips_toolbox_system` |
| `system_iis` | `01` | `ips_toolbox_system` |
| `environnement` | `HORSPROD` | Playbook principal |
| `system_uptime_limit` | `90` | Playbook principal |
| `illumio_enforcement_mode` | `enforced` | Playbook principal |

**Ces valeurs ne sont PAS demandées dans le Survey** et sont automatiquement utilisées.

---

## 🎨 Exemple de Saisie

### Cas d'Usage : Création d'un Socle pour une Application

| Question | Valeur Saisie |
|----------|---------------|
| Nom du serveur cible | `s02vl9942814` |
| Code Application (5 chiffres) | `12345` |
| Code 5 caractères | `ABCDE` |

**Résultat** :
- Hostname : `s02vl9942814`
- CodeAP : `12345`
- code5car : `ABCDE`

**Arborescence créée** :
- `/applis/AP12345-ABCDE-01/`
- Volume Group : `vg_apps` (défaut)
- Taille des LV : 1024 Mo (défaut)

---

## 🔍 Flux des Variables

```
Survey AAP2
├── Hostname    → hostname_target (playbook)
├── CodeAP      → code_ap (playbook)
└── code5car    → code5car (playbook)

Playbook → Rôles
├── code_ap         → system_codeAP (ips_toolbox_system)
├── code5car        → system_code5car (ips_toolbox_system)
└── hostname_target → (utilisé pour hosts)

Rôle ips_toolbox_system → Script Toolbox
├── system_codeAP   → codeAP=AP<valeur>
├── system_code5car → code5car=<valeur>
├── system_vgName   → vg=vg_apps (défaut)
└── system_lvSize   → lv=<spec> (défaut: 1024)
```

**Note** : Le préfixe "AP" est automatiquement ajouté par le script Toolbox.

---

## 🐛 Dépannage

### Erreur : "Variables Survey AAP2 invalides"

**Cause** : Une variable ne respecte pas le format attendu

**Solutions** :
- **CodeAP** : Vérifiez que vous avez saisi exactement 5 chiffres (ex: `12345`)
- **code5car** : Vérifiez que vous avez saisi exactement 5 caractères alphanumériques (ex: `ABCDE`)
- **Hostname** : Vérifiez que le nom d'hôte n'est pas vide

### Erreur : "CodeAP doit contenir 5 chiffres uniquement"

**Cause** : Vous avez saisi le préfixe "AP" (ex: `AP12345`)

**Solution** : Saisissez uniquement les 5 chiffres (ex: `12345`), le préfixe "AP" sera ajouté automatiquement.

---

## 📞 Support

Pour toute question sur la configuration du Survey :

- **Documentation** : Consulter ce guide
- **Équipe Automatisation** : automation-sha@internal.com

---

**Auteur** : Équipe Automatisation SHA  
**Version** : 4.0  
**Date** : 16 octobre 2025

