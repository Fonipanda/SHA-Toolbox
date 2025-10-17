# Guide de Configuration du Survey AAP2

**Version** : 1.0  
**Date** : 16 octobre 2025  
**Public** : Administrateurs AAP2

---

## 📋 Vue d'Ensemble

Ce document décrit la configuration complète du **Survey (questionnaire)** dans l'interface AAP2 (Ansible Automation Platform 2) pour le projet SHA-Toolbox.

---

## 🎯 Objectif du Survey

Le Survey permet de **collecter les informations nécessaires** avant l'exécution du playbook, sans avoir à modifier manuellement les fichiers de variables.

### Avantages

- ✅ **Interface utilisateur** : Formulaire web convivial
- ✅ **Validation** : Contrôle des valeurs saisies
- ✅ **Documentation** : Descriptions intégrées pour chaque champ
- ✅ **Traçabilité** : Historique des valeurs utilisées

---

## 📝 Configuration du Survey

### Accès à la Configuration

1. Connectez-vous à l'interface AAP2
2. Naviguez vers **Resources** → **Templates**
3. Sélectionnez le template **"SHA-Toolbox - Création Socle Applicatif"**
4. Cliquez sur l'onglet **"Survey"**
5. Cliquez sur **"Add"** pour ajouter une question

---

## 🔧 Questions du Survey

### Section 1 : Identification du Serveur

#### Question 1 : Nom du serveur cible

| Paramètre | Valeur |
|-----------|--------|
| **Question Name** | Nom du serveur cible |
| **Description** | Nom d'hôte du serveur sur lequel créer le socle applicatif (ex: s02vl9942814) |
| **Answer Variable Name** | `hostname` |
| **Answer Type** | Text |
| **Required** | ✅ Yes |
| **Minimum Length** | 1 |
| **Maximum Length** | 64 |
| **Default Answer** | *(vide)* |

---

### Section 2 : Identification de l'Application

#### Question 2 : Code Application (APxxxxx)

| Paramètre | Valeur |
|-----------|--------|
| **Question Name** | Code Application (APxxxxx) |
| **Description** | Code application au format APxxxxx (ex: AP12345) |
| **Answer Variable Name** | `codeAP` |
| **Answer Type** | Text |
| **Required** | ✅ Yes |
| **Minimum Length** | 7 |
| **Maximum Length** | 7 |
| **Default Answer** | *(vide)* |

**Validation** : Le code doit commencer par "AP" suivi de 5 chiffres.

---

#### Question 3 : Code 5 caractères

| Paramètre | Valeur |
|-----------|--------|
| **Question Name** | Code 5 caractères |
| **Description** | Code application sur 5 caractères (ex: ABCDE) |
| **Answer Variable Name** | `code5car` |
| **Answer Type** | Text |
| **Required** | ✅ Yes |
| **Minimum Length** | 5 |
| **Maximum Length** | 5 |
| **Default Answer** | *(vide)* |

**Validation** : Le code doit contenir exactement 5 caractères alphanumériques.

---

#### Question 4 : Identifiant instance

| Paramètre | Valeur |
|-----------|--------|
| **Question Name** | Identifiant instance |
| **Description** | Identifiant de l'instance applicative (01, 02, 03, ...) |
| **Answer Variable Name** | `system_iis` |
| **Answer Type** | Text |
| **Required** | ✅ Yes |
| **Minimum Length** | 2 |
| **Maximum Length** | 2 |
| **Default Answer** | `01` |

**Validation** : Le code doit contenir exactement 2 chiffres.

---

### Section 3 : Environnement

#### Question 5 : Environnement cible

| Paramètre | Valeur |
|-----------|--------|
| **Question Name** | Environnement |
| **Description** | Environnement cible pour le déploiement |
| **Answer Variable Name** | `environnement` |
| **Answer Type** | Multiple Choice (single select) |
| **Required** | ✅ Yes |
| **Multiple Choice Options** | `PRODUCTION`<br>`QUALIFICATION`<br>`DEVELOPPEMENT` |
| **Default Answer** | `PRODUCTION` |

---

### Section 4 : Configuration Filesystem

#### Question 6 : Volume Group

| Paramètre | Valeur |
|-----------|--------|
| **Question Name** | Volume Group |
| **Description** | Nom du Volume Group à utiliser pour les filesystems (défaut: vg_apps) |
| **Answer Variable Name** | `system_vgName` |
| **Answer Type** | Text |
| **Required** | ❌ No |
| **Minimum Length** | 1 |
| **Maximum Length** | 32 |
| **Default Answer** | `vg_apps` |

