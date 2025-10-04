# 📋 Guide de Configuration du Survey AAP2 - Create Socle v2

## 🎯 Vue d'ensemble

Ce guide détaille la configuration complète du **Survey** (questionnaire interactif) dans **Ansible Automation Platform 2 (AAP2)** avec l'interface utilisateur en français pour le projet **Create Socle v2**.

Le Survey permet aux utilisateurs de fournir les paramètres nécessaires au déploiement via une interface graphique intuitive, sans avoir à manipuler directement les variables Ansible.

---

## 📝 Étapes de Configuration dans AAP2

### Étape 1 : Accéder à la Job Template

1. **Connexion à AAP2** : Ouvrir votre navigateur et accéder à l'interface AAP2
2. **Navigation** : Aller dans le menu **Ressources** → **Modèles** (ou **Templates**)
3. **Sélection** : Cliquer sur le modèle de job (Job Template) lié à votre playbook principal `site.yml`
   - Si le modèle n'existe pas encore, créer un nouveau modèle de job en cliquant sur **Ajouter** → **Ajouter un modèle de job**

### Étape 2 : Ouvrir l'onglet Survey

1. Dans la page du modèle de job, cliquer sur l'onglet **« Survey »** (ou **« Questionnaire »** en français)
2. Activer le Survey en cliquant sur le bouton **« Activé »** (ou toggle switch)
3. Cliquer sur **« Ajouter »** pour commencer à ajouter les questions

### Étape 3 : Ajouter les Questions du Survey

Configurer chaque question du Survey selon le tableau ci-dessous. Pour chaque question :
- Cliquer sur **« Ajouter »**
- Remplir tous les champs requis
- Cliquer sur **« Enregistrer »**
- Répéter pour toutes les questions

---

## 📊 Configuration Détaillée des Questions

### Question 1 : Nom du Serveur Cible

| **Paramètre** | **Valeur** |
|---------------|------------|
| **Nom de la question** | Nom du serveur cible |
| **Description** | Nom d'hôte ou pattern de la machine cible (ex: server1, srv-myapp-*) |
| **Nom de la variable** | `survey_target_hostname` |
| **Type de réponse** | Texte (Text) |
| **Valeur par défaut** | *(laisser vide)* |
| **Obligatoire** | ✅ Oui |
| **Validation** | *(optionnel)* |

---

### Question 2 : Code Application (CodeAP)

| **Paramètre** | **Valeur** |
|---------------|------------|
| **Nom de la question** | Code Application (5 chiffres) |
| **Description** | Code application à 5 chiffres (ex: 12345) |
| **Nom de la variable** | `survey_codeAP` |
| **Type de réponse** | Texte (Text) |
| **Valeur par défaut** | *(laisser vide)* |
| **Obligatoire** | ✅ Oui |
| **Validation (Regex)** | `^\d{5}$` |
| **Message d'erreur** | Le code AP doit contenir exactement 5 chiffres |

---

### Question 3 : Code Scar (5 caractères)

| **Paramètre** | **Valeur** |
|---------------|------------|
| **Nom de la question** | Code Scar (5 caractères) |
| **Description** | Code Scar alphanumérique de 5 caractères (ex: ABC12, MYAPP) |
| **Nom de la variable** | `survey_codeScar` |
| **Type de réponse** | Texte (Text) |
| **Valeur par défaut** | *(laisser vide)* |
| **Obligatoire** | ✅ Oui |
| **Validation (Regex)** | `^[A-Za-z0-9]{5}$` |
| **Message d'erreur** | Le code Scar doit contenir exactement 5 caractères alphanumériques |

---

### Question 4 : Opération à Effectuer

| **Paramètre** | **Valeur** |
|---------------|------------|
| **Nom de la question** | Opération à effectuer |
| **Description** | Sélectionnez le type d'opération à exécuter sur le serveur cible |
| **Nom de la variable** | `survey_operation` |
| **Type de réponse** | Choix multiple (Multiple Choice - Single Select) |
| **Valeur par défaut** | `check` |
| **Obligatoire** | ✅ Oui |
| **Choix disponibles** | Voir la liste ci-dessous ⬇️ |

