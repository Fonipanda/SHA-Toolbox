# SHA Toolbox - Ansible Playbooks

Modern Ansible-based implementation of the SHA (Socle d'Hébergement Applicatif) Toolbox for managing Linux RHEL and Windows application environments.

## Overview

This project provides a comprehensive set of Ansible playbooks and roles to manage application hosting infrastructure, replacing traditional shell scripts with modern, idempotent automation.

## Architecture

The toolbox is organized into five main modules:

### 1. Operating Module
System operations and middleware management:
- **ips_toolbox_system**: Filesystem management, system information, arborescence creation
- **ips_toolbox_appli**: Application lifecycle management via scripts and systemd
- **ips_toolbox_nimsoft**: Monitoring and alerting (Nimsoft)
- **ips_toolbox_cft**: Cross File Transfer management
- **ips_toolbox_mq**: MQSeries operations
- **ips_toolbox_vormetric**: Encryption management
- **ips_toolbox_illumio**: Network security
- **ips_toolbox_bigfix**: Patch management

### 2. Web Module
WebSphere and IHS management:
- **ips_toolbox_libertycore**: Liberty Core server operations
- **ips_toolbox_libertybase**: Liberty Base server operations
- **ips_toolbox_wasnd**: WebSphere ND management
- **ips_toolbox_wasbase**: WebSphere Base management
- **ips_toolbox_webserver**: IHS and certificate management

### 3. Database Module
Database operations:
- **ips_toolbox_oracle**: Oracle database management, instances, tablespaces

### 4. Backup & Restore Module
Backup operations:
- **ips_toolbox_backup**: Backup execution and conformity checks
- **ips_toolbox_tsm**: TSM client operations, restore procedures

## Directory Structure

```
ansible-sha-toolbox/
├── ansible.cfg                 # Ansible configuration
├── group_vars/
│   └── all.yml                # Global variables
├── inventories/               # Environment-specific inventories
│   ├── dev/
│   ├── qual/
│   └── prod/
├── roles/                     # All toolbox roles
│   ├── ips_toolbox_system/
│   ├── ips_toolbox_appli/
│   ├── ips_toolbox_nimsoft/
│   └── ...
├── playbooks/                 # Module-specific playbooks
│   ├── operating.yml
│   ├── web.yml
│   ├── database.yml
│   └── backup.yml
├── playbook.yml              # Main entry point
└── README.md
```

## SHA Standards Compliance

### Volume Groups
- **rootvg**: System volume group (protected, no application data)
- **vg_apps**: Application volume group (all application data)

### Standard Arborescence

#### /apps/exploit
```
/apps/exploit/
├── autosys/              # Scheduling workspace
├── [fonction]/           # Function-specific directories
│   ├── conf/            # Configuration files
│   ├── logs/            # Exploitation logs
│   ├── scripts/         # Exploitation scripts
│   └── tmp/             # Temporary workspace
└── delivery/            # Delivery directory
```

#### /applis
```
/applis/
├── [codeAP]-[codeScar]-[id]/
│   ├── was|wlc|wlb/     # WebSphere directory
│   ├── ihs/             # IHS directory
│   ├── archives/        # Archives
│   ├── conf/            # Configuration
│   ├── scripts/         # Application scripts
│   ├── shared/          # Shared resources
│   ├── tmp/             # Temporary files
│   └── transfer/
│       ├── in/          # Incoming transfers
│       └── out/         # Outgoing transfers
├── logs/
│   └── [codeAP]-[codeScar]-[id]/
└── delivery/
    └── [codeAP]-[codeScar]-[id]/
```

## Quick Start

### Prerequisites
1. Ansible 2.9 or higher
2. Python 3.6+
3. SSH access to target servers
4. Sudo privileges

### Configuration

1. **Set up inventory:**
```bash
# Edit inventory for your environment
vi inventories/dev/hosts.yml
```

2. **Configure variables:**
```bash
# Edit global variables
vi group_vars/all.yml
```

3. **Configure Supabase (optional):**
```bash
# Set environment variables in your shell or .env
export VITE_SUPABASE_URL="your-supabase-url"
export VITE_SUPABASE_ANON_KEY="your-anon-key"
```

## Usage Examples

### System Information
```bash
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=operating" \
  -e "operation_type=info" \
  --limit your-server
```

### Create Application Arborescence
```bash
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=operating" \
  -e "operation_type=arborescence" \
  -e "codeap=12345" \
  -e "codescar=APP01" \
  -e "create_filesystems=true" \
  --limit your-server
```

### Create Filesystem
```bash
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=operating" \
  -e "operation_type=filesystem" \
  -e "filesystem_action=create" \
  -e "codeap=12345" \
  -e "codescar=APP01" \
  -e "vg_name=vg_apps" \
  -e "size=5" \
  --limit your-server
```

### Extend Filesystem
```bash
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=operating" \
  -e "operation_type=filesystem" \
  -e "filesystem_action=extend" \
  -e "lv_name=lv_APP01" \
  -e "vg_name=vg_apps" \
  -e "size=2" \
  --limit your-server
```

### Manage Applications
```bash
# Start an application
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=operating" \
  -e "operation_type=application" \
  -e "app_action=start" \
  -e "app_name=myapp" \
  --limit your-server

# Check application status
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=operating" \
  -e "operation_type=application" \
  -e "app_action=status" \
  -e "service_name=app-myapp" \
  --limit your-server
```

### WebSphere Operations
```bash
# List Liberty servers
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=web" \
  -e "server_action=list" \
  --limit your-was-server

# Start Liberty server
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=web" \
  -e "server_action=start" \
  -e "server_name=server1" \
  --limit your-was-server

# Manage IHS
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=web" \
  -e "ihs_action=status" \
  --limit your-ihs-server
```

### Oracle Operations
```bash
# List Oracle instances
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=database" \
  --limit your-db-server

# Get instance information
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=database" \
  -e "oracle_sid=ORCL" \
  -e "oracle_home=/u01/app/oracle/product/19.0.0/dbhome_1" \
  --limit your-db-server
```

### Backup Operations
```bash
# Check TSM connection
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=backup" \
  --limit your-server

# Execute incremental backup
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=backup" \
  -e "execute_backup=true" \
  -e "backup_type=INCR_APPLI" \
  --limit your-server
```

### Middleware Management

#### Nimsoft (Monitoring)
```bash
# Enable maintenance mode
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=operating" \
  -e "operation_type=monitoring" \
  -e "maintenance_action=enable" \
  -e "maintenance_duration=60" \
  --limit your-server
```

#### CFT (Cross File Transfer)
```bash
# Check CFT status
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=operating" \
  -e "operation_type=cft" \
  -e "cft_action=status" \
  --limit your-cft-server
```

#### MQSeries
```bash
# List Queue Managers
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=operating" \
  -e "operation_type=mq" \
  --limit your-mq-server
```

## Tags

Use tags for fine-grained control:

```bash
# Only gather system information
ansible-playbook playbook.yml --tags info

# Only manage filesystems
ansible-playbook playbook.yml --tags filesystem

# Only manage applications
ansible-playbook playbook.yml --tags application

# Multiple tags
ansible-playbook playbook.yml --tags "filesystem,application"

# Skip tags
ansible-playbook playbook.yml --skip-tags "backup"
```

## Security Features

### RootVG Protection
All roles validate that operations on filesystems are NOT performed on rootvg, protecting system integrity.

### Row Level Security (RLS)
All database tables have RLS enabled with appropriate policies for secure multi-tenant access.

### Audit Trail
All operations are logged to Supabase with:
- Timestamp
- Hostname
- User
- Action
- Status
- Detailed information

### Production Safety
Production environments require explicit confirmation before execution.

## Database Schema

### execution_logs
Stores all playbook execution logs with status and details.

### servers
Inventory of managed servers with middleware information.

### filesystems
Tracks all created and managed filesystems.

### applications
Application inventory mapping codeap/codescar to servers.

## Logging and Monitoring

Execution logs are automatically sent to Supabase for:
- Centralized log management
- Audit trail
- Compliance reporting
- Operational analytics

Access logs via Supabase Dashboard or API:
```bash
# Query recent executions
curl "${SUPABASE_URL}/rest/v1/execution_logs?order=timestamp.desc&limit=10" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}"
```

## Best Practices

1. **Always test in dev first**: Never run directly in production
2. **Use --check mode**: Dry-run before actual execution
3. **Use --limit**: Target specific servers
4. **Use tags**: Execute only necessary tasks
5. **Review logs**: Check Supabase logs after execution
6. **Backup first**: Always backup before destructive operations
7. **Use version control**: Track inventory and variable changes in git

## Troubleshooting

### Connection Issues
```bash
# Test connectivity
ansible all -i inventories/dev/hosts.yml -m ping

# Test with verbose mode
ansible-playbook playbook.yml -vvv
```

### Permission Issues
```bash
# Verify sudo access
ansible all -i inventories/dev/hosts.yml -m shell -a "sudo -l"
```

### Role Errors
```bash
# Run with maximum verbosity
ansible-playbook playbook.yml -e "operation_type=info" -vvv
```

### Supabase Logging Issues
Check edge function logs in Supabase Dashboard → Edge Functions → log-execution

## Development

### Adding a New Role

1. Create role structure:
```bash
cd roles
mkdir -p ips_toolbox_newrole/{defaults,files,handlers,tasks,templates,vars,meta}
```

2. Create main tasks file:
```bash
vi ips_toolbox_newrole/tasks/main.yml
```

3. Add defaults:
```bash
vi ips_toolbox_newrole/defaults/main.yml
```

4. Update playbooks to include the new role

### Testing

Use the test playbooks in each role's `tests/` directory:
```bash
ansible-playbook roles/ips_toolbox_system/tests/test.yml
```

## Support

For issues, questions, or contributions:
1. Check existing documentation
2. Review execution logs in Supabase
3. Use verbose mode for debugging
4. Contact the SHA Toolbox team

## License

Proprietary - Internal use only

## Version

Version: 1.0.0
Date: 2025-10-02