**Note** : Si laissé vide, la valeur par défaut `vg_apps` sera utilisée.

---

#### Question 7 : Taille des LV (Go)

| Paramètre | Valeur |
|-----------|--------|
| **Question Name** | Taille des LV (Go) |
| **Description** | Taille des Logical Volumes en Go (défaut: 10 Go) |
| **Answer Variable Name** | `system_lvSize` |
| **Answer Type** | Integer |
| **Required** | ❌ No |
| **Minimum** | 1 |
| **Maximum** | 1000 |
| **Default Answer** | `10` |

**Note** : Cette taille sera appliquée à tous les LV créés (lv_ABCDE, lv_ABCDE_ti, lv_ABCDE_to, etc.).

---

#### Question 8 : LV à exclure

| Paramètre | Valeur |
|-----------|--------|
| **Question Name** | LV à exclure |
| **Description** | Liste des Logical Volumes à exclure de la création (séparés par des virgules, ex: lv_shared_tmp,lv_shared_arch) |
| **Answer Variable Name** | `system_lvEx` |
| **Answer Type** | Text |
| **Required** | ❌ No |
| **Minimum Length** | 0 |
| **Maximum Length** | 256 |
| **Default Answer** | *(vide)* |

**Exemple** : `lv_shared_tmp,lv_shared_arch,lv_ABCDE_ti`

---

#### Question 9 : Exclusions supplémentaires 1

| Paramètre | Valeur |
|-----------|--------|
| **Question Name** | Exclusions supplémentaires 1 |
| **Description** | Liste supplémentaire de LV à exclure (optionnel) |
| **Answer Variable Name** | `system_lvEx1` |
| **Answer Type** | Text |
| **Required** | ❌ No |
| **Minimum Length** | 0 |
| **Maximum Length** | 256 |
| **Default Answer** | *(vide)* |

---

#### Question 10 : Exclusions supplémentaires 2

| Paramètre | Valeur |
|-----------|--------|
| **Question Name** | Exclusions supplémentaires 2 |
| **Description** | Liste supplémentaire de LV à exclure (optionnel) |
| **Answer Variable Name** | `system_lvEx2` |
| **Answer Type** | Text |
| **Required** | ❌ No |
| **Minimum Length** | 0 |
| **Maximum Length** | 256 |
| **Default Answer** | *(vide)* |

---

### Section 5 : Utilisateur Applicatif (Optionnel)

#### Question 11 : Nom utilisateur applicatif

| Paramètre | Valeur |
|-----------|--------|
| **Question Name** | Nom utilisateur applicatif |
| **Description** | Nom de l'utilisateur applicatif à créer (laisser vide pour auto-détection selon middleware) |
| **Answer Variable Name** | `system_username` |
| **Answer Type** | Text |
| **Required** | ❌ No |
| **Minimum Length** | 0 |
| **Maximum Length** | 32 |
| **Default Answer** | *(vide)* |

**Note** : Si laissé vide, les utilisateurs seront créés automatiquement selon le middleware détecté (oracle, wasadmin, liberty, cft).

---

#### Question 12 : Groupe applicatif

| Paramètre | Valeur |
|-----------|--------|
| **Question Name** | Groupe applicatif |
| **Description** | Nom du groupe applicatif (laisser vide pour auto-détection selon middleware) |
| **Answer Variable Name** | `system_group` |
| **Answer Type** | Text |
| **Required** | ❌ No |
| **Minimum Length** | 0 |
| **Maximum Length** | 32 |
| **Default Answer** | *(vide)* |

---

#### Question 13 : Permissions (NNN)

| Paramètre | Valeur |
|-----------|--------|
| **Question Name** | Permissions (NNN) |
| **Description** | Permissions au format NNN (ex: 755, 750) |
| **Answer Variable Name** | `system_NNN` |
| **Answer Type** | Text |
| **Required** | ❌ No |
| **Minimum Length** | 0 |
| **Maximum Length** | 3 |
| **Default Answer** | *(vide)* |

**Validation** : Le code doit contenir exactement 3 chiffres entre 0 et 7.

---

## 📊 Exemple de Saisie

### Cas d'Usage : Création d'un Socle pour une Application Oracle

