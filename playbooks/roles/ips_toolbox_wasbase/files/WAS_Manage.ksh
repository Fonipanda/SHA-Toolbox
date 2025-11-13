#!/bin/ksh

# call function audit
. /apps/toolboxes/exploit/include/.audit.ksh

typeset -x TBX_NAME="WEB"
[ -z "${ENTREE}" ] && typeset -x ENTREE="DIRECT"
compteurTbx "$(basename ${0})" "$(md5sum $0 | awk '{print $1}')"

#------------
#- Variables
#------------

WLC_VI="No"
WLB_VI="No"
WND_VI="No"
WBA_VI="No"
RC_SA=0
QUIET="no"
SU_USER=""

operation=$1
element=$2
web_product=$3
quiet=$4

OS_SYSTEM=$(uname)

USER=$(whoami)

[[ "${USER}" == "root" ]] && SU_USER="su - was -c" 

[[ "${web_product}" == "quiet" ]] && QUIET="yes" && web_product=""
[[ "${quiet}" == "quiet" ]] && QUIET="yes"

println()
{
        case $1 in
                noir) TEXT="\033[1;30;40m$2 \033[0m" ;;
                rouge) TEXT="\033[1;31;40m$2 \033[0m" ;;
                vert) TEXT="\033[1;32;40m$2 \033[0m" ;;
                jaune) TEXT="\033[1;33;40m$2 \033[0m" ;;
                bleu) TEXT="\033[1;34;40m$2 \033[0m" ;;
                magenta) TEXT="\033[1;35;40m$2 \033[0m" ;;
                cyan) TEXT="\033[1;36;40m$2 \033[0m" ;;
                blanc) TEXT="\033[1;37;40m$2 \033[0m" ;;
                *) TEXT="$1" ;;
        esac
        # pas de couleur en mode quiet
        if [[ "${QUIET}" == "yes" ]];then
          case $1 in
                noir) TEXT="$2" ;;
                rouge) TEXT="$2" ;;
                vert) TEXT="$2" ;;
                jaune) TEXT="$2" ;;
                bleu) TEXT="$2" ;;
                magenta) TEXT="$2" ;;
                cyan) TEXT="$2" ;;
                blanc) TEXT="$2" ;;
                *) TEXT="$1" ;;
          esac
        fi

        if [ ${OS_SYSTEM} == "Linux" ] ; then
                OPTION="-e"
        fi

        echo ${OPTION} "${TEXT}"
}


#--------
#- Usage
#--------

usage()
{
println rouge "Syntax ERROR"
println jaune "Usage: $(basename ${0}) action element_to_manage (+ Websphere product in option) (+ quiet)"
println jaune "-------------------------------------------------------------"
println " - actions available: "
println "          - list"
println "          - stop"
println "          - start"
println "          - status"
println "          - status_ref (get status and define it as reference status"
println "          - start_ref (start only if reference status is not 'STOPPED')"
println "          - restart"
println jaune "-------------------------------------------------------------"
println " - element_to_manage available: "
println "          - sa-xxxxx_xxxxx (Specify the application server name)"
println "          - all_sa_wlc (all application servers Liberty Core)"
println "          - all_sa_wlb (all application servers Liberty Base)"
println "          - all_sa_wba (all application servers Was Base)"
println "          - all_sa_wnd (all application servers Was ND)"
println "          - all_sa (all application servers on all products)"
println "          - nodeagent(_WAS_instance) (WAS ND Nodeagent with version in option if more than one)"
println "          - dmgr(_WAS_instance) (WAS ND DMGR with version in option if more than one)"
println "          - admserver(_WAS_instance) (WAS Base Admserver with version in option if more than one)"
println jaune "-------------------------------------------------------------"
println " - Websphere product[optionnal when sa name is specified]:"
println "          - wlb (Was Liberty Base)"
println "          - wlc (Was Liberty Core)"
println "          - wba (Was Base)"
println "          - wnd (Was ND)"
println jaune "-------------------------------------------------------------"
println " - quiet[optionnal]: don't display \"Please wait..\" messages"
println jaune "-------------------------------------------------------------"

println ""
println jaune "Examples:"
println " $(basename ${0}) stop sa-12345_sampl_tst-prez-1"
println " $(basename ${0}) status all_sa_wlc"
println " $(basename ${0}) start sa-12345_sampl_tst-prez-1 wlc"
println ""
exit 1
}

# Check was user

id was 1>/dev/null 2>&1
if [ $? -ne 0 ];then
  println jaune " WARNING - was user not found"
  println jaune "Only the list function is available"
fi

#------------
#- Functions
#------------

check_dmgr(){
# Check if dmgradmin is installed
dmgr_cmd="No"
ls /apps/WebSphere${WND_VI}/profiles/dmgr/bin/dmgradmin 1>/dev/null 2>&1
if [ $? -eq 0 ];then
  dmgr_cmd="/apps/WebSphere${WND_VI}/profiles/dmgr/bin/dmgradmin"
fi
}

check_dmgr_status(){

DMGR_STATUS="Unknown"
if [[ "${OS_SYSTEM}" != "Linux" ]];then
  DMGR_STATE=$(${SU_USER} "${dmgr_cmd} list" | while read line; do echo "$line \c"; done | sed $'s/ADMU/,ADMU/g' | tr "," "\n"  | grep '\"dmgr')
else
  DMGR_STATE=$(${SU_USER} "${dmgr_cmd} list" | while read line; do echo -n "$line "; done | sed $'s/ADMU/\\\nADMU/g' | grep '\"dmgr')
fi
echo "$DMGR_STATE" | grep 'appears to be stopped' 1>/dev/null 2>&1
if [ $? -eq 0 ];then
  DMGR_STATUS="STOPPED"
  DMGR_STATUS_MINU="stopped"
else
  echo "$DMGR_STATE" | grep 'is STARTED' 1>/dev/null 2>&1
  if [ $? -eq 0 ];then
    DMGR_STATUS="STARTED"
    DMGR_STATUS_MINU="started"
  fi
fi
}

check_wasadmin_ND(){
# Check if wasadmin is installed for WAS ND operations
wasadmin_ND_cmd="No"
ls /apps/WebSphere${WND_VI}/profiles/node/bin/wasadmin 1>/dev/null 2>&1
if [ $? -eq 0 ];then
  wasadmin_ND_cmd="/apps/WebSphere${WND_VI}/profiles/node/bin/wasadmin"
fi
}

check_nodeagent_status(){
NODEAGENT_STATUS="Unknown"
NODEAGENT_STATE=$(${SU_USER} "${wasadmin_ND_cmd} listPid" | grep ^nodeagent)
echo "$NODEAGENT_STATE" | grep 'Not Running' 1>/dev/null 2>&1
if [ $? -eq 0 ];then
  NODEAGENT_STATUS="STOPPED"
  NODEAGENT_STATUS_MINU="stopped"
else
  NODEAGENT_PID=$(echo "$NODEAGENT_STATE" | grep -w ^nodeagent | awk '{print$2}')
  if [ "$NODEAGENT_PID" != ""  ];then
    NODEAGENT_STATUS="STARTED"
    NODEAGENT_STATUS_MINU="started"
  fi
fi
}


check_wasadmin_Base(){
# Check if wasadmin is installed for WAS Base operations
wasadmin_Base_cmd="No"
ls /apps/WebSphere${WBA_VI}/profiles/svr/bin/wasadmin 1>/dev/null 2>&1
if [ $? -eq 0 ];then
  wasadmin_Base_cmd="/apps/WebSphere${WBA_VI}/profiles/svr/bin/wasadmin"
fi
}

check_admserver_status(){
ADMSERVER_STATUS="Unknown"
if [[ "${OS_SYSTEM}" != "Linux" ]];then
  ADMSERVER_STATE=$(${SU_USER} "${wasadmin_Base_cmd} list" | while read line; do echo "$line \c"; done | sed $'s/ADMU/,ADMU/g' | tr "," "\n"  | grep '\"admserver')
else
  ADMSERVER_STATE=$(${SU_USER} "${wasadmin_Base_cmd} list" | while read line; do echo -n "$line "; done | sed $'s/ADMU/\\\nADMU/g' | grep '\"admserver')
fi
echo "$ADMSERVER_STATE" | grep 'appears to be stopped' 1>/dev/null 2>&1

if [ $? -eq 0 ];then
  ADMSERVER_STATUS="STOPPED"
  ADMSERVER_STATUS_MINU="stopped"
else
  echo "$ADMSERVER_STATE" | grep 'is STARTED' 1>/dev/null 2>&1
  if [ $? -eq 0 ];then
    ADMSERVER_STATUS="STARTED"
    ADMSERVER_STATUS_MINU="started"
  fi
fi
}

check_sa_WLC_status(){
SA_WLC_STATUS="Unknown"
if [ -f $dir_sa_wlc/bin/status ];then
  SA_WLC_STATE=$(${SU_USER} $dir_sa_wlc/bin/status 2>/dev/null)
  echo "$SA_WLC_STATE" | grep 'not running' 1>/dev/null 2>&1
  if [ $? -eq 0 ];then
    SA_WLC_STATUS="STOPPED"
    SA_WLC_STATUS_MINU="stopped"
  else
    echo "$SA_WLC_STATE" | grep 'is running' 1>/dev/null 2>&1
    if [ $? -eq 0 ];then
      SA_WLC_STATUS="STARTED"
      SA_WLC_STATUS_MINU="started"
    fi
  fi
fi
}

