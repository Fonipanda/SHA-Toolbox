# Guide d'Installation - SHA-Toolbox

**Version** : 1.0  
**Date** : 16 octobre 2025  
**Public** : Administrateurs Ansible

---

## 📋 Prérequis

### Environnement Ansible

- **Ansible** : Version 2.9 ou supérieure
- **Python** : Version 3.6 ou supérieure
- **Système d'exploitation** : Linux (RHEL, CentOS, Ubuntu)

### Accès Serveurs Cibles

- **SSH** : Clés SSH configurées pour les serveurs cibles
- **Privilèges** : Accès sudo/root sur les serveurs cibles
- **Connectivité** : Accès réseau aux serveurs cibles

### Serveurs Cibles

- **Toolbox IPS** : Présente et installée (version >= 18.2.0)
- **Répertoire** : `/apps/toolboxes` accessible
- **Système** : Linux (RHEL 9.x), AIX (7.x), ou Windows Server (2019/2022)

---

## 📦 Installation

### Étape 1 : Récupération du Package

#### Option A : Depuis le Dépôt Git

```bash
# Cloner le dépôt
git clone https://github.com/Fonipanda/SHA-Toolbox.git
cd SHA-Toolbox
```

#### Option B : Depuis l'Archive

```bash
# Extraire l'archive
tar -xzf SHA-Toolbox-Final.tar.gz
cd SHA-Toolbox-Final
```

---

### Étape 2 : Copie des Fichiers Corrigés

```bash
# Copier les rôles corrigés dans le projet existant
cp -r roles/ips_toolbox_system/tasks/create-directory_Linux_system.yml \
      /path/to/your/project/roles/ips_toolbox_system/tasks/

# Copier les nouveaux rôles
cp -r roles/ips_toolbox_banner /path/to/your/project/roles/
cp -r roles/ips_toolbox_users /path/to/your/project/roles/

# Copier les rôles améliorés
cp -r roles/ips_toolbox_dynatrace/tasks/check_Linux_dynatrace.yml \
      /path/to/your/project/roles/ips_toolbox_dynatrace/tasks/

cp -r roles/ips_toolbox_illumio/tasks/check_Linux_illumio.yml \
      /path/to/your/project/roles/ips_toolbox_illumio/tasks/

cp -r roles/ips_toolbox_backup/tasks/check_Linux_tsm.yml \
      /path/to/your/project/roles/ips_toolbox_backup/tasks/
```

---

### Étape 3 : Vérification de la Syntaxe

```bash
# Vérifier la syntaxe du playbook principal
ansible-playbook main_playbook_prod.yml --syntax-check

# Vérifier la syntaxe du playbook de vérification
ansible-playbook check_playbook.yml --syntax-check
```

**Résultat attendu** :
```
playbook: main_playbook_prod.yml
playbook: check_playbook.yml
```

---

### Étape 4 : Configuration des Inventaires

#### Inventaire de Production

Éditez le fichier `inventories/prod/hosts` :

```ini
[sha_servers]
s02vl9942814 ansible_host=10.20.30.40 ansible_user=ansible_user

[sha_servers:vars]
ansible_become=true
ansible_become_method=sudo
```

#### Inventaire de Qualification

Éditez le fichier `inventories/qual/hosts` :

```ini
[sha_servers]
s02vl9942815 ansible_host=10.20.30.41 ansible_user=ansible_user

[sha_servers:vars]
ansible_become=true
ansible_become_method=sudo
```

---

### Étape 5 : Test de Connectivité

```bash
# Tester la connectivité SSH
ansible -i inventories/prod/hosts sha_servers -m ping

# Tester l'accès sudo
ansible -i inventories/prod/hosts sha_servers -m shell -a "whoami" --become
```

**Résultat attendu** :
```
s02vl9942814 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

s02vl9942814 | CHANGED | rc=0 >>
root
```

---

## 🔧 Configuration AAP2

### Étape 1 : Création du Projet

1. Connectez-vous à l'interface AAP2
2. Naviguez vers **Resources** → **Projects**
3. Cliquez sur **"Add"**
4. Remplissez les champs :
   - **Name** : `SHA-Toolbox`
   - **Organization** : Sélectionnez votre organisation
   - **Source Control Type** : `Git`
   - **Source Control URL** : `https://github.com/Fonipanda/SHA-Toolbox.git`
   - **Source Control Branch/Tag/Commit** : `main`
5. Cliquez sur **"Save"**
6. Cliquez sur **"Sync Project"** pour synchroniser

---

### Étape 2 : Création de l'Inventaire

1. Naviguez vers **Resources** → **Inventories**
2. Cliquez sur **"Add"** → **"Add inventory"**
3. Remplissez les champs :
   - **Name** : `SHA Servers - Production`
   - **Organization** : Sélectionnez votre organisation
4. Cliquez sur **"Save"**
5. Cliquez sur **"Hosts"** → **"Add"**
6. Ajoutez les serveurs cibles

---

### Étape 3 : Création des Credentials

#### Credential SSH

