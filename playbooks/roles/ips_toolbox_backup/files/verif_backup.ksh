#!/bin/ksh
#
# @(#) verif_backup.ksh   Version: 1.3.2    2020/03/30
#
# Author         : Wilfried NAVARRO
# Creation date  : 2016/06/01
# Description    : Check the complete backup of a database (RMAN + TSM)
#
# Parameters     : $1 : -s ORACLE_SID                     (optional)
#
# Modification   :
#    Date    : Author            : Description
#
# 2016/06/01 : Wilfried NAVARRO  : Creation
# ------------------------------------------------------------------------------------
# 2017/01/31 : Wilfried NAVARRO  : Change log directory
# ------------------------------------------------------------------------------------
# 2017/03/07 : Wilfried NAVARRO  : Change tmp directory (TMP)
#                                : Add purge temporary files
# ------------------------------------------------------------------------------------
# 2017/05/29 : Wilfried NAVARRO  : Bugfix Status TSM
#                                : Change csv format
# ------------------------------------------------------------------------------------
# 2017/09/20 : Wilfried NAVARRO  : Change CsvFilePrev variable
# ------------------------------------------------------------------------------------
# 2019/10/01 : Wilfried NAVARRO  : Add TSM backup verification
# ------------------------------------------------------------------------------------
# 2019/12/04 : Wilfried NAVARRO  : Add -optfile parameter
# ------------------------------------------------------------------------------------
# 2020/03/30 : David PERIN       : Check TSM binaries
#=====================================================================================

#clear

#============
#= header
#=====================

header()
{
 printf "\n${YELLOW} verif_backup.ksh   -   Version  $VERSION   -   ${DATE_SCRIPT}${NORMAL}\n\n"
 printf "${YELLOW}   Check the complete backup of a database (RMAN + TSM)${NORMAL}\n\n"
}

usage()
{
printf "Syntax:"
printf "\n\n${CYAN} verif_backup.ksh${NORMAL} [+ options] : Check the complete backup for all instances \n\n"
printf "OPTIONS"
printf "\n  ${BLUE}-s ${RED}ORACLE_SID${NORMAL}         : Check the complete backup for the specified instance"
printf "\n  ${BLUE}-h ${RED}help${NORMAL}               : Displays the full usage\n\n"
}

usage2()
{
printf "EXEMPLES"
printf "\n${CYAN} verif_backup.ksh${NORMAL}"
printf "\n${CYAN} verif_backup.ksh${BLUE} -s ${MAGENTA}ORACLE_SID${NORMAL}\n\n"
exit
}

#============
#= variables
#=====================

VERSION=`awk 'NR == 3 {print $5}' $0`
DATE_SCRIPT=`awk 'NR == 3 {print $NF}' $0`
DATE=`date +%Y%m%d`
DATESEC=`date +%Y%m%d_%H%M%S`
HOST=`hostname`

NORMAL=`echo "\033[0;39m"`
RED=`echo "\033[1;31m"`
GREEN=`echo "\033[1;32m"`
YELLOW=`echo "\033[1;33m"`
BLUE=`echo "\033[1;34m"`
MAGENTA=`echo "\033[1;35m"`
CYAN=`echo "\033[1;36m"`
WHITE=`echo "\033[1;37m"`
GRAY=`echo "\033[0;37m"`

typeset -x __DIR__TBX_EXPLOIT="/apps/toolboxes/exploit"
DayOfMonth=$(date +%d)
DirGouvBnpp=${__DIR__TBX_EXPLOIT}/GouvBnpp
DirGouvBnppLog=${DirGouvBnpp}/logs
LogFile=${DirGouvBnppLog}/${DayOfMonth}/Report_SaveDatabase_${DATE}_${HOST}.log
CsvFile=${DirGouvBnppLog}/${DayOfMonth}/Report_SaveDatabase_${DATE}_${HOST}.csv
CsvFilePrev=${CsvFile}.old

TMP=/apps/toolboxes/backup_restore/tmp
BRTBX=/apps/toolboxes/backup_restore/scripts
BRCONF=/apps/toolboxes/backup_restore/conf


[ -f ${__DIR__TBX_EXPLOIT}/include/.audit.ksh ] && . ${__DIR__TBX_EXPLOIT}/include/.audit.ksh
if [ -z "${ENTREE}" ]
then
    typeset -x ENTREE="DIRECT"
    typeset -x TBX_NAME="BR"
fi
compteurTbx "$(basename ${0})" "$(md5sum $0 | awk '{print $1}')"

[ -f ${BRTBX}/globalVars.ksh ] && . ${BRTBX}/globalVars.ksh 1>/dev/null 2>&1
[ -f ${BRTBX}/functions.ksh ] && . ${BRTBX}/functions.ksh 1>/dev/null 2>&1


#============
#= fonctions
#=====================

create_dir_oracle()
{

ORACLE_SID=$1
su oracle -c "mkdir -p /apps/oracle/backup/log/${ORACLE_SID}/verif_backup_log && chmod 755 /apps/oracle/backup/log/${ORACLE_SID}/verif_backup_log ;mkdir -p /apps/oracle/backup/log/${ORACLE_SID}/tmp && chmod 755 /apps/oracle/backup/log/${ORACLE_SID}/tmp"
}

