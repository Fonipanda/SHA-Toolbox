Rôle create.banner

Ce rôle crée des bannières sur les hôtes cibles.

Variables


toolbox_banner_defaults.binary (str): Chemin vers le script de bannière. Par défaut : /apps/toolboxes/exploit/banner.


env_link (dict): Mapping des environnements. Par défaut :

env_link:
  DEVELOPPEMENT: "DEV"
  TEST: "DEV"
  INTEGRATION: "INT"
  PRE-RECETTE: "QUA"
  QUALIFICATION: "QUA"
  RECETTE: "QUA"
  PRE-PRODUCTION: "PRP"
  BACKUP: "PROD"
  PRODUCTION: "PROD"





Exemple d'Appel

- name: Create banner
  ansible.builtin.include_role:
    name: create.banner



Résultats Attendus

Création de bannières sur les hôtes cibles.