1. Naviguez vers **Resources** → **Credentials**
2. Cliquez sur **"Add"**
3. Remplissez les champs :
   - **Name** : `SSH Key - SHA Servers`
   - **Organization** : Sélectionnez votre organisation
   - **Credential Type** : `Machine`
   - **Username** : `ansible_user`
   - **SSH Private Key** : Collez votre clé privée SSH
   - **Privilege Escalation Method** : `sudo`
4. Cliquez sur **"Save"**

---

### Étape 4 : Création du Job Template

1. Naviguez vers **Resources** → **Templates**
2. Cliquez sur **"Add"** → **"Add job template"**
3. Remplissez les champs :
   - **Name** : `SHA-Toolbox - Création Socle Applicatif`
   - **Job Type** : `Run`
   - **Inventory** : Sélectionnez `SHA Servers - Production`
   - **Project** : Sélectionnez `SHA-Toolbox`
   - **Playbook** : Sélectionnez `main_playbook_prod.yml`
   - **Credentials** : Sélectionnez `SSH Key - SHA Servers`
   - **Options** : Cochez `Prompt on launch` pour `Survey`
4. Cliquez sur **"Save"**

---

### Étape 5 : Configuration du Survey

1. Dans le Job Template, cliquez sur l'onglet **"Survey"**
2. Cliquez sur **"Add"**
3. Suivez le guide [GUIDE_SURVEY_AAP2.md](GUIDE_SURVEY_AAP2.md) pour ajouter toutes les questions

**Questions à ajouter** :
- Nom du serveur cible (`hostname`)
- Code Application (`codeAP`)
- Code 5 caractères (`code5car`)
- Identifiant instance (`system_iis`)
- Environnement (`environnement`)
- Volume Group (`system_vgName`)
- Taille des LV (`system_lvSize`)
- LV à exclure (`system_lvEx`)
- Nom utilisateur (`system_username`)
- Groupe (`system_group`)
- Permissions (`system_NNN`)

4. Cliquez sur **"Save"** pour chaque question
5. Activez le Survey en cochant **"Survey Enabled"**

---

## ✅ Validation de l'Installation

### Test 1 : Exécution en Mode Check

```bash
# Depuis la ligne de commande
ansible-playbook main_playbook_prod.yml \
  -i inventories/prod/hosts \
  --check \
  -e "hostname=s02vl9942814" \
  -e "codeAP=AP12345" \
  -e "code5car=ABCDE" \
  -e "system_iis=01" \
  -e "environnement=PRODUCTION"
```

**Résultat attendu** : Simulation des changements sans modification du système

---

### Test 2 : Exécution via AAP2

1. Naviguez vers **Resources** → **Templates**
2. Cliquez sur le bouton 🚀 à côté de `SHA-Toolbox - Création Socle Applicatif`
3. Remplissez le Survey avec les valeurs de test
4. Cliquez sur **"Next"** puis **"Launch"**
5. Surveillez l'exécution dans la vue **Jobs**

**Résultat attendu** :
- ✅ Job Status : `Successful`
- ✅ Arborescence créée : `/applis/AP12345-ABCDE-01/`
- ✅ Bannières créées : `/etc/motd`, `/etc/issue`
- ✅ Utilisateurs créés (selon middleware détecté)
- ✅ Services configurés (Dynatrace, Illumio, TSM)

---

## 🐛 Dépannage

### Erreur : "Project sync failed"

**Cause** : Impossible de synchroniser le projet Git

**Solution** :
1. Vérifiez l'URL du dépôt Git
2. Vérifiez les credentials Git (si dépôt privé)
3. Vérifiez la connectivité réseau

---

### Erreur : "Host unreachable"

**Cause** : Impossible de se connecter au serveur cible

**Solution** :
1. Vérifiez la connectivité réseau : `ping <serveur>`
2. Vérifiez l'accès SSH : `ssh ansible_user@<serveur>`
3. Vérifiez les credentials dans AAP2

---

### Erreur : "Privilege escalation failed"

**Cause** : Impossible d'obtenir les privilèges sudo

**Solution** :
1. Vérifiez que l'utilisateur a les droits sudo
2. Vérifiez la configuration sudo sur le serveur cible
3. Vérifiez le paramètre "Privilege Escalation Method" dans les credentials

---

### Erreur : "Toolbox not found"

**Cause** : La Toolbox IPS n'est pas présente sur le serveur cible

**Solution** :
1. Vérifiez que le répertoire `/apps/toolboxes` existe
2. Vérifiez que la version est >= 18.2.0
3. Contactez l'équipe infrastructure pour installer la Toolbox

---

## 📖 Documentation Complémentaire

- [README.md](../README.md) : Documentation principale
- [GUIDE_SURVEY_AAP2.md](GUIDE_SURVEY_AAP2.md) : Configuration du Survey
- [ANALYSE_REVISEE_TOOLBOX.md](ANALYSE_REVISEE_TOOLBOX.md) : Analyse technique

---

## 📞 Support

Pour toute question ou problème :

- **Documentation** : Consulter les fichiers README dans le dépôt
- **Équipe** : Contacter l'équipe d'automatisation SHA
- **Email** : automation-sha@internal.com

---

**Auteur** : Équipe Automatisation SHA  
**Version** : 1.0  
**Date** : 16 octobre 2025

