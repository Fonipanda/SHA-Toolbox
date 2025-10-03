# Modifications pour éliminer les services externes

## Vue d'ensemble

Voici la liste précise des fichiers et sections à modifier pour éliminer toute tentative de connexion vers des services externes (authentification, secrets, APIs). Ces modifications garantissent que la Toolbox fonctionne exclusivement avec les ressources locales de votre organisation.

## 1. group_vars/all.yml - CRITIQUE

### Sections à supprimer complètement :

```yaml
# SUPPRIMER CETTE SECTION COMPLÈTE :
# Supabase Configuration
supabase_url: "{{ lookup('env', 'VITE_SUPABASE_URL') }}"
supabase_anon_key: "{{ lookup('env', 'VITE_SUPABASE_ANON_KEY') }}"
```

### Section logging à modifier :

```yaml
# AVANT (à modifier) :
logging:
  enabled: true
  log_to_supabase: true  # ← PROBLÉMATIQUE
  log_level: INFO
  retention_days: 90

# APRÈS (version corrigée) :
logging:
  enabled: true
  log_to_supabase: false  # ← DÉSACTIVÉ
  log_level: INFO
  retention_days: 90
  use_aap2_logging: true  # ← NOUVEAU
```

## 2. Fichiers de tâches à supprimer

### Supprimer complètement :
```bash
# Ces fichiers tentent de se connecter à des services externes
rm -f roles/ips_toolbox_system/tasks/log_to_supabase.yml
rm -f roles/*/tasks/log_to_supabase.yml
```

## 3. roles/ips_toolbox_system/tasks/main.yml

### Section à supprimer :

```yaml
# SUPPRIMER CETTE SECTION :
- name: Log execution to Supabase
  include_tasks: log_to_supabase.yml
  when: logging.log_to_supabase | default(true) | bool
  tags:
    - always
```

### Version corrigée :

```yaml
---
# Main tasks for ips_toolbox_system role
- name: Include OS-specific variables
  include_vars: "{{ ansible_os_family }}.yml"
  when: ansible_os_family in ['RedHat', 'Windows']

- name: Gather system information
  include_tasks: gather_info.yml
  tags:
    - info
    - system_info

- name: Manage filesystems
  include_tasks: manage_filesystem.yml
  when: filesystem_action is defined
  tags:
    - filesystem
    - fs

- name: Create application arborescence
  include_tasks: create_arborescence.yml
  when: create_arborescence | default(false) | bool
  tags:
    - arborescence
    - create_app

- name: Manage log rotation
  include_tasks: log_rotation.yml
  when: manage_log_rotation | default(false) | bool
  tags:
    - logs
    - rotation

- name: Server reboot management
  include_tasks: reboot.yml
  when: server_action in ['reboot', 'shutdown']
  tags:
    - reboot
    - shutdown

# SUPPRIMÉ: Log execution to Supabase
# Les logs sont automatiquement gérés par AAP2 Activity Stream
```

## 4. playbooks/operating.yml

### Section rescue à modifier :

```yaml
# AVANT (problématique) :
  rescue:
    - name: Operating module error handler
      debug:
        msg:
          - "Error occurred in Operating module"
          - "Task: {{ ansible_failed_task.name }}"
          - "Error: {{ ansible_failed_result.msg | default('Unknown error') }}"
    
    - name: Log error to Supabase  # ← PROBLÉMATIQUE
      include_role:
        name: ips_toolbox_system
        tasks_from: log_to_supabase
      vars:
        execution_status: failed

# APRÈS (version corrigée) :
  rescue:
    - name: Operating module error handler
      debug:
        msg:
          - "Error occurred in Operating module"
          - "Task: {{ ansible_failed_task.name }}"
          - "Error: {{ ansible_failed_result.msg | default('Unknown error') }}"
    
    # SUPPRIMÉ: Log error to Supabase
    # Les erreurs sont automatiquement loggées dans AAP2 Activity Stream
```

## 5. playbooks/web.yml, database.yml, backup.yml

### Supprimer toute mention de logging externe :

Dans tous ces playbooks, supprimer les sections similaires à :
```yaml
# SUPPRIMER ces sections dans tous les playbooks :
- name: Log error to Supabase
  include_role:
    name: ips_toolbox_system
    tasks_from: log_to_supabase
```

## 6. playbook.yml principal

### Section de configuration à modifier :

```yaml
# AVANT (dans vars_prompt) :
- name: "Configure Supabase (optional):"
  # Set environment variables in your shell or .env
  export VITE_SUPABASE_URL="your-supabase-url"
  export VITE_SUPABASE_ANON_KEY="your-anon-key"

# APRÈS : SUPPRIMER COMPLÈTEMENT cette section
```