get_info_instance()
{
#------------
#- Search information about instance
#--------------------------

export ORACLE_SID=$1
ORACLE_HOME=`cat /etc/oratab | grep ^${ORACLE_SID} | cut -d':' -f2`
export ORACLE_HOME
EXP_ENV_ORACLE="export ORACLE_HOME=${ORACLE_HOME};export PATH=${ORACLE_HOME}/bin:$PATH;export ORA_NLS10=${ORACLE_HOME}/nls/data;export LIBPATH=${ORACLE_HOME}/lib:${ORACLE_HOME}/lib32;export LD_LIBRARY_PATH=${ORACLE_HOME}/lib:${ORACLE_HOME}/lib32:${ORACLE_HOME}/precomp/public;export ORACLE_SID=${ORACLE_SID}"

ps -ef | grep smon | grep ${ORACLE_SID}$ 1>/dev/null 2>&1
if [ $? -eq 0 ]
then
    echo "set echo off" > $TEMPORA/requete_info_${ORACLE_SID}_$$.sql
    echo "set head off" >> $TEMPORA/requete_info_${ORACLE_SID}_$$.sql
    echo "set feed off" >> $TEMPORA/requete_info_${ORACLE_SID}_$$.sql
    echo "set newp none" >> $TEMPORA/requete_info_${ORACLE_SID}_$$.sql
    echo "spool $TEMPORA/info_instance_${ORACLE_SID}_$$.tmp" >> $TEMPORA/requete_info_${ORACLE_SID}_$$.sql
    echo "select 'Version:'|| version from v\$instance;" >> $TEMPORA/requete_info_${ORACLE_SID}_$$.sql
    echo "select 'RAC:'|| value from v\$parameter where name='cluster_database';" >> $TEMPORA/requete_info_${ORACLE_SID}_$$.sql
    echo "select 'Role:'|| database_role from v\$database;" >> $TEMPORA/requete_info_${ORACLE_SID}_$$.sql
    echo "select 'Open_mode:'|| open_mode from v\$database;" >> $TEMPORA/requete_info_${ORACLE_SID}_$$.sql
    echo "select 'Log_mode:'|| log_mode from v\$database;" >> $TEMPORA/requete_info_${ORACLE_SID}_$$.sql
    echo "spool off" >> $TEMPORA/requete_info_${ORACLE_SID}_$$.sql
    echo "quit" >> $TEMPORA/requete_info_${ORACLE_SID}_$$.sql

    chmod 777 $TEMPORA/requete_info_${ORACLE_SID}_$$.sql

    su oracle -c "${EXP_ENV_ORACLE};sqlplus -s '/as sysdba' @$TEMPORA/requete_info_${ORACLE_SID}_$$.sql 1>/dev/null 2>&1"
    [ -f $TEMPORA/requete_info_${ORACLE_SID}_$$.sql ] && rm $TEMPORA/requete_info_${ORACLE_SID}_$$.sql || return 1

    grep 'not mounted' $TEMPORA/info_instance_${ORACLE_SID}_$$.tmp 1>/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        Open_mode="NOT MOUNTED"
    else
        Open_mode=`cat $TEMPORA/info_instance_${ORACLE_SID}_$$.tmp | grep ^Open_mode | awk -F':' '{print $NF}' | sed 's/[ ]*$//g'`
    fi

    Version=`cat $TEMPORA/info_instance_${ORACLE_SID}_$$.tmp | grep ^Version | cut -d':' -f2 | awk -F'.' '{print $1"."$2"."$3"."$4}' | sed 's/[ ]*$//g'`
    Dbrole=`cat $TEMPORA/info_instance_${ORACLE_SID}_$$.tmp | grep ^Role | awk -F':' '{print $NF}' | sed 's/[ ]*$//g'`
    RAC=`cat $TEMPORA/info_instance_${ORACLE_SID}_$$.tmp | grep ^RAC | awk -F':' '{print $NF}' | sed 's/[ ]*$//g'`
    Log_Mode=`cat $TEMPORA/info_instance_${ORACLE_SID}_$$.tmp | grep ^Log_mode | awk -F':' '{print $NF}' | sed 's/[ ]*$//g'`
else
    Open_mode="DOWN"
fi

printf "\n%-15s %-2s %-5s\n" "Instance Name" ":" "${ORACLE_SID}" | tee -a $LogFile
[ "${Open_mode}" != "" ] && printf "%-15s %-2s %-5s\n" "Open Mode" ":" "${Open_mode}" | tee -a $LogFile
[ "${Version}" != "" ] && printf "%-15s %-2s %-5s\n" "Oracle version" ":" "${Version}" | tee -a $LogFile
[ "${Dbrole}" != "" ] && printf "%-15s %-2s %-5s\n" "Instance Role" ":" "${Dbrole}" | tee -a $LogFile
[ "${Log_Mode}" != "" ] && printf "%-15s %-2s %-5s\n" "Log Mode" ":" "${Log_Mode}" | tee -a $LogFile
[ "${RAC}" != "" ] && printf "%-15s %-2s %-5s\n\n" "RAC" ":" "${RAC}" | tee -a $LogFile

[ -f $TEMPORA/info_instance_${ORACLE_SID}_$$.tmp ] && rm $TEMPORA/info_instance_${ORACLE_SID}_$$.tmp
[ -f $TEMPORA/info_instance_${ORACLE_SID}_$$.tmp ] && rm $TEMPORA/info_instance_${ORACLE_SID}_$$.tmp

if [ "${Open_mode}" = "DOWN" -o "${Open_mode}" = "NOT MOUNTED" ]
then
    return 3
fi

if [ "${Dbrole}" != "PRIMARY" ]
then
    return 2
fi
}

