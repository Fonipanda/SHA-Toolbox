# SHA-Toolbox Workflow - Diagramme Mermaid

```mermaid
graph TD
    Start([Début Playbook SHA-Toolbox]) --> Validation

    Validation[Validation Surveys AAP2]
    Validation --> V1{CodeAP<br/>5-6 chiffres?}
    V1 -->|✅ Valide| V2{code5car<br/>5 alphanum?}
    V1 -->|❌ Invalide| Erreur1[Erreur: CodeAP invalide]
    V2 -->|✅ Valide| V3{systemd<br/>disponible?}
    V2 -->|❌ Invalide| Erreur2[Erreur: code5car invalide]
    V3 -->|✅ Oui| DetectOS
    V3 -->|❌ Non| Erreur3[Erreur: systemd requis]

    DetectOS[01 - Détection OS et Facts]
    DetectOS --> DetectMW[Détection Middlewares]
    
    DetectMW --> MW1[Scan WebSphere<br/>WASND/WASBASE/Liberty]
    DetectMW --> MW2[Scan Oracle Database]
    DetectMW --> MW3[Scan IBM MQ]
    DetectMW --> MW4[Scan Axway CFT]
    DetectMW --> MW5[Scan IHS/JVM]
    
    MW1 --> ConsolidateMW[Consolidation Middlewares]
    MW2 --> ConsolidateMW
    MW3 --> ConsolidateMW
    MW4 --> ConsolidateMW
    MW5 --> ConsolidateMW
    
    ConsolidateMW --> Banner[02 - Création Banner]
    
    Banner --> B1[Banner PRÉ-LOGIN<br/>/etc/issue.net]
    Banner --> B2[Banner POST-LOGIN<br/>/etc/motd]
    Banner --> B3[Nettoyage Prompt<br/>zzz_clean_prompt.sh]
    
    B1 --> Users
    B2 --> Users
    B3 --> Users
    
    Users[03 - Utilisateurs Techniques]
    Users --> U1{Middlewares<br/>détectés?}
    U1 -->|✅ Oui| U2[Création users<br/>oracle, wasadmin, liberty, etc.]
    U1 -->|❌ Non| U3[Aucun utilisateur créé]
    
    U2 --> ConfigMW
    U3 --> Toolbox
    
    ConfigMW[04 - Configuration Middlewares]
    ConfigMW --> CM1{Middleware<br/>à configurer?}
    CM1 -->|✅ Oui| CM2[Configuration<br/>pas réinstallation]
    CM1 -->|❌ Non| Toolbox
    CM2 --> CM3[Upgrade versions<br/>si nécessaire]
    CM3 --> Toolbox
    
    Toolbox[05 - Toolbox IPS]
    Toolbox --> T1{Toolbox<br/>présente?}
    T1 -->|✅ Oui| T2[Vérification version]
    T1 -->|❌ Non| T3[Installation Toolbox]
    T2 --> T4{Mise à jour<br/>disponible?}
    T4 -->|✅ Oui| T5[Update Toolbox]
    T4 -->|❌ Non| FS
    T3 --> FS
    T5 --> FS
    
    FS[06 - Arborescence Filesystems]
    FS --> FS1[Création /applis]
    FS --> FS2[Création /apps]
    FS --> FS3[Sous-répertoires<br/>/applis/logs, /applis/delivery]
    
    FS1 --> NTP
    FS2 --> NTP
    FS3 --> NTP
    
    NTP[07 - NTP/Chrony]
    NTP --> N1{Chrony<br/>actif?}
    N1 -->|✅ Oui| N2[Vérification sync]
    N1 -->|❌ Non| N3[Démarrage Chrony]
    N2 --> Dynatrace
    N3 --> Dynatrace
    
    Dynatrace[08 - Dynatrace OneAgent]
    Dynatrace --> DT1{OneAgent<br/>installé?}
    DT1 -->|✅ Oui| DT2[Vérif statut + mode]
    DT1 -->|❌ Non| Illumio
    DT2 --> DT3{Agent<br/>actif?}
    DT3 -->|✅ Connected| Illumio
    DT3 -->|❌ Disconnected| DT4[Redémarrage agent]
    DT4 --> Illumio
    
    Illumio[09 - Illumio VEN]
    Illumio --> IL1{VEN<br/>installé?}
    IL1 -->|✅ Oui| IL2[Vérif statut VEN<br/>+ mode enforcement]
    IL1 -->|❌ Non| Backup
    IL2 --> IL3{PCE<br/>connecté?}
    IL3 -->|✅ Connected| IL4{Mode<br/>enforced?}
    IL3 -->|❌ Disconnected| IL5[Test connectivity -j]
    IL4 -->|✅ Full| Backup
    IL4 -->|❌ Autre| Backup
    IL5 --> Backup
    
    Backup[10 - Sauvegarde TSM/Netbackup]
    Backup --> BK1{Type client<br/>backup?}
    BK1 -->|Netbackup| BK2[Config Netbackup<br/>TSM IGNORÉ]
    BK1 -->|TSM seul| BK3[Config TSM<br/>+ service dsmcad]
    BK1 -->|NetWorker| BK4[Config NetWorker]
    BK1 -->|Aucun| BK5[Aucune config backup]
    
    BK2 --> REAR
    BK3 --> REAR
    BK4 --> REAR
    BK5 --> REAR
    
    REAR[11 - REAR Backup Système]
    REAR --> R1{Script REAR<br/>présent?}
    R1 -->|✅ Oui| R2[Vérification config REAR]
    R1 -->|❌ Non| Logs
    R2 --> Logs
    
    Logs[12 - Purge Logs]
    Logs --> L1[Service purge_logs.service]
    Logs --> L2[Timer purge_logs.timer<br/>OnCalendar=01:00:00]
    Logs --> L3[Config rétention<br/>{{ log_purge_days }} jours]
    
    L1 --> Autosys
    L2 --> Autosys
    L3 --> Autosys
    
    Autosys[13 - Autosys optionnel]
    Autosys --> A1{Autosys<br/>détecté?}
    A1 -->|✅ Oui| A2[Config Autosys]
    A1 -->|❌ Non| Report
    A2 --> Report
    
    Report[14 - Rapport Final]
    Report --> R1[Collecte résultats]
    Report --> R2[Middlewares + Versions]
    Report --> R3[Services par catégorie]
    Report --> R4[Agents supervision]
    Report --> R5[Infrastructure]
    Report --> R6[Sauvegarde]
    
    R1 --> Recap
    R2 --> Recap
    R3 --> Recap
    R4 --> Recap
    R5 --> Recap
    R6 --> Recap
    
    Recap[Récapitulatif Complet]
    Recap --> End([Fin Playbook<br/>✅ Succès])
    
    Erreur1 --> EndError([Fin Playbook<br/>❌ Erreur])
    Erreur2 --> EndError
    Erreur3 --> EndError
    
    style Start fill:#90EE90
    style End fill:#90EE90
    style EndError fill:#FFB6C1
    style Erreur1 fill:#FF6B6B
    style Erreur2 fill:#FF6B6B
    style Erreur3 fill:#FF6B6B
    style DetectOS fill:#87CEEB
    style Banner fill:#87CEEB
    style Users fill:#87CEEB
    style ConfigMW fill:#87CEEB
    style Toolbox fill:#87CEEB
    style FS fill:#87CEEB
    style NTP fill:#87CEEB
    style Dynatrace fill:#FFD700
    style Illumio fill:#FFD700
    style Backup fill:#FFD700
    style REAR fill:#FFD700
    style Logs fill:#DDA0DD
    style Autosys fill:#DDA0DD
    style Report fill:#98FB98
    style Recap fill:#98FB98
```

**Légende:**
- 🟢 Vert clair: Début/Fin succès
- 🔵 Bleu ciel: Étapes principales configuration
- 🟡 Jaune: Agents de supervision
- 🟣 Violet: Logs et optionnels
- 🟢 Vert pâle: Rapports
- 🔴 Rouge: Erreurs
