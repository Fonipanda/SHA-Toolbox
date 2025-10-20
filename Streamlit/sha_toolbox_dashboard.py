"""
SHA Toolbox Advanced Dashboard - Interface de visualisation des déploiements
Dashboard de monitoring avancé pour les exécutions Ansible SHA-Toolbox
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from datetime import datetime, timedelta
import time
import json
from sha_toolbox_reporter import SHAToolboxReporter

# Configuration de la page
st.set_page_config(
    page_title="SHA-Toolbox Monitoring Dashboard",
    page_icon="🔧",
    layout="wide",
    initial_sidebar_state="expanded"
)

# CSS personnalisé pour améliorer l'apparence
st.markdown("""
<style>
    .main-header {
        font-size: 2.5rem;
        color: #1f77b4;
        text-align: center;
        margin-bottom: 2rem;
    }
    .metric-card {
        background-color: #f0f2f6;
        padding: 1rem;
        border-radius: 10px;
        border-left: 4px solid #1f77b4;
    }
    .status-success {
        color: #28a745;
        font-weight: bold;
    }
    .status-failed {
        color: #dc3545;
        font-weight: bold;
    }
    .status-running {
        color: #ffc107;
        font-weight: bold;
    }
    .sidebar-info {
        padding: 1rem;
        background-color: #e6f3ff;
        border-radius: 5px;
        margin-bottom: 1rem;
    }