get_last_backup_full()
{
#------------
#- Search status of the last full backup or incremental lvl 0
#--------------------------

printf "\nSearch status of the last full backup or incremental lvl 0\n" | tee -a $LogFile

echo "connect target /" > $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp
echo "sql 'alter session set nls_date_format=\"yyyy/mm/dd;hh24:mi:ss\"';" >> $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp
if [ "${1}" != "" ]
then
    echo "list backup of database summary completed between '$1' and 'sysdate' device type disk;" >> $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp
else
    echo "list backup of database summary device type disk;" >> $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp
fi
echo "quit" >> $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp

chmod 777 $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp

su oracle -c "${EXP_ENV_ORACLE};export NLS_DATE_FORMAT=\"yyyy/mm/dd;HH24:MI:SS\";rman cmdfile=$TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp log=$LOGORA/taginfo_${ORACLE_SID}_$$.log 1>/dev/null 2>&1"
[ -f $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp ] && rm $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp

egrep 'ORA-|RMAN-' $LOGORA/taginfo_${ORACLE_SID}_$$.log 1>/dev/null 2>&1
if [ $? = 0 ]
then
    printf "\nUnable to find backupsets to restore\n" | tee -a $LogFile
    printf "${RED}\n" | tee -a $LogFile
    egrep 'ORA-|RMAN-' $LOGORA/taginfo_${ORACLE_SID}_$$.log | tee -a $LogFile
    printf "${NORMAL}\n" | tee -a $LogFile
    return 1
fi

cat $LOGORA/taginfo_${ORACLE_SID}_$$.log | grep -v "Recovery Manager complete" | sed /^$/d > $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log

grep "does not match" $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log 1>/dev/null 2>&1
if [ $? -eq 1 ]
then
    while [ -s $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log ]
    do
        Key=`tail -1 $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | awk '{print $1}'`
        Lvl=`tail -1 $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | awk '{print $3}'`
        Tag=`tail -1 $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | awk '{print $NF}'`
        if [ "$Lvl" = "0" -o "$Lvl" = "F" ]
        then
            DATE_REC=`cat $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | grep $Tag | head -1 | awk '{print $6}'`
        break
        else
            cat $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | sed /^$Key/d > $TMP/cmd_bkpfile2_${ORACLE_SID}_$$.tmp
            mv $TMP/cmd_bkpfile2_${ORACLE_SID}_$$.tmp $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log
        fi
    done
    [ ! -s $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log ] && Tag=""
fi

if [ "${1}" = "" ]
then
    if [ "${Tag}" != "" ]
    then
        printf "Last Full - $DATE_REC - OK - $Tag\n" | tee -a $LogFile
        STATUS=OK
        if [ "${ENTREE}" = "DIRECT" ]
        then
            echo "${HOST};${ORACLE_SID};oracle;${Version};${DATE_REC};FUL;${STATUS}" >> $CsvFile
        fi
    else
        printf "No full backup completed for instance ${ORACLE_SID}\n" | tee -a $LogFile
        return 2
    fi
else
    if [ "${Tag}" != "" ]
    then
        printf "Last Full - $DATE_REC - OK - $Tag\n" | tee -a $LogFile
        STATUS=OK
        if [ "${ENTREE}" = "DIRECT" ]
        then
            echo "${HOST};${ORACLE_SID};oracle;${Version};${DATE_REC};FUL;${STATUS}" >> $CsvFile
        fi
    else
        printf "Last Full - ${1} - KO\n" | tee -a $LogFile
        STATUS=KO
        DATE_REC=$1
        if [ "${ENTREE}" = "DIRECT" ]
        then
            echo "${HOST};${ORACLE_SID};oracle;${Version};${DATE_REC};FUL;${STATUS}" >> $CsvFile
        fi
    fi
fi
}

get_last_completed_full()
{
#------------
#- Search status of the last full backup or incremental lvl 0
#--------------------------

printf "\nSearch status of the last full backup or incremental lvl 0\n" | tee -a $LogFile

echo "connect target /" > $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp
echo "sql 'alter session set nls_date_format=\"yyyy/mm/dd;hh24:mi:ss\"';" >> $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp
echo "list backup of database summary device type disk;" >> $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp
echo "quit" >> $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp

chmod 777 $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp

su oracle -c "${EXP_ENV_ORACLE};export NLS_DATE_FORMAT=\"yyyy/mm/dd;HH24:MI:SS\";rman cmdfile=$TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp log=$LOGORA/taginfo_${ORACLE_SID}_$$.log 1>/dev/null 2>&1"
[ -f $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp ] && rm $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp

egrep 'ORA-|RMAN-' $LOGORA/taginfo_${ORACLE_SID}_$$.log 1>/dev/null 2>&1
if [ $? = 0 ]
then
    printf "\nUnable to find backupsets to restore\n" | tee -a $LogFile
    printf "${RED}\n" | tee -a $LogFile
    egrep 'ORA-|RMAN-' $LOGORA/taginfo_${ORACLE_SID}_$$.log | tee -a $LogFile
    printf "${NORMAL}\n" | tee -a $LogFile
    return 1
fi

cat $LOGORA/taginfo_${ORACLE_SID}_$$.log | grep -v "Recovery Manager complete" | sed /^$/d > $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log

while [ -s $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log ]
do
    Key=`tail -1 $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | awk '{print $1}'`
    Lvl=`tail -1 $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | awk '{print $3}'`
    Tag=`tail -1 $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | awk '{print $NF}'`
    if [ "$Lvl" = "0" -o "$Lvl" = "F" ]
    then
        DATE_FULL_OK=`cat $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | grep $Tag | head -1 | awk '{print $6}'`
        break
    else
        cat $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | sed /^$Key/d > $TEMPORA/cmd_bkpfile2_${ORACLE_SID}_$$.tmp
        mv $TEMPORA/cmd_bkpfile2_${ORACLE_SID}_$$.tmp $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log
    fi
done
}

