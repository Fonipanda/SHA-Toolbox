1. Nom de la cible
Prompt : Nom d'hôte cible

Variable Name : target_hostname

Answer Variable Type : Text

Default Answer : (vide)

Required : ✅ Coché

2. Code AP
Prompt : Code AP (5 chiffres)

Variable Name : codeAP

Answer Variable Type : Text

Default Answer : (vide)

Required : ✅ Coché

Min Length : 5

Max Length : 5

3. Code SCAR
Prompt : Code SCAR (5 caractères alphanumériques)

Variable Name : codeScar

Answer Variable Type : Text

Default Answer : (vide)

Required : ✅ Coché

Min Length : 5

Max Length : 5

4. ID
Prompt : ID (optionnel)

Variable Name : id

Answer Variable Type : Text

Default Answer : 01

Required : ❌ Non coché

5. Taille filesystem apps
Prompt : Taille LV apps (Go)

Variable Name : fs_size4apps

Answer Variable Type : Integer

Default Answer : 2

Min : 1

Max : 100

Required : ❌ Non coché

6. Configuration WebServer
Prompt : Configurer WebServer/IHS ?

Variable Name : configure_webserver

Answer Variable Type : Multiple Choice

Multiple Choice Options :

text
False
True
Default Answer : False

Required : ❌ Non coché

7. Configuration Oracle
Prompt : Configurer Oracle DB ?

Variable Name : configure_oracle_db

Answer Variable Type : Multiple Choice

Multiple Choice Options :

text
False
True
Default Answer : False

Required : ❌ Non coché

8. Autodétection
Prompt : Autodétection des middlewares ?

Variable Name : auto_detect_middleware

Answer Variable Type : Multiple Choice

Multiple Choice Options :

text
True
False
Default Answer : True

Required : ❌ Non coché
