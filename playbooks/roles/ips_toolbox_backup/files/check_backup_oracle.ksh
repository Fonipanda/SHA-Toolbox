#!/bin/ksh93

#--------------------------------------
# Variables
#--------------------------------------
#set -x

f_ansible_checknorms_orabkp()
{
typeset -x __DIR__TBX_EXPLOIT="/apps/toolboxes/exploit"
DirGouvBnpp=${__DIR__TBX_EXPLOIT}/GouvBnpp
DirGouvBnppLog=${DirGouvBnpp}/logs
BT_TMPDIR=/apps/toolboxes/backup_restore/tmp

if [ -d $DirGouvBnpp ]; then
   CHKTBX=OK
else
   CHKTBX=KO
fi

if [ "${CHKTBX}" == "KO" ];then
   echo "TOOLBOX REPOSITORY NOT FOUND"
   exit 1
fi

CHK_ORA_INST=NOINSTANCE
CHK_ORA_STATE=NOTDETECTED
CHK_ORA_BKP=NOBACKUP
CHK_ORA_BKP2=NOBACKUP
CHK_ORA_BKPTSM=TSM_KO

if [ "${NBDAY}" == "" ];then
 NBDAY=7
 NBDAY2=8
 NBDAY3=NOTDEFINED
elif [ ${NBDAY} -lt 7 ];then
 NBDAY2=8
 NBDAY3=$((${NBDAY}+1))
else
 NBDAY2=$((${NBDAY}+1))
 NBDAY3=NOTDEFINED
fi


# Changement du binaire "date" pour le cas AIX
DATE=date
typeset __SYSTEM__OS="$(uname)"
if [ "${__SYSTEM__OS}" = "AIX" ]; then
  DATE=/usr/linux/bin/date
fi


# verification de la presence de l'instance specifiee en variable de la fonction

grep -w ${ORA_INST} /etc/oratab >/dev/null 2>&1
  if [[ $? != 0 ]];then
    CHK_ORA_INST=INSTANCE_NOT_FOUND
  else
    CHK_ORA_INST=ORA_INST_DETECTED
    echo ${ORA_INST} > ${BT_TMPDIR}/ora_instlist.tmp
  fi

# Check de l'etat de l'instance

if [ "${CHK_ORA_INST}" == "ORA_INST_DETECTED" ]; then
#  $DirGouvBnpp/Info_Oracle.ksh 1>/dev/null 2>&1
#  $DirGouvBnpp/Generate_CsvReport.ksh 1>/dev/null 2>&1
  find $DirGouvBnppLog/*/ -name Report_OracleInstance*.csv -mtime -1 | grep Oracle > /dev/null && CHK_ORA_STATE=DETECTED
  if [ "${CHK_ORA_STATE}" == "DETECTED" ];then
    find  $DirGouvBnppLog/*/ -name Report_OracleInstance*.csv -mtime -1 -ls | awk '{print $NF}' | sort -r | head -1 > ${BT_TMPDIR}/orastate_1d.tmp
    while read orastate; do grep -Hi ${ORA_INST} "$orastate" | grep PRIMARY | grep 'READ WRITE' && CHK_ORA_STATE=PRIM_RW && break; done < ${BT_TMPDIR}/orastate_1d.tmp > /dev/null
    if [ "${CHK_ORA_STATE}" == "DETECTED" ];then
        while read orastate; do grep -Hi ${ORA_INST} "$orastate" | grep -vw PRIMARY | grep 'MOUNTED' && CHK_ORA_STATE=NOPRIM_MNT && break; done < ${BT_TMPDIR}/orastate_1d.tmp > /dev/null
       if [ "${CHK_ORA_STATE}" == "NOPRIM_MNT" ];then
          CHK_ORA_STATE=NO_BACKUP_CHECK_REQUIRED
       else
          while read orastate; do grep -Hi ${ORA_INST} "$orastate" | grep -vw PRIMARY | grep 'READ ONLY' && CHK_ORA_STATE=NOPRIM_ROWA && break; done < ${BT_TMPDIR}/orastate_1d.tmp > /dev/null
          if [ "${CHK_ORA_STATE}" == "NOPRIM_ROWA" ];then
            CHK_ORA_STATE=NO_BACKUP_CHECK_REQUIRED
          else
             while read orastate; do grep -Hi ${ORA_INST} "$orastate" | grep -i 'not_running' && CHK_ORA_STATE=NOT_RUNNING && break; done < ${BT_TMPDIR}/orastate_1d.tmp > /dev/null
             if [ "${CHK_ORA_STATE}" == "NOT_RUNNING" ];then
                CHK_ORA_STATE=NO_BACKUP_CHECK_REQUIRED
             else
                CHK_ORA_STATE=ERROR
             fi
          fi
       fi
    fi
  fi
fi

# verification des sauvegardes uniquement si l'instance est en primary Read Write

if [ "${CHK_ORA_STATE}" == "PRIM_RW" ];then
 # /apps/toolboxes/backup_restore/scripts/verif_backup.ksh 1>/dev/null 2>&1
  find $DirGouvBnppLog/*/ -name Report_SaveDatabase*.csv -mtime -${NBDAY} | grep Report  > /dev/null && CHK_ORA_BKP=DETECTED
  if [ "${CHK_ORA_BKP}" == "DETECTED" ];then
    find /apps/toolboxes/exploit/GouvBnpp/logs/*/ -name Report_SaveDatabase*.csv -mtime -${NBDAY}  | awk -F " " '{print $NF}' | sort -rt_ -k3,3 | head -1 > ${BT_TMPDIR}/orabkp_7d.tmp
    CHK_ORA_BKP2=NOBACKUP
    CHK_ORA_BKP3=NOBACKUP
    # Controle full
    while read orabkp; do grep -Hi ${ORA_INST} "$orabkp" | grep 'FUL;OK' && CHK_ORA_BKP2=FULL_OK && date_full_dsk=$(grep -Hi ${ORA_INST} "$orabkp" | grep 'FUL;OK' | awk -F ";" '{print $5}') && break; done < ${BT_TMPDIR}/orabkp_7d.tmp > /dev/null
    if [ "${CHK_ORA_BKP2}" == "FULL_OK" ];then
      date_today=$(${DATE} '+%Y/%m/%d') > /dev/null
      D1=`${DATE} +%s -d "$date_full_dsk"`
      D2=`${DATE} +%s -d "$date_today"`
      ((diff_sec=D2-D1))
      diff_day=$(echo - | awk -v SECS=$diff_sec '{printf "%d",SECS/(60*60*24)}')
      if [ $diff_day -lt ${NBDAY2} ];then
        CHK_ORA_BKP2=FULL_OK_DATE_OK
        # Controle incrementale si profondeur du check est inferieure a 7 jours
        if [ "${CHK_ORA_BKP2}" == "FULL_OK_DATE_OK" -a "${NBDAY3}" != "NOTDEFINED" ];then
          if [ $diff_day -lt ${NBDAY3} ];then
            CHK_ORA_BKP3=INC_OK_DATE_OK
          else
            while read orabkp; do grep -Hi ${ORA_INST} "$orabkp" | grep 'INC;OK' && CHK_ORA_BKP3=INC_OK && date_inc_dsk=$(grep -Hi ${ORA_INST} "$orabkp" | grep 'INC;OK' | awk -F ";" '{print $5}') && break; done < ${BT_TMPDIR}/orabkp_7d.tmp > /dev/null
            if [ "${CHK_ORA_BKP3}" == "INC_OK" ];then
              D1=`${DATE} +%s -d "$date_inc_dsk"`
              D2=`${DATE} +%s -d "$date_today"`
              ((diff_sec=D2-D1))
              diff_day=$(echo - | awk -v SECS=$diff_sec '{printf "%d",SECS/(60*60*24)}')
              if [ $diff_day -lt ${NBDAY3} ];then
                CHK_ORA_BKP3=INC_OK_DATE_OK
              else
                CHK_ORA_BKP3=INC_OK_DATE_KO
              fi
            fi
          fi
        fi
        # Controle envoi TSM
        while read orabkp; do grep -Hi ${ORA_INST} "$orabkp" | grep 'TSM;OK' && CHK_ORA_BKPTSM=TSM_OK && date_tsm_bkp=$(grep -Hi ${ORA_INST} "$orabkp" | grep 'TSM;OK' | awk -F ";" '{print $5}') && break; done < ${BT_TMPDIR}/orabkp_7d.tmp > /dev/null
        if [ "${CHK_ORA_BKPTSM}" == "TSM_OK" ];then
          D1=`${DATE} +%s -d "$date_tsm_bkp"`
          D2=`${DATE} +%s -d "$date_today"`
          ((diff_sec2=D2-D1))
          diff_day2=$(echo - | awk -v SECS=$diff_sec2 '{printf "%d",SECS/(60*60*24)}')
          if [ $diff_day2 -lt ${NBDAY2} ];then
            CHK_ORA_BKPTSM=TSM_OK_DATE_OK
          else
            CHK_ORA_BKPTSM=TSM_OK_DATE_KO
          fi
        else
          while read orabkp; do grep -Hi ${ORA_INST} "$orabkp" | grep 'TSM;NO_TSM_BINARIES' && CHK_ORA_BKPTSM=TSM_NA && break; done < ${BT_TMPDIR}/orabkp_7d.tmp > /dev/null
        fi
      else
        CHK_ORA_BKP2=FULL_OK_DATE_KO
      fi
    fi
  fi
fi

}

