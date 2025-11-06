# AAP2 SURVEY CONFIGURATION - SHA-Toolbox

## Version: 4.7
## Date: 2025-10-28

---

## SURVEYS OBLIGATOIRES (3)

### 1. Target Hostname
- **Prompt**: `Target Hostname (FQDN or short name)`
- **Variable Name**: `Hostname`
- **Answer Variable Type**: `Text`
- **Required**: ✅ Yes
- **Min/Max Length**: 1/255 characters
- **Default Answer**: _(empty)_

### 2. Application Code (CodeAP)
- **Prompt**: `CodeAP (5 or 6 digits)`
- **Variable Name**: `CodeAP`
- **Answer Variable Type**: `Text`
- **Required**: ✅ Yes
- **Min/Max Length**: 5/6 characters
- **Default Answer**: _(empty)_
- **Validation Regex**: `^[0-9]{5,6}$`

### 3. Pentagram Code (Code5car)
- **Prompt**: `Code5car (5 alphanumeric characters OR trigram + 2 zeros)`
- **Variable Name**: `code5car`
- **Answer Variable Type**: `Text`
- **Required**: ✅ Yes
- **Min/Max Length**: 5/5 characters
- **Default Answer**: _(empty)_
- **Validation Regex**: `^[A-Z0-9]{5}$|^[A-Z]{3}00$`

---

## SURVEYS OPTIONNELS - INFRASTRUCTURE

### 4. Instance Identifier
- **Prompt**: `Instance ID (ex: 01, 02, 03)`
- **Variable Name**: `id`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: 2/2 characters
- **Default Answer**: `01`
- **Validation Regex**: `^[0-9]{2}$`

### 5. Log Purge Retention (Days)
- **Prompt**: `Log purge retention (number of days)`
- **Variable Name**: `log_purge_days`
- **Answer Variable Type**: `Integer`
- **Required**: ❌ No
- **Min/Max**: 1/365
- **Default Answer**: `30`

---

## SURVEYS OPTIONNELS - FILESYSTEMS

### 6. CodeAP for Filesystems
- **Prompt**: `CodeAP for filesystems (identical to CodeAP)`
- **Variable Name**: `fs_apcode`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: 5/6 characters
- **Default Answer**: `{{ CodeAP }}`

### 7. Code5car for Filesystems
- **Prompt**: `Code5car for Filesystems`
- **Variable Name**: `fs_code5cars`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: 5/5 characters
- **Default Answer**: `{{ code5car }}`

### 8. Suffix for Logical Volumes
- **Prompt**: `Suffix LV`
- **Variable Name**: `fs_suffix`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: _(default)_
- **Default Answer**: `_{{ id }}`

### 9. Size /apps
- **Prompt**: `Size of the main /apps filesystem (e.g., 5G, 10G)`
- **Variable Name**: `fs_size4apps`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Default Answer**: `1G`
- **Validation Regex**: `^[0-9]+[MGT]$`

### 10. Size /apps/ti
- **Prompt**: `Size /apps/ti`
- **Variable Name**: `fs_size4apps_ti`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Default Answer**: `1G`
- **Validation Regex**: `^[0-9]+[MGT]$`

### 11. Size /apps/to
- **Prompt**: `Size /apps/to`
- **Variable Name**: `fs_size4apps_to`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Default Answer**: `1G`
- **Validation Regex**: `^[0-9]+[MGT]$`

### 12. Size /apps/tmp
- **Prompt**: `Size /apps/tmp`
- **Variable Name**: `fs_size4apps_tmp`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Default Answer**: `1G`
- **Validation Regex**: `^[0-9]+[MGT]$`

### 13. Size /apps/arch
- **Prompt**: `Size /apps/arch`
- **Variable Name**: `fs_size4apps_arch`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Default Answer**: `1G`
- **Validation Regex**: `^[0-9]+[MGT]$`

### 14. Size /shared
- **Prompt**: `Size /shared`
- **Variable Name**: `fs_size4shared`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Default Answer**: `1G`
- **Validation Regex**: `^[0-9]+[MGT]$`

### 15. Size /shared/tmp
- **Prompt**: `Size /shared/tmp`
- **Variable Name**: `fs_size4shared_tmp`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Default Answer**: `1G`
- **Validation Regex**: `^[0-9]+[MGT]$`

### 16. Size /shared/arch
- **Prompt**: `Size /shared/arch`
- **Variable Name**: `fs_size4shared_arch`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Default Answer**: `1G`
- **Validation Regex**: `^[0-9]+[MGT]$`

### 17. Size /log/apps
- **Prompt**: `Size /log/apps`
- **Variable Name**: `fs_size4log_apps`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Default Answer**: `1G`
- **Validation Regex**: `^[0-9]+[MGT]$`

