# Quick Start Guide - SHA Toolbox

## 5-Minute Setup

### 1. Configure Your Inventory

Edit the inventory file for your environment:

```bash
vi inventories/dev/hosts.yml
```

Add your servers:

```yaml
all:
  children:
    rhel_servers:
      hosts:
        rhel-app-01:
          ansible_host: 10.0.1.10
          codeap: "12345"
          codescar: "APP01"
          environment: dev
```

### 2. Test Connectivity

```bash
ansible all -i inventories/dev/hosts.yml -m ping
```

### 3. Gather System Information

```bash
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=operating" \
  -e "operation_type=info" \
  --limit rhel-app-01
```

## Common Tasks

### Create Complete Application Environment

This will create all filesystems and directories for a new application:

```bash
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=operating" \
  -e "operation_type=arborescence" \
  -e "codeap=12345" \
  -e "codescar=APP01" \
  -e "create_filesystems=true" \
  -e "websphere_type=wlc" \
  --limit rhel-app-01
```

### Manage Application Lifecycle

```bash
# Start application
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=operating" \
  -e "operation_type=application" \
  -e "app_action=start" \
  -e "app_name=myapp" \
  --limit rhel-app-01

# Stop application
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "operation_type=application" \
  -e "app_action=stop" \
  -e "app_name=myapp" \
  --limit rhel-app-01

# Check status
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "operation_type=application" \
  -e "app_action=status" \
  --limit rhel-app-01
```

### WebSphere Management

```bash
# List all Liberty servers
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=web" \
  -e "server_action=list" \
  --limit rhel-app-01

# Start a specific server
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "toolbox_module=web" \
  -e "server_action=start" \
  -e "server_name=server1" \
  --limit rhel-app-01
```

## Variable Reference

### Common Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `toolbox_module` | Module to execute | `operating`, `web`, `database`, `backup` |
| `operation_type` | Type of operation | `info`, `filesystem`, `arborescence`, `application` |
| `codeap` | Application code (5 digits) | `12345` |
| `codescar` | Application identifier (5 chars) | `APP01` |
| `id` | Optional identifier (2 chars) | `FR`, `01` |
| `environment_name` | Environment | `dev`, `qual`, `prod` |

### Filesystem Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `filesystem_action` | Action to perform | `create`, `extend`, `delete` |
| `vg_name` | Volume group name | `vg_apps` |
| `lv_name` | Logical volume name | `lv_APP01` |
| `mount_point` | Mount point | `/applis/12345-APP01` |
| `size` | Size in GB | `5` |

### Application Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `app_action` | Application action | `start`, `stop`, `restart`, `status` |
| `app_name` | Application name | `myapp` |
| `service_name` | Systemd service name | `app-myapp` |

### WebSphere Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `server_action` | Server action | `start`, `stop`, `status`, `list` |
| `server_name` | Server name | `server1` |
| `websphere_type` | WebSphere type | `was`, `wlc`, `wlb` |
| `was_variant` | WAS variant | `nd`, `base`, `core` |

## Dry Run Mode

Always test with check mode first:

```bash
ansible-playbook playbook.yml \
  -i inventories/dev/hosts.yml \
  -e "operation_type=filesystem" \
  -e "filesystem_action=create" \
  --check \
  --diff
```

## Production Execution

Production requires confirmation:

```bash
ansible-playbook playbook.yml \
  -i inventories/prod/hosts.yml \
  -e "toolbox_module=operating" \
  --limit prod-server-01
```

To skip confirmation (use with caution):

```bash
ansible-playbook playbook.yml \
  -i inventories/prod/hosts.yml \
  -e "toolbox_module=operating" \
  -e "force_prod=true" \
  --limit prod-server-01
```

## Tips

1. **Use --limit**: Always target specific servers
2. **Check logs**: Review execution logs in Supabase
3. **Use tags**: Execute specific parts only
4. **Test first**: Use dev environment before prod
5. **Backup**: Always backup before destructive operations

## Next Steps

1. Review the full [README.md](README.md)
2. Customize variables in `group_vars/all.yml`
3. Set up Supabase logging (optional)
4. Create environment-specific variable files
5. Document your server inventory
