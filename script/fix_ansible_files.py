#!/usr/bin/env python3
"""
Script de correction automatique des fichiers Ansible YAML
Corrige l'indentation, ajoute les préfixes ansible.builtin et changed_when
"""

import os
import re
import sys
import yaml
from pathlib import Path
from typing import List, Dict, Tuple
import argparse
import shutil
from datetime import datetime

# Modules Ansible qui nécessitent le préfixe ansible.builtin
BUILTIN_MODULES = [
    'shell', 'command', 'copy', 'file', 'template', 'lineinfile',
    'blockinfile', 'stat', 'set_fact', 'debug', 'fail', 'assert',
    'include_tasks', 'include_role', 'import_tasks', 'import_role',
    'systemd', 'service', 'user', 'group', 'package', 'yum', 'apt',
    'dnf', 'pip', 'git', 'unarchive', 'get_url', 'uri', 'wait_for',
    'pause', 'meta', 'add_host', 'group_by', 'setup', 'ping',
    'fetch', 'synchronize', 'replace', 'find', 'cron', 'at'
]

# Commandes en lecture seule qui nécessitent changed_when: false
READ_ONLY_PATTERNS = [
    r'cat\s+',
    r'grep\s+',
    r'awk\s+',
    r'sed\s+-n',
    r'head\s+',
    r'tail\s+',
    r'ls\s+',
    r'find\s+',
    r'stat\s+',
    r'df\s+',
    r'du\s+',
    r'ps\s+',
    r'systemctl\s+(status|is-active|is-enabled|list-)',
    r'which\s+',
    r'whereis\s+',
    r'echo\s+',
    r'date\s+',
    r'uptime',
    r'hostname',
    r'uname\s+',
    r'--version',
    r'--get-',
    r'--check',
    r'\|\s*grep',
    r'\|\s*awk',
    r'\|\s*sed',
    r'\|\s*head',
    r'\|\s*tail',
    r'\|\s*wc',
]

