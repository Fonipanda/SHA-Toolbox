Ce rôle gère les services offerts par le système d'exploitation lorsqu'ils sont livrés par BP²I. Il peut démarrer et configurer des services spécifiques comme Dynatrace, Illumio, TSM et REAR.

## Variables Requises

- `services_name` (str): Nom du service (`dynatrace`, `illumio`, `tsm`, `rear`).

## Description des Services

### Dynatrace

- Configure Dynatrace en fullstack.
- Ne génère pas d'erreur si la configuration échoue, mais l'erreur est signalée.

### Illumio

- Vérifie si Illumio est forcé.
- Échoue si Illumio n'est pas forcé.

### REAR

- Vérifie si le système de sauvegarde est présent.
  - S'il n'est pas présent, démarre un système de sauvegarde local.

### TSM

- Vérifie si tous les artefacts TSM sont présents.
  - Échoue si un ou plusieurs artefacts sont absents.
- Démarre une sauvegarde du système REAR.

## Exemples d'Appel

### Dynatrace

```yaml
- name: Configure dynatrace
  ansible.builtin.include_role:
    name: services
  vars:
    services_name: "dynatrace"
```

### Illumio

```yaml
- name: Check illumio
  ansible.builtin.include_role:
    name: services
  vars:
    services_name: "illumio"
```

### TSM

```yaml
- name: Check and start backup system
  ansible.builtin.include_role:
    name: services
  vars:
    services_name: "tsm"
```

### REAR

```yaml
- name: Check or start rear backup system
  ansible.builtin.include_role:
    name: services
  vars:
    services_name: "rear"
```

## Résultats Attendus

- Démarrage et configuration des agents Dynatrace, Illumio, TSM et exécution du script de sauvegarde REAR.