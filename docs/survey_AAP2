# SURVEY AAP2 - SHA APPLICATION ENVIRONMENT BUILDER
# Configuration des Surveys pour Ansible Automation Platform 2

## Variables Obligatoires (Tous Environnements)

| Variable | Type | Description | Validation |
|----------|------|-------------|------------|
| **Hostname** | text | Nom du serveur cible (FQDN) | 5-253 caractères |
| **CodeAP** | text | Code applicatif (5 chiffres numériques) | Exactement 5 chiffres |
| **code5car** | text | Code pentagramme (5 caractères alphanumériques) | Exactement 5 caractères |

---

## Survey PRODUCTION - Le Plus Strict

```json
{
  "name": "SHA Application Environment Survey - PRODUCTION",
  "description": "Variables requises pour la construction d'environnement applicatif en PRODUCTION",
  "spec": [
    {
      "question_name": "Hostname du serveur cible",
      "question_description": "FQDN du serveur de production - Vérifier DNS",
      "variable": "Hostname",
      "required": true,
      "type": "text",
      "min": 5,
      "max": 253,
      "default": "",
      "choices": "",
      "new_question": true
    },
    {
      "question_name": "Code AP (Application)", 
      "question_description": "5 chiffres selon référentiel REFI (ex: 12345)",
      "variable": "CodeAP",
      "required": true,
      "type": "text",
      "min": 5,
      "max": 5,
      "default": "",
      "choices": "",
      "new_question": true
    },
    {
      "question_name": "Code5car (Pentagramme)",
      "question_description": "/!\\ code5car (pas codeScar) - 5 caractères (ex: APP01)",
      "variable": "code5car", 
      "required": true,
      "type": "text",
      "min": 5,
      "max": 5,
      "default": "",
      "choices": "",
      "new_question": true
    },
    {
      "question_name": "Validation avant exécution",
      "question_description": "Serveur prêt pour PRODUCTION ? (SHA installé, vg_apps OK)",
      "variable": "production_validation",
      "required": true,
      "type": "multiplechoice",
      "min": 0,
      "max": 0,
      "default": "non",
      "choices": "oui\nnon",
      "new_question": true
    }
  ]
}
```

---

## Survey ISO-PRODUCTION - Mode Test

```json
{
  "name": "SHA Application Environment Survey - ISO-PRODUCTION",
  "description": "Variables requises pour la construction d'environnement applicatif en ISO-PRODUCTION",
  "spec": [
    {
      "question_name": "Hostname du serveur cible",
      "question_description": "FQDN du serveur d'iso-production",
      "variable": "Hostname",
      "required": true,
      "type": "text",
      "min": 5,
      "max": 253,
      "default": "",
      "choices": "",
      "new_question": true
    },
    {
      "question_name": "Code AP (Application)",
      "question_description": "5 chiffres selon référentiel REFI (ex: 12345)",
      "variable": "CodeAP",
      "required": true,
      "type": "text",
      "min": 5,
      "max": 5,
      "default": "",
      "choices": "",
      "new_question": true
    },
    {
      "question_name": "Code5car (Pentagramme)",
      "question_description": "/!\\ code5car (pas codeScar) - 5 caractères (ex: TST01)",
      "variable": "code5car",
      "required": true,
      "type": "text",
      "min": 5,
      "max": 5,
      "default": "",
      "choices": "",
      "new_question": true
    },
    {
      "question_name": "Mode de test",
      "question_description": "Activer fonctionnalités de test et debug ?",
      "variable": "enable_test_mode", 
      "required": false,
      "type": "multiplechoice",
      "min": 0,
      "max": 0,
      "default": "oui",
      "choices": "oui\nnon",
      "new_question": true
    }
  ]
}
```

---

## Survey HORS-PRODUCTION - Plus Permissif

