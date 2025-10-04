# SHA Toolbox - Project Overview

## Project Structure

```
ansible-sha-toolbox/
├── ansible.cfg                     # Ansible configuration
├── playbook.yml                    # Main entry point
├── QUICKSTART.md                   # Quick start guide
├── README.md                       # Complete documentation
├── PROJECT_OVERVIEW.md            # This file
│
├── group_vars/
│   └── all.yml                    # Global variables and configuration
│
├── inventories/                   # Environment-specific inventories
│   ├── dev/
│   │   └── hosts.yml             # Development servers
│   ├── qual/
│   │   └── hosts.yml             # Qualification servers
│   └── prod/
│       └── hosts.yml             # Production servers
│
├── playbooks/                     # Module-specific playbooks
│   ├── operating.yml             # Operating module orchestration
│   ├── web.yml                   # Web module orchestration
│   ├── database.yml              # Database module orchestration
│   └── backup.yml                # Backup module orchestration
│
├── roles/                         # All toolbox roles
│   │
│   ├── Operating Module (8 roles)
│   ├── ips_toolbox_system/       # System operations
│   │   ├── defaults/main.yml     # Default variables
│   │   ├── tasks/
│   │   │   ├── main.yml          # Entry point
│   │   │   ├── gather_info.yml   # System information
│   │   │   ├── manage_filesystem.yml  # Filesystem operations
│   │   │   ├── create_arborescence.yml # Directory structure
│   │   │   ├── log_rotation.yml  # Log management
│   │   │   ├── reboot.yml        # Reboot operations
│   │   │   └── log_to_supabase.yml # Logging
│   │   ├── templates/
│   │   │   └── logrotate.conf.j2
│   │   └── meta/main.yml
│   │
│   ├── ips_toolbox_appli/        # Application management
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── manage_scripts.yml
│   │   │   ├── manage_systemd.yml
│   │   │   └── create_systemd_service.yml
│   │   └── templates/
│   │       └── systemd-service.j2
│   │
│   ├── ips_toolbox_nimsoft/      # Monitoring (Nimsoft)
│   ├── ips_toolbox_cft/          # Cross File Transfer
│   ├── ips_toolbox_mq/           # MQSeries
│   ├── ips_toolbox_vormetric/    # Encryption
│   ├── ips_toolbox_illumio/      # Network security
│   ├── ips_toolbox_bigfix/       # Patch management
│   │
│   ├── Web Module (5 roles)
│   ├── ips_toolbox_libertycore/  # Liberty Core
│   ├── ips_toolbox_libertybase/  # Liberty Base
│   ├── ips_toolbox_wasnd/        # WebSphere ND
│   ├── ips_toolbox_wasbase/      # WebSphere Base
│   ├── ips_toolbox_webserver/    # IHS & certificates
│   │
│   ├── Database Module (1 role)
│   ├── ips_toolbox_oracle/       # Oracle operations
│   │
│   └── Backup Module (2 roles)
│       ├── ips_toolbox_backup/   # Backup operations
│       └── ips_toolbox_tsm/      # TSM client
│
├── examples/                      # Usage examples
│   ├── create-app-environment.yml
│   ├── manage-filesystems.yml
│   ├── websphere-operations.yml
│   └── variables-examples.yml
│
├── templates/                     # Global templates
├── library/                       # Custom Ansible modules
└── pipeline/                      # CI/CD integration
```

## Roles Mapping to Toolbox Modules

### Operating Module (OPERATING)

| Role | Purpose | Key Functions |
|------|---------|---------------|
| ips_toolbox_system | Core system operations | Info, filesystem, arborescence, reboot |
| ips_toolbox_appli | Application lifecycle | Start/stop apps, systemd services |
| ips_toolbox_nimsoft | Monitoring | Maintenance mode, policies |
| ips_toolbox_cft | CFT management | Service control, catalog, IDF check |
| ips_toolbox_mq | MQSeries | Queue managers, queues, channels |
| ips_toolbox_vormetric | Encryption | Guardpoints, policies |
| ips_toolbox_illumio | Network security | VEN management, reports |
| ips_toolbox_bigfix | Patch management | Agent status, updates |

### Web Module (WEB)

| Role | Purpose | Key Functions |
|------|---------|---------------|
| ips_toolbox_libertycore | Liberty Core | Server management, deployment |
| ips_toolbox_libertybase | Liberty Base | Server management, deployment |
| ips_toolbox_wasnd | WAS Network Deployment | JVM control, DMGR operations |
| ips_toolbox_wasbase | WAS Base | JVM control, application ops |
| ips_toolbox_webserver | IHS management | Server control, certificates |

### Database Module (DATABASE)