## 7. Documentation à nettoyer

### README.md - Sections à supprimer :

```markdown
<!-- SUPPRIMER ces sections : -->

### Configure Supabase (optional):
Set environment variables in your shell or .env
export VITE_SUPABASE_URL="your-supabase-url"
export VITE_SUPABASE_ANON_KEY="your-anon-key"

<!-- ET -->

### Supabase Logging Issues
Check edge function logs in Supabase Dashboard → Edge Functions → log-execution

<!-- ET -->

Access logs via Supabase Dashboard or API:
curl "${SUPABASE_URL}/rest/v1/execution_logs?order=timestamp.desc&limit=10" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}"
```

### QUICKSTART.md - Sections à supprimer :

```markdown
<!-- SUPPRIMER : -->
3. **Configure Supabase (optional):**
   Set environment variables in your shell or .env
   export VITE_SUPABASE_URL="your-supabase-url"
   export VITE_SUPABASE_ANON_KEY="your-anon-key"
```

## 8. Variables d'environnement à éviter

### Ne jamais définir ces variables :

```bash
# NE PAS DÉFINIR ces variables :
export VITE_SUPABASE_URL="..."
export VITE_SUPABASE_ANON_KEY="..."

# Variables d'environnement interdites :
SUPABASE_*
VITE_SUPABASE_*
```

## 9. Roles defaults/main.yml

### Dans tous les rôles, supprimer :

```yaml
# SUPPRIMER dans tous les defaults/main.yml :
supabase_enabled: false
supabase_url: ""
supabase_key: ""
log_to_external: false
```

## 10. Script de nettoyage automatique

### Commandes pour nettoyer automatiquement :

```bash
#!/bin/bash
# Script de nettoyage des services externes

# Supprimer les fichiers de logging externe
find . -name "log_to_supabase.yml" -delete

# Nettoyer group_vars/all.yml
sed -i '/supabase_url:/d' group_vars/all.yml
sed -i '/supabase_anon_key:/d' group_vars/all.yml
sed -i '/VITE_SUPABASE/d' group_vars/all.yml

# Modifier logging configuration
sed -i 's/log_to_supabase: true/log_to_supabase: false/' group_vars/all.yml

# Nettoyer les main.yml des rôles
find roles/ -name "main.yml" -exec sed -i '/log_to_supabase/d' {} \;

# Nettoyer les playbooks
find playbooks/ -name "*.yml" -exec sed -i '/log.*supabase/d' {} \;
find playbooks/ -name "*.yml" -exec sed -i '/tasks_from: log_to_supabase/d' {} \;

# Nettoyer la documentation
sed -i '/Supabase/d' README.md
sed -i '/VITE_SUPABASE/d' README.md
sed -i '/supabase-url/d' README.md

echo "Nettoyage terminé - Aucun service externe ne sera contacté"
```

## 11. Vérification après modification

### Commandes de vérification :

```bash
# Vérifier qu'aucune référence externe ne subsiste
grep -r "supabase" . --exclude-dir=.git
grep -r "VITE_" . --exclude-dir=.git
grep -r "lookup.*env" . --exclude-dir=.git
grep -r "http" . --exclude-dir=.git | grep -v "IBM"

# Ces commandes ne doivent retourner AUCUN résultat
```

## 12. Configuration AAP2 sécurisée

### Variables AAP2 à utiliser à la place :

```yaml
# Dans AAP2 Controller, définir ces variables :
logging_enabled: true
use_aap2_logging: true
external_logging: false
compliance_mode: organizational

# Credentials AAP2 pour authentification :
# Utiliser Machine Credentials au lieu de secrets externes
```

## Résumé des bénéfices

### Après ces modifications :

✅ **Aucune connexion sortante** vers des services externes  
✅ **Aucun secret externe** requis  
✅ **Authentification organisationnelle** uniquement  
✅ **Logging AAP2 natif** utilisé  
✅ **Conformité sécurité** organisationnelle  
✅ **Fonctionnement autonome** sur images SHA  

### Fonctionnalités préservées :

✅ **Tous les rôles métier** fonctionnent  
✅ **Standards SHA** respectés  
✅ **Protection rootvg** active  
✅ **Gestion middlewares** complète  
✅ **Workflows AAP2** opérationnels  

## Points d'attention

### Après modification, la Toolbox :

- **Ne contacte AUCUN service externe**
- **Utilise uniquement l'authentification organisationnelle**
- **Fonctionne entièrement sur les images SHA**
- **Log uniquement dans AAP2 Activity Stream**
- **Respecte les politiques de sécurité internes**

Ces modifications garantissent une utilisation 100% autonome et conforme aux politiques de sécurité de votre organisation.