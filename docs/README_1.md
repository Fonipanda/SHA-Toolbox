# Create Socle - Solution d'Automatisation VSI avec Ansible AAP2

## 🎯 Objectif

Le projet Create-Socle automatise l'installation et la configuration de la couche applicative sur des VM/VSI. Il prend en charge les environnements AIX, Linux, RHEL et Windows avec détection automatique du middleware et configuration adaptative.

## Fonctionnalités principales

- ✅ **Installation automatisée** de VSI avec différents middlewares
- ✅ **Gestion des filesystems** avec création de logical volumes
- ✅ **Configuration des utilisateurs techniques** (CFT, Oracle, middleware)
- ✅ **Installation et configuration des middlewares** WebSphere et Liberty
- ✅ **Configuration des services système** (monitoring [Dynatrace], sécurité [Illumio], sauvegarde [TSM/NetBackup])
- ✅ **Gestion des erreurs** et rollback automatique
- ✅ **Bannières personnalisées** et informations système
<details>
    <summary>- ✅ Fonctionnalités détaillées</summary>

### 📋 **Support Multi-OS**
- **Linux** (RedHat) : Support complet avec LVM, filesystems, arborescence Unix
- **AIX** : Support des spécificités AIX avec adaptation des commandes système
- **Windows** : Adaptation des chemins, répertoires, modules spécifiques

### 🔍 **Détection Automatique Intelligente**
- **Auto-détection du middleware** : Liberty Base/Core, WAS Base/ND, IHS
- **Validation du socle SHA** : TSM, Vormetric, CFT, Illumio, Oracle, SQL Server
- **Adaptation dynamique** : Le playbook s'adapte à l'environnement détecté

### 🛠️ **Configuration Complète**
- **Filesystems applicatifs** : Création automatique avec LVM (Linux/AIX)
- **Arborescence applicative** : Structure standardisée /apps, /shared, /log, /div
- **Utilisateurs techniques** : Création et configuration des comptes de service
- **Middleware** : Configuration et déploiement automatique selon le type détecté
- **Sécurité** : Bannière, certificats SSL, sauvegardes

### 📊 **Reporting Détaillé**
- **Sorties explicites** avec emojis et formatage visuel
- **Rapports par phase** avec statuts clairs (✅ SUCCÈS, ❌ ÉCHEC, ⏭️ SKIP)
- **Rapport final complet** résumant toute l'installation
</details>

## Types de VSI supportés

| Type de VSI | Description | Middleware | Durée d'installation |
|-------------|-------------|------------|---------------------|
| VSI Simple | Installation de base sans middleware | Aucun | 5-10 minutes |
| VSI WebSphere Base | Installation avec WebSphere Application Server | WAS 9.0.5 | 20-30 minutes |
| VSI WebSphere Liberty Base | Installation avec WebSphere Liberty (complet) | Liberty Base | 10-15 minutes |
| VSI WebSphere Liberty Core | Installation avec WebSphere Liberty (allégé) | Liberty Core | 8-12 minutes |

## 🏗️ Structure du Projet

```
create_socle/
├── group_vars/                  # Variables globales communes à tous les environnements
│   └── all.yml
├── inventories/                 # Inventaires par environnement
│   ├── dev/
│   ├── prod/
│   └── qual/
├── pipeline/  
├── roles/                       # Contient tous les rôles ips_toolbox_* avec leurs structures standards
│   ├── ips_toolbox_*          
│   │   ├── defaults/
│   │   ├── files/
│   │   ├── handlers/  
│   │   ├── library/             # Modules Python/PowerShell ips_toolbox_modules
│   │   ├── meta/  
│   │   ├── tasks/  
│   │   ├── templates/  
│   │   ├── tests/  
│   │   └── vars/  
│   └── ...
├── 02_playbook.yml              # Playbook principal
└── README.md                    # Cette documentation
```

<details>
    <summary><h2>📋 Phases d'Exécution du Job Ansible</h2></summary>
Le playbook s'exécute en **8 phases séquentielles** :

### **Phase 0 : Initialisation**
- Collecte des informations système
- Vérification de la compatibilité OS
- Affichage de l'environnement détecté

### **Phase 1 : Validation Toolbox**
- Vérification de la version de la Toolbox
- Mise à jour automatique si nécessaire

### **Phase 2 : Détection Automatique**
- Détection du middleware installé (Liberty, WAS, IHS)
- Identification du type d'environnement

### **Phase 3 : Validation du Socle (SHA)**
- Vérification de tous les composants du socle technique
- Validation TSM, Vormetric, CFT, Illumio, Oracle, SQL Server, Dynatrace

### **Phase 4 : Configuration Système**
- Vérification de l'uptime du serveur
- Création des filesystems (Linux/AIX) ou répertoires (Windows)
- Configuration de l'arborescence applicative

### **Phase 5 : Configuration WebServer**
- Configuration d'IHS si activé
- Génération des demandes de certificat (CSR)

### **Phase 6 : Configuration Spécifique**
- Configuration du tablespace Oracle si activé
- Création de l'environnement middleware détecté

### **Phase 7 : Déploiement Applicatif**
- Déploiement de l'application sur le middleware
- Configuration des paramètres de déploiement

### **Phase 8 : Finalisation**
- Vérifications post-déploiement
- Configuration de la bannière de connexion
- Lancement de la sauvegarde initiale
- Rapport final complet
</details>

### **Stratégie de Résilience**
- **`ignore_errors: yes`** sur toutes les tâches de détection
- **Conditions intelligentes** : les tâches s'adaptent aux résultats précédents
- **Messages d'erreur explicites** avec guidance pour la résolution
- **Continuation gracieuse** : le playbook continue même si certaines étapes échouent

### **Codes de Statut**
- **✅ SUCCÈS** : Tâche exécutée avec succès
- **❌ ÉCHEC** : Tâche échouée, investigation requise
- **⏭️ SKIP** : Tâche ignorée selon la configuration (normal)
- **⚠️ ATTENTION** : Tâche partiellement réussie, vérification recommandée


