"""
SHA Toolbox Reporter - Script Python pour récupérer l'état des lieux des exécutions Ansible
Compatible avec Streamlit et tout autre projet Python
"""

from supabase import create_client, Client
from typing import Optional, Dict, List, Any
from datetime import datetime, timedelta
import os


class SHAToolboxReporter:
    def __init__(self, supabase_url: Optional[str] = None, supabase_key: Optional[str] = None):
        self.supabase_url = supabase_url or os.getenv('VITE_SUPABASE_URL')
        self.supabase_key = supabase_key or os.getenv('VITE_SUPABASE_ANON_KEY')

        if not self.supabase_url or not self.supabase_key:
            raise ValueError("Supabase URL and Key must be provided")

        self.client: Client = create_client(self.supabase_url, self.supabase_key)

    def get_execution_logs(
        self,
        hostname: Optional[str] = None,
        environment: Optional[str] = None,
        status: Optional[str] = None,
        hours_ago: Optional[int] = 24,
        limit: int = 100
    ) -> List[Dict[str, Any]]:
        query = self.client.table('execution_logs').select('*')

        if hostname:
            query = query.eq('hostname', hostname)
        if environment:
            query = query.eq('environment', environment)
        if status:
            query = query.eq('status', status)
        if hours_ago:
            cutoff_time = datetime.now() - timedelta(hours=hours_ago)
            query = query.gte('timestamp', cutoff_time.isoformat())

        query = query.order('timestamp', desc=True).limit(limit)

        response = query.execute()
        return response.data

    def get_execution_summary(self, hours_ago: int = 24) -> Dict[str, Any]:
        logs = self.get_execution_logs(hours_ago=hours_ago, limit=1000)

        total = len(logs)
        success = sum(1 for log in logs if log['status'] == 'success')
        failed = sum(1 for log in logs if log['status'] == 'failed')
        in_progress = sum(1 for log in logs if log['status'] == 'in_progress')

        by_environment = {}
        by_role = {}
        by_hostname = {}

        for log in logs:
            env = log['environment']
            role = log['role']
            host = log['hostname']

            by_environment[env] = by_environment.get(env, 0) + 1
            by_role[role] = by_role.get(role, 0) + 1
            by_hostname[host] = by_hostname.get(host, 0) + 1

        return {
            'total_executions': total,
            'success': success,
            'failed': failed,
            'in_progress': in_progress,
            'success_rate': round((success / total * 100) if total > 0 else 0, 2),
            'by_environment': by_environment,
            'by_role': by_role,
            'by_hostname': by_hostname,
            'time_range_hours': hours_ago
        }

    def get_servers(
        self,
        environment: Optional[str] = None,
        codeap: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        query = self.client.table('servers').select('*')

        if environment:
            query = query.eq('environment', environment)
        if codeap:
            query = query.eq('codeap', codeap)

        response = query.execute()
        return response.data

    def get_server_details(self, hostname: str) -> Optional[Dict[str, Any]]:
        response = self.client.table('servers').select('*').eq('hostname', hostname).maybeSingle()
        return response.data

    def get_filesystems(self, hostname: Optional[str] = None) -> List[Dict[str, Any]]:
        query = self.client.table('filesystems').select('*, servers(*)')

        if hostname:
            query = query.eq('servers.hostname', hostname)

        response = query.execute()
        return response.data

    def get_applications(
        self,
        codeap: Optional[str] = None,
        environment: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        query = self.client.table('applications').select('*, servers(*)')

        if codeap:
            query = query.eq('codeap', codeap)
        if environment:
            query = query.eq('servers.environment', environment)

        response = query.execute()
        return response.data

    def get_failed_executions(self, hours_ago: int = 24) -> List[Dict[str, Any]]:
        return self.get_execution_logs(status='failed', hours_ago=hours_ago)

    def get_recent_executions_by_hostname(self, hostname: str, limit: int = 10) -> List[Dict[str, Any]]:
        return self.get_execution_logs(hostname=hostname, limit=limit)

    def get_environment_health(self, environment: str) -> Dict[str, Any]:
        servers = self.get_servers(environment=environment)
        logs = self.get_execution_logs(environment=environment, hours_ago=24)

        failed_logs = [log for log in logs if log['status'] == 'failed']

        return {
            'environment': environment,
            'total_servers': len(servers),
            'total_executions_24h': len(logs),
            'failed_executions_24h': len(failed_logs),
            'servers': servers,
            'recent_failures': failed_logs[:10]
        }

    def get_infrastructure_overview(self) -> Dict[str, Any]:
        all_servers = self.get_servers()
        all_filesystems = self.get_filesystems()
        all_applications = self.get_applications()

        servers_by_env = {}
        for server in all_servers:
            env = server['environment']
            servers_by_env[env] = servers_by_env.get(env, 0) + 1

        total_storage = sum(fs['size_gb'] for fs in all_filesystems)

        return {
            'total_servers': len(all_servers),
            'servers_by_environment': servers_by_env,
            'total_filesystems': len(all_filesystems),
            'total_storage_gb': total_storage,
            'total_applications': len(all_applications),
            'environments': list(servers_by_env.keys())
        }


def example_usage():
    reporter = SHAToolboxReporter()

    print("=== État des lieux SHA Toolbox ===\n")

    summary = reporter.get_execution_summary(hours_ago=24)
    print(f"📊 Résumé des 24 dernières heures:")
    print(f"  Total exécutions: {summary['total_executions']}")
    print(f"  Succès: {summary['success']} ({summary['success_rate']}%)")
    print(f"  Échecs: {summary['failed']}")
    print(f"  En cours: {summary['in_progress']}\n")

    infrastructure = reporter.get_infrastructure_overview()
    print(f"🏗️ Vue d'ensemble infrastructure:")
    print(f"  Total serveurs: {infrastructure['total_servers']}")
    print(f"  Par environnement: {infrastructure['servers_by_environment']}")
    print(f"  Total filesystems: {infrastructure['total_filesystems']}")
    print(f"  Stockage total: {infrastructure['total_storage_gb']} GB\n")

    failed = reporter.get_failed_executions(hours_ago=24)
    if failed:
        print(f"❌ Échecs récents ({len(failed)}):")
        for fail in failed[:5]:
            print(f"  - {fail['hostname']} | {fail['role']} | {fail['action']}")
            if fail['error_message']:
                print(f"    Erreur: {fail['error_message']}")


if __name__ == "__main__":
    example_usage()
