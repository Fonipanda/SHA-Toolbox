#!/bin/bash
# SHA Toolbox - Quick Start Setup Script
# This script helps you get started with the SHA Toolbox Ansible Playbooks

set -e

echo "========================================="
echo "SHA Toolbox - Quick Start Setup"
echo "========================================="
echo ""

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "❌ Ansible is not installed!"
    echo "Please install Ansible 2.9+ first:"
    echo "  - RHEL/CentOS: sudo yum install ansible"
    echo "  - Debian/Ubuntu: sudo apt install ansible"
    echo "  - pip: pip install ansible"
    exit 1
fi

echo "✅ Ansible is installed: $(ansible --version | head -1)"
echo ""

# Check Python version
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo "✅ Python version: $PYTHON_VERSION"
echo ""

# Create logs and cache directories
echo "📁 Creating necessary directories..."
mkdir -p logs facts_cache
echo "✅ Created logs/ and facts_cache/ directories"
echo ""

# Check inventory configuration
echo "📋 Checking inventory configuration..."
if [ -f "inventories/dev/hosts.yml" ]; then
    echo "✅ Development inventory found"

    # Check if inventory is configured
    if grep -q "ansible_host: 10.0.1.10" inventories/dev/hosts.yml; then
        echo "⚠️  WARNING: Inventory still has example configuration"
        echo "   Please edit inventories/dev/hosts.yml with your actual servers"
        echo ""
        read -p "Would you like to edit it now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ${EDITOR:-vi} inventories/dev/hosts.yml
        fi
    fi
else
    echo "❌ Development inventory not found!"
    exit 1
fi
echo ""

# Check Supabase configuration (optional)
echo "🔗 Checking Supabase configuration (optional)..."
if [ -z "$VITE_SUPABASE_URL" ] || [ -z "$VITE_SUPABASE_ANON_KEY" ]; then
    echo "⚠️  Supabase not configured (execution logging will be skipped)"
    echo "   To enable logging, set these environment variables:"
    echo "   export VITE_SUPABASE_URL='your-supabase-url'"
    echo "   export VITE_SUPABASE_ANON_KEY='your-anon-key'"
    echo ""
else
    echo "✅ Supabase is configured"
    echo ""
fi

# Test Ansible configuration
echo "🧪 Testing Ansible configuration..."
if ansible-playbook --syntax-check playbook.yml > /dev/null 2>&1; then
    echo "✅ Playbook syntax is valid"
else
    echo "❌ Playbook syntax check failed!"
    ansible-playbook --syntax-check playbook.yml
    exit 1
fi
echo ""

# Test connectivity (if hosts are configured)
echo "🔌 Testing connectivity to hosts..."
read -p "Would you like to test connectivity to your hosts? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Testing connectivity..."
    if ansible all -i inventories/dev/hosts.yml -m ping; then
        echo "✅ All hosts are reachable!"
    else
        echo "⚠️  Some hosts are not reachable"
        echo "   Check your SSH configuration and host connectivity"
    fi
    echo ""
fi

# Provide next steps
echo "========================================="
echo "✅ Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Configure your inventory:"
echo "   vi inventories/dev/hosts.yml"
echo ""
echo "2. Test system information gathering:"
echo "   ansible-playbook playbook.yml -e 'toolbox_module=operating' -e 'operation_type=info' --limit your-server"
echo ""
echo "3. Create application environment:"
echo "   ansible-playbook playbook.yml -e 'operation_type=arborescence' -e 'codeap=12345' -e 'codescar=APP01' --limit your-server"
echo ""
echo "4. Read the documentation:"
echo "   - QUICKSTART.md for common tasks"
echo "   - README.md for complete documentation"
echo "   - PROJECT_OVERVIEW.md for architecture details"
echo ""
echo "5. Check examples:"
echo "   ls examples/"
echo ""
echo "For help: cat README.md | less"
echo ""
