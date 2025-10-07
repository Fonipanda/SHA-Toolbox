Variables Obligatoires (Tous Environnements)
Variable	Type	Description	Validation
Hostname	text	Nom du serveur cible (FQDN)	5-253 caractères
CodeAP	text	Code applicatif (5 chiffres numériques)	Exactement 5 chiffres
code5car	text	Code pentagramme (5 caractères alphanumériques)	Exactement 5 caractères
Survey PRODUCTION - Le Plus Strict
json
{
  "questions": [
    {
      "question_name": "Hostname du serveur cible",
      "description": "FQDN du serveur de production - Vérifier DNS",
      "variable": "Hostname",
      "required": true,
      "type": "text"
    },
    {
      "question_name": "Code AP (Application)", 
      "description": "5 chiffres selon référentiel REFI (ex: 12345)",
      "variable": "CodeAP",
      "required": true,
      "type": "text",
      "min": 5, "max": 5
    },
    {
      "question_name": "Code5car (Pentagramme)",
      "description": "/!\\ code5car (pas codeScar) - 5 caractères (ex: APP01)",
      "variable": "code5car", 
      "required": true,
      "type": "text",
      "min": 5, "max": 5
    },
    {
      "question_name": "Validation avant exécution",
      "description": "Serveur prêt pour PRODUCTION ? (SHA installé, vg_apps OK)",
      "variable": "production_validation",
      "required": true,
      "type": "multiplechoice",
      "choices": ["oui", "non"]
    }
  ]
}
Survey ISO-PRODUCTION - Mode Test
json
{
  "questions": [
    "// Variables obligatoires identiques",
    {
      "question_name": "Mode de test",
      "description": "Activer fonctionnalités de test et debug ?",
      "variable": "enable_test_mode", 
      "required": false,
      "type": "multiplechoice",
      "choices": ["oui", "non"],
      "default": "oui"
    }
  ]
}
Survey HORS-PRODUCTION - Plus Permissif
json
{
  "questions": [
    "// Variables obligatoires avec valeurs par défaut",
    {
      "question_name": "Fonctionnalités expérimentales",
      "variable": "enable_experimental",
      "type": "multiplechoice", 
      "choices": ["oui", "non"]
    },
    {
      "question_name": "Niveau de logging",
      "variable": "ansible_verbosity",
      "type": "multiplechoice",
      "choices": ["normal", "verbose", "debug"]
    },
    {
      "question_name": "Sauvegarde avant déploiement", 
      "variable": "enable_backup",
      "type": "multiplechoice",
      "choices": ["oui", "non"],
      "default": "oui"
    }
  ]
}