get_last_backup_incr()
{
#------------
#- Search status and start time of the last incremental lvl 1
#--------------------------

printf "\nSearch status of the last backup incremental lvl 1 \n" | tee -a $LogFile

echo "connect target /" > $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp
echo "sql 'alter session set nls_date_format=\"yyyy/mm/dd;hh24:mi:ss\"';" >> $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp
if [ "${1}" != "" ]
then
    echo "list backup of database summary completed between '$1' and 'sysdate' device type disk;" >> $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp
else
    echo "list backup of database summary device type disk;" >> $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp
fi
echo "quit" >> $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp

chmod 777 $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp

su oracle -c "${EXP_ENV_ORACLE};export NLS_DATE_FORMAT=\"yyyy/mm/dd;HH24:MI:SS\";rman cmdfile=$TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp log=$LOGORA/taginfo_${ORACLE_SID}_$$.log 1>/dev/null 2>&1"
[ -f $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp ] && rm $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp

egrep 'ORA-|RMAN-' $LOGORA/taginfo_${ORACLE_SID}_$$.log 1>/dev/null 2>&1
if [ $? = 0 ]
then
    printf "\nUnable to find backupsets to restore\n" | tee -a $LogFile
    printf "${RED}\n" | tee -a $LogFile
    egrep 'ORA-|RMAN-' $LOGORA/taginfo_${ORACLE_SID}_$$.log | tee -a $LogFile
    printf "${NORMAL}\n" | tee -a $LogFile
    return 1
fi

cat $LOGORA/taginfo_${ORACLE_SID}_$$.log | grep -v "Recovery Manager complete" | sed /^$/d > $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log

grep "does not match" $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log 1>/dev/null 2>&1
if [ $? -eq 1 ]
then
    if [ "${Tag}" != "" ]
    then
        DATE_TAG_L=`echo ${Tag} | awk -F'_' '{print $(NF-1)"_"$NF}'`
    else
        DATE_TAG_L=""
    fi
    Tagi=""

    while [ -s $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log -o "${Tagi}" != "${TAG_L}" ]
    do
        Keyi=`tail -1 $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | awk '{print $1}'`
        Lvli=`tail -1 $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | awk '{print $3}'`
        Tagi=`tail -1 $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | awk '{print $NF}'`
        DATE_Tagi=`echo ${Tagi} | awk -F'_' '{print $(NF-1)"_"$NF}'`
        if [ "$Lvli" = "1" -a "${DATE_Tagi}" != "${DATE_TAG_L}" ]
        then
            DATE_RECI=`cat $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | grep $Tagi | head -1 | awk '{print $6}'`
            break
        elif [ "${DATE_Tagi}" = "${DATE_TAG_L}" ]
        then
            DATE_RECI=""
            Keyi=""
            Lvli=""
            Tagi=""
            break
        else
            cat $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | sed /^$Keyi/d > $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.tmp
            mv $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.tmp $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log
        fi
    done
    [ ! -s $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log ] && Tagi=""
else
    if [ "$TYPE" != "INCR" ]
    then
        printf "No incremental level 1 since last backup $TYPE $STATUS\n" | tee -a $LogFile
    else
        printf "Last Incr - ${DATE_REC} - KO\n" | tee -a $LogFile
        STATUS=KO
        if [ "${ENTREE}" = "DIRECT" ]
        then
            echo "${HOST};${ORACLE_SID};oracle;${Version};${DATE_REC};INC;${STATUS}" >> $CsvFile
        fi
    fi
    return
fi

if [ "${Tagi}" != "" ]
then
    printf "Last Incr - ${DATE_RECI} - OK - ${Tagi}\n" | tee -a $LogFile
    STATUS=OK
    DATE_REC=${DATE_RECI}
    if [ "${ENTREE}" = "DIRECT" ]
    then
        echo "${HOST};${ORACLE_SID};oracle;${Version};${DATE_REC};INC;${STATUS}" >> $CsvFile
    fi
else
    if [ "${TYPE}" = "INCR" ]
    then
        printf "Last Incr - ${DATE_REC} - KO\n" | tee -a $LogFile
        STATUS=KO
        if [ "${ENTREE}" = "DIRECT" ]
        then
            echo "${HOST};${ORACLE_SID};oracle;${Version};${DATE_REC};INC;${STATUS}" >> $CsvFile
        fi
    else
        printf "No incremental level 1 since last backup $TYPE $STATUS\n" | tee -a $LogFile
    fi
fi
}

get_last_backup_arch()
{
#------------
#- Search status and start time of the last backup of archivelog
#--------------------------

printf "\nSearch status of the last backup of archivelog\n" | tee -a $LogFile

echo "connect target /" > $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp
echo "sql 'alter session set nls_date_format=\"yyyy/mm/dd;hh24:mi:ss\"';" >> $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp
if [ "${1}" != "" ]
then
    echo "list backup summary completed between '$1' and 'sysdate' device type disk;" >> $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp
else
    echo "list backup summary device type disk;" >> $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp
fi
echo "quit" >> $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp

chmod 777 $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp

su oracle -c "${EXP_ENV_ORACLE};export NLS_DATE_FORMAT=\"yyyy/mm/dd;HH24:MI:SS\";rman cmdfile=$TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp log=$LOGORA/taginfo_${ORACLE_SID}_$$.log 1>/dev/null 2>&1"
[ -f $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp ] && rm $TEMPORA/cmd_bkpfile_${ORACLE_SID}_$$.tmp

egrep 'ORA-|RMAN-' $LOGORA/taginfo_${ORACLE_SID}_$$.log 1>/dev/null 2>&1
if [ $? = 0 ]
then
    printf "\nUnable to find backupsets to restore\n" | tee -a $LogFile
    printf "${RED}\n" | tee -a $LogFile
    egrep 'ORA-|RMAN-' $LOGORA/taginfo_${ORACLE_SID}_$$.log | tee -a $LogFile
    printf "${NORMAL}\n" | tee -a $LogFile
    return 1
fi

cat $LOGORA/taginfo_${ORACLE_SID}_$$.log | grep -v "Recovery Manager complete" | sed /^$/d > $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log

grep "does not match" $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log 1>/dev/null 2>&1
if [ $? -eq 1 ]
then
    if [ "$DATE_RECI" != "" ]
    then
        DATE_TAG_L=`echo ${Tagi} | awk -F'_' '{print $(NF-1)"_"$NF}'`
    else
        if [ "${Tag}" != "" ]
        then
            DATE_TAG_L=`echo ${Tag} | awk -F'_' '{print $(NF-1)"_"$NF}'`
        else
            DATE_TAG_L=""
        fi
    fi

    Taga=""
    while [ -s $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log -o "${Taga}" != "${TAG_L}" ]
    do
        Keya=`tail -1 $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | awk '{print $1}'`
        Lvla=`tail -1 $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | awk '{print $3}'`
        Taga=`tail -1 $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | awk '{print $NF}'`
        DATE_Taga=`echo ${Taga} | awk -F'_' '{print $(NF-1)"_"$NF}'`
        if [ "$Lvla" = "A" -a "${DATE_Taga}" != "${DATE_TAG_L}" ]
        then
            DATE_RECA=`cat $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | grep $Taga | head -1 | awk '{print $6}'`
            break
        elif [ "${DATE_Taga}" = "${DATE_TAG_L}" ]
        then
            DATE_RECA=""
            Keya=""
            Lvla=""
            Taga=""
            break
        else
            cat $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log | sed /^$Keya/d > $TEMPORA/cmd_bkpfile2_${ORACLE_SID}_$$.tmp
            mv $TEMPORA/cmd_bkpfile2_${ORACLE_SID}_$$.tmp $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log
        fi
    done
    [ ! -s $LOGORA/cmd_bkpfile2_${ORACLE_SID}_$$.log ] && Taga=""
else
    if [ "$TYPE" != "ARCH" ]
        then
            printf "No archivelog backup since last backup $TYPE $STATUS\n" | tee -a $LogFile
        else
            printf "Last Arch - ${DATE_REC} - KO\n" | tee -a $LogFile
            STATUS=KO
        if [ "${ENTREE}" = "DIRECT" ]
        then
            echo "${HOST};${ORACLE_SID};oracle;${Version};${DATE_REC};ARC;${STATUS}" >> $CsvFile
        fi
    fi
    return
fi


if [ "${Taga}" != "" ]
then
    printf "Last Arch - ${DATE_RECA} - OK - ${Taga}\n" | tee -a $LogFile
    STATUS=OK
    DATE_REC=${DATE_RECA}
    if [ "${ENTREE}" = "DIRECT" ]
    then
        echo "${HOST};${ORACLE_SID};oracle;${Version};${DATE_REC};ARC;${STATUS}" >> $CsvFile
    fi
else
    if [ "${TYPE}" = "ARCH" ]
    then
        printf "Last Arch - ${DATE_REC} - KO\n" | tee -a $LogFile
        STATUS=KO
        if [ "${ENTREE}" = "DIRECT" ]
        then
            echo "${HOST};${ORACLE_SID};oracle;${Version};${DATE_REC};ARC;${STATUS}" >> $CsvFile
        fi
    else
        printf "No archivelog backup since last backup $TYPE $STATUS\n" | tee -a $LogFile
    fi
fi
}

