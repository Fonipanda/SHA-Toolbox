"""
SHA-Toolbox Local Dashboard
Monitoring interface for Ansible execution metrics and compliance reports
Without Supabase dependency
"""

import streamlit as st
import pandas as pd
import json
import os
from datetime import datetime
import plotly.express as px
import plotly.graph_objects as go

# --- UI Setup ------------------------------------------------------
st.set_page_config(
    page_title="SHA-Toolbox Local Dashboard",
    page_icon="🧰",
    layout="wide",
)

st.title("🧰 SHA-Toolbox Local Monitoring Dashboard")
st.caption("Local autonomous dashboard for Ansible automation reports")

# --- Load local data ------------------------------------------------
def load_reports(path: str):
    reports = []
    for root, _, files in os.walk(path):
        for f in files:
            if f.endswith(".json"):
                try:
                    with open(os.path.join(root, f)) as infile:
                        data = json.load(infile)
                        reports.append(data)
                except Exception:
                    continue
    return reports

def load_log_file(log_path: str):
    if os.path.exists(log_path):
        with open(log_path, "r") as f:
            return f.read().splitlines()
    return ["No logs found"]

report_dir = st.text_input("📂 Reports directory", "/tmp/ansible_reports")
log_file = st.text_input("📝 Log file path", "/tmp/ansible_reports/execution.log")

# --- Data Loading ---------------------------------------------------
if os.path.isdir(report_dir):
    reports = load_reports(report_dir)
    st.success(f"Loaded {len(reports)} JSON reports from {report_dir}")
else:
    st.warning("No valid report directory found")

if st.button("🔄 Refresh"):
    st.experimental_rerun()

# --- Quick Metrics --------------------------------------------------
col1, col2, col3 = st.columns(3)
col1.metric("Reports Total", len(reports))
col2.metric("Last Update", datetime.now().strftime("%H:%M:%S"))
col3.metric("Logs Present", "✅ Yes" if os.path.exists(log_file) else "❌ No")

# --- Logs Display ---------------------------------------------------
with st.expander("📜 View recent logs"):
    logs = load_log_file(log_file)
    st.text_area("Execution Logs", "\n".join(logs[-30:]), height=200)

# --- Compliance Visualization --------------------------------------
compliance_data = []
for rpt in reports:
    if isinstance(rpt, dict) and "compliance_score" in rpt:
        compliance_data.append(
            {
                "Hostname": rpt.get("hostname", "unknown"),
                "Compliance Score": rpt["compliance_score"],
                "Status": rpt.get("overall_status", "UNKNOWN"),
                "Violations": len(rpt.get("violations", [])),
                "Warnings": len(rpt.get("warnings", [])),
            }
        )

if compliance_data:
    df = pd.DataFrame(compliance_data)
    st.subheader("📊 Compliance Overview")

    # Bar chart of compliance scores
    fig = px.bar(
        df,
        x="Hostname",
        y="Compliance Score",
        color="Status",
        text="Compliance Score",
        color_discrete_map={
            "COMPLIANT": "#28a745",
            "NON_COMPLIANT": "#dc3545",
            "UNKNOWN": "#adb5bd",
        },
    )
    fig.update_layout(height=400)
    st.plotly_chart(fig, use_container_width=True)

    # Violations pie chart
    st.subheader("🚨 Violations and Warnings Summary")
    violation_sum = df["Violations"].sum()
    warning_sum = df["Warnings"].sum()
    pie_fig = go.Figure(
        data=[
            go.Pie(
                labels=["Violations", "Warnings"],
                values=[violation_sum, warning_sum],
                textinfo="label+percent",
                marker_colors=["#dc3545", "#ffc107"],
            )
        ]
    )
    st.plotly_chart(pie_fig, use_container_width=True)

else:
    st.info("No compliance reports found in this directory.")

# --- Download Data --------------------------------------------------
if compliance_data:
    csv_export = pd.DataFrame(compliance_data).to_csv(index=False)
    st.download_button(
        label="📥 Download Compliance CSV",
        data=csv_export,
        file_name=f"sha_toolbox_compliance_{datetime.now().strftime('%Y%m%d')}.csv",
    )

# --- Footer ---------------------------------------------------------
st.write("---")
st.caption("SHA-Toolbox Local Dashboard © 2025 — Offline monitoring of AAP2 runs.")