check_sa_WLB_status(){
SA_WLB_STATUS="Unknown"
if [ -f $dir_sa_wlb/bin/status ];then
  SA_WLB_STATE=$(${SU_USER} $dir_sa_wlb/bin/status 2>/dev/null)
  echo "$SA_WLB_STATE" | grep 'not running' 1>/dev/null 2>&1
  if [ $? -eq 0 ];then
    SA_WLB_STATUS="STOPPED"
    SA_WLB_STATUS_MINU="stopped"
  else
    echo "$SA_WLB_STATE" | grep 'is running' 1>/dev/null 2>&1
    if [ $? -eq 0 ];then
      SA_WLB_STATUS="STARTED"
      SA_WLB_STATUS_MINU="started"
    fi
  fi
fi
}

check_sa_ND_status(){
SA_ND_STATUS="Unknown"
if [[ "${OS_SYSTEM}" != "Linux" ]];then
  SA_ND_STATE=$(${SU_USER} "${wasadmin_ND_cmd} list" | while read line; do echo "$line \c"; done | sed $'s/ADMU/,ADMU/g' | tr "," "\n" | grep \"${sa_wnd}\")
else
  SA_ND_STATE=$(${SU_USER} "${wasadmin_ND_cmd} list" | while read line; do echo -n "$line "; done | sed $'s/ADMU/\\\nADMU/g' | grep \"${sa_wnd}\")
fi
echo "$SA_ND_STATE" | grep 'appears to be stopped' 1>/dev/null 2>&1
if [ $? -eq 0 ];then
  SA_ND_STATUS="STOPPED"
  SA_ND_STATUS_MINU="stopped"
else
  echo "$SA_ND_STATE" | grep 'is STARTED' 1>/dev/null 2>&1
  if [ $? -eq 0 ];then
    SA_ND_STATUS="STARTED"
    SA_ND_STATUS_MINU="started"
  else
    echo "$SA_ND_STATE" | grep ADMU[0-9][0-9][0-9][0-9]E: 1>/dev/null 2>&1
    if [ $? -eq 0 ];then
      SA_ND_STATUS="KO"
      SA_ND_STATUS_MINU="ko"
    fi
  fi
fi
}

check_sa_Base_status(){
SA_BA_STATUS="Unknown"
if [[ "${OS_SYSTEM}" != "Linux" ]];then
  SA_BA_STATE=$(${SU_USER} "${wasadmin_Base_cmd} list" | while read line; do echo "$line \c"; done | sed $'s/ADMU/,ADMU/g' | tr "," "\n"  | grep \"${sa_wba}\")
else
  SA_BA_STATE=$(${SU_USER} "${wasadmin_Base_cmd} list" | while read line; do echo -n "$line "; done | sed $'s/ADMU/\\\nADMU/g' | grep \"${sa_wba}\")
fi
echo "$SA_BA_STATE" | grep 'appears to be stopped' 1>/dev/null 2>&1
if [ $? -eq 0 ];then
  SA_BA_STATUS="STOPPED"
  SA_BA_STATUS_MINU="stopped"
else
  echo "$SA_BA_STATE" | grep 'is STARTED' 1>/dev/null 2>&1
  if [ $? -eq 0 ];then
    SA_BA_STATUS="STARTED"
    SA_BA_STATUS_MINU="started"
  fi
fi
}


#--------
#- MAIN
#--------

if [[ "${operation}" != "stop" && "${operation}" != "start" && "${operation}" != "status" && "${operation}" != "list" && "${operation}" != "status_ref" && "${operation}" != "start_ref" && "${operation}" != "restart" ]];then
  usage
fi

if [[ "${element}" == "all_sa_wlc" ]];then
  element="sa*"
  web_product="wlc"
  if [[ "${operation}" == "list" ]];then
    operation="list_sa"
  fi
elif [[ "${element}" == "all_sa_wlb" ]];then
  element="sa*"
  web_product="wlb"
  if [[ "${operation}" == "list" ]];then
    operation="list_sa"
  fi
elif [[ "${element}" == "all_sa_wba" ]];then
  element="sa*"
  element_wba="*"
  web_product="wba"
  if [[ "${operation}" == "list" ]];then
    operation="list_sa"
  fi
elif [[ "${element}" == "all_sa_wnd" ]];then
  element="sa*"
  element_wnd="*"
  web_product="wnd"
  if [[ "${operation}" == "list" ]];then
    operation="list_sa"
  fi
elif [[ "${element}" == "all_sa" ]];then
  element="sa*"
  element_wba="*"
  element_wnd="*"
  if [[ "${operation}" == "list" ]];then
    operation="list_sa"
  fi
elif echo "${element}" | grep ^dmgr >/dev/null;then
  if [[ "${element}" != "dmgr" ]];then
    WND_VI=$(echo "${element}" | awk -F "_" '{print$2}')
    element="dmgr"
  fi
  web_product="wnd"
elif echo "${element}" | grep ^nodeagent >/dev/null;then
  if [[ "${element}" != "nodeagent" ]];then
    WND_VI=$(echo "${element}" | awk -F "_" '{print$2}')
    element="nodeagent"
  fi
  web_product="wnd"
elif echo "${element}" | grep ^admserver >/dev/null;then
  if [[ "${element}" != "admserver" ]];then
    WBA_VI=$(echo "${element}" | awk -F "_" '{print$2}')
    element="admserver"
  fi
  web_product="wba"
else
  echo "${element}" | grep -v '^sw-' 1>/dev/null 2>&1
  if [ $? == 0 ];then
    element_wba=${element}
    element_wnd=${element}
    if [[ "${operation}" == "list" ]];then
      operation="list_sa"
    fi
  else
    usage
  fi
fi

if [[ "${web_product}" != "" && "${web_product}" != "wlc" && "${web_product}" != "wlb" && "${web_product}" != "wba" && "${web_product}" != "wnd" ]];then
  usage
fi

#------------------------------------------------------------
#- Detection des produits installes et recuperation du WAS_VI
#------------------------------------------------------------

if [[ "${web_product}" != "wlb" && "${web_product}" != "wba" && "${web_product}" != "wnd" ]];then
  find /apps/WebSphere*/ -name LibertyCore -type d 2>/dev/null | grep LibertyCore 1>/dev/null 2>&1
  if [ $? == 0 ];then
    WLC_VI=$(find /apps/WebSphere*/ -name LibertyCore -type d 2>/dev/null | awk -F"/" '{print $3}' | sed -e s/WebSphere//)
  else
    println jaune "Liberty Core product not installed"
  fi
fi

if [[ "${web_product}" != "wlc" && "${web_product}" != "wba" && "${web_product}" != "wnd" ]];then
  find /apps/WebSphere*/ -name LibertyBase -type d 2>/dev/null | grep LibertyBase 1>/dev/null 2>&1
  if [ $? == 0 ];then
    WLB_VI=$(find /apps/WebSphere*/ -name LibertyBase -type d 2>/dev/null | awk -F"/" '{print $3}' | sed -e s/WebSphere//)
  else
    println jaune "Liberty Base product not installed"
  fi
fi
 
if [[ "${WND_VI}" != "No" ]];then
  WND="KO"
  for product in $(ls /apps/WebSphere${WND_VI}/AppServer*/bin/versionInfo.sh);do
    $product | grep ND | grep installed 1>/dev/null
    if [ $? == 0 ];then
      WND="OK"
      break
    fi
  done
  if [[ "${WND}" == "KO" ]];then
    println jaune "WAS ND product not installed with this profile (${WND_VI})"
    exit
  fi
fi
if [[ "${WBA_VI}" != "No" ]];then
  WBA="KO"
  for product in $(ls /apps/WebSphere${WBA_VI}/AppServer*/bin/versionInfo.sh);do
    $product | grep BASE | grep installed 1>/dev/null
    if [ $? == 0 ];then
      WBA="OK"
      break
    fi
  done
  if [[ "${WBA}" == "KO" ]];then
    println jaune "WAS BASE product not installed with this profile (${WBA_VI})"
    exit 1
  fi
fi

if [[ "${WBA_VI}" == "No" && "${WND_VI}" == "No" ]];then
  if [[ "${web_product}" == "wnd" || "${web_product}" == "wba" || "${web_product}" == "" ]];then
    if [[ "${web_product}" != "wba" ]];then
      for product in $(ls /apps/WebSphere*/AppServer*/bin/versionInfo.sh);do
        $product | grep ND | grep installed 1>/dev/null
        if [ $? == 0 ];then
          if [[ "${WND_VI}" != "No" ]];then
            if [[ "${element}" == "nodeagent" || "${element}" == "dmgr" ]];then
              println jaune "More than one WAS ND instance has been detected. You must provide the _WAS_instance in the command (see usage)"
              exit 1
            fi
          fi
          WND_VI=$(echo $product | awk -F"/" '{print $3}' | sed -e s/WebSphere//)
        fi
      done
      if [[ "${WND_VI}" == "No" ]];then
        println jaune "WAS ND product not installed"
      fi
    fi
    if [[ "${web_product}" != "wnd" ]];then
      for product in $(ls /apps/WebSphere*/AppServer*/bin/versionInfo.sh);do
        $product | grep BASE | grep installed  1>/dev/null
        if [ $? == 0 ];then
          if [[ "${WBA_VI}" != "No" ]];then
            if [[ "${element}" == "admserver" ]];then
              println jaune "More than one WAS Base instance has been detected. You must provide the _WAS_instance in the command (see usage)"
              exit 1
            fi
          fi
          WBA_VI=$(echo $product | awk -F"/" '{print $3}' | sed -e s/WebSphere//)
        fi
      done
      if [[ "${WBA_VI}" == "No" ]];then
        println jaune "WAS Base product not installed"
      fi
    fi
  fi
fi
#-------------------------------
#- Recherche et Gestion des JVM
#-------------------------------


# Liberty Core

if [[ "${WLC_VI}" != "No" ]];then
  find /applis/*/wlc/*/servers/ -name ${element} -print 2>/dev/null | grep -v temp | grep -v pid | awk -F"/" '{print $5 }' 1>/dev/null 2>&1
  if [ $? -eq 0 ];then
    if [[ "${operation}" == "list_sa" ]];then
      verif_jvm=$(find /applis/*/wlc/ -name ${element} -print 2>/dev/null | grep -v temp | grep -v servers | grep -v pid | awk -F"/" '{print $5 }')
      if [[ "${verif_jvm}" == "" ]];then 
        println jaune "WLC: No JVM found on Liberty Core"
      else
        for sa_wlc in $(find /applis/*/wlc/ -name ${element} -print 2>/dev/null | grep -v temp | grep -v servers | grep -v pid | awk -F"/" '{print $5 }');do
          println cyan "WLC: $(println vert "$sa_wlc")"
        done
      fi
    elif [[ "${operation}" == "status" || "${operation}" == "status_ref" ]];then
      for dir_sa_wlc in $(find /applis/*/wlc/*/servers/ -name ${element} -print 2>/dev/null | grep -v temp | grep -v pid );do
        sa_wlc=$(echo $dir_sa_wlc | awk -F"/" '{print $5 }')
        check_sa_WLC_status
        if [[ "${SA_WLC_STATUS}" == "STARTED" || "${SA_WLC_STATUS}" == "STOPPED" ]];then
          [[ "${SA_WLC_STATUS}" == "STARTED" ]] && println vert "WLC: ${sa_wlc} is STARTED"
          [[ "${SA_WLC_STATUS}" == "STOPPED" ]] && println jaune "WLC: ${sa_wlc} is STOPPED"
          if [[ "${operation}" == "status_ref" ]];then
            rm -f /var/tmp/wlc_sa_ref_status_*_${sa_wlc}
            echo "${SA_WLC_STATUS}" > /var/tmp/wlc_sa_ref_status_${SA_WLC_STATUS_MINU}_${sa_wlc}
          fi
        else
          println rouge "WLC: ${sa_wlc} -ERROR: unknown status"
          RC_SA=1
        fi
      done
    elif [[ "${operation}" == "start" || "${operation}" == "start_ref" ]];then
      for dir_sa_wlc in $(find /applis/*/wlc/*/servers/ -name ${element} -print 2>/dev/null | grep -v temp | grep -v pid );do
        sa_wlc=$(echo $dir_sa_wlc | awk -F"/" '{print $5 }')
        if [[ "${operation}" == "start_ref" && -f /var/tmp/wlc_sa_ref_status_stopped_${sa_wlc} ]];then
          println jaune "WLC: ${sa_wlc} will not be started because reference status is stopped"
        else
          check_sa_WLC_status
          if [[ "${SA_WLC_STATUS}" != "STARTED" ]];then
            [[ "${QUIET}" == "no" ]] && println jaune "Starting ${sa_wlc} - Please wait..."
            if [ -f $dir_sa_wlc/bin/start ];then
              ${SU_USER} $dir_sa_wlc/bin/start 2>/dev/null | grep started >/dev/null
              if [ $? != 0 ];then
                println rouge "WLC: $sa_wlc encountered an ERROR while starting : ${SU_USER} $dir_sa_wlc/bin/start"
                RC_SA=1
              else
                println vert "WLC: $sa_wlc has been STARTED successfully"
              fi
            else
              println rouge "WLC: $sa_wlc encountered an ERROR while starting : start script not found on the server"
              RC_SA=1
            fi
          else
            println jaune "WLC: $sa_wlc is already STARTED"
          fi
        fi
      done
    elif [[ "${operation}" == "stop" ]];then
      for dir_sa_wlc in $(find /applis/*/wlc/*/servers/ -name ${element} -print 2>/dev/null | grep -v temp | grep -v pid );do
        sa_wlc=$(echo $dir_sa_wlc | awk -F"/" '{print $5 }')
        check_sa_WLC_status
        if [[ "${SA_WLC_STATUS}" != "STOPPED" ]];then
          [[ "${QUIET}" == "no" ]] && println jaune "Stopping ${sa_wlc} - Please wait..."
          if [ -f $dir_sa_wlc/bin/stop ];then
            ${SU_USER} $dir_sa_wlc/bin/stop 2>/dev/null | grep stopped >/dev/null
            if [ $? != 0 ];then
              println rouge "WLC: $sa_wlc encountered an ERROR while stopping : ${SU_USER} $dir_sa_wlc/bin/stop"
              RC_SA=1
            else
              println vert "WLC: $sa_wlc has been STOPPED successfully"
            fi
          else
            println rouge "WLC: $sa_wlc encountered an ERROR while stoppping : stop script not found on the server"
            RC_SA=1
          fi
        else
          println jaune "WLC: $sa_wlc is already STOPPED"
        fi
      done
    elif [[ "${operation}" == "restart" ]];then
      for dir_sa_wlc in $(find /applis/*/wlc/*/servers/ -name ${element} -print 2>/dev/null | grep -v temp | grep -v pid );do
        RC_STOP=0
        sa_wlc=$(echo $dir_sa_wlc | awk -F"/" '{print $5 }')
        check_sa_WLC_status
        if [[ "${SA_WLC_STATUS}" != "STOPPED" ]];then
          [[ "${QUIET}" == "no" ]] && println jaune "Stopping ${sa_wlc} - Please wait..."
          if [ -f $dir_sa_wlc/bin/stop ];then
            ${SU_USER} $dir_sa_wlc/bin/stop 2>/dev/null | grep stopped >/dev/null
            if [ $? != 0 ];then
              println rouge "WLC: $sa_wlc encountered an ERROR while stopping : ${SU_USER} $dir_sa_wlc/bin/stop"
              RC_STOP=1
              RC_SA=1
            else
              [[ "${QUIET}" == "no" ]] && println vert "WLC: $sa_wlc has been STOPPED successfully"
            fi
          else
            println rouge "WLC: $sa_wlc encountered an ERROR while stoppping : stop script not found on the server"
            RC_STOP=1
            RC_SA=1
          fi
        else
          [[ "${QUIET}" == "no" ]] && println jaune "WLC: $sa_wlc is already STOPPED"
        fi
        if [[ "${RC_STOP}" == "0" ]];then
          [[ "${QUIET}" == "no" ]] && print
          [[ "${QUIET}" == "no" ]] && println jaune "Starting ${sa_wlc} - Please wait..."
          sleep 5
          if [ -f $dir_sa_wlc/bin/start ];then
            ${SU_USER} $dir_sa_wlc/bin/start 2>/dev/null | grep started >/dev/null
            if [ $? != 0 ];then
              println rouge "WLC: $sa_wlc encountered an ERROR while starting : ${SU_USER} $dir_sa_wlc/bin/start"
              RC_SA=1
            else
              println vert "WLC: $sa_wlc has been RESTARTED successfully"
            fi
          else
            println rouge "WLC: $sa_wlc encountered an ERROR while starting : start script not found on the server"
            RC_SA=1
          fi
        fi
        [[ "${QUIET}" == "no" ]] && print
      done
    fi
  else
    println jaune "WLC: Application server not found"
  fi
fi

# Liberty Base

if [[ "${WLB_VI}" != "No" ]];then
  find /applis/*/wlb/*/servers/ -name ${element} -print 2>/dev/null | grep -v temp | grep -v pid | awk -F"/" '{print $5 }' 1>/dev/null 2>&1
  if [ $? -eq 0 ];then
    if [[ "${operation}" == "list_sa" ]];then
      verif_jvm=$(find /applis/*/wlb/ -name ${element} -print 2>/dev/null | grep -v temp | grep -v servers | grep -v pid | awk -F"/" '{print $5 }')
      if [[ "${verif_jvm}" == "" ]];then
        println jaune "WLB: No JVM found on Liberty Base"
      else
        for sa_wlb in $(find /applis/*/wlb/ -name ${element} -print 2>/dev/null | grep -v temp | grep -v servers | grep -v pid | awk -F"/" '{print $5 }');do
          println cyan "WLB: $(println vert "$sa_wlb")"
        done
      fi
    elif [[ "${operation}" == "status" || "${operation}" == "status_ref" ]];then
      for dir_sa_wlb in $(find /applis/*/wlb/*/servers/ -name ${element} -print 2>/dev/null | grep -v temp | grep -v pid );do
        sa_wlb=$(echo $dir_sa_wlb | awk -F"/" '{print $5 }')
        check_sa_WLB_status
        if [[ "${SA_WLB_STATUS}" == "STARTED" || "${SA_WLB_STATUS}" == "STOPPED" ]];then
          [[ "${SA_WLB_STATUS}" == "STARTED" ]] && println vert "WLB: ${sa_wlb} is STARTED"
          [[ "${SA_WLB_STATUS}" == "STOPPED" ]] && println jaune "WLB: ${sa_wlb} is STOPPED"
          if [[ "${operation}" == "status_ref" ]];then
            rm -f /var/tmp/wlb_sa_ref_status_*_${sa_wlb}
            echo "${SA_WLB_STATUS}" > /var/tmp/wlb_sa_ref_status_${SA_WLB_STATUS_MINU}_${sa_wlb}
          fi
        else
          println rouge "WLB: ${sa_wlb} -ERROR: unknown status"
          RC_SA=1
        fi
      done
    elif [[ "${operation}" == "start" || "${operation}" == "start_ref" ]];then
      for dir_sa_wlb in $(find /applis/*/wlb/*/servers/ -name ${element} -print 2>/dev/null | grep -v temp | grep -v pid );do
        sa_wlb=$(echo $dir_sa_wlb | awk -F"/" '{print $5 }')
        if [[ "${operation}" == "start_ref" && -f /var/tmp/wlb_sa_ref_status_stopped_${sa_wlb} ]];then
          println jaune "WLB: ${sa_wlb} will not be started because reference status is stopped"
        else
          check_sa_WLB_status
          if [[ "${SA_WLB_STATUS}" != "STARTED" ]];then
            [[ "${QUIET}" == "no" ]] && println jaune "Starting ${sa_wlb} - Please wait..."
            if [ -f $dir_sa_wlb/bin/start ];then
              ${SU_USER} $dir_sa_wlb/bin/start 2>/dev/null | grep started >/dev/null
              if [ $? != 0 ];then
                println rouge "WLB: $sa_wlb encountered an ERROR while starting : ${SU_USER} $dir_sa_wlb/bin/start"
                RC_SA=1
              else
                println vert "WLB: $sa_wlb has been STARTED successfully"
              fi
            else
              println rouge "WLB: $sa_wlb encountered an ERROR while starting : start script not found on the server"
              RC_SA=1
            fi
          else
            println jaune "WLB: $sa_wlb is already STARTED"
          fi
        fi
      done
    elif [[ "${operation}" == "stop" ]];then
      for dir_sa_wlb in $(find /applis/*/wlb/*/servers/ -name ${element} -print 2>/dev/null | grep -v temp | grep -v pid );do
        sa_wlb=$(echo $dir_sa_wlb | awk -F"/" '{print $5 }')
        check_sa_WLB_status
        if [[ "${SA_WLB_STATUS}" != "STOPPED" ]];then
          [[ "${QUIET}" == "no" ]] && println jaune "Stopping ${sa_wlb} - Please wait..."
          if [ -f $dir_sa_wlb/bin/stop ];then
            ${SU_USER} $dir_sa_wlb/bin/stop 2>/dev/null | grep stopped >/dev/null
            if [ $? != 0 ];then
              println rouge "WLB: $sa_wlb encountered an ERROR while stopping : ${SU_USER} $dir_sa_wlb/bin/stop"
              RC_SA=1
            else
              println vert "WLB: $sa_wlb has been STOPPED successfully"
            fi
          else
            println rouge "WLB: $sa_wlb encountered an ERROR while stoppping : stop script not found on the server"
            RC_SA=1
          fi
        else
          println jaune "WLB: $sa_wlb is already STOPPED"
        fi
      done
    elif [[ "${operation}" == "restart" ]];then
      for dir_sa_wlb in $(find /applis/*/wlb/*/servers/ -name ${element} -print 2>/dev/null | grep -v temp | grep -v pid );do
        RC_STOP=0
        sa_wlb=$(echo $dir_sa_wlb | awk -F"/" '{print $5 }')
        check_sa_WLB_status
        if [[ "${SA_WLB_STATUS}" != "STOPPED" ]];then
          [[ "${QUIET}" == "no" ]] && println jaune "Stopping ${sa_wlb} - Please wait..."
          if [ -f $dir_sa_wlb/bin/stop ];then
            ${SU_USER} $dir_sa_wlb/bin/stop 2>/dev/null | grep stopped >/dev/null
            if [ $? != 0 ];then
              println rouge "WLB: $sa_wlb encountered an ERROR while stopping : ${SU_USER} $dir_sa_wlb/bin/stop"
              RC_STOP=1
              RC_SA=1
            else
              [[ "${QUIET}" == "no" ]] && println vert "WLB: $sa_wlb has been STOPPED successfully"
            fi
          else
            println rouge "WLB: $sa_wlb encountered an ERROR while stoppping : stop script not found on the server"
            RC_STOP=1
            RC_SA=1
          fi
        else
          [[ "${QUIET}" == "no" ]] && println jaune "WLB: $sa_wlb is already STOPPED"
        fi
        if [[ "${RC_STOP}" == "0" ]];then
          [[ "${QUIET}" == "no" ]] && print
          [[ "${QUIET}" == "no" ]] && println jaune "Starting ${sa_wlb} - Please wait..."
          sleep 5
          if [ -f $dir_sa_wlb/bin/start ];then
            ${SU_USER} $dir_sa_wlb/bin/start 2>/dev/null | grep started >/dev/null
            if [ $? != 0 ];then
              println rouge "WLB: $sa_wlb encountered an ERROR while starting : ${SU_USER} $dir_sa_wlb/bin/start"
              RC_SA=1
            else
              println vert "WLB: $sa_wlb has been RESTARTED successfully"
            fi
          else
            println rouge "WLB: $sa_wlb encountered an ERROR while starting : start script not found on the server"
            RC_SA=1
          fi
        fi
        [[ "${QUIET}" == "no" ]] && print
      done
    fi
  else
    println jaune "WLB: Application server not found"
  fi
fi

# WAS Traditionnal (WAS BASE & ND)
if [[ "${element}" == "dmgr" ]];then
  check_dmgr
  if [[ "${dmgr_cmd}" == "No" ]];then
    if [[ "${operation}" == "list" ]];then
      println jaune "WND: DMGR binaries are missing"
      exit
    else
      println rouge "WND: DMGR binaries are missing.No DMGR operation could be done"
      exit 1
    fi
  fi
  if [[ "${operation}" == "list" ]];then
    println vert "WND: DMGR binaries are present"
    exit
  elif [[ "${operation}" == "status" || "${operation}" == "status_ref" ]];then
    check_dmgr_status
    if [[ "${DMGR_STATUS}" == "STOPPED" || "${DMGR_STATUS}" == "STARTED" ]];then
      [[ "${DMGR_STATUS}" == "STOPPED" ]] && println jaune "The Deployment Manager 'dmgr' is STOPPED"
      [[ "${DMGR_STATUS}" == "STARTED" ]] && println vert "The Deployment Manager 'dmgr' is STARTED"
      if [[ "${operation}" == "status_ref" ]];then
        rm -f /var/tmp/dmgr_ref_status_*_${WND_VI}
        echo "${DMGR_STATUS}" > /var/tmp/dmgr_ref_status_${DMGR_STATUS_MINU}_${WND_VI}
      fi
      exit
    else
      println rouge "ERROR - DMGR Unknown state. Check manually"
      exit 1
    fi
  elif [[ "${operation}" == "stop" ]];then
    [[ "${QUIET}" == "no" ]] && println jaune "Stopping DMGR - Please wait..."
    check_dmgr_status
    if [[ "${DMGR_STATUS}" == "STOPPED" ]];then
      println jaune 'The Deployment Manager "dmgr" is already STOPPED'
      exit
    else
      ${SU_USER} "${dmgr_cmd} stop" 1>/dev/null 2>&1
      if [ $? -eq 0 ];then
        check_dmgr_status
        if [[ "${DMGR_STATUS}" == "STOPPED" ]];then
          println vert 'The Deployment Manager "dmgr" has been STOPPED successfully'
          exit
        else
          println rouge "The Deployment Manager "dmgr" seems still STARTED. Check manually"
          exit 1
        fi
      else
        println rouge "ERROR while stopping the DMGR. Check manually"
        exit 1
      fi
    fi
  elif [[ "${operation}" == "start" || "${operation}" == "start_ref" ]];then
    if [[ "${operation}" == "start_ref" && -f /var/tmp/dmgr_ref_status_stopped_${WND_VI} ]];then
      println jaune "The Deployment Manager 'dmgr' will not be started because reference status is stopped"
    else
      [[ "${QUIET}" == "no" ]] && println jaune "Starting DMGR - Please wait..."
      DMGR_START=$(${SU_USER} "${dmgr_cmd} start")
      echo "$DMGR_START" | grep 'Starting Deployment Manager' 1>/dev/null 2>&1
      if [ $? -eq 0 ];then
        compt=0
        while [ ${compt} -lt 12 -a "${DMGR_STATUS}" != "STARTED" ];do
          compt=$((${compt}+1))
          sleep 10
          check_dmgr_status
        done
        if [[ "${DMGR_STATUS}" == "STARTED" ]];then
          println vert 'The Deployment Manager "dmgr" has been STARTED successfully'
          exit
        elif [[ "${DMGR_STATUS}" == "STOPPED" ]];then
          println rouge 'ERROR - The Deployment Manager "dmgr" is still STOPPED. Check manually'
          exit 1
        else
          println rouge "ERROR - DMGR Unknown state. Check manually"
          exit 1
        fi
      else
        echo "$DMGR_START" | grep 'is already running' 1>/dev/null 2>&1
        if [ $? -eq 0 ];then
          println jaune 'The Deployment Manager "dmgr" is already STARTED'
          exit
        else
          println rouge "ERROR while starting the DMGR. Check manually"
          exit 1
        fi
      fi
    fi
  elif [[ "${operation}" == "restart" ]];then
    [[ "${QUIET}" == "no" ]] && println jaune "Stopping DMGR - Please wait..."
    check_dmgr_status
    if [[ "${DMGR_STATUS}" == "STOPPED" ]];then
      [[ "${QUIET}" == "no" ]] && println jaune 'The Deployment Manager "dmgr" is already STOPPED'
    else
      ${SU_USER} "${dmgr_cmd} stop" 1>/dev/null 2>&1
      if [ $? -eq 0 ];then
        check_dmgr_status
        if [[ "${DMGR_STATUS}" == "STOPPED" ]];then
          [[ "${QUIET}" == "no" ]] && println vert 'The Deployment Manager "dmgr" has been STOPPED successfully'
        else
          println rouge "The Deployment Manager "dmgr" seems still STARTED. Check manually"
          exit 1
        fi
      else
        println rouge "ERROR while stopping the DMGR. Check manually"
        exit 1
      fi
    fi
    [[ "${QUIET}" == "no" ]] && println jaune "Starting DMGR - Please wait..."
    sleep 5
    DMGR_START=$(${SU_USER} "${dmgr_cmd} start")
    echo "$DMGR_START" | grep 'Starting Deployment Manager' 1>/dev/null 2>&1
    if [ $? -eq 0 ];then
      compt=0
      while [ ${compt} -lt 12 -a "${DMGR_STATUS}" != "STARTED" ];do
        compt=$((${compt}+1))
        sleep 10
        check_dmgr_status
      done
      if [[ "${DMGR_STATUS}" == "STARTED" ]];then
        println vert 'The Deployment Manager "dmgr" has been RESTARTED successfully'
        exit
      elif [[ "${DMGR_STATUS}" == "STOPPED" ]];then
        println rouge 'ERROR - The Deployment Manager "dmgr" is still STOPPED. Check manually'
        exit 1
      else
        println rouge "ERROR - DMGR Unknown state. Check manually"
        exit 1
      fi
    else
      println rouge "ERROR while starting the DMGR. Check manually"
      exit 1
    fi
  fi
fi

if [[ "${element}" == "admserver" ]];then
  check_wasadmin_Base
  if [[ "${wasadmin_Base_cmd}" == "No" ]];then
    println rouge "WBA: wasadmin binaries are missing"
    exit 1
  fi
  if [[ "${operation}" == "list" ]];then
    println vert "WBA: wasadmin binaries are present"
    exit
  elif [[ "${operation}" == "status" || "${operation}" == "status_ref" ]];then
    check_admserver_status
    if [[ "${ADMSERVER_STATUS}" == "STOPPED" || "${ADMSERVER_STATUS}" == "STARTED" ]];then
      [[ "${ADMSERVER_STATUS}" == "STOPPED" ]] && println jaune "The Admin server 'admserver' is STOPPED"
      [[ "${ADMSERVER_STATUS}" == "STARTED" ]] && println vert "The Admin server 'admserver' is STARTED"
      if [[ "${operation}" == "status_ref" ]];then
        rm -f /var/tmp/admserver_ref_status_*_${WBA_VI}
        echo "${ADMSERVER_STATUS}" > /var/tmp/admserver_ref_status_${ADMSERVER_STATUS_MINU}_${WBA_VI}
      fi
      exit
    else
      println rouge "ERROR - admserver Unknown state. Check manually"
      exit 1
    fi
  elif [[ "${operation}" == "stop" ]];then
    [[ "${QUIET}" == "no" ]] && println jaune "Stopping Admserver - Please wait..."
    check_admserver_status
    if [[ "${ADMSERVER_STATUS}" == "STOPPED" ]];then
      println jaune 'The Admin server "admserver" is already STOPPED'
      exit
    else
      ${SU_USER} "${wasadmin_Base_cmd} stopAdmin" 1>/dev/null 2>&1
      if [ $? -eq 0 ];then
        check_admserver_status
        if [[ "${ADMSERVER_STATUS}" == "STOPPED" ]];then
          println vert 'The Admin server "admserver" has been STOPPED successfully'
          exit
        else
          println rouge 'The Admin server "admserver" seems still STARTED. Check manually'
          exit 1
        fi
      else
        println rouge "ERROR while stopping the admserver. Check manually"
        exit 1
      fi
    fi
  elif [[ "${operation}" == "start" || "${operation}" == "start_ref" ]];then
    if [[ "${operation}" == "start_ref" && -f /var/tmp/admserver_ref_status_stopped_${WBA_VI} ]];then
      println jaune "admserver will not be started because reference status is stopped"
    else
      [[ "${QUIET}" == "no" ]] && println jaune "Starting Admserver - Please wait..."
      ADMSERVER_START=$(${SU_USER} "${wasadmin_Base_cmd} startAdmin")
      echo "$ADMSERVER_START" | grep 'Starting admin Base Server' 1>/dev/null 2>&1
      if [ $? -eq 0 ];then
        compt=0
        while [ ${compt} -lt 12 -a "${ADMSERVER_STATUS}" != "STARTED" ];do
          compt=$((${compt}+1))
          sleep 10
          check_admserver_status
        done
        if [[ "${ADMSERVER_STATUS}" == "STARTED" ]];then
          println vert 'The Admin server "admserver" has been STARTED successfully'
          exit
        elif [[ "${ADMSERVER_STATUS}" == "STOPPED" ]];then
          println rouge 'ERROR - The Admin server "admserver" is still STOPPED. Check manually'
          exit 1
        else
          println rouge "ERROR - admserver Unknown state. Check manually"
          exit 1
        fi
      else
        echo "$ADMSERVER_START" | grep 'is already running' 1>/dev/null 2>&1
        if [ $? -eq 0 ];then
          println jaune 'The Admin server "admserver" is already STARTED'
          exit
        else
          println rouge "ERROR while starting the admserver. Check manually"
          exit 1
        fi
      fi
    fi
  elif [[ "${operation}" == "restart" ]];then
    [[ "${QUIET}" == "no" ]] && println jaune "Stopping Admserver - Please wait..."
    check_admserver_status
    if [[ "${ADMSERVER_STATUS}" == "STOPPED" ]];then
      [[ "${QUIET}" == "no" ]] && println jaune 'The Admin server "admserver" is already STOPPED'
    else
      ${SU_USER} "${wasadmin_Base_cmd} stopAdmin" 1>/dev/null 2>&1
      if [ $? -eq 0 ];then
        check_admserver_status
        if [[ "${ADMSERVER_STATUS}" == "STOPPED" ]];then
          [[ "${QUIET}" == "no" ]] && println vert 'The Admin server "admserver" has been STOPPED successfully'
        else
          println rouge 'The Admin server "admserver" seems still STARTED. Check manually'
          exit 1
        fi
      else
        println rouge "ERROR while stopping the admserver. Check manually"
        exit 1
      fi
    fi
    [[ "${QUIET}" == "no" ]] && println jaune "Starting Admserver - Please wait..."
    sleep 5
    ADMSERVER_START=$(${SU_USER} "${wasadmin_Base_cmd} startAdmin")
    echo "$ADMSERVER_START" | grep 'Starting admin Base Server' 1>/dev/null 2>&1
    if [ $? -eq 0 ];then
      compt=0
      while [ ${compt} -lt 12 -a "${ADMSERVER_STATUS}" != "STARTED" ];do
        compt=$((${compt}+1))
        sleep 10
        check_admserver_status
      done
      if [[ "${ADMSERVER_STATUS}" == "STARTED" ]];then
        println vert 'The Admin server "admserver" has been RESTARTED successfully'
        exit
      elif [[ "${ADMSERVER_STATUS}" == "STOPPED" ]];then
        println rouge 'ERROR - The Admin server "admserver" is still STOPPED. Check manually'
        exit 1
      else
        println rouge "ERROR - admserver Unknown state. Check manually"
        exit 1
      fi
    else
      println rouge "ERROR while starting the admserver. Check manually"
      exit 1
    fi
  fi
fi


if [[ "${element}" == "nodeagent" ]];then
  check_wasadmin_ND
  if [[ "${wasadmin_ND_cmd}" == "No" ]];then
    println rouge "WND: wasadmin binaries to check nodeagent are missing"
    exit 1
  fi
  if [[ "${operation}" == "list" ]];then
    println vert "WND: wasadmin binaries to check nodeadgent are present"
    exit
  elif [[ "${operation}" == "status" || "${operation}" == "status_ref" ]];then
    check_nodeagent_status
    if [[ "${NODEAGENT_STATUS}" == "STOPPED" || "${NODEAGENT_STATUS}" == "STARTED" ]];then
      [[ "${NODEAGENT_STATUS}" == "STOPPED" ]] && println jaune "The nodeagent is STOPPED"
      [[ "${NODEAGENT_STATUS}" == "STARTED" ]] && println vert "The nodeagent is STARTED"
      if [[ "${operation}" == "status_ref" ]];then
        rm -f /var/tmp/nodeagent_ref_status_*_${WND_VI}
        echo "${NODEAGENT_STATUS}" > /var/tmp/nodeagent_ref_status_${NODEAGENT_STATUS_MINU}_${WND_VI}
      fi
      exit
    else
      println rouge "ERROR - nodeagent Unknown state. Check manually"
      exit 1
    fi
  elif [[ "${operation}" == "stop" ]];then
    [[ "${QUIET}" == "no" ]] && println jaune "Stopping Nodeagent - Please wait..."
    check_nodeagent_status
    if [[ "${NODEAGENT_STATUS}" == "STOPPED" ]];then
      println jaune 'The nodeagent is already STOPPED'
      exit
    else
      ${SU_USER} "${wasadmin_ND_cmd} stopNode" 1>/dev/null 2>&1
      if [ $? -eq 0 ];then
        check_nodeagent_status
        if [[ "${NODEAGENT_STATUS}" == "STOPPED" ]];then
          println vert 'The nodeagent has been STOPPED successfully'
          exit
        else
          println rouge 'The nodeagent seems still STARTED. Check manually'
          exit 1
        fi
      else
        println rouge "ERROR while stopping the nodeagent. Check manually"
        exit 1
      fi
    fi
  elif [[ "${operation}" == "start" || "${operation}" == "start_ref" ]];then
    if [[ "${operation}" == "start_ref" && -f /var/tmp/nodeagent_ref_status_stopped_${WND_VI} ]];then
      println jaune "nodeagent will not be started because reference status is stopped"
    else
      [[ "${QUIET}" == "no" ]] && println jaune "Starting Nodeagent - Please wait..."
      NODEAGENT_START=$(${SU_USER} "${wasadmin_ND_cmd} startNode")
      echo "$NODEAGENT_START" | grep 'Starting Node Agent' 1>/dev/null 2>&1
      if [ $? -eq 0 ];then
        compt=0
        while [ ${compt} -lt 12 -a "${NODEAGENT_STATUS}" != "STARTED" ];do
          compt=$((${compt}+1))
          sleep 10
          check_nodeagent_status
        done
        if [[ "${NODEAGENT_STATUS}" == "STARTED" ]];then
          println vert 'The nodeagent has been STARTED successfully'
          exit
        elif [[ "${NODEAGENT_STATUS}" == "STOPPED" ]];then
          println rouge 'ERROR - The nodeagent is still STOPPED. Check manually'
          exit 1
        else
          println rouge "ERROR - nodeagent Unknown state. Check manually"
          exit 1
        fi
      else
        echo "$NODEAGENT_START" | grep 'is already running' 1>/dev/null 2>&1
        if [ $? -eq 0 ];then
          println jaune 'The nodeagent is already STARTED'
          exit
        else
          println rouge "ERROR while starting the nodeagent. Check manually"
          exit 1
        fi
      fi
    fi
  elif [[ "${operation}" == "restart" ]];then
    [[ "${QUIET}" == "no" ]] && println jaune "Stopping Nodeagent - Please wait..."
    check_nodeagent_status
    if [[ "${NODEAGENT_STATUS}" == "STOPPED" ]];then
      [[ "${QUIET}" == "no" ]] && println jaune 'The nodeagent is already STOPPED'
    else
      ${SU_USER} "${wasadmin_ND_cmd} stopNode" 1>/dev/null 2>&1
      if [ $? -eq 0 ];then
        check_nodeagent_status
        if [[ "${NODEAGENT_STATUS}" == "STOPPED" ]];then
          [[ "${QUIET}" == "no" ]] && println vert 'The nodeagent has been STOPPED successfully'
        else
          println rouge 'The nodeagent seems still STARTED. Check manually'
          exit 1
        fi
      else
        println rouge "ERROR while stopping the nodeagent. Check manually"
        exit 1
      fi
    fi
    [[ "${QUIET}" == "no" ]] && println jaune "Starting Nodeagent - Please wait..."
    sleep 5
    NODEAGENT_START=$(${SU_USER} "${wasadmin_ND_cmd} startNode")
    echo "$NODEAGENT_START" | grep 'Starting Node Agent' 1>/dev/null 2>&1
    if [ $? -eq 0 ];then
      compt=0
      while [ ${compt} -lt 12 -a "${NODEAGENT_STATUS}" != "STARTED" ];do
        compt=$((${compt}+1))
        sleep 10
        check_nodeagent_status
      done
      if [[ "${NODEAGENT_STATUS}" == "STARTED" ]];then
        println vert 'The nodeagent has been RESTARTED successfully'
        exit
      elif [[ "${NODEAGENT_STATUS}" == "STOPPED" ]];then
        println rouge 'ERROR - The nodeagent is still STOPPED. Check manually'
        exit 1
      else
        println rouge "ERROR - nodeagent Unknown state. Check manually"
        exit 1
      fi
    else
      println rouge "ERROR while starting the nodeagent. Check manually"
      exit 1
    fi
  fi
fi


if [[ ("${WND_VI}" != "No" || "${WBA_VI}" != "No") && "${operation}" != "list" ]];then
# WAS ND
  if [[ "${WND_VI}" != "No" ]];then
    ls -ltr /apps/WebSphere${WND_VI}/profiles/node/config/cells/*/nodes/*/servers/${element_wnd}/server.xml 2>/dev/null | grep -v nodeagent |grep -v ^sw- 1>/dev/null 2>&1
    if [ $? -eq 0 ];then
      if [[ "${operation}" == "list_sa" ]];then
        verif_jvm=$(ls -ltr /apps/WebSphere${WND_VI}/profiles/node/config/cells/*/nodes/*/servers/${element_wnd}/server.xml 2>/dev/null | awk -F '/' '{print$12}'| grep -v nodeagent | grep -v ^sw-)
        if [[ "${verif_jvm}" == "" ]];then
          println jaune "WND: No JVM found on WAS ND"
        else
          for sa_wnd in $(ls -ltr /apps/WebSphere${WND_VI}/profiles/node/config/cells/*/nodes/*/servers/${element}/server.xml 2>/dev/null | awk -F '/' '{print$12}' | grep ^sa- );do
            println cyan "WND: $(println vert "$sa_wnd")"
          done
          for sa_wnd in $(ls -ltr /apps/WebSphere${WND_VI}/profiles/node/config/cells/*/nodes/*/servers/${element_wnd}/server.xml 2>/dev/null | awk -F '/' '{print$12}'| grep -v nodeagent | grep -v ^sa- | grep -v ^sw- );do
            println cyan "WND: $(println vert "$sa_wnd") $(println jaune ' (does not meet the BNPP naming standards)')"
          done
        fi
      else
        # Check if wasadmin is installed for other operations
        check_wasadmin_ND
        if [[ "${wasadmin_ND_cmd}" == "No" ]];then
          println rouge "WND: wasadmin binaries are missing"
          RC_SA=1
        else
          if [[ "${operation}" == "status" || "${operation}" == "status_ref" ]];then
            for sa_wnd in $(ls -ltr /apps/WebSphere${WND_VI}/profiles/node/config/cells/*/nodes/*/servers/${element_wnd}/server.xml 2>/dev/null | awk -F '/' '{print$12}' | grep -v nodeagent | grep -v ^sw- );do
              check_sa_ND_status
              if [[ "${SA_ND_STATUS}" == "STARTED" || "${SA_ND_STATUS}" == "STOPPED" ]];then
                [[ "${SA_ND_STATUS}" == "STARTED" ]] && println vert "WND: ${sa_wnd} is STARTED"
                [[ "${SA_ND_STATUS}" == "STOPPED" ]] && println jaune "WND: ${sa_wnd} is STOPPED"
                if [[ "${operation}" == "status_ref" ]];then
                  rm -f /var/tmp/wnd_sa_ref_status_*_${sa_wnd}
                  echo "${SA_ND_STATUS}" > /var/tmp/wnd_sa_ref_status_${SA_ND_STATUS_MINU}_${sa_wnd}
                fi
              else
                println rouge "WND: ${sa_wnd} -ERROR: unknown status"
                RC_SA=1
              fi
            done
          elif [[ "${operation}" == "start" || "${operation}" == "start_ref" ]];then
            check_dmgr
            if [[ "${dmgr_cmd}" != "No" ]];then
              check_dmgr_status
              if [[ "${DMGR_STATUS}" == "STOPPED" ]];then
                [[ "${QUIET}" == "no" ]] && println jaune "Starting DMGR - Please wait..." 
                DMGR_START=$(${SU_USER} "${dmgr_cmd} start")
                echo "$DMGR_START" | grep 'Starting Deployment Manager' 1>/dev/null 2>&1
                if [ $? -eq 0 ];then
                  compt=0
                  while [ ${compt} -lt 12 -a "${DMGR_STATUS}" != "STARTED" ];do
                    compt=$((${compt}+1))
                    sleep 10
                    check_dmgr_status
                  done
                  if [[ "${DMGR_STATUS}" == "STOPPED" ]];then
                    println rouge 'ERROR - The Deployment Manager "dmgr" must be started to perform the JVM start and the startup has failed. Check manually'
                    exit 1
                  fi
                else
                  println rouge 'ERROR - The Deployment Manager "dmgr" must be started to perform the JVM start and the startup has failed. Check manually'
                  exit 1
                fi
              fi
            fi 
            for sa_wnd in $(ls -ltr /apps/WebSphere${WND_VI}/profiles/node/config/cells/*/nodes/*/servers/${element_wnd}/server.xml 2>/dev/null | awk -F '/' '{print$12}' | grep -v nodeagent | grep -v ^sw- );do
              if [[ "${operation}" == "start_ref" && -f /var/tmp/wnd_sa_ref_status_stopped_${sa_wnd} ]];then
                println jaune "WND: ${sa_wnd} will not be started because reference status is stopped"
              else
                check_sa_ND_status
                if [ "${SA_ND_STATUS}" == "STARTED" ];then
                  println jaune "WND: ${sa_wnd} is already STARTED"
                fi
                if [ "${SA_ND_STATUS}" == "STOPPED" ];then
                  [[ "${QUIET}" == "no" ]] && println jaune "Starting ${sa_wnd} - Please wait..."
                  ${SU_USER} "${wasadmin_ND_cmd} startApp ${sa_wnd}" 1>/dev/null 2>&1
                  if [ $? -eq 0 ];then
                    check_sa_ND_status
                    if [ "${SA_ND_STATUS}" != "KO" ];then
                      compt=0
                      while [ ${compt} -lt 12 -a "${SA_ND_STATUS}" != "STARTED" ];do
                        compt=$((${compt}+1))
                        sleep 10
                        check_sa_ND_status
                      done
                      if [[ "${SA_ND_STATUS}" == "STARTED" ]];then
                        println vert "WND: ${sa_wnd} has been STARTED successfully"
                      elif [[ "${SA_ND_STATUS}" == "STOPPED" ]];then
                        println rouge "WND: ERROR - ${sa_wnd} is still STOPPED. Check manually"
                        RC_SA=1
                      else
                        println rouge "WND: ${sa_wnd} -ERROR: unknown status. Check manually"
                        RC_SA=1
                      fi
                    else
                      println rouge "WND: ${sa_wnd} -ERROR while starting the Application server."
                      RC_SA=1
                    fi
                  else
                    println rouge "WND: ${sa_wnd} -ERROR while starting the Application server."
                    RC_SA=1
                  fi
                elif [ "${SA_ND_STATUS}" != "STARTED" ];then
                  println rouge "WND: ${sa_wnd} -ERROR: unknown status. Check manually"
                  RC_SA=1
                fi
              fi
            done
          elif [[ "${operation}" == "stop" ]];then
            for sa_wnd in $(ls -ltr /apps/WebSphere${WND_VI}/profiles/node/config/cells/*/nodes/*/servers/${element_wnd}/server.xml 2>/dev/null | awk -F '/' '{print$12}' | grep -v nodeagent | grep -v ^sw- );do
              check_sa_ND_status
              if [ "${SA_ND_STATUS}" == "STOPPED" ];then
                println jaune "WND: ${sa_wnd} is already STOPPED"
              fi
              if [ "${SA_ND_STATUS}" == "STARTED" ];then
                [[ "${QUIET}" == "no" ]] && println jaune "Stopping ${sa_wnd} - Please wait..."
                ${SU_USER} "${wasadmin_ND_cmd} stopApp ${sa_wnd}" 1>/dev/null 2>&1
                if [ $? -eq 0 ];then
                  compt=0
                  while [ ${compt} -lt 12 -a "${SA_ND_STATUS}" != "STOPPED" ];do
                    compt=$((${compt}+1))
                    sleep 10
                    check_sa_ND_status
                  done
                  if [[ "${SA_ND_STATUS}" == "STOPPED" ]];then
                    println vert "WND: ${sa_wnd} has been STOPPED successfully"
                  elif [[ "${SA_ND_STATUS}" == "STARTED" ]];then
                    println rouge "WND: ERROR - ${sa_wnd} is still STARTED. Check manually"
                    RC_SA=1
                  else
                    println rouge "WND: ${sa_wnd} -ERROR: unknown status. Check manually"
                    RC_SA=1
                  fi
                else
                  println rouge "WND: ${sa_wnd} -ERROR while stopping the Application server."
                  RC_SA=1
                fi
              elif [ "${SA_ND_STATUS}" != "STOPPED" ];then
                [[ "${QUIET}" == "no" ]] && println jaune "Unknown status - Force stopping ${sa_wnd} - Please wait..."
                ${SU_USER} "${wasadmin_ND_cmd} stopApp ${sa_wnd}" 1>/dev/null 2>&1
                if [ $? -eq 0 ];then
                  compt=0
                  while [ ${compt} -lt 12 -a "${SA_ND_STATUS}" != "STOPPED" ];do
                    compt=$((${compt}+1))
                    sleep 10
                    check_sa_ND_status
                  done
                  if [[ "${SA_ND_STATUS}" == "STOPPED" ]];then
                    println vert "WND: ${sa_wnd} has been STOPPED successfully"
                  elif [[ "${SA_ND_STATUS}" == "STARTED" ]];then
                    println rouge "WND: ERROR - ${sa_wnd} is still STARTED. Check manually"
                    RC_SA=1
                  else
                    println rouge "WND: ${sa_wnd} -ERROR: unknown status. Check manually"
                    RC_SA=1
                  fi
                else
                  println rouge "WND: ${sa_wnd} -ERROR while stopping the Application server."
                  RC_SA=1
                fi
              fi
            done
          elif [[ "${operation}" == "restart" ]];then
            check_dmgr
            if [[ "${dmgr_cmd}" != "No" ]];then
              check_dmgr_status
              if [[ "${DMGR_STATUS}" == "STOPPED" ]];then
                [[ "${QUIET}" == "no" ]] && println jaune "Starting DMGR - Please wait..."
                DMGR_START=$(${SU_USER} "${dmgr_cmd} start")
                echo "$DMGR_START" | grep 'Starting Deployment Manager' 1>/dev/null 2>&1
                if [ $? -eq 0 ];then
                  compt=0
                  while [ ${compt} -lt 12 -a "${DMGR_STATUS}" != "STARTED" ];do
                    compt=$((${compt}+1))
                    sleep 10
                    check_dmgr_status
                  done
                  if [[ "${DMGR_STATUS}" == "STOPPED" ]];then
                    println rouge 'ERROR - The Deployment Manager "dmgr" must be started to perform the JVM start and the startup has failed. Check manually'
                    exit 1
                  fi
                else
                  println rouge 'ERROR - The Deployment Manager "dmgr" must be started to perform the JVM start and the startup has failed. Check manually'
                  exit 1
                fi
              fi
            fi
            for sa_wnd in $(ls -ltr /apps/WebSphere${WND_VI}/profiles/node/config/cells/*/nodes/*/servers/${element_wnd}/server.xml 2>/dev/null | awk -F '/' '{print$12}' | grep -v nodeagent | grep -v ^sw- );do
              RC_STOP=0
              check_sa_ND_status
              if [ "${SA_ND_STATUS}" == "STOPPED" ];then
                [[ "${QUIET}" == "no" ]] && println jaune "WND: ${sa_wnd} is already STOPPED"
              fi
              if [ "${SA_ND_STATUS}" == "STARTED" ];then
                [[ "${QUIET}" == "no" ]] && println jaune "Stopping ${sa_wnd} - Please wait..."
                ${SU_USER} "${wasadmin_ND_cmd} stopApp ${sa_wnd}" 1>/dev/null 2>&1
                if [ $? -eq 0 ];then
                  compt=0
                  while [ ${compt} -lt 12 -a "${SA_ND_STATUS}" != "STOPPED" ];do
                    compt=$((${compt}+1))
                    sleep 10
                    check_sa_ND_status
                  done
                  if [[ "${SA_ND_STATUS}" == "STOPPED" ]];then
                    [[ "${QUIET}" == "no" ]] && println vert "WND: ${sa_wnd} has been STOPPED successfully"
                  elif [[ "${SA_ND_STATUS}" == "STARTED" ]];then
                    println rouge "WND: ERROR - ${sa_wnd} is still STARTED. Check manually"
                    RC_STOP=1
                    RC_SA=1
                  else
                    println rouge "WND: ${sa_wnd} -ERROR: unknown status. Check manually"
                    RC_STOP=1
                    RC_SA=1
                  fi
                else
                  println rouge "WND: ${sa_wnd} -ERROR while stopping the Application server."
                  RC_STOP=1
                  RC_SA=1
                fi
              elif [ "${SA_ND_STATUS}" != "STOPPED" ];then
                [[ "${QUIET}" == "no" ]] && println jaune "Unknown status - Force stopping ${sa_wnd} - Please wait..."
                ${SU_USER} "${wasadmin_ND_cmd} stopApp ${sa_wnd}" 1>/dev/null 2>&1
                if [ $? -eq 0 ];then
                  compt=0
                  while [ ${compt} -lt 12 -a "${SA_ND_STATUS}" != "STOPPED" ];do
                    compt=$((${compt}+1))
                    sleep 10
                    check_sa_ND_status
                  done
                  if [[ "${SA_ND_STATUS}" == "STOPPED" ]];then
                    [[ "${QUIET}" == "no" ]] && println vert "WND: ${sa_wnd} has been STOPPED successfully"
                  elif [[ "${SA_ND_STATUS}" == "STARTED" ]];then
                    println rouge "WND: ERROR - ${sa_wnd} is still STARTED. Check manually"
                    RC_STOP=1
                    RC_SA=1
                  else
                    println rouge "WND: ${sa_wnd} -ERROR: unknown status. Check manually"
                    RC_STOP=1
                    RC_SA=1
                  fi
                else
                  println rouge "WND: ${sa_wnd} -ERROR while stopping the Application server."
                  RC_STOP=1
                  RC_SA=1
                fi
              fi
              if [[ "${RC_STOP}" == "0" ]];then
                [[ "${QUIET}" == "no" ]] && println jaune "Starting ${sa_wnd} - Please wait..."
                sleep 5
                ${SU_USER} "${wasadmin_ND_cmd} startApp ${sa_wnd}" 1>/dev/null 2>&1
                if [ $? -eq 0 ];then
                  check_sa_ND_status
                  if [ "${SA_ND_STATUS}" != "KO" ];then
                    compt=0
                    while [ ${compt} -lt 12 -a "${SA_ND_STATUS}" != "STARTED" ];do
                      compt=$((${compt}+1))
                      sleep 10
                      check_sa_ND_status
                    done
                    if [[ "${SA_ND_STATUS}" == "STARTED" ]];then
                      println vert "WND: ${sa_wnd} has been RESTARTED successfully"
                    elif [[ "${SA_ND_STATUS}" == "STOPPED" ]];then
                      println rouge "WND: ERROR - ${sa_wnd} is still STOPPED. Check manually"
                      RC_SA=1
                    else
                      println rouge "WND: ${sa_wnd} -ERROR: unknown status. Check manually"
                      RC_SA=1
                    fi
                  else
                    println rouge "WND: ${sa_wnd} -ERROR while starting the Application server."
                    RC_SA=1
                  fi
                else
                  println rouge "WND: ${sa_wnd} -ERROR while starting the Application server."
                  RC_SA=1
                fi   
              fi
              [[ "${QUIET}" == "no" ]] && print
            done
          fi
        fi
      fi
    else
      println jaune "WND: Application server not found"
    fi
  fi

# WAS BASE

  if [[ "${WBA_VI}" != "No" ]];then
    ls -ltr /apps/WebSphere${WBA_VI}/profiles/svr/config/cells/*/nodes/*/servers/${element_wba}/server.xml 2>/dev/null | grep -v admserver | grep -v ^sw- 1>/dev/null 2>&1
    if [ $? -eq 0 ];then
      if [[ "${operation}" == "list_sa" ]];then
        verif_jvm=$(ls -ltr /apps/WebSphere${WBA_VI}/profiles/svr/config/cells/*/nodes/*/servers/${element_wba}/server.xml 2>/dev/null | awk -F '/' '{print$12}' | grep -v admserver | grep -v ^sw-)
        if [[ "${verif_jvm}" == "" ]];then
          println jaune "WBA: No JVM found on WAS Base"
        else
          for sa_wba in $(ls -ltr /apps/WebSphere${WBA_VI}/profiles/svr/config/cells/*/nodes/*/servers/${element}/server.xml 2>/dev/null | awk -F '/' '{print$12}' | grep ^sa- );do
            println cyan "WBA: $(println vert "$sa_wba")"
          done
          for sa_wba in $(ls -ltr /apps/WebSphere${WBA_VI}/profiles/svr/config/cells/*/nodes/*/servers/${element_wba}/server.xml 2>/dev/null | awk -F '/' '{print$12}' | grep -v admserver | grep -v ^sa- | grep -v ^sw- );do
            println cyan "WBA: $(println vert "$sa_wba") $(println jaune ' (does not meet the BNPP naming standards)')"
          done
        fi
      else
      # Check if wasadmin is installed for other operations
        check_wasadmin_Base
        if [[ "${wasadmin_Base_cmd}" == "No" ]];then
          println rouge "WBA: wasadmin binaries are missing"
          RC_SA=1
        else
          if [[ "${operation}" == "status" || "${operation}" == "status_ref" ]];then
            for sa_wba in $(ls -ltr /apps/WebSphere${WBA_VI}/profiles/svr/config/cells/*/nodes/*/servers/${element_wba}/server.xml 2>/dev/null | awk -F '/' '{print$12}' | grep -v admserver | grep -v ^sw- );do
              check_sa_Base_status
              if [[ "${SA_BA_STATUS}" == "STARTED" || "${SA_BA_STATUS}" == "STOPPED" ]];then
                [[ "${SA_BA_STATUS}" == "STARTED" ]] &&  println vert "WBA: ${sa_wba} is STARTED"
                [[ "${SA_BA_STATUS}" == "STOPPED" ]] &&  println jaune "WBA: ${sa_wba} is STOPPED"
                if [[ "${operation}" == "status_ref" ]];then
                  rm -f /var/tmp/wba_sa_ref_status_*_${sa_wba}
                  echo "${SA_BA_STATUS}" > /var/tmp/wba_sa_ref_status_${SA_BA_STATUS_MINU}_${sa_wba}
                fi
              else
                println rouge "WBA: ${sa_wba} -ERROR: unknown status"
                RC_SA=1
              fi
            done
          elif [[ "${operation}" == "start" || "${operation}" == "start_ref" ]];then
            for sa_wba in $(ls -ltr /apps/WebSphere${WBA_VI}/profiles/svr/config/cells/*/nodes/*/servers/${element_wba}/server.xml 2>/dev/null | awk -F '/' '{print$12}' | grep -v admserver | grep -v ^sw- );do
              if [[ "${operation}" == "start_ref" && -f /var/tmp/wba_sa_ref_status_stopped_${sa_wba} ]];then
                println jaune "WBA: ${sa_wba} will not be started because reference status is stopped"
              else
                check_sa_Base_status
                if [[ "${SA_BA_STATUS}" == "STARTED" ]];then
                  println jaune "WBA: ${sa_wba} is already STARTED"
                elif [[ "${SA_BA_STATUS}" == "STOPPED" ]];then
                  [[ "${QUIET}" == "no" ]] && println jaune "Starting ${sa_wba} - Please wait..."
                  ${SU_USER} "${wasadmin_Base_cmd} startApp ${sa_wba}" 1>/dev/null 2>&1
                  if [ $? -eq 0 ];then
                    compt=0
                    while [ ${compt} -lt 12 -a "${SA_BA_STATUS}" != "STARTED" ];do
                      compt=$((${compt}+1))
                      sleep 10
                      check_sa_Base_status
                    done
                    if [[ "${SA_BA_STATUS}" == "STARTED" ]];then
                      println vert "WBA: ${sa_wba} has been STARTED successfully"
                    elif [[ "${SA_BA_STATUS}" == "STOPPED" ]];then
                      println rouge "WBA: ERROR - ${sa_wba} is still STOPPED. Check manually"
                      RC_SA=1
                    else
                      println rouge "WBA: ${sa_wba} -ERROR: unknown status. Check manually"
                      RC_SA=1
                    fi
                  else
                    println rouge "WBA: ${sa_wba} -ERROR while starting the Application server."
                    RC_SA=1
                  fi
                else
                  println rouge "WBA: ${sa_wba} -ERROR: unknown status. Check manually"
                  RC_SA=1
                fi
              fi
            done
          elif [[ "${operation}" == "stop" ]];then
            for sa_wba in $(ls -ltr /apps/WebSphere${WBA_VI}/profiles/svr/config/cells/*/nodes/*/servers/${element_wba}/server.xml 2>/dev/null | awk -F '/' '{print$12}' | grep -v admserver | grep -v ^sw- );do
              check_sa_Base_status
              if [ "${SA_BA_STATUS}" == "STOPPED" ];then
                println jaune "WBA: ${sa_wba} is already STOPPED"
              elif [ "${SA_BA_STATUS}" == "STARTED" ];then
                [[ "${QUIET}" == "no" ]] && println jaune "Stopping ${sa_wba} - Please wait..."
                ${SU_USER} "${wasadmin_Base_cmd} stopApp ${sa_wba}" 1>/dev/null 2>&1
                if [ $? -eq 0 ];then
                  compt=0
                  while [ ${compt} -lt 12 -a "${SA_BA_STATUS}" != "STOPPED" ];do
                    compt=$((${compt}+1))
                    sleep 10
                    check_sa_Base_status
                  done
                  if [[ "${SA_BA_STATUS}" == "STOPPED" ]];then
                    println vert "WBA: ${sa_wba} has been STOPPED successfully"
                  elif [[ "${SA_BA_STATUS}" == "STARTED" ]];then
                    println rouge "WBA: ERROR - ${sa_wba} is still STARTED. Check manually"
                    RC_SA=1
                  else
                    println rouge "WBA: ${sa_wba} -ERROR: unknown status. Check manually"
                    RC_SA=1
                  fi
                else
                  println rouge "WBA: ${sa_wba} -ERROR while stopping the Application server."
                  RC_SA=1
                fi
              else
                println rouge "WBA: ${sa_wba} -ERROR: unknown status. Check manually"
                RC_SA=1
              fi
            done
          elif [[ "${operation}" == "restart" ]];then
            for sa_wba in $(ls -ltr /apps/WebSphere${WBA_VI}/profiles/svr/config/cells/*/nodes/*/servers/${element_wba}/server.xml 2>/dev/null | awk -F '/' '{print$12}' | grep -v admserver | grep -v ^sw- );do
              RC_STOP=0
              check_sa_Base_status
              if [ "${SA_BA_STATUS}" == "STOPPED" ];then
                [[ "${QUIET}" == "no" ]] && println jaune "WBA: ${sa_wba} is already STOPPED"
              elif [ "${SA_BA_STATUS}" == "STARTED" ];then
                [[ "${QUIET}" == "no" ]] && println jaune "Stopping ${sa_wba} - Please wait..."
                ${SU_USER} "${wasadmin_Base_cmd} stopApp ${sa_wba}" 1>/dev/null 2>&1
                if [ $? -eq 0 ];then
                  compt=0
                  while [ ${compt} -lt 12 -a "${SA_BA_STATUS}" != "STOPPED" ];do
                    compt=$((${compt}+1))
                    sleep 10
                    check_sa_Base_status
                  done
                  if [[ "${SA_BA_STATUS}" == "STOPPED" ]];then
                    [[ "${QUIET}" == "no" ]] && println vert "WBA: ${sa_wba} has been STOPPED successfully"
                  elif [[ "${SA_BA_STATUS}" == "STARTED" ]];then
                    println rouge "WBA: ERROR - ${sa_wba} is still STARTED. Check manually"
                    RC_STOP=1
                    RC_SA=1
                  else
                    println rouge "WBA: ${sa_wba} -ERROR: unknown status. Check manually"
                    RC_STOP=1
                    RC_SA=1
                  fi
                else
                  println rouge "WBA: ${sa_wba} -ERROR while stopping the Application server."
                  RC_STOP=1
                  RC_SA=1
                fi
              else
                println rouge "WBA: ${sa_wba} -ERROR: unknown status. Check manually"
                RC_STOP=1
                RC_SA=1
              fi
              if [[ "${RC_STOP}" == "0" ]];then
                [[ "${QUIET}" == "no" ]] && println jaune "Starting ${sa_wba} - Please wait..."
                sleep 5
                ${SU_USER} "${wasadmin_Base_cmd} startApp ${sa_wba}" 1>/dev/null 2>&1
                if [ $? -eq 0 ];then
                  compt=0
                  while [ ${compt} -lt 12 -a "${SA_BA_STATUS}" != "STARTED" ];do
                    compt=$((${compt}+1))
                    sleep 10
                    check_sa_Base_status
                  done
                  if [[ "${SA_BA_STATUS}" == "STARTED" ]];then
                    println vert "WBA: ${sa_wba} has been RESTARTED successfully"
                  elif [[ "${SA_BA_STATUS}" == "STOPPED" ]];then
                    println rouge "WBA: ERROR - ${sa_wba} is still STOPPED. Check manually"
                    RC_SA=1
                  else
                    println rouge "WBA: ${sa_wba} -ERROR: unknown status. Check manually"
                    RC_SA=1
                  fi
                else
                  println rouge "WBA: ${sa_wba} -ERROR while starting the Application server."
                  RC_SA=1
                fi
              fi
              [[ "${QUIET}" == "no" ]] && print
            done
          fi
        fi
      fi
    else
      println jaune "WBA: Application server not found"
    fi
  fi
fi

exit $RC_SA