get_list_ko()
{
#------------
#- Search list of failed backup
#--------------------------

echo "set linesize 150
set feed off
set head off
set newp none
alter session set nls_date_format=\"yyyy/mm/dd;hh24:mi:ss\";
spool $LOGORA/rman_list_ko_${ORACLE_SID}_$$.log
select SESSION_RECID,START_TIME from v\$rman_status where STATUS='FAILED' and OPERATION='BACKUP' order by START_TIME;
spool off
quit" >> $TEMPORA/get_list_ko_${ORACLE_SID}_$$.sql

chmod 777 $TEMPORA/get_list_ko_${ORACLE_SID}_$$.sql

su oracle -c "${EXP_ENV_ORACLE};sqlplus -s '/as sysdba' @$TEMPORA/get_list_ko_${ORACLE_SID}_$$.sql 1>/dev/null 2>&1"
[ -f $TEMPORA/get_list_ko_${ORACLE_SID}_$$.sql ] && rm $TEMPORA/get_list_ko_${ORACLE_SID}_$$.sql

if [ -f $LOGORA/rman_list_ko_${ORACLE_SID}_$$.log ]
then
    while read SESS_RECID DATE_KO
    do
        get_type_backup_ko ${SESS_RECID} ${DATE_KO} >> $TMP/type_backup_ko_${ORACLE_SID}_$$.tmp
    done < $LOGORA/rman_list_ko_${ORACLE_SID}_$$.log
    [ -f $LOGORA/rman_list_ko_${ORACLE_SID}_$$.log ] && rm $LOGORA/rman_list_ko_${ORACLE_SID}_$$.log
fi
}

get_type_backup_ko()
{
#------------
#- Search incremental level of failed backup
#--------------------------

echo "set linesize 150
set pages 9999
set feed off
set head off
col OUTPUT for a150
spool $LOGORA/rman_output_${ORACLE_SID}_$$_$1.log
select OUTPUT from V\$RMAN_OUTPUT where SESSION_RECID=$1 and upper(OUTPUT) like '%BACKUP%INCREMENTAL%';
select OUTPUT from V\$RMAN_OUTPUT where SESSION_RECID=$1 and upper(OUTPUT) like '%BACKUP%FULL%';
spool off
quit" >> $TEMPORA/requete_output_rman_${ORACLE_SID}_$$_$1.sql

chmod 777 $TEMPORA/requete_output_rman_${ORACLE_SID}_$$_$1.sql

su oracle -c "${EXP_ENV_ORACLE};sqlplus -s '/as sysdba' @$TEMPORA/requete_output_rman_${ORACLE_SID}_$$_$1.sql 1>/dev/null 2>&1"
[ -f $TEMPORA/requete_output_rman_${ORACLE_SID}_$$_$1.sql ] && rm $TEMPORA/requete_output_rman_${ORACLE_SID}_$$_$1.sql

if [ ! -s $LOGORA/rman_output_${ORACLE_SID}_$$_$1.log ]
then
    LEVEL=ARCH
else
    for mot in `cat $LOGORA/rman_output_${ORACLE_SID}_$$_$1.log`
    do
        echo $mot | grep ^[0-2]$ 1>/dev/null 2>&1
        if [ $? -eq 0 ]
        then
            LEVEL=$mot
        fi
    done
    [ "$LEVEL" = "" ] && LEVEL=0
fi

[ ! -s $LOGORA/rman_output_${ORACLE_SID}_$$_$1.log ] && rm $LOGORA/rman_output_${ORACLE_SID}_$$_$1.log

echo "$2,$LEVEL"
}

get_date_last_backup()
{
#------------
#- Search start time of the last backup
#--------------------------

if [ -f $TMP/type_backup_ko_${ORACLE_SID}_$$.tmp ]
then
    cat $TMP/type_backup_ko_${ORACLE_SID}_$$.tmp | grep -i $1$ 1>/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        DATE_REC=`cat $TMP/type_backup_ko_${ORACLE_SID}_$$.tmp | grep $1$ | tail -1 | cut -d',' -f1`
        [ "${1}" = "0" ] && echo "${DATE_REC}-KO-FULL" >> $TMP/liste_date_${ORACLE_SID}_$$.tmp
        [ "${1}" = "1" ] && echo "${DATE_REC}-KO-INCR" >> $TMP/liste_date_${ORACLE_SID}_$$.tmp
        [ "${1}" = "ARCH"  ] && echo "${DATE_REC}-KO-ARCH" >> $TMP/liste_date_${ORACLE_SID}_$$.tmp
    fi
    rm $TMP/type_backup_ko_${ORACLE_SID}_$$.tmp
fi

if [ "${1}" != "0" -a -f $TMP/liste_date_${ORACLE_SID}_$$.tmp ]
then
    DATE_REC=`sort $TMP/liste_date_${ORACLE_SID}_$$.tmp | tail -1 | cut -d'-' -f1`
    STATUS=`sort $TMP/liste_date_${ORACLE_SID}_$$.tmp | tail -1 | cut -d'-' -f2`
    TYPE=`sort $TMP/liste_date_${ORACLE_SID}_$$.tmp | tail -1 | cut -d'-' -f3`
fi
}

