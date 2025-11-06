### 4. Instance Identifier
- **Prompt**: `ID Instance (ex: 01, 02, 03)`
- **Variable Name**: `id`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: 2/2 characters
- **Default Answer**: `01`

### 5. CodeAP for Filesystems
- **Prompt**: `CodeAP for filesystems (identical to CodeAP)`
- **Variable Name**: `fs_apcode`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: _(default)_
- **Default Answer**: `{{ codeAP }}`

### 6. Code5car for Filesystems
- **Prompt**: `Code5car for Filesystems`
- **Variable Name**: `fs_code5cars`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: _(default)_
- **Default Answer**: `{{ code5car }}`

### 7. Suffix for Logical Volumes
- **Prompt**: `Suffix LV`
- **Variable Name**: `fs_suffix`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: _(default)_
- **Default Answer**: `_{{ id }}`

### 8. Size /apps
- **Prompt**: `Size of the main /apps filesystem (e.g., 5G, 10G)`
- **Variable Name**: `fs_size4apps`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: _(default)_
- **Default Answer**: `1G`

### 9. Size /apps/ti
- **Prompt**: `Size /apps/ti`
- **Variable Name**: `fs_size4apps_ti`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: _(default)_
- **Default Answer**: `1G`

### 10. Size /apps/to
- **Prompt**: `Size /apps/to`
- **Variable Name**: `fs_size4apps_to`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: _(default)_
- **Default Answer**: `1G`

### 11. Size /apps/tmp
- **Prompt**: `Size /apps/tmp`
- **Variable Name**: `fs_size4apps_tmp`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: _(default)_
- **Default Answer**: `1G`

### 12. Size /apps/arch
- **Prompt**: `Size /apps/arch`
- **Variable Name**: `fs_size4apps_arch`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: _(default)_
- **Default Answer**: `1G`

### 13. Size /shared
- **Prompt**: `Size /shared`
- **Variable Name**: `fs_size4shared`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: _(default)_
- **Default Answer**: `1G`

### 14. Size /shared/tmp
- **Prompt**: `Size /shared/tmp`
- **Variable Name**: `fs_size4shared_tmp`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: _(default)_
- **Default Answer**: `1G`

### 15. Size /shared/arch
- **Prompt**: `Size /shared/arch`
- **Variable Name**: `fs_size4shared_arch`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: _(default)_
- **Default Answer**: `1G`

### 16. Size /log/apps
- **Prompt**: `Size /log/apps`
- **Variable Name**: `fs_size4log_apps`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: _(default)_
- **Default Answer**: `1G`

### 17. Size /log/shared
- **Prompt**: `Size /log/shared`
- **Variable Name**: `fs_size4log_shared`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: _(default)_
- **Default Answer**: `1G`

### 18. Size /div/apps
- **Prompt**: `Size /div/apps`
- **Variable Name**: `fs_size4div_apps`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: _(default)_
- **Default Answer**: `2G`

### 19. Size /div/shared
- **Prompt**: `Size /div/shared`
- **Variable Name**: `fs_size4div_shared`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: _(default)_
- **Default Answer**: `2G`

### 20. Web Server (IHS)
- **Prompt**: `IHS (IBM HTTP SERVER)?`
- **Variable Name**: `configure_webserver`
- **Answer Variable Type**: `Multiple Choice (single select)`
- **Required**: ❌ No
- **Default Answer**: `true`
- **Multiple Choice Options**:
  ```
  true
  false
  ```

### 21. Java (JVM)
- **Prompt**: `Java Virtual Machines (JVM)?`
- **Variable Name**: `configure_java`
- **Answer Variable Type**:
- **Required**: ❌ No
- **Default Answer**: `true`
- **Multiple Choice Options**:
  ```
  true
  false
  ```

### 22. Oracle DB
- **Prompt**: `Oracle database?`
- **Variable Name**: `configure_oracle_db`
- **Answer Variable Type**: `Multiple Choice (single select)`
- **Required**: ❌ No
- **Default Answer**: `true`
- **Multiple Choice Options**:
  ```
  true
  false
  ```

### 23. Configure CFT (Cross File Transfer)
- **Prompt**: `CFT?`
- **Variable Name**: `configure_cft`
- **Answer Variable Type**: `Multiple Choice (single select)`
- **Required**: ❌ No
- **Default Answer**: `false`
- **Multiple Choice Options**:
  ```
  true
  false
  ```

### 24. Oracle Instance
- **Prompt**: `Oracle Instance Name (if Oracle is enabled)`
- **Variable Name**: `oracle_instance_name`
- **Answer Variable Type**: `Text`
- **Required**: ❌ No
- **Min/Max Length**: _(default)_
- **Default Answer**: `ORCL1`