### 18. Size /log/shared
- **Prompt**: `Size /log/shared`
- **Variable Name**: `fs_size4log_shared`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Default Answer**: `1G`
- **Validation Regex**: `^[0-9]+[MGT]$`

### 19. Size /div/apps
- **Prompt**: `Size /div/apps`
- **Variable Name**: `fs_size4div_apps`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Default Answer**: `2G`
- **Validation Regex**: `^[0-9]+[MGT]$`

### 20. Size /div/shared
- **Prompt**: `Size /div/shared`
- **Variable Name**: `fs_size4div_shared`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Default Answer**: `2G`
- **Validation Regex**: `^[0-9]+[MGT]$`

---

## SURVEYS OPTIONNELS - MIDDLEWARES

### 21. Web Server (IHS)
- **Prompt**: `Install/Configure IBM HTTP SERVER (IHS)?`
- **Variable Name**: `configure_webserver`
- **Answer Variable Type**: `Multiple Choice (single select)`
- **Required**: ❌ No
- **Default Answer**: `false`
- **Multiple Choice Options**:
  ```
  true
  false
  ```

### 22. Java (JVM)
- **Prompt**: `Install/Configure Java Virtual Machine (JVM)?`
- **Variable Name**: `configure_java`
- **Answer Variable Type**: `Multiple Choice (single select)`
- **Required**: ❌ No
- **Default Answer**: `false`
- **Multiple Choice Options**:
  ```
  true
  false
  ```

### 23. Oracle DB
- **Prompt**: `Install/Configure Oracle Database?`
- **Variable Name**: `configure_oracle_db`
- **Answer Variable Type**: `Multiple Choice (single select)`
- **Required**: ❌ No
- **Default Answer**: `false`
- **Multiple Choice Options**:
  ```
  true
  false
  ```

### 24. Oracle Instance Name
- **Prompt**: `Oracle Instance Name (if Oracle is enabled)`
- **Variable Name**: `oracle_instance_name`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: 1/8 characters
- **Default Answer**: `ORCL1`
- **Validation Regex**: `^[A-Z0-9]{1,8}$`

### 25. Configure CFT (Axway Cross File Transfer)
- **Prompt**: `Install/Configure Axway CFT?`
- **Variable Name**: `configure_cft`
- **Answer Variable Type**: `Multiple Choice (single select)`
- **Required**: ❌ No
- **Default Answer**: `false`
- **Multiple Choice Options**:
  ```
  true
  false
  ```

---

## RÉSUMÉ DES VALIDATIONS

| Survey | Variable | Type | Regex Validation |
|--------|----------|------|------------------|
| CodeAP | `CodeAP` | Text (5-6) | `^[0-9]{5,6}$` |
| Code5car | `code5car` | Text (5) | `^[A-Z0-9]{5}$\|^[A-Z]{3}00$` |
| ID Instance | `id` | Text (2) | `^[0-9]{2}$` |
| Log Purge Days | `log_purge_days` | Integer | 1-365 |
| Filesystem Sizes | `fs_size*` | Text | `^[0-9]+[MGT]$` |
| Oracle Instance | `oracle_instance_name` | Text (1-8) | `^[A-Z0-9]{1,8}$` |

---

## NOTES IMPORTANTES

### CodeAP (5 ou 6 chiffres)
- ✅ Accepte: `12345`, `123456`
- ❌ Rejette: `1234` (trop court), `1234567` (trop long), `12A45` (pas numérique)

### Code5car (5 caractères)
**Format 1**: 5 alphanumériques
- ✅ Accepte: `ABC12`, `TEST1`, `XYZ99`

**Format 2**: Trigramme + 2 zéros
- ✅ Accepte: `ABC00`, `XYZ00`, `TST00`

**Rejetés**:
- ❌ `ABCDE` (tout lettres, pas Format 2)
- ❌ `12345` (tout chiffres sauf si Format 2)
- ❌ `ABC0` (trop court)

### Log Purge Retention
- Valeur en **jours**
- Min: 1 jour
- Max: 365 jours (1 an)
- Default: 30 jours

### Filesystem Sizes
- Format: `<nombre><unité>`
- Unités: `M` (Megabytes), `G` (Gigabytes), `T` (Terabytes)
- ✅ Exemples: `1G`, `500M`, `2T`, `10G`
- ❌ Invalides: `1`, `1GB`, `1g` (minuscule)

---

**Date de création**: 2025-10-28  
**Auteur**: AI Engineer (Emergent)  
**Version**: 4.7  
**Total Surveys**: 25 (3 obligatoires + 22 optionnels)
