#!/bin/ksh93

#--------------------------------------
# Variables
#--------------------------------------

CHK_BKP_LOG=improper
CHK_BKP_FREQ=improper
CHK_BKP_SCHEDMODE=improper
CHK_BKP_RC=improper
NBDAY=$1

#--------------------------------------
# Functions
#--------------------------------------

f_checknorms_bkp () {

if [ "${NBDAY}" == "" ];then
 NBDAY=7
fi

# Verification de le presence d'une log de sauvegarde.

ls /apps/toolboxes/backup_restore/logs/backup*.log >/dev/null 2>&1 # Code retour de la commande doit etre 0
if [ $? -eq 0 ]; then
  CHK_BKP_LOG=proper
fi

# La sauvegarde (via la toolbox ) est elle planifiee au moins de maniere hebdomadaire.

if [ "${CHK_BKP_LOG}" == "proper" ]; then
 find /apps/toolboxes/backup_restore/logs/backup*.log  -mtime -${NBDAY} -ls | grep .log > /dev/null # Code retour de la commande doit etre 0
 if [ $? -eq 0 ]; then
   CHK_BKP_FREQ=proper
 fi
fi

# La sauvegarde est elle ordonnancee par Autosys ou Control-M

if [ "${CHK_BKP_LOG}" == "proper" ]; then
 find /apps/toolboxes/backup_restore/logs/backup*.log  -ls | awk '{print $NF}' > ${BT_TMPDIR}/bkplog_7d.tmp
 while read backuplog; do grep '\-- JOB :' "$backuplog" | grep -v "CRONTAB" | grep -v "DIRECT"  && CHK_BKP_SCHEDMODE=partialproper && break; done < ${BT_TMPDIR}/bkplog_7d.tmp > /dev/null
fi

if [ "${CHK_BKP_LOG}" == "proper" ]; then
 find /apps/toolboxes/backup_restore/logs/backup*.log  -mtime -${NBDAY} -ls | awk '{print $NF}' > ${BT_TMPDIR}/bkplog_7d.tmp
 while read backuplog; do grep '\-- JOB :' "$backuplog" | grep -v "CRONTAB" | grep -v "DIRECT"  && CHK_BKP_SCHEDMODE=proper && break; done < ${BT_TMPDIR}/bkplog_7d.tmp > /dev/null
fi


# Le Script de sauvegarde doit etre en code retour 0 au moins une fois sur les x derniers jours

if [ "${CHK_BKP_FREQ}" == "proper" ]; then
 find /apps/toolboxes/backup_restore/logs/backup*.log  -mtime -${NBDAY} -ls | awk '{print $NF}' > ${BT_TMPDIR}/bkplog_7d.tmp
 while read backuplog; do grep -Hi '\-- CR : 0' "$backuplog" && CHK_BKP_RC=proper && break; done < ${BT_TMPDIR}/bkplog_7d.tmp > /dev/null
fi

if [ "${CHK_BKP_LOG}" == "proper" ] && [ "${CHK_BKP_FREQ}" == "proper" ] && [ "${CHK_BKP_SCHEDMODE}" == "proper" ] && [ "${CHK_BKP_RC}"  == "proper" ];then
  CHK_BKP=OK
fi

}


#--------------------------------------
# Check Backup Conformity
#--------------------------------------

f_checknorms_bkp ${NBDAY} > /dev/null 2>&1

if [ "${CHK_BKP}" == "OK" ];then
   echo "${CHK_BKP}"
else
   if [ "${CHK_BKP_LOG}" == "improper" ]; then
     CHK_BKP=ERROR_NO_BKP_LOG_WAS_FOUND
     echo "${CHK_BKP}"
     exit 1
   else
      if [ "${CHK_BKP_FREQ}" == "improper" ] && [ "${CHK_BKP_SCHEDMODE}" == "improper" ]; then
       CHK_BKP=ERROR_NO_BKP_FOR_MORE_THAN_${NBDAY}_DAYS_AND_PREVIOUS_BACKUP_WAS_NOT_SCHEDULED_WITH_AUTOSYS_OR_CONTROLM
       echo "${CHK_BKP}"
       exit 1
      else
        if [ "${CHK_BKP_FREQ}" == "improper" ]; then
           CHK_BKP=ERROR_NO_BKP_FOR_MORE_THAN_${NBDAY}_DAYS
           echo "${CHK_BKP}"
           exit 1
        else
           if [ "${CHK_BKP_RC}" == "improper" ] && [ "${CHK_BKP_SCHEDMODE}" == "improper" ]; then
             CHK_BKP=ERROR_TSM_BACKUP_RETURN_CODE_NOT_OK_AND_BACKUP_WAS_NOT_SCHEDULED_WITH_AUTOSYS_OR_CONTROLM
             echo "${CHK_BKP}"
             exit 1
           else
              if [ "${CHK_BKP_RC}" == "improper" ]; then
                CHK_BKP=ERROR_TSM_BACKUP_RETURN_CODE_NOT_OK
                echo "${CHK_BKP}" 
                exit 1
              fi
              if [ "${CHK_BKP_SCHEDMODE}" == "improper" ]; then
                CHK_BKP=ERROR_BKP_NOT_SCHEDULED_WITH_AUTOSYS_OR_CONTROLM
                echo "${CHK_BKP}"
                exit 1
              fi
           fi
        fi
      fi
   fi
fi
