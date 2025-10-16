## Description

Ce playbook Ansible exécute plusieurs rôles pour gérer les systèmes de fichiers, les services, la toolbox et la purge des logs sur les hôtes cibles. Chaque rôle est configuré pour effectuer des tâches spécifiques en fonction des variables fournies, assurant ainsi une configuration cohérente et automatisée de l'infrastructure.

## Structure du Playbook

### Playbook principal (`playbook.yml`)

```yaml
---
- name: Execute all specified roles
  hosts: all
  become: yes

  roles:
    - role: filesystem
      vars:
        fs_action: "create"
        fs_applis: false
        fs_lv_name: "my_lv_name"
        fs_mount_point: "/applis/my_mount_point"
        fs_vgname: "vg_apps"
        fs_size: 3
        fs_mount_options: "rw,noauto"
        fs_mount_type: "ext4"
        fs_rights:
          user: "root"
          group: "root"
          mode: "0750"

    - role: filesystem
      vars:
        fs_action: "create"
        fs_applis: true
        fs_apcode: "{{ codeAP }}"
        fs_code5cars: "{{ code5car }}"
        fs_suffix: "{{ standard_lv_suffix }}"
        fs_rights:
          user: "root"
          group: "root"
          mode: "0750"
        fs_size:
          apps: "{{ fs_size4apps }}"
          apps_ti: "{{ fs_size4apps_ti }}"
          apps_to: "{{ fs_size4apps_to }}"
          apps_tmp: "{{ fs_size4apps_tmp }}"
          apps_arch: "{{ fs_size4apps_arch }}"
          shared: "{{ fs_size4shared }}"
          shared_tmp: "{{ fs_size4shared_tmp }}"
          shared_arch: "{{ fs_size4shared_arch }}"
          log_apps: "{{ fs_size4log_apps }}"
          log_shared: "{{ fs_size4log_shared }}"
          div_apps: "{{ fs_size4div_apps }}"
          div_shared: "{{ fs_size4div_shared }}"

    - role: ntp

    - role: services
      vars:
        services_name: "dynatrace"

    - role: services
      vars:
        services_name: "illumio"

    - role: services
      vars:
        services_name: "tsm"

    - role: services
      vars:
        services_name: "rear"

    - role: toolbox
      vars:
        toolbox_tool: "toolbox"

    - role: logs
      vars:
        logs_action: "purge"

    - role: update.facts

    - role: create.banner

    - role: create.user
      vars:
        user_name: "example_user"
```

## Enchaînements et Résultats Attendus

### Rôle `filesystem`

1. **Première exécution du rôle `filesystem`**:
   - **Variables**:
     - `fs_action`: "create"
     - `fs_applis`: false
     - `fs_lv_name`: "my_lv_name"
     - `fs_mount_point`: "/applis/my_mount_point"
     - `fs_vgname`: "vg_apps"
     - `fs_size`: 3
     - `fs_mount_options`: "rw,noauto"
     - `fs_mount_type`: "ext4"
     - `fs_rights`:
       - `user`: "root"
       - `group`: "root"
       - `mode`: "0750"
   - **Tâches**:
     - **Création d'un volume logique (LV) et montage**:
       - Le rôle va créer un LV nommé `my_lv_name` dans le groupe de volumes `vg_apps` avec une taille de 3 Go.
       - Le LV sera formaté en `ext4` et monté sur `/applis/my_mount_point` avec les options `rw,noauto`.
       - Les droits d'accès seront appliqués avec l'utilisateur `root`, le groupe `root` et les permissions `0750`.

2. **Deuxième exécution du rôle `filesystem`**:
   - **Variables**:
     - `fs_action`: "create"
     - `fs_applis`: true
     - `fs_apcode`: "APxxxx"
     - `fs_code5cars`: "xxxxx"
     - `fs_suffix`: "01,02"
     - `fs_rights`:
       - `user`: "root"
       - `group`: "root"
       - `mode`: "0750"
     - `fs_size`:
       - `apps`: 50
       - `apps_ti`: 2
       - `apps_to`: 2
       - `apps_tmp`: 1
       - `apps_arch`: 10
       - `shared`: 10
       - `shared_tmp`: 1
       - `shared_arch`: 1
       - `log_apps`: 2
       - `log_shared`: 1
       - `div_apps`: 15
       - `div_shared`: 2
   - **Tâches**:
     - **Création de plusieurs LV et répertoires**:
       - Le rôle va créer plusieurs LV et répertoires pour les applications spécifiées par `fs_apcode` et `fs_code5cars`.
       - Les suffixes `01` et `02` seront utilisés pour créer des LV et répertoires supplémentaires.
       - Les tailles des LV seront définies selon les valeurs fournies dans `fs_size`.
       - Les droits d'accès seront appliqués avec l'utilisateur `root`, le groupe `root` et les permissions `0750`.

### Rôle `services`