get_date_sbt()
{
#------------
#- Search status and start time of the last backup on SBT TAPE
#--------------------------

echo "set linesize 150
set feed off
set head off
set newp none
alter session set nls_date_format=\"yyyy/mm/dd;hh24:mi:ss\";
spool $LOGORA/date_sbt_${ORACLE_SID}_$$.log
select END_TIME from v\$rman_status where OUTPUT_DEVICE_TYPE='SBT_TAPE' and OPERATION='BACKUP BACKUPSET' order by START_TIME;
spool off
quit" >> $TEMPORA/get_date_sbt${ORACLE_SID}_$$.sql

chmod 777 $TEMPORA/get_date_sbt${ORACLE_SID}_$$.sql

su oracle -c "${EXP_ENV_ORACLE};sqlplus -s '/as sysdba' @$TEMPORA/get_date_sbt${ORACLE_SID}_$$.sql 1>/dev/null 2>&1"
[ -f $TEMPORA/get_date_sbt${ORACLE_SID}_$$.sql ] && rm $TEMPORA/get_date_sbt${ORACLE_SID}_$$.sql

if [ -f $LOGORA/date_sbt_${ORACLE_SID}_$$.log ]
then
    DATE_SBT=`tail -1 $LOGORA/date_sbt_${ORACLE_SID}_$$.log | sed 's/[ ]*$//g'`
fi
}

get_backupset()
{
#------------
#- List of backupsets
#--------------------------

printf "\nSearch the list of the backupets\n" | tee -a $LogFile

echo "connect target /" > $TEMPORA/cmd_list_bkpfile_${ORACLE_SID}_$$.tmp
echo "sql 'alter session set nls_date_format=\"yyyy/mm/dd;hh24:mi:ss\"';" >> $TEMPORA/cmd_list_bkpfile_${ORACLE_SID}_$$.tmp
if [ "${RAC}" = "TRUE" ]
then
    echo "list backup summary completed between '$1' and 'sysdate';" >> $TEMPORA/cmd_list_bkpfile_${ORACLE_SID}_$$.tmp
else
    echo "list backup completed between '$1' and 'sysdate';" >> $TEMPORA/cmd_list_bkpfile_${ORACLE_SID}_$$.tmp
fi
echo "quit;" >> $TEMPORA/cmd_list_bkpfile_${ORACLE_SID}_$$.tmp

chmod 777 $TEMPORA/cmd_list_bkpfile_${ORACLE_SID}_$$.tmp

su oracle -c "${EXP_ENV_ORACLE};export NLS_DATE_FORMAT=\"yyyy/mm/dd;HH24:MI:SS\";rman cmdfile=$TEMPORA/cmd_list_bkpfile_${ORACLE_SID}_$$.tmp log=$LOGORA/rman_list_bkpfile_${ORACLE_SID}_$$.log 1>/dev/null 2>&1"
[ -f $TEMPORA/cmd_list_bkpfile_${ORACLE_SID}_$$.tmp ] && rm $TEMPORA/cmd_list_bkpfile_${ORACLE_SID}_$$.tmp

if [ "${RAC}" = "TRUE" ]
then
    cat $LOGORA/rman_list_bkpfile_${ORACLE_SID}_$$.log | grep ^[1-9] | grep -v '>' > $TMP/list_bkpfile_${ORACLE_SID}_$$.tmp
else
    cat $LOGORA/rman_list_bkpfile_${ORACLE_SID}_$$.log | grep bkp$ | awk '{print $NF}' | sed 's/ //g' > $TMP/list_bkpfile_${ORACLE_SID}_$$.tmp
fi

[ -f $TMP/list_bkpfile_${ORACLE_SID}_$$.tmp ] && cp $TMP/list_bkpfile_${ORACLE_SID}_$$.tmp $TEMPORA/list_bkpfile_${ORACLE_SID}_$$.tmp
[ -f $TEMPORA/list_bkpfile_${ORACLE_SID}_$$.tmp ] && chmod 777 $TEMPORA/list_bkpfile_${ORACLE_SID}_$$.tmp
}

getoptfile()
{
#------------
#- Get dsm.opt file configured to perform TSM backup/archive
#--------------------------

if [ -f ${BRCONF}/bt_sauvegarde.conf ]
then
  configured_optfile=$(grep $1 ${BRCONF}/bt_sauvegarde.conf | grep ^$2 | tail -1 | cut -d';' -f7)

  if [ "${configured_optfile}" != "defaut" -a "${configured_optfile}" != "" ]
  then
    DSM_OPTFILE="-optfile=${TSM_BINDIR}/${configured_optfile}"
  else
    DSM_OPTFILE=""
  fi
else
  DSM_OPTFILE=""
fi
}

verifTSMoracle()
{
#------------
#- Check presence of backupset on TSM (with oracle)
#--------------------------

su oracle -c "dsmc q ar "$1" -date=3 ${DSM_OPTFILE} 1>$TEMPORA/test_dsmc_${ORACLE_SID}_$$.tmp 2>&1 && return 0 || return 1"
RETURN=$?
if [ ${RETURN} = 0 ]
then
    printf "${CYAN}%-105s ${GREEN}%-5s${NORMAL}\n" $1 OK | tee -a $LogFile
    DATE_TSM=`cat $TEMPORA/test_dsmc_${ORACLE_SID}_$$.tmp | grep "$1" | awk '{print $3" "$4}'`
    [ -f $TEMPORA/test_dsmc_${ORACLE_SID}_$$.tmp ] && rm $TMP/test_dsmc_${ORACLE_SID}_$$.tmp
    return 0
else
    grep "ANS1092W" $TEMPORA/test_dsmc_${ORACLE_SID}_$$.tmp 1>/dev/null 2>&1
    if [ $? = 0 ]
    then
        printf "${CYAN}%-105s ${RED}%-5s${NORMAL}\n" $1 KO | tee -a $LogFile
        STATUS_TSM=KO
        [ -f $TEMPORA/test_dsmc_${ORACLE_SID}_$$.tmp ] && rm $TEMPORA/test_dsmc_${ORACLE_SID}_$$.tmp
        return 1
    else
        STATUS_TSM=KO
        [ -f $TEMPORA/test_dsmc_${ORACLE_SID}_$$.tmp ] && rm $TEMPORA/test_dsmc_${ORACLE_SID}_$$.tmp
        return 2
    fi
fi
}

