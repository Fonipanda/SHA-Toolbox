# Tests des Corrections v4.8

## Test 1 : Dynatrace OneAgent - Commande de redémarrage

### Commandes de test

```bash
# Vérifier le nom du service
systemctl list-units --type=service | grep -i dynatrace

# Test de statut avec le nouveau nom
systemctl status oneagent

# Si l'agent est arrêté, le redémarrer
systemctl restart oneagent

# Vérifier le statut après redémarrage
systemctl is-active oneagent
```

### Résultat attendu
- Le service doit s'appeler `oneagent` et non `dynatrace-oneagent`
- Le redémarrage doit fonctionner avec `systemctl restart oneagent`
- Le playbook doit correctement détecter et redémarrer l'agent

---

## Test 2 : IHS - Vérification des binaires et affichage OK/KO

### Commandes de test

```bash
# Vérifier la présence d'IHS
ls -la /opt/IBM/HTTPServer
ls -la /usr/IBM/HTTPServer

# Vérifier le répertoire bin
ls -la /opt/IBM/HTTPServer/bin

# Vérifier apachectl
/opt/IBM/HTTPServer/bin/apachectl -v

# Lancer le playbook
ansible-playbook -i inventories/test/hosts main_playbook.yml --tags middleware,detection
```

### Résultat attendu dans l'output Ansible

```
═══════════════════════════════════════════════════════════════════
IBM HTTP Server (IHS) - Détection
═══════════════════════════════════════════════════════════════════
Chemin: /opt/IBM/HTTPServer
Répertoire bin: ✅ OK
Binaire apachectl: ✅ OK
Version: Apache/2.4.x (IBM)
Processus actifs: 2
Statut global: ✅ OK - Binaires présents
═══════════════════════════════════════════════════════════════════
```

### Résultat attendu dans le rapport final

```
│ 🔵 MIDDLEWARES D'APPLICATIONS (X)
│    • IBM_HTTP_Server - Version: Apache/2.4.x - Binaires: ✅ OK
```

**Cas KO attendu si binaires manquants :**
```
Répertoire bin: ❌ KO
Binaire apachectl: ❌ KO
Statut global: ⚠️ KO - Répertoire présent mais binaires manquants
```

---

## Test 3 : JVM - Vérification des binaires et affichage OK/KO

### Commandes de test

```bash
# Vérifier Java
which java
java -version

# Vérifier JAVA_HOME
echo $JAVA_HOME

# Vérifier alternatives
ls -la /usr/lib/jvm/

# Lancer le playbook
ansible-playbook -i inventories/test/hosts main_playbook.yml --tags middleware,detection
```

### Résultat attendu dans l'output Ansible

```
═══════════════════════════════════════════════════════════════════
JVM (Java Virtual Machine) - Détection
═══════════════════════════════════════════════════════════════════
Chemin Java: /usr/bin/java
Répertoire bin: ✅ OK
Version courte: openjdk version "11.0.x"
Version complète:
openjdk version "11.0.x" 2024-xx-xx
OpenJDK Runtime Environment
OpenJDK 64-Bit Server VM
JAVA_HOME: /usr/lib/jvm/java-11-openjdk
Statut global: ✅ OK - Java fonctionnel
═══════════════════════════════════════════════════════════════════
```

### Résultat attendu dans le rapport final

```
│ 🔵 MIDDLEWARES D'APPLICATIONS (X)
│    • JVM - Version: openjdk version "11.0.x" - Binaires: ✅ OK
```

---

## Test 4 : WebSphere Liberty Core - Détection améliorée

### Configuration de test

Créer une VSI avec WebSphere Liberty Core installé dans l'un de ces chemins :
- `/opt/IBM/WebSphere/Liberty`
- `/apps/wlp`
- `/opt/wlp`

### Commandes de test

```bash
# Vérifier présence Liberty
ls -la /opt/IBM/WebSphere/Liberty
ls -la /opt/wlp

# Recherche productInfo
find /opt -name "productInfo" -type f

# Vérifier les features
ls -la /opt/IBM/WebSphere/Liberty/lib/features/

# Lancer le playbook
ansible-playbook -i inventories/test/hosts main_playbook.yml --tags middleware,detection -vv
```

### Résultat attendu dans l'output Ansible

```
Chemin Liberty détecté: /opt/IBM/WebSphere/Liberty

Type Liberty détecté: WebSphere_Liberty_Core
Méthode 1 (appSecurity): Liberty_Core
Méthode 2 (feature count): Liberty_Core
```

### Résultat attendu dans le rapport final

```
│ 🔵 MIDDLEWARES D'APPLICATIONS (X)
│    • WebSphere_Liberty_Core - Version: 24.0.0.x
```

### Points de vérification

1. **Chemin détecté correctement** : Le playbook doit trouver Liberty dans n'importe quel chemin standard
2. **Type identifié** : Core vs Base doit être correctement différencié
3. **Version extraite** : La version doit être lisible (pas de N/A)
4. **Présence dans le rapport** : Liberty doit apparaître dans le récapitulatif final

---

## Test 5 : Test complet d'intégration

### Commandes

```bash
# Test complet avec toutes les corrections
ansible-playbook -i inventories/test/hosts main_playbook.yml -e "CodeAP=12345 code5car=ABC12 Hostname=test-server" --tags all

# Vérifier le rapport JSON généré
cat /tmp/ansible_reports/execution_summary_*.json | jq '.'

# Vérifier les logs
cat /tmp/ansible_reports/execution_*.log
```

### Vérifications finales

- [ ] Dynatrace utilise bien `systemctl restart oneagent`
- [ ] IHS affiche statut OK/KO avec vérification binaires
- [ ] JVM affiche statut OK/KO avec vérification binaires
- [ ] Liberty Core est détecté correctement
- [ ] Rapport final contient les statuts OK/KO pour IHS et JVM
- [ ] Aucune régression sur les autres middlewares (WAS, Oracle, MQ, CFT, SQL Server)

---

## Résolution de problèmes

### Dynatrace ne redémarre pas

```bash
# Vérifier le nom exact du service
systemctl list-units --type=service | grep -i dynatrace

# Si le service s'appelle différemment
systemctl status dynatrace-oneagent  # Ancien nom
systemctl status oneagent            # Nouveau nom
```

### IHS non détecté

```bash
# Vérifier les chemins recherchés
ls -la /opt/IBM/HTTPServer
ls -la /usr/IBM/HTTPServer
ls -la /opt/IBM/IHS
ls -la /apps/IBM/HTTPServer

# Vérifier les processus
pgrep -f "IBM/HTTPServer"
ps aux | grep httpd | grep IBM
```

### Liberty non détecté

```bash
# Recherche exhaustive
find /opt /apps /usr -type d -name "*Liberty*" -o -name "wlp" 2>/dev/null

# Vérifier productInfo
find /opt /apps /usr -name "productInfo" -type f 2>/dev/null

# Vérifier processus
pgrep -f "liberty|wlp|Liberty"
ps aux | grep java | grep -i liberty
```

---

## Notes importantes

1. Les corrections doivent fonctionner sans casser les détections existantes
2. Le rapport final doit clairement indiquer OK ou KO pour chaque composant
3. Les messages de debug doivent être suffisamment détaillés pour le troubleshooting
4. Les chemins standards doivent être prioritaires, mais les alternatives doivent être supportées