1. **Exécution du rôle `services` pour `dynatrace`**:
   - **Variables**:
     - `services_name`: "dynatrace"
   - **Tâches**:
     - **Démarrage de l'agent Dynatrace**:
       - Le rôle va exécuter le script `/apps/dynatrace/oneagent/agent/tools/oneagentctl start` pour démarrer l'agent Dynatrace.
       - L'agent sera configuré pour démarrer automatiquement au démarrage du système.

2. **Exécution du rôle `services` pour `illumio`**:
   - **Variables**:
     - `services_name`: "illumio"
   - **Tâches**:
     - **Démarrage de l'agent Illumio**:
       - Le rôle va exécuter le script `/opt/illumio_ven/illumio-ven-ctl start` pour démarrer l'agent Illumio.
       - L'agent sera configuré pour démarrer automatiquement au démarrage du système.

3. **Exécution du rôle `services` pour `tsm`**:
   - **Variables**:
     - `services_name`: "tsm"
   - **Tâches**:
     - **Configuration et démarrage du client TSM**:
       - Le rôle va configurer le client TSM en utilisant le fichier `/apps/sys/admin/tsm_system/dsm.opt`.
       - Le rôle va exécuter le script `/opt/tivoli/tsm/client/ba/bin/dsmc schedule` pour démarrer le client TSM.
       - Le client TSM sera configuré pour démarrer automatiquement au démarrage du système.

4. **Exécution du rôle `services` pour `rear`**:
   - **Variables**:
     - `services_name`: "rear"
   - **Tâches**:
     - **Exécution du script de sauvegarde REAR**:
       - Le rôle va exécuter le script `/apps/sys/admin/rear-bp2i.sh` pour effectuer une sauvegarde.
       - Une archive de sauvegarde sera créée à l'emplacement `/apps/sys/back/rear-{{ inventory_hostname | lower }}.tar`.
       - Une sauvegarde mksysb sera créée à l'emplacement `/apps/sys/back/mksysb_{{ inventory_hostname | lower }}`.

### Rôle `toolbox`

1. **Exécution du rôle `toolbox`**:
   - **Variables**:
     - `toolbox_tool`: "toolbox"
   - **Tâches**:
     - **Création du répertoire de travail**:
       - Le rôle va créer un répertoire de travail à l'emplacement `/apps/Deploy/install_tbx` avec les permissions `0700`.
     - **Installation ou mise à jour de la toolbox**:
       - Le rôle va vérifier la version actuelle de la toolbox en lisant le fichier `/apps/toolboxes/version`.
       - Le rôle va récupérer la version la plus récente de la toolbox depuis le dépôt spécifié.
       - Si la version actuelle n'est pas la plus récente, le rôle va télécharger et extraire la version la plus récente dans le répertoire de travail.
       - Le rôle va exécuter le script d'installation `Install_IPS_TOOLBOXES_MAN.ksh` pour installer ou mettre à jour la toolbox.
     - **Application des droits d'accès**:
       - Le rôle va appliquer les droits d'accès spécifiés pour les répertoires de la toolbox.
     - **Suppression du répertoire de travail**:
       - Le rôle va supprimer le répertoire de travail `/apps/Deploy/install_tbx`.

### Rôle `logs`

1. **Exécution du rôle `logs`**:
   - **Variables**:
     - `logs_action`: "purge"
   - **Tâches**:
     - **Configuration et démarrage du service de purge des logs**:
       - Le rôle va copier les fichiers `purge_logs.service` et `purge_logs.timer` dans `/etc/systemd/system/`.
       - Le rôle va générer le script `purgelogs_launcher.sh` en utilisant le template `purgelogs_launcher.sh.j2`.
       - Le rôle va recharger systemd pour reconnaître les nouveaux services et timers.
       - Le rôle va activer et démarrer le timer `purge_logs.timer` pour exécuter la purge des logs à 01:00 chaque jour.

## Résultats Attendus

- **Rôle `filesystem`**:
  - Création et montage de volumes logiques pour les systèmes de fichiers spécifiés.
  - Application des droits d'accès aux répertoires montés.

- **Rôle `services`**:
  - Démarrage et configuration des agents Dynatrace, Illumio, TSM et exécution du script de sauvegarde REAR.

- **Rôle `toolbox`**:
  - Installation ou mise à jour de la toolbox avec les droits d'accès appropriés appliqués.

- **Rôle `logs`**:
  - Configuration et démarrage du service de purge des logs avec un timer pour exécuter la purge à 01:00 chaque jour.

## Conclusion

Le playbook `playbook.yml` orchestrera l'exécution de plusieurs rôles pour gérer les systèmes de fichiers, les services, la toolbox et la purge des logs sur les hôtes cibles. Chaque rôle est configuré pour effectuer des tâches spécifiques en fonction des variables fournies, assurant ainsi une configuration cohérente et automatisée de l'infrastructure.