verifTSMroot()
{
#------------
#- Check presence of backupset on TSM (with root)
#--------------------------

if [ "${TSM_TYPE}" = "" -o "${TSM_TYPE}" = "BACKUP" ]
then
    getoptfile ${ORACLE_SID} backup_rep
    dsmc q ba "$1" -date=3 ${DSM_OPTFILE} 1>$TMP/test_dsmc_${ORACLE_SID}_$$.tmp 2>&1
    RETURN=$?
    if [ ${RETURN} = 0 ]
    then
        TSM_TYPE=BACKUP
        printf "${CYAN}%-105s ${GREEN}%-5s${NORMAL}\n" $1 OK | tee -a $LogFile
        DATE_TSM=`cat $TMP/test_dsmc_${ORACLE_SID}_$$.tmp | grep "$1" | awk '{print $3" "$4}'`
        [ -f $TMP/test_dsmc_${ORACLE_SID}_$$.tmp ] && rm $TMP/test_dsmc_${ORACLE_SID}_$$.tmp
    elif [ ${RETURN} = 8 ]
    then
        [ "${TSM_TYPE}" = "BACKUP" ] && printf "${CYAN}%-105s ${RED}%-5s${NORMAL}\n" $1 KO | tee -a $LogFile
        [ "${TSM_TYPE}" = "BACKUP" ] && STATUS_TSM=KO
        [ -f $TMP/test_dsmc_${ORACLE_SID}_$$.tmp ] && rm $TMP/test_dsmc_${ORACLE_SID}_$$.tmp
        [ "${TSM_TYPE}" = "BACKUP" ] && return 1
    else
        [ -f $TMP/test_dsmc_${ORACLE_SID}_$$.tmp ] && rm $TMP/test_dsmc_${ORACLE_SID}_$$.tmp
        return 2
    fi
fi

if [ "${TSM_TYPE}" = "" -o "${TSM_TYPE}" = "ARCHIVE" ]
then
    getoptfile ${ORACLE_SID} archive
    dsmc q ar "$1" -date=3 ${DSM_OPTFILE} 1>$TMP/test_dsmc_${ORACLE_SID}_$$.tmp 2>&1
    RETURN=$?
    if [ ${RETURN} = 0 ]
    then
        TSM_TYPE=ARCHIVE
        printf "${CYAN}%-105s ${GREEN}%-5s${NORMAL}\n" $1 OK | tee -a $LogFile
        DATE_TSM=`cat $TMP/test_dsmc_${ORACLE_SID}_$$.tmp | grep "$1" | awk '{print $3" "$4}'`
        [ -f $TMP/test_dsmc_${ORACLE_SID}_$$.tmp ] && rm $TMP/test_dsmc_${ORACLE_SID}_$$.tmp
    elif [ ${RETURN} = 8 ]
    then
        printf "${CYAN}%-105s ${RED}%-5s${NORMAL}\n" $1 KO | tee -a $LogFile
        STATUS_TSM=KO
        [ -f $TMP/test_dsmc_${ORACLE_SID}_$$.tmp ] && rm $TMP/test_dsmc_${ORACLE_SID}_$$.tmp
        return 1
    else
        [ -f $TMP/test_dsmc_${ORACLE_SID}_$$.tmp ] && rm $TMP/test_dsmc_${ORACLE_SID}_$$.tmp
        return 2
    fi
fi
}

