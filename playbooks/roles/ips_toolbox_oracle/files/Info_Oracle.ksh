#!/bin/ksh
################################################################################
# Program       : Info_Oracle.ksh
# Author        : Wilfried NAVARRO
# Description   : statut Oracle
# Version       : v2.1
# Modification  :
# 2018-11-30    : NAVARRO Wilfried : Adaptation script Karim Hamlaoui pour Ansible   
# 2019-03-01    : NAVARRO Wilfried : Ajout information Log_mode
  

################################################################################

# Include
# ========
. /apps/toolboxes/exploit/include/inc_variable.ksh
. /apps/toolboxes/exploit/include/inc_terminal.ksh

# Variables
# ==========
TodayDate=$(date +%Y%m%d)
DayOfMonth=$(date +%d)
DirGouvBnpp=${__DIR__TBX_EXPLOIT}/GouvBnpp
DirGouvBnppLog=${DirGouvBnpp}/logs

# Test if user oracle exist
# =========================
NbUserOracle=$(awk -F':' '$1 ~/^oracle$/{print $1}' /etc/passwd | sort -u | wc -l)
[ ${NbUserOracle} -eq 0 ] && return 0

OraTab=/etc/oratab
[ ! -f ${OraTab} ] && return 0

NbInstance=$(awk -F':' '$1 ~/^[A-Z]/{print $1}' ${OraTab} | grep -v AGENT | wc -l)
[ ${NbInstance} -eq 0 ] && return 0

SourceOracle="export ORAENV_ASK=NO;export ORACLE_SID="
SourceOraEnv=". oraenv"
if [ "$1" != "all" ]
then
  ListInstance=$1
else
  ListInstance=$(awk -F':' '$1 ~/^[A-Z]/{print $1}' ${OraTab} | grep -v AGENT | awk 'length($1)>=8')
fi
DescOracleInstance="OracleInstance"


# Program main
# ============

# Request Sql Oracle
# ==================
echo "
export LIBPATH=${ORACLE_HOME}/lib:${ORACLE_HOME}/lib32
export LD_LIBRARY_PATH=${ORACLE_HOME}/lib:${ORACLE_HOME}/lib32:${ORACLE_HOME}/precomp/public

sqlplus -S \"/as sysdba\" <<EOF
set linesize 145
set pagesize 9999
set verify   off
set heading  off

select 'CheckIfDataguard=' || dataguard_broker from v\\\$database;
select 'CheckCluster=' || value from v\\\$parameter where name like 'cluster_database';
select 'InstanceStatus=' || status from gv\\\$instance;
select 'InstanceRole=' || database_role from v\\\$database;
select 'NbInstance=' || count(*) from gv\\\$instance;
select 'OpenMode=' || open_mode from v\\\$database;
select 'OracleVersion=' || BANNER from v\\\$version where BANNER like '%Oracle%';
select 'LogMode=' || log_mode FROM v\\\$database;
select 'fal_server=' || decode(CONTROLFILE_TYPE,'CURRENT',nvl((select distinct 'TRUE' from v\\\$archive_dest where target in ('REMOTE','STANDBY')),'FALSE'), 'TRUE') from v\\\$database;
EOF " > ${DirGouvBnpp}/RequestOracle.sql

chmod 755 ${DirGouvBnpp}/RequestOracle.sql

# Request dgmgrl for 4S
# ==================
echo "
export LIBPATH=${ORACLE_HOME}/lib:${ORACLE_HOME}/lib32
export LD_LIBRARY_PATH=${ORACLE_HOME}/lib:${ORACLE_HOME}/lib32:${ORACLE_HOME}/precomp/public

dgmgrl / <<EOF

show configuration
EOF " > ${DirGouvBnpp}/RequestDgmgrl.sql

chmod 755 ${DirGouvBnpp}/RequestDgmgrl.sql