</style>
""", unsafe_allow_html=True)

def init_reporter():
    """Initialise le reporter SHA Toolbox"""
    try:
        return SHAToolboxReporter()
    except ValueError as e:
        st.error(f"❌ Erreur de configuration: {e}")
        st.info("💡 Assurez-vous que les variables VITE_SUPABASE_URL et VITE_SUPABASE_ANON_KEY sont définies.")
        return None

def create_status_gauge(success_rate):
    """Crée une jauge pour le taux de succès"""
    fig = go.Figure(go.Indicator(
        mode = "gauge+number+delta",
        value = success_rate,
        domain = {'x': [0, 1], 'y': [0, 1]},
        title = {'text': "Taux de Succès (%)"},
        delta = {'reference': 95},
        gauge = {
            'axis': {'range': [None, 100]},
            'bar': {'color': "darkblue"},
            'steps': [
                {'range': [0, 50], 'color': "lightgray"},
                {'range': [50, 80], 'color': "yellow"},
                {'range': [80, 100], 'color': "lightgreen"}
            ],
            'threshold': {
                'line': {'color': "red", 'width': 4},
                'thickness': 0.75,
                'value': 90
            }
        }
    ))
    fig.update_layout(height=300)
    return fig

def create_execution_timeline(logs):
    """Crée un timeline des exécutions"""
    if not logs:
        return None
    
    df = pd.DataFrame(logs)
    df['timestamp'] = pd.to_datetime(df['timestamp'])
    df['status_color'] = df['status'].map({
        'success': '#28a745',
        'failed': '#dc3545',
        'in_progress': '#ffc107'
    })
    
    fig = px.scatter(df, 
                     x='timestamp', 
                     y='hostname',
                     color='status',
                     color_discrete_map={
                         'success': '#28a745',
                         'failed': '#dc3545',
                         'in_progress': '#ffc107'
                     },
                     hover_data=['role', 'action', 'environment'],
                     title="Timeline des Exécutions")
    
    fig.update_layout(height=400)
    return fig

def create_role_distribution(summary):
    """Crée un graphique de distribution des rôles"""
    if not summary.get('by_role'):
        return None
    
    df_roles = pd.DataFrame([
        {'Rôle': k, 'Exécutions': v}
        for k, v in summary['by_role'].items()
    ]).sort_values('Exécutions', ascending=True)
    
    fig = px.bar(df_roles, 
                 x='Exécutions', 
                 y='Rôle',
                 orientation='h',
                 title="Distribution des Exécutions par Rôle",
                 color='Exécutions',
                 color_continuous_scale='Blues')
    
    fig.update_layout(height=500)
    return fig

def create_environment_comparison(summary):
    """Crée un graphique de comparaison des environnements"""
    if not summary.get('by_environment'):
        return None
    
    environments = list(summary['by_environment'].keys())
    executions = list(summary['by_environment'].values())
    
    fig = go.Figure(go.Bar(
        x=environments,
        y=executions,
        marker_color=['#1f77b4', '#ff7f0e', '#2ca02c'][:len(environments)],
        text=executions,
        textposition='auto'
    ))
    
    fig.update_layout(
        title="Exécutions par Environnement",
        xaxis_title="Environnement",
        yaxis_title="Nombre d'Exécutions",
        height=400
    )
    
    return fig

def main():
    # Header principal
    st.markdown('<h1 class="main-header">🔧 SHA-Toolbox Monitoring Dashboard</h1>', unsafe_allow_html=True)
    
    # Sidebar pour les contrôles
    with st.sidebar:
        st.markdown('<div class="sidebar-info"><h3>⚙️ Configuration</h3></div>', unsafe_allow_html=True)
        
        # Contrôles temporels
        time_range = st.selectbox(
            "📅 Période d'analyse",
            [("1 heure", 1), ("6 heures", 6), ("24 heures", 24), ("7 jours", 168)],
            index=2,
            format_func=lambda x: x[0]
        )[1]
        
        # Auto-refresh
        auto_refresh = st.checkbox("🔄 Actualisation automatique (30s)")
        
        # Filtres
        st.markdown("### 🔍 Filtres")
        env_filter = st.selectbox("Environnement", ["Tous", "dev", "qual", "prod"])
        status_filter = st.selectbox("Statut", ["Tous", "success", "failed", "in_progress"])
        
        # Informations système
        st.markdown("### ℹ️ Informations")
        st.info(f"⏰ Dernière mise à jour: {datetime.now().strftime('%H:%M:%S')}")
    
    # Initialisation du reporter
    reporter = init_reporter()
    if not reporter:
        return
    
    # Auto-refresh
    if auto_refresh:
        time.sleep(30)
        st.experimental_rerun()
    
    # Récupération des données
    with st.spinner("🔄 Chargement des données..."):
        summary = reporter.get_execution_summary(hours_ago=time_range)
        infrastructure = reporter.get_infrastructure_overview()
        logs = reporter.get_execution_logs(
            environment=None if env_filter == "Tous" else env_filter,
            status=None if status_filter == "Tous" else status_filter,
            hours_ago=time_range,
            limit=500
        )
        failed_logs = reporter.get_failed_executions(hours_ago=time_range)
    
    # Métriques principales
    st.markdown("## 📊 Vue d'Ensemble Temps Réel")
    
    col1, col2, col3, col4, col5 = st.columns(5)
    
    with col1:
        st.metric(
            "🎯 Total Exécutions",
            summary['total_executions'],
            delta=f"Dernières {time_range}h"
        )
    
    with col2:
        st.metric(
            "✅ Succès",
            summary['success'],
            delta=f"{summary['success_rate']}%"
        )
    
    with col3:
        st.metric(
            "❌ Échecs",
            summary['failed'],
            delta=f"{round(summary['failed']/summary['total_executions']*100 if summary['total_executions'] > 0 else 0, 1)}%"
        )
    
    with col4:
        st.metric(
            "⏳ En Cours",
            summary['in_progress']
        )
    
    with col5:
        st.metric(
            "🖥️ Serveurs Actifs",
            infrastructure['total_servers']
        )
    
    # Graphiques principaux
    col1, col2 = st.columns([2, 1])
    
    with col1:
        # Timeline des exécutions
        timeline_fig = create_execution_timeline(logs)
        if timeline_fig:
            st.plotly_chart(timeline_fig, use_container_width=True)
    
    with col2:
        # Jauge de succès
        gauge_fig = create_status_gauge(summary['success_rate'])
        st.plotly_chart(gauge_fig, use_container_width=True)
    
    # Deuxième ligne de graphiques
    col1, col2 = st.columns(2)
    
    with col1:
        # Distribution des rôles
        role_fig = create_role_distribution(summary)
        if role_fig:
            st.plotly_chart(role_fig, use_container_width=True)
    
    with col2:
        # Comparaison des environnements
        env_fig = create_environment_comparison(summary)
        if env_fig:
            st.plotly_chart(env_fig, use_container_width=True)
    
    # Tabs pour les détails
    tab1, tab2, tab3, tab4 = st.tabs(["🏥 Santé des Environnements", "🖥️ Serveurs", "📝 Logs Détaillés", "🚨 Alertes & Échecs"])
    
    with tab1:
        st.markdown("## 🏥 Santé des Environnements")
        
        env_cols = st.columns(3)
        environments = ["dev", "qual", "prod"]
        
        for idx, env in enumerate(environments):
            with env_cols[idx]:
                env_health = reporter.get_environment_health(env)
                
                st.markdown(f"### {env.upper()}")
                st.metric("Serveurs", env_health['total_servers'])
                st.metric("Exécutions 24h", env_health['total_executions_24h'])
                st.metric("Échecs 24h", env_health['failed_executions_24h'])
                
                if env_health['failed_executions_24h'] > 0:
                    st.error(f"⚠️ {env_health['failed_executions_24h']} échec(s) détecté(s)")
                else:
                    st.success("✅ Environnement sain")
    
    with tab2:
        st.markdown("## 🖥️ Gestion des Serveurs")
        
        servers = reporter.get_servers()
        if servers:
            df_servers = pd.DataFrame(servers)
            
            # Filtres pour les serveurs
            col1, col2 = st.columns(2)
            with col1:
                env_server_filter = st.selectbox("Environnement serveur", ["Tous"] + list(df_servers['environment'].unique()))
            with col2:
                os_filter = st.selectbox("Système d'exploitation", ["Tous"] + list(df_servers['os_type'].unique() if 'os_type' in df_servers.columns else []))
            
            # Application des filtres
            if env_server_filter != "Tous":
                df_servers = df_servers[df_servers['environment'] == env_server_filter]
            if os_filter != "Tous" and 'os_type' in df_servers.columns:
                df_servers = df_servers[df_servers['os_type'] == os_filter]
            
            st.dataframe(df_servers, use_container_width=True)
            
            # Détail d'un serveur sélectionné
            if not df_servers.empty:
                selected_server = st.selectbox("Sélectionner un serveur pour les détails", df_servers['hostname'].tolist())
                if selected_server:
                    col1, col2 = st.columns(2)
                    
                    with col1:
                        server_details = reporter.get_server_details(selected_server)
                        st.json(server_details)
                    
                    with col2:
                        recent_executions = reporter.get_recent_executions_by_hostname(selected_server, limit=10)
                        if recent_executions:
                            st.markdown("### Exécutions Récentes")
                            df_recent = pd.DataFrame(recent_executions)
                            st.dataframe(df_recent[['timestamp', 'role', 'action', 'status']], use_container_width=True)
    
    with tab3:
        st.markdown("## 📝 Logs Détaillés")
        
        if logs:
            df_logs = pd.DataFrame(logs)
            df_logs['timestamp'] = pd.to_datetime(df_logs['timestamp'])
            
            # Affichage avec couleurs selon le statut
            def color_status(val):
                if val == 'success':
                    return 'background-color: #d4edda; color: #155724'
                elif val == 'failed':
                    return 'background-color: #f8d7da; color: #721c24'
                elif val == 'in_progress':
                    return 'background-color: #fff3cd; color: #856404'
                return ''
            
            styled_df = df_logs[['timestamp', 'hostname', 'environment', 'role', 'action', 'status', 'executed_by']].style.applymap(color_status, subset=['status'])
            st.dataframe(styled_df, use_container_width=True)
            
            # Export des logs
            csv = df_logs.to_csv(index=False)
            st.download_button(
                label="📥 Télécharger les logs (CSV)",
                data=csv,
                file_name=f"sha_toolbox_logs_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",
                mime="text/csv"
            )
    
    with tab4:
        st.markdown("## 🚨 Alertes & Échecs")
        
        if failed_logs:
            st.error(f"⚠️ {len(failed_logs)} échec(s) détecté(s) dans les dernières {time_range} heures")
            
            # Analyse des échecs par type
            if len(failed_logs) > 0:
                df_fails = pd.DataFrame(failed_logs)
                
                col1, col2 = st.columns(2)
                
                with col1:
                    # Top des rôles en échec
                    role_fails = df_fails['role'].value_counts()
                    st.markdown("### Top Rôles en Échec")
                    fig_fails = px.bar(x=role_fails.values, y=role_fails.index, orientation='h')
                    st.plotly_chart(fig_fails, use_container_width=True)
                
                with col2:
                    # Échecs par environnement
                    env_fails = df_fails['environment'].value_counts()
                    st.markdown("### Échecs par Environnement")
                    fig_env_fails = px.pie(values=env_fails.values, names=env_fails.index)
                    st.plotly_chart(fig_env_fails, use_container_width=True)
            
            # Détail des échecs
            st.markdown("### Détail des Échecs")
            for idx, fail in enumerate(failed_logs[:10]):  # Limiter aux 10 premiers
                with st.expander(f"❌ {fail['hostname']} - {fail['role']} - {fail.get('timestamp', 'N/A')}"):
                    col1, col2 = st.columns(2)
                    
                    with col1:
                        st.markdown("**Informations:**")
                        st.write(f"🏢 Environnement: {fail.get('environment', 'N/A')}")
                        st.write(f"👤 Exécuté par: {fail.get('executed_by', 'N/A')}")
                        st.write(f"🔧 Action: {fail.get('action', 'N/A')}")
                        st.write(f"⏰ Timestamp: {fail.get('timestamp', 'N/A')}")
                    
                    with col2:
                        if fail.get('error_message'):
                            st.markdown("**Message d'erreur:**")
                            st.code(fail['error_message'], language='text')
                        
                        if fail.get('details'):
                            st.markdown("**Détails:**")
                            st.json(fail['details'])
        else:
            st.success(f"✅ Aucun échec détecté dans les dernières {time_range} heures!")
            st.balloons()
    
    # Footer avec informations de débogage
    with st.expander("🔧 Informations de Debug"):
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown("**Résumé des données:**")
            st.json(summary)
        
        with col2:
            st.markdown("**Infrastructure:**")
            st.json(infrastructure)

if __name__ == "__main__":
    main()