purgetmplogs()
{
#------------
#- Check presence of backupset on TSM (with root)
#--------------------------
[ "${TMP}" != "" ] && find ${TMP}/*.tmp -mtime +7 -ls -exec rm {} \; 1>/dev/null 2>&1
[ "${TEMPORA}" != "" ] && find ${TEMPORA}/*.tmp -mtime +7 -ls -exec rm {} \; 1>/dev/null 2>&1
}

#============
#= Script
#=====================

header

if [ "root" != `whoami` ]
then
    printf "The script must be executed by the user root!!!\n\n"
    exit 1
fi

if [ ! -d ${DirGouvBnppLog}/${DayOfMonth} ]
then
    mkdir -p ${DirGouvBnppLog}/${DayOfMonth}
    chmod -R 777 ${DirGouvBnppLog}
fi

if [ ! -d $TMP  ]
then
    mkdir -p $TMP
    chmod -R 777 $TMP
fi

header >> $LogFile
[ -f $CsvFile ] && mv $CsvFile $CsvFilePrev

if [ $# -ne 0 ]
then
    while getopts ":hs:" HOpt
    do
        case $HOpt in
            h)usage && usage2;;
            s)ORA_FILTRE=$OPTARG
            egrep -v "^#|^$|^\*" /etc/oratab | grep -w ${ORA_FILTRE} | cut -d: -f 1 > $TMP/list_instance_$$.tmp
            ;;
            :)usage && exit;;
            \?)usage && exit;;
        esac
    done
else
    egrep -v "^#|^$|^\*" /etc/oratab | cut -d: -f 1 > $TMP/list_instance_$$.tmp
fi

if [ ! -s $TMP/list_instance_$$.tmp ]
then
    if [ "${ORA_FILTRE}" != "" ]
    then
        printf "\nNo instance ${ORA_FILTRE} on the server\n\n" | tee -a $LogFile
                purgetmplogs
        exit 1
    else
        printf "No oracle instance on the server\n\n" | tee -a $LogFile
                purgetmplogs
        exit
    fi
fi

Compt=0
while read ORACLE_SID
do
    Compt=$(($Compt + 1))
    [ $Compt -gt 1 ] && printf "\n\n=========================================================================\n\n" | tee -a $LogFile

    unset Version Dbrole RAC Log_Mode
    unset Key Lvl Tag DATE_REC STATUS
    unset Keyi Lvli Tagi DATE_Tagi DATE_RECI TYPE
    unset Keya Lvla Taga DATE_Taga DATE_RECA
    unset DATE_FULL_OK DATE_TAG_L LEVEL
    unset STATUS_TSM DATE_TSM STATUS_SBT DATE_SBT
    unset TSM_TYPE

    LOGORA=/apps/oracle/backup/log/${ORACLE_SID}/verif_backup_log
    TEMPORA=/apps/oracle/backup/log/${ORACLE_SID}/tmp

    create_dir_oracle ${ORACLE_SID}
    if [ ! -d ${LOGORA} ]
    then
        printf "\nIncapable to create ${LOGORA} directory\n\n" | tee -a $LogFile
        continue
    fi

    if [ ! -d ${TEMPORA} ]
    then
        printf "\nIncapable to create ${TEMPORA} directory\n\n" | tee -a $LogFile
        continue
    fi

    get_info_instance ${ORACLE_SID}
    RETURN=$?

    if [ ${RETURN} -eq 1 ]
    then
        printf "\nError while looking for information about instance ${ORACLE_SID}\n\n" | tee -a $LogFile
        continue
    elif [ ${RETURN} -eq 2 ]
    then
        printf "\nNo backup on physical standby instance\n\n" | tee -a $LogFile
        continue
    elif [ ${RETURN} -eq 3 ]
    then
        printf "\nInstance ${ORACLE_SID} is ${Open_mode}\n\n" | tee -a $LogFile
        continue
    fi

    get_list_ko

    get_date_last_backup 0
    get_last_backup_full ${DATE_REC}

    if [ $? -eq 0 ]
    then
        echo "${DATE_REC}-${STATUS}-FULL" >> $TMP/liste_date_${ORACLE_SID}_$$.tmp
    else
        continue
    fi

    get_date_last_backup 1
    get_last_backup_incr ${DATE_REC}

    if [ $? -eq 0 ]
    then
        echo "${DATE_REC}-${STATUS}-INCR" >> $TMP/liste_date_${ORACLE_SID}_$$.tmp
    else
        continue
    fi

    if [ "${Log_Mode}" = "ARCHIVELOG" ]
    then
        get_date_last_backup ARCH
        get_last_backup_arch ${DATE_REC}
    fi

    grep FULL $TMP/liste_date_${ORACLE_SID}_$$.tmp | grep OK 1>/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        DATE_FULL_OK=`grep FULL $TMP/liste_date_${ORACLE_SID}_$$.tmp | grep OK | cut -d '-' -f1`
    else
        get_last_completed_full
    fi

    get_backupset ${DATE_FULL_OK}

    if [ "${RAC}" = "FALSE" ]
    then
      which dsmc 1>/dev/null 2>&1
      if [[ $? -ne 0 ]];then
        printf "\nTSM Binaries not found (dsmc)\n\n"
        DATE_TSM="NO_TSM_BINARIES"
        STATUS_TSM="NO_TSM_BINARIES"
      else
        for account in root oracle
        do
            printf "\nFiles on TSM with $account\n\n"
            [ "${account}" = "root" ] && TEMP=$TMP || TEMP=$TEMPORA
            while read file
            do
                verifTSM${account} $file
                Return=$?
                if [ ${Return} = 2 ]
                then
                    printf "\nTSM not configured for ${account}\n" | tee -a $LogFile
                    STATUS_TSM=ERROR
                    break
                fi
            done < $TEMP/list_bkpfile_${ORACLE_SID}_$$.tmp
            if [ "${STATUS_TSM}" = "ERROR" ]
            then
                continue
            elif [ "${STATUS_TSM}" != "KO" ]
            then
                STATUS_TSM=OK
                break
            fi
        done
        if [ "${STATUS_TSM}" != "OK" ]
        then
          STATUS_TSM=KO
        fi
        if [ "${DATE_TSM}" != "" -a "${STATUS_TSM}" = "OK" ]
        then
            DATETSM=`echo ${DATE_TSM} | awk '{print $1}'`
            HOURTSM=`echo ${DATE_TSM} | awk '{print $2}'`

            typeset -i YTSM=`echo ${DATETSM} | awk -F'/' '{print $3}'`
            YTSM=`echo ${DATETSM} | awk -F'-' '{print $1}'`
            MTSM=`echo ${DATETSM} | awk -F'-' '{print $2}'`
            DTSM=`echo ${DATETSM} | awk -F'-' '{print $3}'`

            DATE_TSM="${YTSM}/${MTSM}/${DTSM};${HOURTSM}"
        else
            DATE_TSM=`date '+%Y/%m/%d;%H:%M:%S'`
        fi
      fi
      if [ "${ENTREE}" = "DIRECT" ]
      then
        echo "$HOST;${ORACLE_SID};oracle;$Version;${DATE_TSM};TSM;${STATUS_TSM}" >> $CsvFile
      fi
    else
        while read Key TY LV AVAIL DEVICE_TYPE Completion_Time Pieces Copies Compressed File
        do
            if [ "${DEVICE_TYPE}" = "DISK" -o \( "${DEVICE_TYPE}" != "DISK" -a "${AVAIL}" != "A" \) ]
            then
                printf "${CYAN}%-50s ${RED}%-5s${NORMAL}\n" $File KO | tee -a $LogFile
                STATUS_SBT=KO
            else
                printf "${CYAN}%-50s ${GREEN}%-5s${NORMAL}\n" $File OK | tee -a $LogFile
            fi
        done < $TEMPORA/list_bkpfile_${ORACLE_SID}_$$.tmp
        [ "${STATUS_SBT}" != "KO" ] && STATUS_SBT=OK
        get_date_sbt
        if [ "${ENTREE}" = "DIRECT" ]
        then
            echo "$HOST;${ORACLE_SID};oracle;$Version;${DATE_SBT};SBT;${STATUS_SBT}" >> $CsvFile
        fi
    fi
    [ -f $TMP/list_bkpfile_${ORACLE_SID}_$$.tmp ] && rm $TMP/list_bkpfile_${ORACLE_SID}_$$.tmp
    [ -f $TEMPORA/list_bkpfile_${ORACLE_SID}_$$.tmp ] && rm $TEMPORA/list_bkpfile_${ORACLE_SID}_$$.tmp
    cd $LOGORA && find *bkpfile*${ORACLE_SID}*.log -mtime +30 -ls -exec rm {} \; 1>/dev/null 2>&1
    cd $LOGORA && find *taginfo*${ORACLE_SID}*.log -mtime +30 -ls -exec rm {} \; 1>/dev/null 2>&1
done < $TMP/list_instance_$$.tmp

purgetmplogs
[ -f $CsvFile ] && chmod 555 $CsvFile
[ -f $TMP/list_instance_$$.tmp ] && rm $TMP/list_instance_$$.tmp