| Role | Purpose | Key Functions |
|------|---------|---------------|
| ips_toolbox_oracle | Oracle operations | Instances, tablespaces, FRA |

### Backup Module (BACKUP & RESTORE)

| Role | Purpose | Key Functions |
|------|---------|---------------|
| ips_toolbox_backup | Backup execution | Execute, verify, conformity |
| ips_toolbox_tsm | TSM operations | Connection, query, restore, policies |

## Key Design Principles

### 1. SHA Standards Compliance
- Strict rootvg protection
- Standard arborescence creation
- Naming conventions enforcement
- Volume group management (vg_apps only)

### 2. Modularity
- Each role is self-contained
- Clear separation of concerns
- Reusable components
- Independent testing

### 3. Idempotency
- Safe to run multiple times
- State checking before actions
- No duplicate operations
- Predictable outcomes

### 4. Security
- RLS on all database tables
- Audit trail for all operations
- Production safeguards
- Secrets management ready

### 5. Flexibility
- Tag-based execution
- Variable-driven configuration
- Environment-specific settings
- Dry-run mode support

## Data Flow

1. **User Invocation**
   ```
   ansible-playbook playbook.yml -e "variables..."
   ```

2. **Main Playbook**
   - Validates environment
   - Checks production access
   - Routes to module playbook

3. **Module Playbook**
   - Detects middleware
   - Includes appropriate roles
   - Error handling

4. **Role Execution**
   - Validates prerequisites
   - Performs operations
   - Logs to Supabase

5. **Logging**
   - Edge function receives log
   - Data stored in execution_logs
   - Available for audit/analytics

## Supabase Integration

### Database Tables

1. **execution_logs**: All playbook executions
2. **servers**: Managed server inventory
3. **filesystems**: Filesystem tracking
4. **applications**: Application inventory

### Edge Function

- **log-execution**: Receives execution logs from playbooks
- Automatically configured
- No manual secret management needed

## Extension Points

### Adding New Middleware

1. Create new role: `ips_toolbox_[middleware]`
2. Add tasks for middleware operations
3. Include in `playbooks/operating.yml`
4. Update documentation

### Adding New Operations

1. Add task file in existing role
2. Include in role's `main.yml`
3. Add variables in defaults
4. Document usage

### Custom Variables

1. Add to `group_vars/all.yml` for global
2. Add to role's `defaults/main.yml` for role-specific
3. Add to inventory for host-specific

## Execution Modes

### Interactive
```bash
ansible-playbook playbook.yml
# Prompts for module selection
```

### Direct
```bash
ansible-playbook playbook.yml -e "toolbox_module=operating"
# Skips prompts
```

### Dry Run
```bash
ansible-playbook playbook.yml --check --diff
# Preview changes without execution
```

### Tagged
```bash
ansible-playbook playbook.yml --tags filesystem
# Execute only filesystem operations
```

### Limited
```bash
ansible-playbook playbook.yml --limit server-01
# Target specific server
```

## Best Practices

1. **Always use --limit** for production
2. **Test in dev** before qual/prod
3. **Use tags** for surgical operations
4. **Check logs** in Supabase after execution
5. **Use --check** for dry runs
6. **Version control** inventory changes
7. **Document** custom configurations
8. **Backup** before destructive operations

## Troubleshooting Quick Reference

| Issue | Solution |
|-------|----------|
| Connection failed | Check SSH keys, test with `ansible ... -m ping` |
| Permission denied | Verify sudo access, check become settings |
| Role not found | Check roles_path in ansible.cfg |
| Variable not defined | Check group_vars, defaults, or extra vars |
| Filesystem on rootvg | Design prevents this, check vg_name variable |
| Supabase logging fails | Check SUPABASE_URL and ANON_KEY env vars |

## Performance Considerations

- Uses fact caching to reduce gathering time
- Pipelining enabled for faster SSH operations
- Parallel execution with forks=10
- Smart gathering (only when needed)

## Compliance and Auditing

All operations are logged with:
- Timestamp (ISO 8601)
- Hostname
- User (ansible_user)
- Role executed
- Action performed
- Status (success/failed)
- Detailed information (JSON)

Logs are retained for 90 days by default (configurable).

## Future Enhancements

Potential additions:
- Windows Server support (PowerShell modules)
- Scheduling module (Autosys/Control-M)
- Additional databases (SQL Server, DB2)
- Web UI for execution and monitoring
- Ansible Tower/AWX integration
- Prometheus metrics export
- Enhanced rollback capabilities

## Support and Maintenance

- Version: 1.0.0
- Release Date: 2025-10-02
- Maintained by: SHA Toolbox Team
- Documentation: See README.md and QUICKSTART.md