class AnsibleFileFixer:
    """Classe pour corriger les fichiers Ansible YAML"""
    
    def __init__(self, dry_run=False, verbose=False, backup=True):
        self.dry_run = dry_run
        self.verbose = verbose
        self.backup = backup
        self.stats = {
            'files_processed': 0,
            'files_modified': 0,
            'indentation_fixed': 0,
            'modules_prefixed': 0,
            'changed_when_added': 0,
            'errors': 0
        }
    
    def log(self, message, level='INFO'):
        """Affiche un message de log"""
        if self.verbose or level in ['ERROR', 'WARNING']:
            timestamp = datetime.now().strftime('%H:%M:%S')
            print(f"[{timestamp}] {level}: {message}")
    
    def is_read_only_command(self, command: str) -> bool:
        """Détermine si une commande est en lecture seule"""
        command_lower = command.lower().strip()
        
        # Vérifier les patterns de lecture seule
        for pattern in READ_ONLY_PATTERNS:
            if re.search(pattern, command_lower):
                return True
        
        # Exclure les commandes qui modifient le système
        write_patterns = [
            r'\brm\s+', r'\bmkdir\s+', r'\btouch\s+', r'\bcp\s+',
            r'\bmv\s+', r'\bchmod\s+', r'\bchown\s+', r'\bln\s+',
            r'\btar\s+.*-[cxz]', r'\bunzip\s+', r'\bgzip\s+',
            r'\bsystemctl\s+(start|stop|restart|reload|enable|disable)',
            r'\bservice\s+.*\s+(start|stop|restart)',
            r'\b(yum|apt|dnf)\s+(install|remove|update)',
            r'\b>>', r'\b>', r'\btee\s+',
        ]
        
        for pattern in write_patterns:
            if re.search(pattern, command_lower):
                return False
        
        return False
    
    def fix_indentation(self, content: str) -> Tuple[str, int]:
        """Corrige l'indentation pour utiliser 2 espaces"""
        lines = content.split('\n')
        fixed_lines = []
        fixes_count = 0
        
        for line in lines:
            if not line.strip() or line.strip().startswith('#'):
                fixed_lines.append(line)
                continue
            
            # Compter les espaces de début
            leading_spaces = len(line) - len(line.lstrip(' '))
            
            # Si l'indentation n'est pas un multiple de 2, corriger
            if leading_spaces > 0 and leading_spaces % 2 != 0:
                # Arrondir au multiple de 2 le plus proche
                correct_indent = (leading_spaces // 2) * 2
                fixed_line = ' ' * correct_indent + line.lstrip(' ')
                fixed_lines.append(fixed_line)
                fixes_count += 1
                self.log(f"  Indentation corrigée: {leading_spaces} -> {correct_indent} espaces", 'DEBUG')
            else:
                fixed_lines.append(line)
        
        return '\n'.join(fixed_lines), fixes_count
    
    def add_builtin_prefix(self, content: str) -> Tuple[str, int]:
        """Ajoute le préfixe ansible.builtin aux modules"""
        fixes_count = 0
        lines = content.split('\n')
        fixed_lines = []
        
        for i, line in enumerate(lines):
            original_line = line
            
            # Ignorer les commentaires et les lignes vides
            if not line.strip() or line.strip().startswith('#'):
                fixed_lines.append(line)
                continue
            
            # Détecter les modules sans préfixe
            for module in BUILTIN_MODULES:
                # Pattern pour détecter "module:" sans préfixe
                pattern = rf'^(\s*)({module}):\s*$'
                match = re.match(pattern, line)
                
                if match:
                    indent = match.group(1)
                    module_name = match.group(2)
                    
                    # Vérifier si le préfixe n'est pas déjà présent
                    if not line.strip().startswith('ansible.builtin.'):
                        fixed_line = f"{indent}ansible.builtin.{module_name}:"
                        fixed_lines.append(fixed_line)
                        fixes_count += 1
                        self.log(f"  Préfixe ajouté: {module_name} -> ansible.builtin.{module_name}", 'DEBUG')
                        break
            else:
                fixed_lines.append(original_line)
        
        return '\n'.join(fixed_lines), fixes_count
    
    def add_changed_when(self, content: str) -> Tuple[str, int]:
        """Ajoute changed_when: false aux commandes en lecture seule"""
        fixes_count = 0
        lines = content.split('\n')
        fixed_lines = []
        i = 0
        
        while i < len(lines):
            line = lines[i]
            
            # Détecter les blocs shell: ou command:
            if re.match(r'^\s*(ansible\.builtin\.)?(shell|command):\s*$', line):
                indent = len(line) - len(line.lstrip(' '))
                
                # Chercher le contenu de la commande
                command_content = ""
                j = i + 1
                
                # Lire les lignes suivantes pour trouver la commande
                while j < len(lines):
                    next_line = lines[j]
                    next_indent = len(next_line) - len(next_line.lstrip(' '))
                    
                    # Si l'indentation est supérieure, c'est le contenu de la commande
                    if next_indent > indent and next_line.strip():
                        if next_line.strip().startswith('cmd:') or next_line.strip().startswith('|'):
                            # Lire le contenu de la commande
                            k = j + 1
                            while k < len(lines):
                                cmd_line = lines[k]
                                cmd_indent = len(cmd_line) - len(cmd_line.lstrip(' '))
                                if cmd_indent > next_indent and cmd_line.strip():
                                    command_content += cmd_line.strip() + " "
                                    k += 1
                                elif cmd_line.strip() and not cmd_line.strip().startswith('#'):
                                    break
                                else:
                                    k += 1
                            break
                        else:
                            command_content += next_line.strip() + " "
                    elif next_indent <= indent and next_line.strip():
                        break
                    
                    j += 1
                
                # Vérifier si changed_when est déjà présent
                has_changed_when = False
                for k in range(i + 1, min(i + 10, len(lines))):
                    if 'changed_when' in lines[k]:
                        has_changed_when = True
                        break
                    # Si on rencontre une nouvelle tâche, arrêter
                    if re.match(r'^\s*-\s+name:', lines[k]):
                        break
                
                # Si la commande est en lecture seule et n'a pas changed_when
                if command_content and self.is_read_only_command(command_content) and not has_changed_when:
                    fixed_lines.append(line)
                    
                    # Trouver où insérer changed_when
                    insert_pos = i + 1
                    while insert_pos < len(lines):
                        next_line = lines[insert_pos]
                        next_indent = len(next_line) - len(next_line.lstrip(' '))
                        
                        # Insérer après les paramètres de la commande
                        if next_indent <= indent and next_line.strip():
                            break
                        
                        fixed_lines.append(next_line)
                        insert_pos += 1
                    
                    # Ajouter changed_when: false
                    changed_when_line = ' ' * (indent + 2) + 'changed_when: false'
                    fixed_lines.append(changed_when_line)
                    fixes_count += 1
                    self.log(f"  changed_when ajouté pour commande: {command_content[:50]}...", 'DEBUG')
                    
                    i = insert_pos
                    continue
            
            fixed_lines.append(line)
            i += 1
        
        return '\n'.join(fixed_lines), fixes_count
    
    def fix_file(self, file_path: Path) -> bool:
        """Corrige un fichier YAML"""
        try:
            self.log(f"Traitement de {file_path}", 'DEBUG')
            
            # Lire le contenu original
            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()
            
            # Appliquer les corrections
            content = original_content
            total_fixes = 0
            
            # 1. Corriger l'indentation
            content, indent_fixes = self.fix_indentation(content)
            total_fixes += indent_fixes
            if indent_fixes > 0:
                self.stats['indentation_fixed'] += indent_fixes
            
            # 2. Ajouter les préfixes ansible.builtin
            content, prefix_fixes = self.add_builtin_prefix(content)
            total_fixes += prefix_fixes
            if prefix_fixes > 0:
                self.stats['modules_prefixed'] += prefix_fixes
            
            # 3. Ajouter changed_when: false
            content, changed_when_fixes = self.add_changed_when(content)
            total_fixes += changed_when_fixes
            if changed_when_fixes > 0:
                self.stats['changed_when_added'] += changed_when_fixes
            
            # Si des modifications ont été faites
            if content != original_content:
                if not self.dry_run:
                    # Créer une sauvegarde si demandé
                    if self.backup:
                        backup_path = str(file_path) + '.backup'
                        shutil.copy2(file_path, backup_path)
                        self.log(f"  Sauvegarde créée: {backup_path}", 'DEBUG')
                    
                    # Écrire le fichier corrigé
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    
                    self.log(f"✓ Fichier modifié: {file_path} ({total_fixes} corrections)", 'INFO')
                else:
                    self.log(f"[DRY-RUN] Fichier à modifier: {file_path} ({total_fixes} corrections)", 'INFO')
                
                self.stats['files_modified'] += 1
                return True
            
            return False
        
        except Exception as e:
            self.log(f"Erreur lors du traitement de {file_path}: {str(e)}", 'ERROR')
            self.stats['errors'] += 1
            return False
    
    def process_directory(self, directory: Path):
        """Traite tous les fichiers YAML d'un répertoire"""
        self.log(f"Scan du répertoire: {directory}", 'INFO')
        
        # Trouver tous les fichiers YAML
        yaml_files = list(directory.rglob('*.yml')) + list(directory.rglob('*.yaml'))
        
        self.log(f"Fichiers YAML trouvés: {len(yaml_files)}", 'INFO')
        
        for yaml_file in yaml_files:
            self.stats['files_processed'] += 1
            self.fix_file(yaml_file)
    
    def print_summary(self):
        """Affiche un résumé des corrections"""
        print("\n" + "="*70)
        print("RÉSUMÉ DES CORRECTIONS")
        print("="*70)
        print(f"Fichiers traités:              {self.stats['files_processed']}")
        print(f"Fichiers modifiés:             {self.stats['files_modified']}")
        print(f"Corrections d'indentation:     {self.stats['indentation_fixed']}")
        print(f"Préfixes ajoutés:              {self.stats['modules_prefixed']}")
        print(f"changed_when ajoutés:          {self.stats['changed_when_added']}")
        print(f"Erreurs:                       {self.stats['errors']}")
        print("="*70)
        
        if self.dry_run:
            print("\n⚠️  MODE DRY-RUN: Aucune modification n'a été effectuée.")
            print("   Relancez sans --dry-run pour appliquer les corrections.")
        else:
            print("\n✅ Corrections appliquées avec succès!")
            if self.backup:
                print("   Les fichiers originaux ont été sauvegardés avec l'extension .backup")


def main():
    parser = argparse.ArgumentParser(
        description='Correction automatique des fichiers Ansible YAML',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemples d'utilisation:
  
  # Mode dry-run (simulation sans modification)
  python3 fix_ansible_files.py /path/to/SHA-Toolbox --dry-run
  
  # Correction avec sauvegarde automatique
  python3 fix_ansible_files.py /path/to/SHA-Toolbox --verbose
  
  # Correction sans sauvegarde
  python3 fix_ansible_files.py /path/to/SHA-Toolbox --no-backup
  
  # Correction d'un seul rôle
  python3 fix_ansible_files.py /path/to/SHA-Toolbox/roles/ips_toolbox_system
        """
    )
    
    parser.add_argument(
        'directory',
        type=str,
        help='Répertoire contenant les fichiers Ansible à corriger'
    )
    
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Simulation sans modification des fichiers'
    )
    
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Affichage détaillé des corrections'
    )
    
    parser.add_argument(
        '--no-backup',
        action='store_true',
        help='Ne pas créer de fichiers de sauvegarde'
    )
    
    args = parser.parse_args()
    
    # Vérifier que le répertoire existe
    directory = Path(args.directory)
    if not directory.exists():
        print(f"❌ Erreur: Le répertoire {directory} n'existe pas.")
        sys.exit(1)
    
    if not directory.is_dir():
        print(f"❌ Erreur: {directory} n'est pas un répertoire.")
        sys.exit(1)
    
    # Créer le correcteur
    fixer = AnsibleFileFixer(
        dry_run=args.dry_run,
        verbose=args.verbose,
        backup=not args.no_backup
    )
    
    # Traiter les fichiers
    print(f"\n🔧 Correction automatique des fichiers Ansible")
    print(f"📁 Répertoire: {directory}")
    print(f"{'🔍 Mode: DRY-RUN (simulation)' if args.dry_run else '✏️  Mode: CORRECTION'}\n")
    
    fixer.process_directory(directory)
    fixer.print_summary()


if __name__ == '__main__':
    main()