| Question | Valeur Saisie |
|----------|---------------|
| Nom du serveur cible | `s02vl9942814` |
| Code Application (APxxxxx) | `AP12345` |
| Code 5 caractères | `ABCDE` |
| Identifiant instance | `01` |
| Environnement | `PRODUCTION` |
| Volume Group | `vg_apps` *(défaut)* |
| Taille des LV (Go) | `20` |
| LV à exclure | `lv_shared_tmp` |
| Exclusions supplémentaires 1 | *(vide)* |
| Exclusions supplémentaires 2 | *(vide)* |
| Nom utilisateur applicatif | *(vide - auto-détection)* |
| Groupe applicatif | *(vide - auto-détection)* |
| Permissions (NNN) | *(vide)* |

**Résultat attendu** :
- Arborescence créée : `/applis/AP12345-ABCDE-01/`
- Volume Group : `vg_apps`
- Taille des LV : 20 Go
- LV `lv_shared_tmp` exclu de la création
- Utilisateur `oracle` créé automatiquement (middleware Oracle détecté)
- Groupe `dba` créé automatiquement

---

## 🔒 Validation des Données

### Validation Côté AAP2

AAP2 effectue automatiquement les validations suivantes :

- ✅ **Champs obligatoires** : Vérification que les champs marqués "Required" sont remplis
- ✅ **Longueur** : Vérification des longueurs min/max
- ✅ **Type** : Vérification du type de données (texte, nombre, choix)
- ✅ **Plage** : Vérification des valeurs min/max pour les nombres

### Validation Côté Playbook

Le playbook effectue des validations supplémentaires :

- ✅ **Format du code AP** : Vérification que le code commence par "AP"
- ✅ **Existence du Volume Group** : Vérification que le VG existe sur le serveur
- ✅ **Version Toolbox** : Vérification que la Toolbox est >= 18.2.0
- ✅ **Permissions** : Vérification que les permissions sont valides (0-777)

---

## 🎨 Personnalisation du Survey

### Ajout d'une Question

1. Cliquez sur **"Add"** dans l'onglet Survey
2. Remplissez les champs selon le tableau ci-dessus
3. Cliquez sur **"Save"**
4. Réorganisez l'ordre des questions avec les flèches ↑↓

### Modification d'une Question

1. Cliquez sur l'icône ✏️ à côté de la question
2. Modifiez les champs nécessaires
3. Cliquez sur **"Save"**

### Suppression d'une Question

1. Cliquez sur l'icône 🗑️ à côté de la question
2. Confirmez la suppression

---

## 📖 Bonnes Pratiques

### 1. Descriptions Claires

- ✅ Utilisez des descriptions explicites pour chaque question
- ✅ Donnez des exemples de valeurs attendues
- ✅ Indiquez les valeurs par défaut

### 2. Valeurs par Défaut

- ✅ Définissez des valeurs par défaut pour les champs optionnels
- ✅ Utilisez des valeurs courantes pour simplifier la saisie

### 3. Validation

- ✅ Définissez des longueurs min/max appropriées
- ✅ Utilisez des types de données appropriés (Text, Integer, Multiple Choice)
- ✅ Marquez les champs obligatoires

### 4. Organisation

- ✅ Regroupez les questions par section logique
- ✅ Ordonnez les questions du plus général au plus spécifique
- ✅ Placez les questions obligatoires en premier

---

## 🐛 Dépannage

### Problème : "Survey non affiché"

**Cause** : Le Survey n'est pas activé pour le template

**Solution** :
1. Vérifiez que l'option "Prompt on Launch" est activée pour "Survey"
2. Vérifiez que le Survey contient au moins une question

### Problème : "Valeur par défaut non appliquée"

**Cause** : La valeur par défaut n'est pas définie correctement

**Solution** :
1. Vérifiez que le champ "Default Answer" est rempli
2. Vérifiez que la valeur par défaut respecte les contraintes (longueur, type)

### Problème : "Validation échoue côté playbook"

**Cause** : La validation AAP2 est moins stricte que la validation playbook

**Solution** :
1. Ajoutez des contraintes supplémentaires dans le Survey (longueur, regex)
2. Ajoutez des descriptions explicites pour guider l'utilisateur

---

## 📞 Support

Pour toute question sur la configuration du Survey :

- **Documentation AAP2** : https://docs.ansible.com/automation-controller/
- **Équipe Automatisation** : automation-sha@internal.com

---

**Auteur** : Équipe Automatisation SHA  
**Version** : 1.0  
**Date** : 16 octobre 2025

