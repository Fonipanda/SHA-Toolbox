---
# Mode de statut de l'agent VEN
illumio_ven_status: "active"  # active, stopped, suspended, unmanaged

# Mode d'enforcement de l'agent VEN
illumio_ven_enforcement: "enforced"  # idle, visibility_only, enforced

# Opération par défaut
illumio_operation: "configure"

# Activation du debug
illumio_debug_mode: false

# Timeout pour les opérations
illumio_timeout: 60

# Répertoires standards Illumio VEN
illumio_install_dir: "/opt/illumio_ven"
illumio_config_dir: "/etc/illumio"
illumio_log_dir: "/var/log/illumio"

# Service Illumio VEN
illumio_service_name: "illumio-ven"

# Binaire principal
illumio_ctl_binary: "{{ illumio_install_dir }}/illumio-ven-ctl"

# Configuration enforcement (pour production)
illumio_enable_enforcement: true

# Configuration visibility (pour développement/test)
illumio_visibility_mode: false