#### Liste des Valeurs pour `survey_operation`

Ajouter les options suivantes dans l'ordre :

| **Valeur** | **Description** |
|------------|-----------------|
| `check` | Vérification de l'état des composants |
| `info` | Récupération des informations système |
| `filesystem` | Gestion du système de fichiers |
| `arborescence` | Création de l'arborescence applicative |
| `application` | Déploiement de l'application |
| `monitoring` | Configuration du monitoring |
| `liberty` | Configuration Liberty Core/Base |
| `was` | Configuration WebSphere Application Server |
| `web` | Configuration serveur web (IHS/Apache) |
| `oracle` | Configuration base de données Oracle |
| `tsm` | Configuration sauvegarde TSM |
| `backup` | Configuration sauvegarde générique |

**Instructions pour ajouter les choix multiples dans AAP2 :**
1. Dans le champ **« Choix multiples »**, cliquer sur **« Ajouter »**
2. Pour chaque ligne, entrer la **valeur** (ex: `check`) et optionnellement une **description**
3. Répéter pour toutes les valeurs listées ci-dessus

---

## 🔧 Configuration Avancée (Optionnelle)

### Questions Supplémentaires Recommandées

Vous pouvez ajouter ces questions supplémentaires pour une gestion plus fine :

#### Question 5 : Environnement Cible

| **Paramètre** | **Valeur** |
|---------------|------------|
| **Nom de la question** | Environnement cible |
| **Description** | Environnement de déploiement |
| **Nom de la variable** | `survey_environment` |
| **Type de réponse** | Choix multiple (Single Select) |
| **Valeur par défaut** | `dev` |
| **Obligatoire** | ✅ Oui |
| **Choix** | `dev`, `test`, `qual`, `prod` |

#### Question 6 : Nom de l'Application

| **Paramètre** | **Valeur** |
|---------------|------------|
| **Nom de la question** | Nom de l'application |
| **Description** | Nom complet de l'application à déployer |
| **Nom de la variable** | `survey_application_name` |
| **Type de réponse** | Texte (Text) |
| **Valeur par défaut** | *(laisser vide)* |
| **Obligatoire** | ❌ Non |

#### Question 7 : Utilisateur Technique

| **Paramètre** | **Valeur** |
|---------------|------------|
| **Nom de la question** | Utilisateur technique |
| **Description** | Nom de l'utilisateur technique pour l'application (ex: was, liberty) |
| **Nom de la variable** | `survey_technical_user` |
| **Type de réponse** | Texte (Text) |
| **Valeur par défaut** | `was` |
| **Obligatoire** | ✅ Oui |

#### Question 8 : Groupe Technique

| **Paramètre** | **Valeur** |
|---------------|------------|
| **Nom de la question** | Groupe technique |
| **Description** | Nom du groupe technique pour l'application (ex: was, liberty) |
| **Nom de la variable** | `survey_technical_group` |
| **Type de réponse** | Texte (Text) |
| **Valeur par défaut** | `was` |
| **Obligatoire** | ✅ Oui |

#### Question 9 : Configurer le Serveur Web

| **Paramètre** | **Valeur** |
|---------------|------------|
| **Nom de la question** | Configurer le serveur web (IHS/Apache) |
| **Description** | Activer la configuration du serveur web |
| **Nom de la variable** | `survey_configure_webserver` |
| **Type de réponse** | Choix multiple (Single Select) |
| **Valeur par défaut** | `false` |
| **Obligatoire** | ✅ Oui |
| **Choix** | `true`, `false` |

#### Question 10 : Configurer Oracle

| **Paramètre** | **Valeur** |
|---------------|------------|
| **Nom de la question** | Configurer la base de données Oracle |
| **Description** | Activer la configuration Oracle (tablespaces, listener) |
| **Nom de la variable** | `survey_configure_oracle_db` |
| **Type de réponse** | Choix multiple (Single Select) |
| **Valeur par défaut** | `false` |
| **Obligatoire** | ✅ Oui |
| **Choix** | `true`, `false` |