#--------------------------------------
# Check Backup Conformity
#--------------------------------------

ORA_INST=$1
NBDAY=$2

f_ansible_checknorms_orabkp ${ORA_INST} ${NBDAY} #1>/dev/null 2>&1

if [ "${CHK_ORA_INST}" == "INSTANCE_NOT_FOUND" ]
then
  echo "INSTANCE ${ORA_INST} NOT FOUND" && exit 1
fi

if [ "${NBDAY3}" != "NOTDEFINED" ];then
  if [ "${CHK_ORA_STATE}" != "ERROR" -a "${CHK_ORA_BKP3}" == "INC_OK_DATE_OK" -a "${CHK_ORA_BKPTSM}" == "TSM_OK_DATE_OK" ]
  then
    echo "OK"
  elif [ "${CHK_ORA_STATE}" != "ERROR" -a "${CHK_ORA_BKP3}" == "INC_OK_DATE_OK" -a "${CHK_ORA_BKPTSM}" == "TSM_NA" ]
  then
    echo "OK - ONLY ON DISK BECAUSE NO TSM BINARIES"
  else
    if [ "${CHK_ORA_STATE}" == "NO_BACKUP_CHECK_REQUIRED" ]
    then
      echo "OK - NO BACKUP CHECK REQUIRED DUE TO THE ${ORA_INST} INSTANCE STATE"
    elif [ "${CHK_ORA_STATE}" = "NOTDETECTED" ]
    then
      echo "ERROR - INSTANCE_STATE NOT DEFINED" && exit 1
    elif [ "${CHK_ORA_STATE}" = "ERROR" ]
    then
      echo "ERROR - INSTANCE STATE IN ERROR" && exit 1
    elif [ "${CHK_ORA_BKP2}" = "NOBACKUP" -o "${CHK_ORA_BKP2}" = "FULL_KO" ]
    then
      echo "ERROR - NO INSTANCE FULL BACKUP" && exit 1
    elif [ "${CHK_ORA_BKP2}" = "FULL_OK_DATE_KO" ]
    then
      echo "ERROR - NO INSTANCE FULL BACKUP FOR LAST 7 DAYS" && exit 1
    elif [ "${CHK_ORA_BKP3}" = "NOBACKUP" ]
    then
      echo "ERROR - NO INSTANCE INCREMENTAL BACKUP AND FULL IS TOO OLD" && exit 1
    elif [ "${CHK_ORA_BKP3}" = "INC_OK_DATE_KO" ]
    then
      echo "ERROR - NO INSTANCE INCREMENTAL BACKUP FOR LAST ${NBDAY} DAYS" && exit 1
    elif [ "${CHK_ORA_BKPTSM}" = "TSM_KO" ]
    then
      echo "ERROR - BACKUPSETS NOT STORED ON TSM" && exit 1
    elif [ "${CHK_ORA_BKPTSM}" = "TSM_OK_DATE_KO" ]
    then
      echo "ERROR BACKUPSETS NOT STORED ON TSM FOR LAST ${NBDAY} DAYS" && exit 1
    fi
  fi