# Info Instance
# =============
for Instance in ${ListInstance}
do
    TmpInstance="${DirGouvBnpp}/${Instance}$$"
    InstanceName=${Instance}

    InfoInstance=$(su - oracle -c "${SourceOracle}${InstanceName};${SourceOraEnv};'${DirGouvBnpp}/RequestOracle.sql' 2>/dev/null" > ${TmpInstance} 2>/dev/null)
    CheckIfDataguard=$(grep CheckIfDataguard ${TmpInstance} | awk -F'=' '{print $NF}' | egrep "ENABLE|DISABLE")

    if [ "${CheckIfDataguard}" = "ENABLED" ] || [ "${CheckIfDataguard}" = "DISABLED" ]
    then
        TmpInstancedgmgrl="${DirGouvBnpp}/Instancedgmgrl$$"
        su - oracle -c "${SourceOracle}${InstanceName};${SourceOraEnv};'${DirGouvBnpp}/RequestDgmgrl.sql' 2>/dev/null" > ${TmpInstancedgmgrl} 2>/dev/null
        Instancedgmgrl=$(cat ${TmpInstancedgmgrl} | grep -i "Physical standby database" | wc -l)

        if [ ${Instancedgmgrl} -gt 1 ]
        then
            flag4S="4S"
	else
	    unset flag4S
        fi

        InstanceStatus=$(grep InstanceStatus ${TmpInstance} | tail -1 | awk -F'=' '{print $NF}')
        InstanceRole=$(grep InstanceRole ${TmpInstance} | awk -F'=' '{print $NF}' | egrep "PRIMARY|STANDBY")
        InstanceType=$(grep fal_server ${TmpInstance} | awk -F'=' '{print $NF}')
        CheckCluster=$(grep CheckCluster ${TmpInstance} | awk -F'=' '$NF ~/^[A-Za-z]/{print $NF}')
        NbInstance=$(grep NbInstance ${TmpInstance} | awk -F'=' '$NF ~/^[0-9]/{print $NF}')
        OpenMode=$(grep OpenMode ${TmpInstance} | awk -F'=' '{print $NF}')
        NlsCharacterset=$(grep NlsCharacterset ${TmpInstance} | awk -F'=' '{print $NF}')
        NlsLanguage=$(grep NlsLanguage ${TmpInstance} | awk -F'=' '{print $NF}')
        NlsTerritory=$(grep NlsTerritory ${TmpInstance} | awk -F'=' '{print $NF}')
        CheckNbWordVersion=$(grep OracleVersion ${TmpInstance} | awk -F'=' '{print $NF}' | wc -w)
        OracleVersion=$(grep OracleVersion ${TmpInstance} | awk -F'=' '{print $NF}')
        LogMode=$(grep LogMode ${TmpInstance} | awk -F'=' '{print $NF}')

        if [[ ${CheckNbWordVersion} -ge 9 ]]
        then
            OracleVersion=$(echo ${OracleVersion} | tail -1 | awk '{print $7}')
        else
            OracleVersion=$(echo ${OracleVersion} | tail -1 | awk '{print $5}')
        fi

        CheckUserStartOracle=$(ps -ef |awk '$NF ~/'ora_smon_${InstanceName}'/{print $1}')
        ps -fu oracle | grep -q ora_pmon_${InstanceName}
        ReturnCodePs=$?

        if [ ${ReturnCodePs} -eq 0 ]
        then
            ProcessStatus="RUNNING"
        else
            if [ "${CheckUserStartOracle}" = "oracle" ]
            then
                ProcessStatus="NOT_RUNNING"
            else
                ProcessStatus="NOT_ORACLE_USER"
            fi
        fi

        # Check InstanceType InstanceRole Cluster
        # =======================================
        if [ "${NbInstance}" -eq 2 ]
        then
            if [ "${InstanceType}" = "TRUE" ]
            then
                if [ "${InstanceRole}" = "PHYSICAL STANDBY" ]
                then
                    Cluster="RAC"
                    InstanceType="DATAGUARD${flag4S}"
                    InstanceRole="STANDBY"
                else
                    Cluster="RAC"
                    InstanceType="DATAGUARD${flag4S}"
                    InstanceRole=${InstanceRole}
                fi
            else
                if [ "${InstanceRole}" = "PHYSICAL STANDBY" ]
                then
                    Cluster="RAC"
                    InstanceType="NO_DATAGUARD"
                    InstanceRole="STANDBY"
                else
                    Cluster="RAC"
                    InstanceType="NO_DATAGUARD"
                    InstanceRole=${InstanceRole}
                fi
            fi
        else
            if [ "${InstanceType}" = "TRUE" ]
            then
                if [ "${InstanceRole}" = "PHYSICAL STANDBY" ]
                then
                    Cluster="NO"
                    InstanceType="DATAGUARD${flag4S}"
                    InstanceRole="STANDBY"
                else
                    Cluster="NO"
                    InstanceType="DATAGUARD${flag4S}"
                    InstanceRole=${InstanceRole}
                fi
            else
                if [ "${InstanceRole}" = "PHYSICAL STANDBY" ]
                then
                    Cluster="NO"
                    InstanceType="STANDALONE"
                    InstanceRole="STANDBY"
                else
                    Cluster="NO"
                    InstanceType="STANDALONE"
                    InstanceRole=${InstanceRole}
                fi
            fi
        fi
    else
        CheckUserStartOracle=$(ps -ef | grep -q ora_smon_${InstanceName} | awk '{print $1}')
        ps -fu oracle | grep -q ora_smon_${InstanceName}
        ReturnCodePs=$?

        if [ ${ReturnCodePs} -eq 0 ]
        then
            ProcessStatus="RUNNING"
            OracleVersion="UNKNOWN"
            LogMode="UNKNOWN"
            Cluster="UNKNOWN"
            InstanceType="UNKNOWN"
            InstanceRole="UNKNOWN"
            InstanceStatus="UNKNOWN"
            OpenMode="NOT MOUNTED"
            NlsCharacterset="UNKNOWN"
            NlsLanguage="UNKNOWN"
            NlsTerritory="UNKNOWN"
        else
            ProcessStatus="NOT_RUNNING"
            OracleVersion=""
            LogMode=""
            Cluster=""
            InstanceType=""
            InstanceRole=""
            InstanceStatus=""
            OpenMode=""
            NlsCharacterset=""
            NlsLanguage=""
            NlsTerritory=""
        fi
    fi

    echo "${__SYSTEM__HOSTNAME};${TodayDate};${InstanceName};${OracleVersion};${ProcessStatus};${Cluster};${InstanceType};${InstanceRole};${InstanceStatus};${OpenMode};${NlsCharacterset};${NlsLanguage};${NlsTerritory};${LogMode}" 

    if [ "${TmpInstance}" != "" ]
    then
      [ -f ${TmpInstance} ] && rm ${TmpInstance}
    fi
    if [ "${TmpInstancedgmgrl}" != "" ]
    then
      [ -f ${TmpInstancedgmgrl} ] && rm ${TmpInstancedgmgrl}
    fi
done

[ -f ${DirGouvBnpp}/RequestOracle.sql ] && rm -f ${DirGouvBnpp}/RequestOracle.sql
[ -f ${DirGouvBnpp}/RequestDgmgrl.sql ] && rm -f ${DirGouvBnpp}/RequestDgmgrl.sql

return 0