#### Question 11 : URL de l'Application

| **Paramètre** | **Valeur** |
|---------------|------------|
| **Nom de la question** | URL de l'application |
| **Description** | URL complète de l'application (ex: https://myapp.company.com) |
| **Nom de la variable** | `survey_application_url` |
| **Type de réponse** | Texte (Text) |
| **Valeur par défaut** | *(laisser vide)* |
| **Obligatoire** | ❌ Non |
| **Validation (Regex)** | `^https?://.*` |

---

## ✅ Étape 4 : Finaliser et Sauvegarder

1. **Vérifier l'ordre** : Réorganiser les questions dans l'ordre souhaité en utilisant les flèches de déplacement
2. **Prévisualiser** : Cliquer sur **« Aperçu »** pour visualiser le Survey tel qu'il apparaîtra aux utilisateurs
3. **Enregistrer** : Cliquer sur **« Enregistrer »** pour sauvegarder la configuration du Survey
4. **Retour au modèle** : Revenir à la page principale du modèle de job

---

## 🧪 Étape 5 : Tester le Job Template avec le Survey

1. **Lancer le Job** : Depuis la liste des modèles, cliquer sur l'icône **« Lancer »** (fusée) à côté de votre modèle
2. **Remplir le Survey** : Une fenêtre modale s'ouvre avec toutes les questions configurées
3. **Valider** : Remplir les champs obligatoires et cliquer sur **« Suivant »** puis **« Lancer »**
4. **Vérifier l'exécution** : Le playbook s'exécute avec les variables fournies via le Survey

### Exemple de Test

**Valeurs de test recommandées :**
- **Nom du serveur cible** : `test-server-01`
- **Code Application** : `12345`
- **Code Scar** : `MYAPP`
- **Opération** : `check`
- **Environnement** : `dev`

---

## 📊 Résumé des Variables Survey

| **Variable AAP2** | **Description** | **Type** | **Validation** | **Obligatoire** | **Défaut** |
|-------------------|-----------------|----------|----------------|-----------------|------------|
| `survey_target_hostname` | Nom machine cible | Texte | - | ✅ Oui | - |
| `survey_codeAP` | Code App (5 chiffres) | Texte | `^\d{5}$` | ✅ Oui | - |
| `survey_codeScar` | Code Scar (5 alphanum.) | Texte | `^[A-Za-z0-9]{5}$` | ✅ Oui | - |
| `survey_operation` | Opération | Liste | 12 valeurs | ✅ Oui | `check` |
| `survey_environment` | Environnement | Liste | 4 valeurs | ✅ Oui | `dev` |
| `survey_application_name` | Nom application | Texte | - | ❌ Non | - |
| `survey_technical_user` | Utilisateur technique | Texte | - | ✅ Oui | `was` |
| `survey_technical_group` | Groupe technique | Texte | - | ✅ Oui | `was` |
| `survey_configure_webserver` | Config serveur web | Liste | true/false | ✅ Oui | `false` |
| `survey_configure_oracle_db` | Config Oracle | Liste | true/false | ✅ Oui | `false` |
| `survey_application_url` | URL application | Texte | `^https?://.*` | ❌ Non | - |

---

## 🔗 Mapping des Variables Survey vers Playbook

Les variables du Survey sont automatiquement injectées dans votre playbook `site.yml`. Voici comment les mapper :

```yaml
---
# site.yml - Playbook principal
- name: Create Socle v2 - Déploiement complet
  hosts: "{{ survey_target_hostname | default('all') }}"
  gather_facts: yes
  become: yes
  
  vars:
    # Mapping des variables Survey
    target_hostname: "{{ survey_target_hostname }}"
    application_code_ap: "{{ survey_codeAP }}"
    application_code_5car: "{{ survey_codeScar }}"
    operation_type: "{{ survey_operation | default('check') }}"
    environment: "{{ survey_environment | default('dev') }}"
    application_name: "{{ survey_application_name | default('') }}"
    technical_user: "{{ survey_technical_user | default('was') }}"
    technical_group: "{{ survey_technical_group | default('was') }}"
    configure_webserver: "{{ survey_configure_webserver | default(false) | bool }}"
    configure_oracle_db: "{{ survey_configure_oracle_db | default(false) | bool }}"
    application_url: "{{ survey_application_url | default('') }}"
  
  tasks:
    - name: Afficher les paramètres reçus du Survey
      debug:
        msg:
          - "Serveur cible: {{ target_hostname }}"
          - "Code AP: {{ application_code_ap }}"
          - "Code Scar: {{ application_code_5car }}"
          - "Opération: {{ operation_type }}"
          - "Environnement: {{ environment }}"
```