else
  if [ "${CHK_ORA_STATE}" != "ERROR" -a "${CHK_ORA_BKP2}" != "NOBACKUP" -a "${CHK_ORA_BKP2}" != "FULL_KO" -a "${CHK_ORA_BKP2}" != "FULL_OK_DATE_KO" -a "${CHK_ORA_BKPTSM}" != "TSM_KO" -a "${CHK_ORA_BKPTSM}" != "TSM_OK_DATE_KO" -a "${CHK_ORA_BKPTSM}" != "TSM_NA" ]
  then
    echo "OK"
  elif [ "${CHK_ORA_STATE}" != "ERROR" -a "${CHK_ORA_BKP2}" != "NOBACKUP" -a "${CHK_ORA_BKP2}" != "FULL_KO" -a "${CHK_ORA_BKP2}" != "FULL_OK_DATE_KO" -a "${CHK_ORA_BKPTSM}" == "TSM_NA" ]
  then
     echo "OK - ONLY ON DISK BECAUSE NO TSM BINARIES"
  else
    if [ "${CHK_ORA_STATE}" == "NO_BACKUP_CHECK_REQUIRED" ]
    then
      echo "OK - NO BACKUP CHECK REQUIRED DUE TO THE ${ORA_INST} INSTANCE STATE"
    elif [ "${CHK_ORA_STATE}" = "NOTDETECTED" ]
    then
      echo "ERROR - INSTANCE_STATE NOT DEFINED" && exit 1
    elif [ "${CHK_ORA_STATE}" = "ERROR" ]
    then
      echo "ERROR - INSTANCE STATE IN ERROR" && exit 1
    elif [ "${CHK_ORA_BKP2}" = "NOBACKUP" -o "${CHK_ORA_BKP2}" = "FULL_KO" ]
    then
      echo "ERROR - NO INSTANCE FULL BACKUP" && exit 1
    elif [ "${CHK_ORA_BKP2}" = "FULL_OK_DATE_KO" ]
    then
      echo "ERROR - NO INSTANCE FULL BACKUP FOR LAST ${NBDAY} DAYS" && exit 1
    elif [ "${CHK_ORA_BKPTSM}" = "TSM_KO" ]
    then
      echo "ERROR - BACKUPSETS NOT STORED ON TSM" && exit 1
    elif [ "${CHK_ORA_BKPTSM}" = "TSM_OK_DATE_KO" ]
    then
      echo "ERROR BACKUPSETS NOT STORED ON TSM FOR LAST ${NBDAY} DAYS" && exit 1
    fi
  fi
fi