```json
{
  "name": "SHA Application Environment Survey - HORS-PRODUCTION",
  "description": "Variables requises pour la construction d'environnement applicatif en HORS-PRODUCTION",
  "spec": [
    {
      "question_name": "Hostname du serveur cible",
      "question_description": "Nom d'hôte du serveur de développement/test",
      "variable": "Hostname",
      "required": true,
      "type": "text",
      "min": 3,
      "max": 253,
      "default": "",
      "choices": "",
      "new_question": true
    },
    {
      "question_name": "Code AP (Application)",
      "question_description": "5 chiffres (peut être factice pour les tests)",
      "variable": "CodeAP",
      "required": true,
      "type": "text",
      "min": 5,
      "max": 5,
      "default": "99999",
      "choices": "",
      "new_question": true
    },
    {
      "question_name": "Code5car (Pentagramme)",
      "question_description": "/!\\ code5car (pas codeScar) - 5 caractères (ex: DEV01)",
      "variable": "code5car",
      "required": true,
      "type": "text",
      "min": 5,
      "max": 5,
      "default": "DEV01",
      "choices": "",
      "new_question": true
    },
    {
      "question_name": "Fonctionnalités expérimentales",
      "question_description": "Activer les fonctionnalités expérimentales et en développement ?",
      "variable": "enable_experimental",
      "required": false,
      "type": "multiplechoice",
      "min": 0,
      "max": 0,
      "default": "non",
      "choices": "oui\nnon",
      "new_question": true
    },
    {
      "question_name": "Niveau de logging",
      "question_description": "Niveau de détail des logs Ansible",
      "variable": "ansible_verbosity",
      "required": false,
      "type": "multiplechoice",
      "min": 0,
      "max": 0,
      "default": "normal",
      "choices": "normal\nverbose\ndebug",
      "new_question": true
    },
    {
      "question_name": "Sauvegarde avant déploiement", 
      "question_description": "Créer une sauvegarde avant le déploiement ? (recommandé même en dev)",
      "variable": "enable_backup",
      "required": false,
      "type": "multiplechoice",
      "min": 0,
      "max": 0,
      "default": "oui",
      "choices": "oui\nnon",
      "new_question": true
    }
  ]
}
```

---

## Injection Automatique des Variables

### Variables Injectées Selon l'Environnement

#### PRODUCTION
```yaml
extra_vars:
  environment_type: "PROD"
  validation_level: "strict"
  enable_rollback: true
  backup_retention: "30d"
  compliance_check: true
```

#### ISO-PRODUCTION
```yaml
extra_vars:
  environment_type: "ISOPROD"
  validation_level: "medium"
  allow_testing_features: true
  backup_retention: "7d"
  enable_debug_mode: true
```

#### HORS-PRODUCTION
```yaml
extra_vars:
  environment_type: "HORSPROD"
  validation_level: "low"
  allow_experimental_features: true
  backup_retention: "3d"
  enable_debug_tools: true
```

---

## Validation des Variables

### Regex de Validation
```yaml
validation_patterns:
  hostname: "^[a-zA-Z0-9][a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9]?$"
  codeap: "^[0-9]{5}$"
  code5car: "^[A-Za-z0-9]{5}$"
```

### Messages d'Erreur
- **Hostname** : "Le hostname doit être un FQDN valide (5-253 caractères)"
- **CodeAP** : "Le Code AP doit contenir exactement 5 chiffres"
- **code5car** : "Le code5car doit contenir exactement 5 caractères alphanumériques"

---

## Utilisation dans AAP2

### Import via Interface Web
1. Aller dans **Templates** → **Job Templates**
2. Créer/Modifier le Job Template
3. Activer **Survey Enabled**
4. Coller le JSON dans **Survey**

### Import via CLI
```bash
# Création du Job Template avec Survey
awx job_templates create \
  --name "SHA-ApplicationEnv-PROD" \
  --playbook "main_playbook_prod.yml" \
  --project "SHA-Toolbox" \
  --inventory "PROD-Inventory" \
  --survey-enabled true

# Import du Survey
awx job_templates modify SHA-ApplicationEnv-PROD \
  --survey-spec @aap2_survey_prod.json
```

### Import via API
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AAP_TOKEN" \
  -d @aap2_survey_prod.json \
  https://aap.company.com/api/v2/job_templates/123/survey_spec/
```

---

## Exemples d'Exécution

### Exemple PRODUCTION
```
Hostname du serveur cible: srv-app-prod-01.fr.net.intra
Code AP (Application): 12345
Code5car (Pentagramme): APP01
Validation avant exécution: oui
```

### Exemple ISO-PRODUCTION
```
Hostname du serveur cible: srv-app-isoprod-01.fr.net.intra
Code AP (Application): 12345
Code5car (Pentagramme): TST01
Mode de test: oui
```

### Exemple HORS-PRODUCTION
```
Hostname du serveur cible: srv-app-dev-01
Code AP (Application): 99999
Code5car (Pentagramme): DEV01
Fonctionnalités expérimentales: non
Niveau de logging: debug
Sauvegarde avant déploiement: oui
```

---

## Notes Importantes

⚠️ **ATTENTION** : Il s'agit bien de **code5car** et non **codeScar** selon les spécifications fournies.

✅ **Middleware** : La détection des middlewares se fait automatiquement par les playbooks, aucune question n'est posée à l'utilisateur.

✅ **Variables obligatoires** : Seules 3 variables sont demandées dans tous les environnements : Hostname, CodeAP, code5car.

✅ **Conformité** : Les surveys respectent les normes BP21 et les documents de règles IT fournis.