---

## 🎨 Captures d'Écran et Exemples Visuels

### Interface du Survey dans AAP2

Lorsque le Survey est correctement configuré, l'utilisateur verra une interface similaire à :

```
┌─────────────────────────────────────────────────────────────┐
│  Lancer le modèle de job : Create Socle v2                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Nom du serveur cible *                                      │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ server1                                                 │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  Code Application (5 chiffres) *                             │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ 12345                                                   │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  Code Scar (5 caractères) *                                  │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ MYAPP                                                   │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│  Opération à effectuer *                                     │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ check                                            ▼     │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
│                                    [Annuler]  [Suivant >]   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Dépannage et Bonnes Pratiques

### Problèmes Courants

#### ❌ Le Survey ne s'affiche pas
**Solution** : Vérifier que le Survey est bien **activé** dans l'onglet Survey du modèle de job

#### ❌ Les variables ne sont pas injectées dans le playbook
**Solution** : Vérifier que les noms de variables commencent bien par `survey_` et correspondent exactement dans le playbook

#### ❌ La validation Regex ne fonctionne pas
**Solution** : Tester votre expression régulière sur un site comme [regex101.com](https://regex101.com) avant de l'ajouter

#### ❌ Les choix multiples ne s'affichent pas correctement
**Solution** : S'assurer que chaque choix est bien ajouté ligne par ligne dans l'interface AAP2

### Bonnes Pratiques

✅ **Descriptions claires** : Toujours fournir des descriptions détaillées et des exemples pour chaque question

✅ **Validation stricte** : Utiliser des expressions régulières pour valider les formats (codes, URLs, etc.)

✅ **Valeurs par défaut** : Définir des valeurs par défaut sensées pour faciliter les tests

✅ **Ordre logique** : Organiser les questions dans un ordre logique (général → spécifique)

✅ **Tests réguliers** : Tester le Survey après chaque modification importante

✅ **Documentation** : Maintenir une documentation à jour des variables Survey disponibles

---

## 📚 Ressources Complémentaires

### Documentation Officielle
- **AAP2 Documentation** : [https://docs.ansible.com/automation-controller/](https://docs.ansible.com/automation-controller/)
- **Survey Configuration** : [https://docs.ansible.com/automation-controller/latest/html/userguide/job_templates.html#surveys](https://docs.ansible.com/automation-controller/latest/html/userguide/job_templates.html#surveys)

### Fichiers du Projet
- **README.md** : Documentation complète du projet Create Socle v2
- **aap2/job_templates_config.yml** : Configuration automatisée des Job Templates
- **WORKFLOW_DIAGRAMS.md** : Diagrammes de flux et workflows

---

## 🎉 Conclusion

Votre Survey AAP2 est maintenant configuré et prêt à l'emploi ! Les utilisateurs peuvent désormais lancer des déploiements via une interface graphique intuitive sans avoir à manipuler directement les variables Ansible.

**Points clés à retenir :**
- ✅ 4 questions obligatoires minimum (hostname, codeAP, codeScar, operation)
- ✅ 7 questions supplémentaires recommandées pour une gestion complète
- ✅ Validation stricte avec expressions régulières
- ✅ Mapping automatique vers les variables du playbook
- ✅ Interface utilisateur intuitive et en français

---

**Version** : 2.0.0  
**Date de création** : 2025-01-04  
**Compatibilité** : AAP2 2.4+  
**Maintenu par** : Équipe Infrastructure & Middleware

**🚀 Votre Survey est prêt pour la production !**
