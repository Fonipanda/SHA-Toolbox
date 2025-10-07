# CHECKLIST DE CONFORMITÉ ET DÉPLOIEMENT
# SHA Application Environment Builder - Contrôle qualité avant PRODUCTION

## 1. VALIDATION DES PRÉREQUIS

### 1.1 Environnement Ansible AAP2
- [ ] AAP2 configuré et opérationnel
- [ ] Inventaires PROD/ISOPROD/HORSPROD créés
- [ ] Credentials configurés (Machine + Vault)
- [ ] Execution Environment SHA disponible
- [ ] Job Templates créés pour chaque environnement

### 1.2 Accès et Permissions
- [ ] Accès SSH/WinRM aux serveurs cibles configuré
- [ ] Permissions sudo/admin configurées
- [ ] Vault Ansible configuré pour les secrets
- [ ] Certificats/clés SSH déployés

### 1.3 Dépôt Git SHA-Toolbox
- [ ] Dépôt https://github.com/Fonipanda/SHA-Toolbox.git accessible
- [ ] Rôles ips_toolbox_* disponibles et fonctionnels
- [ ] Branche main/master stable
- [ ] Variables group_vars/all.yml validées

## 2. VALIDATION DES PLAYBOOKS

### 2.1 Main Playbooks
- [ ] main_playbook_prod.yml syntaxe validée
- [ ] main_playbook_isoprod.yml syntaxe validée  
- [ ] main_playbook_horsprod.yml syntaxe validée
- [ ] Tous les rôles référencés existent
- [ ] Variables obligatoires définies

### 2.2 Rôles Personnalisés
- [ ] app_environment_builder/tasks/main.yml fonctionnel
- [ ] detect_os.yml testé sur AIX/RHEL/Windows
- [ ] detect_middleware.yml détecte tous les middlewares requis
- [ ] create_app_structure.yml respecte normes BP21
- [ ] report_generator génère JSON et stdout corrects

### 2.3 Templates et Configurations
- [ ] Templates Jinja2 syntaxiquement corrects
- [ ] Job Templates AAP2 importés et configurés
- [ ] Survey AAP2 avec questions obligatoires (Hostname, CodeAP, code5car)
- [ ] Variables extra_vars correctement mappées

## 3. CONFORMITÉ AUX RÈGLES BP21

### 3.1 Arborescence Applicative
- [ ] Structure /applis/[CodeAP]-[code5car] respectée
- [ ] Sous-répertoires selon norme: was/, ihs/, conf/, scripts/, etc.
- [ ] Répertoires de logs: /applis/logs/[CodeAP]-[code5car]/
- [ ] Répertoires de delivery: /applis/delivery/[CodeAP]-[code5car]/
- [ ] Liens symboliques /etc/local vers scripts applicatifs

### 3.2 Filesystems et Volume Groups
- [ ] Utilisation exclusive de vg_apps (pas rootvg)
- [ ] Nomenclature LV: lv_[code5car], lv_[code5car]_ti, etc.
- [ ] Tailles par défaut respectées (1G, 2G selon usage)
- [ ] Mount points conformes aux normes

### 3.3 Permissions et Sécurité
- [ ] Permissions 0755 pour répertoires applicatifs
- [ ] Permissions 0755 pour scripts
- [ ] Permissions 0750 pour configurations
- [ ] Utilisateurs middleware (was, oracle, mqm) respectés

## 4. INTÉGRATION SHA-TOOLBOX

### 4.1 Rôles Réutilisés
- [ ] ips_toolbox_system pour création filesystems
- [ ] ips_toolbox_appli pour gestion applications
- [ ] ips_toolbox_backup pour sauvegardes TSM
- [ ] ips_toolbox_wasnd/wasbase pour WebSphere
- [ ] ips_toolbox_oracle pour bases Oracle
- [ ] Autres rôles selon middlewares détectés

### 4.2 Variables Héritées
- [ ] group_vars/all.yml de SHA-Toolbox préservées
- [ ] ansible_become_method: sesu maintenu
- [ ] Variables spécifiques middleware respectées
- [ ] Pas de duplication/conflit de variables

