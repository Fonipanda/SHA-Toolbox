#!/bin/ksh93

#--------------------------------------
# Variables
#--------------------------------------
#set -x

DirGouvBnpp=/apps/toolboxes/exploit/GouvBnpp
DirTbxBkp=/apps/toolboxes/backup_restore/scripts

#--------------------------------------
# Refresh Oracle Backup State files
#--------------------------------------
if [ -f $DirGouvBnpp/Info_Oracle.ksh -a -f $DirGouvBnpp/Generate_CsvReport.ksh -a -f $DirTbxBkp/verif_backup.ksh ];then
  $DirGouvBnpp/Info_Oracle.ksh 1>/dev/null 2>&1
  $DirGouvBnpp/Generate_CsvReport.ksh 1>/dev/null 2>&1
  if [ "$1" != "" ]
  then
    $DirTbxBkp/verif_backup.ksh -s $1 1>/dev/null 2>&1
    Verif_CR=$?
  else
    $DirTbxBkp/verif_backup.ksh 1>/dev/null 2>&1
    Verif_CR=$?
  fi
  echo "Refresh finished successfully"
else
  echo "Missing toolbox scripts"
  exit 1
fi
exit ${Verif_CR}
