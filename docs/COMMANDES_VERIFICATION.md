# COMMANDES DE VÉRIFICATION - SHA-Toolbox

## Guide complet des commandes CLI Linux et Windows
## Version: 4.4.4
## Date: 2025-10-28

---

# 📋 TABLE DES MATIÈRES

1. [Bannières et Prompt](#bannières-et-prompt)
2. [Détection OS et Facts](#détection-os-et-facts)
3. [Middlewares Détectés](#middlewares-détectés)
4. [Utilisateurs Techniques](#utilisateurs-techniques)
5. [Toolbox IPS](#toolbox-ips)
6. [Arborescence et Filesystems](#arborescence-et-filesystems)
7. [NTP et Synchronisation](#ntp-et-synchronisation)
8. [Dynatrace OneAgent](#dynatrace-oneagent)
9. [Illumio VEN](#illumio-ven)
10. [TSM et Backup](#tsm-et-backup)
11. [REAR Backup](#rear-backup)
12. [Purge Logs](#purge-logs)
13. [Configuration SSH](#configuration-ssh)
14. [Autosys](#autosys)
15. [Services Système](#services-système)
16. [Rapports Ansible](#rapports-ansible)

---

# 1. BANNIÈRES ET PROMPT

## Linux (RHEL/CentOS)

### Vérifier les bannières créées
```bash
# Bannière PRÉ-LOGIN (SSH)
cat /etc/issue.net
echo "---"

# Bannière PRÉ-LOGIN (Console)
cat /etc/issue
echo "---"

# Bannière POST-LOGIN (MOTD)
cat /etc/motd
```

### Vérifier le contenu détaillé
```bash
# Voir les codes spéciaux éventuels
cat -A /etc/motd
cat -A /etc/issue.net

# Compter les lignes
wc -l /etc/motd /etc/issue.net /etc/issue
```

### Vérifier le prompt
```bash
# Variable PS1 actuelle
echo "$PS1"

# Fichier de prompt custom
cat /etc/profile.d/zzz_clean_prompt.sh

# Vérifier les codes ANSI dans les fichiers
grep -r '033\[' /etc/profile /etc/bashrc /etc/profile.d/ 2>/dev/null

# Lister tous les fichiers profile.d par ordre alphabétique
ls -la /etc/profile.d/ | sort
```

### Vérifier les backups
```bash
ls -la /etc/bashrc.bak /etc/profile.bak /etc/profile.d/*.bak 2>/dev/null
```

---

## Windows (2019/2022)

### Vérifier la bannière
```powershell
# Fichier de bannière (si créé)
Get-Content C:\Windows\System32\banner.txt -ErrorAction SilentlyContinue

# Clé de registre bannière
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -ErrorAction SilentlyContinue
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -ErrorAction SilentlyContinue
```

---

# 2. DÉTECTION OS ET FACTS

## Linux

### Informations système
```bash
# Distribution et version
cat /etc/os-release
cat /etc/redhat-release

# Architecture
uname -m
arch

# Hostname
hostname
hostname -f  # FQDN

# Kernel
uname -r
uname -a
```

### Informations matériel
```bash
# Manufacturer et Machine Type
dmidecode -s system-manufacturer
dmidecode -s system-product-name

# Serial Number
dmidecode -s system-serial-number

# Virtualisation
systemd-detect-virt
cat /sys/hypervisor/type 2>/dev/null

# CPU
lscpu | grep -E "Model name|Architecture|CPU\(s\)"

# Mémoire
free -h
cat /proc/meminfo | grep MemTotal
```

### Informations réseau
```bash
# Adresse IP principale
ip addr show | grep "inet " | grep -v "127.0.0.1"
hostname -I

# Interfaces réseau
ip link show
nmcli device status

# DNS et domaine
cat /etc/resolv.conf
hostname -d  # domaine
```

---

## Windows

### Informations système
```powershell
# Version Windows
systeminfo | findstr /C:"OS"
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion

# Hostname
hostname
$env:COMPUTERNAME

# Architecture
$env:PROCESSOR_ARCHITECTURE
```

### Informations matériel
```powershell
# Manufacturer
Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Manufacturer, Model

# Serial Number
Get-CimInstance -ClassName Win32_BIOS | Select-Object SerialNumber

# Virtualisation
Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Model

# CPU
Get-CimInstance -ClassName Win32_Processor | Select-Object Name, NumberOfCores

# Mémoire
Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object TotalPhysicalMemory
```

### Informations réseau
```powershell
# Adresse IP
ipconfig | findstr IPv4
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"}

# Interfaces
Get-NetAdapter

# DNS
Get-DnsClientServerAddress
```

---

# 3. MIDDLEWARES DÉTECTÉS

## Linux

### WebSphere (WASND, WASBASE)
```bash
# Répertoires d'installation
ls -ld /opt/IBM/WebSphere/AppServer* 2>/dev/null
ls -ld /usr/IBM/WebSphere/AppServer* 2>/dev/null

# Processus
ps -ef | grep -i "websphere" | grep -v grep
pgrep -f "WebSphere"

# Version
/opt/IBM/WebSphere/AppServer/bin/versionInfo.sh 2>/dev/null | head -20
```

### Liberty (Core/Base)
```bash
# Répertoires
ls -ld /opt/IBM/WebSphere/Liberty 2>/dev/null
ls -ld /opt/wlp 2>/dev/null
ls -ld /apps/WebSphere 2>/dev/null

# Processus
ps -ef | grep -i "liberty" | grep -v grep
pgrep -f "wlp"

# Version
/opt/IBM/WebSphere/Liberty/bin/productInfo version 2>/dev/null
```

### Oracle Database
```bash
# Répertoires
ls -ld /opt/oracle 2>/dev/null
ls -ld /u01/app/oracle 2>/dev/null

# Processus
ps -ef | grep -E "ora_|oracle" | grep -v grep
pgrep -f "oracle"

# Version
su - oracle -c "sqlplus -version" 2>/dev/null
cat /opt/oracle/product/*/inventory/ContentsXML/oraclehomeproperties.xml 2>/dev/null | grep -i version
```

### IBM MQ
```bash
# Répertoires
ls -ld /opt/mqm 2>/dev/null
ls -ld /var/mqm 2>/dev/null

# Processus
ps -ef | grep -i "mq" | grep -v grep

# Version
/opt/mqm/bin/dspmqver 2>/dev/null
```

### Axway CFT
```bash
# Répertoires
ls -ld /opt/axway 2>/dev/null
ls -ld /apps/axway 2>/dev/null

# Processus
ps -ef | grep -i "cft" | grep -v grep

# Version
find /opt/axway -name "cftutil" -exec {} about \; 2>/dev/null
```

### IBM HTTP Server (IHS)
```bash
# Répertoires
ls -ld /opt/IBM/HTTPServer* 2>/dev/null
ls -ld /usr/IBM/HTTPServer* 2>/dev/null

# Processus
ps -ef | grep -i "httpd" | grep -v grep

# Version
/opt/IBM/HTTPServer/bin/httpd -v 2>/dev/null
```

### JVM
```bash
# Version Java
java -version 2>&1
/usr/bin/java -version 2>&1

# Localisation
which java
ls -l /etc/alternatives/java

# Toutes les installations
find /usr/java /opt /usr/lib/jvm -name "java" -type f 2>/dev/null
```

### SQL Server (si Linux)
```bash
# Service
systemctl status mssql-server

# Version
/opt/mssql/bin/sqlservr --version 2>/dev/null
```

### Détection automatique via script Python
```bash
# Exécuter le script WebSphere manager
python3 /tmp/websphere_manager.py

# Vérifier s'il existe
ls -la /tmp/websphere_manager.py
```

---

## Windows

### WebSphere / Liberty
```powershell
# Répertoires
Get-ChildItem "C:\Program Files\IBM\WebSphere" -Recurse -ErrorAction SilentlyContinue
Get-ChildItem "C:\IBM\WebSphere" -Recurse -ErrorAction SilentlyContinue

# Processus
Get-Process | Where-Object {$_.ProcessName -like "*java*" -or $_.ProcessName -like "*websphere*"}

# Services
Get-Service | Where-Object {$_.DisplayName -like "*WebSphere*" -or $_.DisplayName -like "*Liberty*"}
```

### SQL Server
```powershell
# Services
Get-Service | Where-Object {$_.DisplayName -like "*SQL Server*"}

# Version
sqlcmd -S localhost -Q "SELECT @@VERSION" 2>$null

# Instances
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server" -ErrorAction SilentlyContinue
```

### Oracle (si installé sur Windows)
```powershell
# Répertoires
Get-ChildItem "C:\oracle" -ErrorAction SilentlyContinue
Get-ChildItem "C:\app" -ErrorAction SilentlyContinue

# Services
Get-Service | Where-Object {$_.DisplayName -like "*Oracle*"}
```

---

# 4. UTILISATEURS TECHNIQUES

## Linux

### Vérifier les utilisateurs créés
```bash
# Lister les utilisateurs techniques
cat /etc/passwd | grep -E "oracle|wasadmin|liberty|mqm|cft|sqladmin"

# Détails complets
id oracle
id wasadmin
id liberty
id mqm
id cft
id sqladmin

# Groupes
groups oracle
groups wasadmin
groups liberty

# Home directories
ls -ld /home/oracle /home/wasadmin /home/liberty 2>/dev/null

# Shell
getent passwd oracle wasadmin liberty | cut -d: -f7
```

### Vérifier les groupes
```bash
cat /etc/group | grep -E "dba|mqm|wasadmin"

# Membres d'un groupe
getent group dba
getent group mqm
```

---

## Windows

### Vérifier les utilisateurs
```powershell
# Lister utilisateurs locaux
Get-LocalUser

# Utilisateurs spécifiques
Get-LocalUser -Name "oracle" -ErrorAction SilentlyContinue
Get-LocalUser -Name "wasadmin" -ErrorAction SilentlyContinue

# Groupes d'un utilisateur
Get-LocalGroup | ForEach-Object { $group = $_; Get-LocalGroupMember $group | Where-Object {$_.Name -like "*oracle*"} }
```

---

# 5. TOOLBOX IPS

## Linux

### Vérifier la présence de la Toolbox
```bash
# Répertoire principal
ls -la /apps/toolboxes/

# Version
cat /apps/toolboxes/VERSION 2>/dev/null
cat /apps/toolboxes/exploit/version 2>/dev/null

# Scripts disponibles
ls -la /apps/toolboxes/exploit/

# Binaires banner
ls -la /apps/toolboxes/exploit/banner

# Includes
ls -la /apps/toolboxes/exploit/include/
cat /apps/toolboxes/exploit/include/inc_banner.ksh 2>/dev/null | head -20
```

### Vérifier l'installation
```bash
# Propriétaire
ls -ld /apps/toolboxes | awk '{print $3, $4}'

# Permissions
find /apps/toolboxes -type f -name "*.ksh" -o -name "*.sh" | xargs ls -l

# Tester un script
/apps/toolboxes/exploit/banner --help 2>/dev/null || echo "Script banner non exécutable"
```

---

# 6. ARBORESCENCE ET FILESYSTEMS

## Linux

### Vérifier les répertoires créés
```bash
# Arborescence principale
ls -ld /applis /apps /applis/logs /applis/delivery 2>/dev/null

# Propriétaires et permissions
ls -l / | grep -E "applis|apps"

# Points de montage
df -h | grep -E "applis|apps"
mount | grep -E "applis|apps"

# Inodes
df -i | grep -E "applis|apps"

# Taille utilisée
du -sh /applis /apps 2>/dev/null
```

### Vérifier les filesystems
```bash
# LVM si utilisé
lvs | grep -E "applis|apps"
vgs
pvs

# Fstab
cat /etc/fstab | grep -E "applis|apps"

# Vérifier l'espace disponible
df -h /applis /apps 2>/dev/null
```

---

## Windows

### Vérifier les répertoires
```powershell
# Répertoires principaux
Get-ChildItem C:\ | Where-Object {$_.Name -like "*applis*" -or $_.Name -like "*apps*"}

# Détails
Get-Item "C:\applis" -ErrorAction SilentlyContinue
Get-Item "C:\apps" -ErrorAction SilentlyContinue

# Permissions
Get-Acl "C:\applis" | Format-List

# Taille
Get-ChildItem "C:\applis" -Recurse | Measure-Object -Property Length -Sum
```

---

# 7. NTP ET SYNCHRONISATION

## Linux (Chrony)

### Vérifier le service Chrony
```bash
# Statut du service
systemctl status chronyd
systemctl is-active chronyd
systemctl is-enabled chronyd

# Version
chronyc --version

# Sources de temps
chronyc sources -v

# Tracking
chronyc tracking

# Statistiques
chronyc sourcestats
```

### Vérifier la configuration
```bash
# Fichier de config
cat /etc/chrony.conf

# Serveurs NTP configurés
grep "^server" /etc/chrony.conf
grep "^pool" /etc/chrony.conf

# Logs
journalctl -u chronyd -n 50
tail -f /var/log/chrony/
```

### Vérifier la synchronisation
```bash
# Date et heure système
date
timedatectl

# Statut NTP
timedatectl status | grep "NTP"

# Décalage
chronyc tracking | grep "System time"
```

---

## Windows

### Vérifier le service W32Time
```powershell
# Statut du service
Get-Service W32Time
sc query w32time

# Configuration
w32tm /query /configuration
w32tm /query /status

# Sources NTP
w32tm /query /peers

# Tester la synchronisation
w32tm /stripchart /computer:time.windows.com /samples:5
```

### Vérifier la synchronisation
```powershell
# Dernière synchro
w32tm /query /status /verbose

# Forcer une synchro
w32tm /resync /rediscover
```

---

# 8. DYNATRACE ONEAGENT

## Linux

### Vérifier l'installation
```bash
# Répertoire d'installation
ls -ld /apps/dynatrace/oneagent 2>/dev/null
ls -ld /opt/dynatrace/oneagent 2>/dev/null

# Version
/apps/dynatrace/oneagent/agent/tools/oneagentctl --version 2>&1 | head -1
```

### Vérifier le service
```bash
# Statut systemd
systemctl status dynatrace-oneagent
systemctl is-active dynatrace-oneagent
systemctl is-enabled dynatrace-oneagent

# Processus
ps -ef | grep -i dynatrace | grep -v grep
pgrep -f dynatrace
```

### Vérifier le statut et mode
```bash
# Statut de l'agent
/apps/dynatrace/oneagent/agent/tools/oneagentctl status 2>&1

# Connectivité
systemctl is-active dynatrace-oneagent 2>&1

# Configuration
cat /apps/dynatrace/oneagent/agent/conf/ruxitagent.conf 2>/dev/null | grep -i mode

# Logs
tail -f /apps/dynatrace/oneagent/log/oneagent.log 2>/dev/null
journalctl -u dynatrace-oneagent -n 50
```

---

## Windows

### Vérifier l'installation
```powershell
# Répertoire
Get-ChildItem "C:\Program Files\dynatrace" -ErrorAction SilentlyContinue

# Service
Get-Service "Dynatrace OneAgent" -ErrorAction SilentlyContinue

# Processus
Get-Process | Where-Object {$_.ProcessName -like "*dynatrace*" -or $_.ProcessName -like "*oneagent*"}
```

---

# 9. ILLUMIO VEN

## Linux

### Vérifier l'installation
```bash
# Répertoire d'installation
ls -ld /opt/illumio_ven 2>/dev/null

# Version
/opt/illumio_ven/illumio-ven-ctl version 2>&1
```

### Vérifier le statut
```bash
# Statut complet
/opt/illumio_ven/illumio-ven-ctl status 2>&1

# Composants
systemctl status illumio-ven -l

# Processus
ps -ef | grep -i illumio | grep -v grep
pgrep -f illumio
```

### Vérifier le mode et connectivité
```bash
# État de l'agent (enforced, idle, visibility)
/opt/illumio_ven/illumio-ven-ctl status 2>&1 | grep -i "agent state"

# Test de connectivité au PCE
/opt/illumio_ven/illumio-ven-ctl connectivity-test 2>&1

# Configuration
cat /opt/illumio_ven/etc/agent_config.json 2>/dev/null | grep -E "mode|pce"

# Logs
tail -f /opt/illumio_ven/var/log/illumio-ven.log 2>/dev/null
journalctl -u illumio-ven -n 50
```

---

## Windows

### Vérifier l'installation
```powershell
# Répertoire
Get-ChildItem "C:\Program Files\Illumio" -ErrorAction SilentlyContinue

# Service
Get-Service | Where-Object {$_.DisplayName -like "*Illumio*"}

# Version
& "C:\Program Files\Illumio\illumio-ven-ctl.exe" version
```

---

# 10. TSM ET BACKUP

## Linux

### Vérifier l'installation TSM
```bash
# Répertoire d'installation
ls -ld /opt/tivoli/tsm/client/ba/bin 2>/dev/null
ls -ld /usr/tivoli/tsm/client/ba/bin 2>/dev/null

# Binaire dsmc
which dsmc
ls -la /opt/tivoli/tsm/client/ba/bin/dsmc

# Version
/opt/tivoli/tsm/client/ba/bin/dsmc -version 2>&1 | head -5
dsmc query session 2>&1 | head -10
```

### Vérifier le service dsmcad
```bash
# Statut du service
systemctl status dsmcad
systemctl is-active dsmcad
systemctl is-enabled dsmcad

# Processus
ps -ef | grep dsmc | grep -v grep
```

### Vérifier la configuration TSM
```bash
# Fichier de configuration
cat /opt/tivoli/tsm/client/ba/bin/dsm.sys
cat /opt/tivoli/tsm/client/ba/bin/dsm.opt

# Tester la connexion
dsmc query session 2>&1

# Vérifier les backups récents
dsmc query backup -subdir=yes / 2>&1 | head -20
```

---

## Windows

### Vérifier TSM
```powershell
# Répertoire
Get-ChildItem "C:\Program Files\Tivoli" -ErrorAction SilentlyContinue

# Service
Get-Service | Where-Object {$_.DisplayName -like "*TSM*" -or $_.DisplayName -like "*Tivoli*"}

# Version
& "C:\Program Files\Tivoli\TSM\baclient\dsmc.exe" -version
```

---

# 11. REAR BACKUP

## Linux

### Vérifier l'installation REAR
```bash
# Paquet installé
rpm -qa | grep -i rear
dpkg -l | grep -i rear

# Version
rear --version

# Configuration
cat /etc/rear/local.conf 2>/dev/null
cat /etc/rear/site.conf 2>/dev/null

# Scripts
ls -la /usr/share/rear/backup/
ls -la /etc/rear/
```

### Vérifier les backups REAR
```bash
# Dernière sauvegarde
ls -lt /var/lib/rear/output/ 2>/dev/null | head -10

# Logs REAR
tail -f /var/log/rear/rear-*.log 2>/dev/null
ls -la /var/log/rear/
```

---

# 12. PURGE LOGS

## Linux

### Vérifier le service de purge
```bash
# Service systemd
systemctl status purge_logs.service
systemctl status purge_logs.timer

# Est-ce activé?
systemctl is-enabled purge_logs.timer
systemctl is-active purge_logs.timer

# Liste des timers
systemctl list-timers purge_logs.timer --no-pager

# Prochaine exécution
systemctl list-timers purge_logs.timer --all
```

### Vérifier la configuration
```bash
# Fichier service
cat /etc/systemd/system/purge_logs.service 2>/dev/null

# Fichier timer
cat /etc/systemd/system/purge_logs.timer 2>/dev/null

# Configuration logrotate
cat /etc/logrotate.d/exploit_rotate-log.conf 2>/dev/null
cat /apps/toolboxes/exploit/conf/rotate-log.conf 2>/dev/null

# Tester logrotate manuellement
logrotate -d /etc/logrotate.d/exploit_rotate-log.conf 2>&1
```

### Vérifier les logs purgés
```bash
# Voir les dernières purges
journalctl -u purge_logs.service -n 50

# Logs de logrotate
cat /var/log/logrotate.log | tail -50
```

---

# 13. CONFIGURATION SSH

## Linux

### Vérifier la configuration SSH
```bash
# Fichier de config principal
cat /etc/ssh/sshd_config | grep -v "^#" | grep -v "^$"

# Banner configuré
grep "^Banner" /etc/ssh/sshd_config

# PrintLastLog
grep "^PrintLastLog" /etc/ssh/sshd_config

# PrintMotd
grep "^PrintMotd" /etc/ssh/sshd_config

# Tester la syntaxe
sshd -t

# Statut du service
systemctl status sshd
systemctl is-active sshd
```

### Vérifier les backups
```bash
ls -lat /etc/ssh/sshd_config* | head -5
```

---

## Windows

### Vérifier OpenSSH
```powershell
# Service SSH
Get-Service sshd -ErrorAction SilentlyContinue

# Configuration
Get-Content "C:\ProgramData\ssh\sshd_config" -ErrorAction SilentlyContinue
```

---

# 14. AUTOSYS

## Linux

### Vérifier Autosys
```bash
# Variables d'environnement
echo $AUTOSYS
echo $AUTOUSER

# Binaires
which autosyslog
which sendevent
which autorep

# Processus
ps -ef | grep -i autosys | grep -v grep

# Jobs définis
autorep -J ALL 2>/dev/null | head -20
```

---

# 15. SERVICES SYSTÈME

## Linux

### Lister les services détectés
```bash
# Services actifs
systemctl list-units --type=service --state=running

# Services spécifiques
systemctl status chronyd sshd rsyslog crond atd

# Tous les services
systemctl list-unit-files --type=service | grep -E "enabled|running"
```

### Catégories de services
```bash
# Synchronisation
systemctl status chronyd

# Sécurité
systemctl status sshd sssd

# Journalisation
systemctl status rsyslog filebeat

# Planification
systemctl status crond atd

# Supervision
systemctl status elastic-agent

# Réseau
systemctl status NetworkManager snmpd
```

---

## Windows

### Lister les services
```powershell
# Tous les services
Get-Service | Sort-Object Status, DisplayName

# Services en cours
Get-Service | Where-Object {$_.Status -eq "Running"}

# Services spécifiques
Get-Service | Where-Object {$_.DisplayName -like "*Time*" -or $_.DisplayName -like "*DNS*"}
```

---

# 16. RAPPORTS ANSIBLE

## Linux

### Vérifier les rapports générés
```bash
# Répertoire des rapports
ls -la /tmp/ansible_reports/ 2>/dev/null

# Dernier rapport d'exécution
ls -lt /tmp/ansible_reports/execution_*.log | head -1
cat /tmp/ansible_reports/execution_*.log | tail -100

# Rapport de compliance
ls -lt /tmp/ansible_checks/compliance_report_*.json 2>/dev/null | head -1
cat /tmp/ansible_checks/compliance_report_*.json | jq '.' 2>/dev/null || cat /tmp/ansible_checks/compliance_report_*.json

# Facts collectés
cat /tmp/ansible_reports/ansible_facts_*.json 2>/dev/null | jq '.' 2>/dev/null | head -50
```

---

# 🔧 COMMANDES COMBINÉES

## Audit complet Linux

```bash
#!/bin/bash
# Audit complet SHA-Toolbox

echo "=== SYSTÈME ==="
hostname
cat /etc/os-release | grep -E "^NAME=|^VERSION="
uname -r

echo -e "\n=== BANNIÈRES ==="
echo "Issue.net:" && head -5 /etc/issue.net
echo "MOTD:" && head -10 /etc/motd

echo -e "\n=== PROMPT ==="
echo "PS1: $PS1"
ls /etc/profile.d/zzz_clean_prompt.sh 2>/dev/null && echo "✓ Clean prompt présent"

echo -e "\n=== MIDDLEWARES ==="
ls -ld /opt/IBM/WebSphere* /opt/oracle /opt/mqm 2>/dev/null | awk '{print $9}'

echo -e "\n=== UTILISATEURS ==="
cat /etc/passwd | grep -E "oracle|wasadmin|liberty" | cut -d: -f1

echo -e "\n=== TOOLBOX ==="
ls /apps/toolboxes/VERSION 2>/dev/null && cat /apps/toolboxes/VERSION

echo -e "\n=== FILESYSTEMS ==="
df -h | grep -E "Filesystem|applis|apps"

echo -e "\n=== NTP ==="
systemctl is-active chronyd && chronyc tracking | grep "System time"

echo -e "\n=== DYNATRACE ==="
systemctl is-active dynatrace-oneagent && echo "✓ Actif"

echo -e "\n=== ILLUMIO ==="
/opt/illumio_ven/illumio-ven-ctl status 2>/dev/null | grep "agent state"

echo -e "\n=== TSM ==="
systemctl is-active dsmcad && echo "✓ dsmcad actif"

echo -e "\n=== PURGE LOGS ==="
systemctl is-active purge_logs.timer && echo "✓ Timer actif"
```

---

## Audit complet Windows

```powershell
# Audit complet SHA-Toolbox Windows

Write-Host "`n=== SYSTÈME ===" -ForegroundColor Cyan
hostname
systeminfo | findstr /C:"OS Name" /C:"OS Version"

Write-Host "`n=== SERVICES ===" -ForegroundColor Cyan
Get-Service | Where-Object {$_.Status -eq "Running"} | Select-Object DisplayName, Status | Format-Table

Write-Host "`n=== MIDDLEWARES ===" -ForegroundColor Cyan
Get-ChildItem "C:\Program Files\IBM" -ErrorAction SilentlyContinue
Get-Service | Where-Object {$_.DisplayName -like "*SQL Server*"}

Write-Host "`n=== NTP ===" -ForegroundColor Cyan
w32tm /query /status | Select-String "Source|Last Successful"

Write-Host "`n=== DYNATRACE ===" -ForegroundColor Cyan
Get-Service "Dynatrace OneAgent" -ErrorAction SilentlyContinue

Write-Host "`n=== ILLUMIO ===" -ForegroundColor Cyan
Get-Service | Where-Object {$_.DisplayName -like "*Illumio*"}
```

---

# 📊 RÉSUMÉ DES FICHIERS CLÉS

## Linux
```
/etc/motd                                    # Bannière post-login
/etc/issue.net                               # Bannière pré-login SSH
/etc/issue                                   # Bannière pré-login console
/etc/profile.d/zzz_clean_prompt.sh          # Prompt propre
/etc/ssh/sshd_config                         # Config SSH
/apps/toolboxes/                             # Toolbox IPS
/applis/                                     # Arborescence applicative
/apps/                                       # Applications
/opt/tivoli/tsm/                             # TSM Client
/apps/dynatrace/oneagent/                    # Dynatrace
/opt/illumio_ven/                            # Illumio VEN
/tmp/ansible_reports/                        # Rapports Ansible
```

## Windows
```
C:\Windows\System32\banner.txt               # Bannière (si créé)
C:\apps\toolboxes\                           # Toolbox (si Windows support)
C:\Program Files\dynatrace\                  # Dynatrace
C:\Program Files\Illumio\                    # Illumio
C:\Program Files\Tivoli\                     # TSM
```

---

**Date de création**: 2025-10-28  
**Auteur**: AI Engineer (Emergent)  
**Version**: 4.4.4  
**Usage**: Guide de vérification complète post-exécution Ansible