## 5. TESTS ET VALIDATION

### 5.1 Tests Unitaires par OS
- [ ] Test détection OS sur serveur AIX
- [ ] Test détection OS sur serveur RHEL 8
- [ ] Test détection OS sur serveur Windows 2019/2025
- [ ] Test création arborescence sur chaque OS
- [ ] Test génération rapports sur chaque OS

### 5.2 Tests Middleware
- [ ] Détection WebSphere WAS ND/Base
- [ ] Détection Liberty Core/Base
- [ ] Détection IHS (IBM HTTP Server)
- [ ] Détection Oracle Database
- [ ] Détection SQL Server
- [ ] Détection MQ Series
- [ ] Détection CFT
- [ ] Détection Illumio (si présent)
- [ ] Détection TSM

### 5.3 Tests d'Intégration
- [ ] Exécution complète en environnement HORSPROD
- [ ] Exécution complète en environnement ISOPROD
- [ ] Test du Survey AAP2 avec valeurs réelles
- [ ] Test des notifications (succès/échec)
- [ ] Test de génération des rapports JSON/stdout

## 6. SÉCURITÉ ET ROLLBACK

### 6.1 Mécanismes de Sauvegarde
- [ ] Points de rollback créés avant modifications
- [ ] Sauvegarde des fichiers de configuration modifiés
- [ ] Politique de rétention des sauvegardes configurée
- [ ] Procédure de rollback documentée et testée

### 6.2 Validation Sécuritaire
- [ ] Aucun mot de passe en clair dans les playbooks
- [ ] Utilisation d'Ansible Vault pour secrets
- [ ] Logging sécurisé (pas de secrets dans logs)
- [ ] Principe de moindre privilège respecté

## 7. DOCUMENTATION ET FORMATION

### 7.1 Documentation Technique
- [ ] Guide de déploiement rédigé
- [ ] Documentation des variables obligatoires
- [ ] Procédures de troubleshooting documentées
- [ ] Guide de rollback détaillé
- [ ] Matrice de compatibilité OS/Middleware

### 7.2 Formation Équipes
- [ ] Formation AAP2 dispensée aux équipes
- [ ] Formation sur les nouveaux playbooks
- [ ] Procédures d'escalade définies
- [ ] Contacts support identifiés

## 8. ENVIRONNEMENT DE PRODUCTION

### 8.1 Prérequis Infrastructure
- [ ] Serveurs cibles avec SHA installé
- [ ] Volume groupe vg_apps configuré
- [ ] Middlewares installés selon besoins
- [ ] Connectivité réseau validée
- [ ] DNS/FQDN résolvables

### 8.2 Processus d'Approbation
- [ ] Validation par l'architecture IT
- [ ] Approbation sécurité obtenue
- [ ] Tests de non-régression effectués
- [ ] Planning de déploiement validé
- [ ] Procédure de rollback approuvée

## 9. MÉTRIQUES ET MONITORING

### 9.1 Indicateurs de Performance
- [ ] Temps d'exécution par environnement mesuré
- [ ] Taux de succès par OS documenté
- [ ] Métriques de conformité BP21 suivies
- [ ] Alerting sur échecs configuré

### 9.2 Reporting et Auditabilité
- [ ] Rapports JSON archivés et accessibles
- [ ] Logs Ansible centralisés
- [ ] Traçabilité des modifications maintenue
- [ ] Reporting périodique configuré

## 10. VALIDATION FINALE

### 10.1 Tests de Recette
- [ ] Scenario complet PROD exécuté avec succès
- [ ] Validation fonctionnelle par équipes métier
- [ ] Performance acceptable en production
- [ ] Aucun impact sur existant

### 10.2 Mise en Production
- [ ] Planning de déploiement respecté
- [ ] Communication aux équipes effectuée
- [ ] Support niveau 2/3 disponible
- [ ] Mécanisme de rollback immédiat opérationnel

---

**RESPONSABLE VALIDATION :** _____________________ **DATE :** ___________

**APPROBATION PRODUCTION :** _____________________ **DATE :** ___________

**NOTES PARTICULIÈRES :**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________