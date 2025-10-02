"""
Exemple d'intégration du SHA Toolbox Reporter dans une application Streamlit
"""

import streamlit as st
import pandas as pd
from sha_toolbox_reporter import SHAToolboxReporter
from datetime import datetime


def main():
    st.set_page_config(
        page_title="SHA Toolbox Dashboard",
        page_icon="🔧",
        layout="wide"
    )

    st.title("🔧 SHA Toolbox - Tableau de bord des exécutions")

    try:
        reporter = SHAToolboxReporter()
    except ValueError as e:
        st.error(f"Erreur de configuration: {e}")
        st.info("Assurez-vous que les variables VITE_SUPABASE_URL et VITE_SUPABASE_ANON_KEY sont définies.")
        return

    tab1, tab2, tab3, tab4 = st.tabs(["📊 Vue d'ensemble", "🖥️ Serveurs", "📝 Logs d'exécution", "❌ Échecs"])

    with tab1:
        st.header("Vue d'ensemble")

        hours = st.slider("Période d'analyse (heures)", 1, 168, 24)

        col1, col2 = st.columns(2)

        with col1:
            summary = reporter.get_execution_summary(hours_ago=hours)

            st.subheader(f"Exécutions ({hours}h)")
            metric_cols = st.columns(4)
            metric_cols[0].metric("Total", summary['total_executions'])
            metric_cols[1].metric("Succès", summary['success'], delta=f"{summary['success_rate']}%")
            metric_cols[2].metric("Échecs", summary['failed'])
            metric_cols[3].metric("En cours", summary['in_progress'])

            if summary['by_environment']:
                st.subheader("Répartition par environnement")
                df_env = pd.DataFrame([
                    {'Environnement': k, 'Exécutions': v}
                    for k, v in summary['by_environment'].items()
                ])
                st.bar_chart(df_env.set_index('Environnement'))

        with col2:
            infrastructure = reporter.get_infrastructure_overview()

            st.subheader("Infrastructure")
            infra_cols = st.columns(3)
            infra_cols[0].metric("Serveurs", infrastructure['total_servers'])
            infra_cols[1].metric("Filesystems", infrastructure['total_filesystems'])
            infra_cols[2].metric("Stockage (GB)", infrastructure['total_storage_gb'])

            if infrastructure['servers_by_environment']:
                st.subheader("Serveurs par environnement")
                df_servers = pd.DataFrame([
                    {'Environnement': k, 'Nombre': v}
                    for k, v in infrastructure['servers_by_environment'].items()
                ])
                st.bar_chart(df_servers.set_index('Environnement'))

        if summary['by_role']:
            st.subheader("Top rôles exécutés")
            df_roles = pd.DataFrame([
                {'Rôle': k, 'Exécutions': v}
                for k, v in sorted(summary['by_role'].items(), key=lambda x: x[1], reverse=True)[:10]
            ])
            st.dataframe(df_roles, use_container_width=True)

    with tab2:
        st.header("Gestion des serveurs")

        env_filter = st.selectbox(
            "Filtrer par environnement",
            ["Tous", "dev", "qual", "prod"]
        )

        environment = None if env_filter == "Tous" else env_filter
        servers = reporter.get_servers(environment=environment)

        if servers:
            df_servers = pd.DataFrame(servers)
            columns_to_show = ['hostname', 'ip_address', 'os_type', 'environment', 'codeap', 'codescar', 'last_seen']
            available_columns = [col for col in columns_to_show if col in df_servers.columns]
            st.dataframe(df_servers[available_columns], use_container_width=True)

            st.subheader("Détails d'un serveur")
            selected_hostname = st.selectbox(
                "Sélectionner un serveur",
                [s['hostname'] for s in servers]
            )

            if selected_hostname:
                server_details = reporter.get_server_details(selected_hostname)
                if server_details:
                    col1, col2 = st.columns(2)
                    with col1:
                        st.json(server_details)
                    with col2:
                        recent_logs = reporter.get_recent_executions_by_hostname(selected_hostname, limit=10)
                        if recent_logs:
                            st.subheader("Exécutions récentes")
                            df_logs = pd.DataFrame(recent_logs)
                            st.dataframe(df_logs[['timestamp', 'role', 'action', 'status']], use_container_width=True)
        else:
            st.info("Aucun serveur trouvé")

    with tab3:
        st.header("Logs d'exécution")

        col1, col2, col3 = st.columns(3)
        with col1:
            env_log_filter = st.selectbox(
                "Environnement",
                ["Tous", "dev", "qual", "prod"],
                key="log_env"
            )
        with col2:
            status_filter = st.selectbox(
                "Statut",
                ["Tous", "success", "failed", "in_progress"]
            )
        with col3:
            hours_filter = st.number_input("Dernières heures", min_value=1, max_value=168, value=24)

        logs = reporter.get_execution_logs(
            environment=None if env_log_filter == "Tous" else env_log_filter,
            status=None if status_filter == "Tous" else status_filter,
            hours_ago=hours_filter,
            limit=200
        )

        if logs:
            df_logs = pd.DataFrame(logs)

            df_logs['timestamp'] = pd.to_datetime(df_logs['timestamp'])

            st.dataframe(
                df_logs[['timestamp', 'hostname', 'environment', 'role', 'action', 'status', 'executed_by']],
                use_container_width=True
            )

            with st.expander("Voir les détails d'un log"):
                log_index = st.number_input("Index du log", min_value=0, max_value=len(logs)-1, value=0)
                st.json(logs[log_index])
        else:
            st.info("Aucun log trouvé pour les critères sélectionnés")

    with tab4:
        st.header("Échecs récents")

        fail_hours = st.slider("Période (heures)", 1, 168, 24, key="fail_hours")

        failed_logs = reporter.get_failed_executions(hours_ago=fail_hours)

        if failed_logs:
            st.metric("Total d'échecs", len(failed_logs))

            for fail in failed_logs:
                with st.expander(
                    f"❌ {fail['hostname']} - {fail['role']} - {fail['action']} ({fail['timestamp']})"
                ):
                    col1, col2 = st.columns(2)
                    with col1:
                        st.write("**Détails:**")
                        st.write(f"- Environnement: {fail['environment']}")
                        st.write(f"- Exécuté par: {fail['executed_by']}")
                        st.write(f"- Timestamp: {fail['timestamp']}")
                    with col2:
                        if fail.get('error_message'):
                            st.write("**Message d'erreur:**")
                            st.code(fail['error_message'])

                    if fail.get('details'):
                        st.write("**Détails complets:**")
                        st.json(fail['details'])
        else:
            st.success(f"✅ Aucun échec dans les {fail_hours} dernières heures!")


if __name__ == "__main__":
    main()
