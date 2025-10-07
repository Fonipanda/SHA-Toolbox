#!/bin/ksh
#set -x

# Variables
script_current_dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

systemctl > /dev/null 2>&1
if [[ $? != 127 ]];then
  SYSTEMD="True"
else
  SYSTEMD="False"
fi

operation=$1
ihs_name=$2
ref=$3
RC=0


#################
# Usage
#################

usage()
{
echo "Syntax ERROR"
echo "Usage: $(basename ${0}) action Websphere_product ihs_name (+ref in option)"
echo "-------------------------------------------------------------"
echo " - actions available: "
echo "          - stop"
echo "          - start"
echo "          - status"
echo "          - restart"
echo "-------------------------------------------------------------"
echo " - ihs_name/all: name of the ihs or 'all' to perform operation over all ihs detected"
echo "-------------------------------------------------------------"
echo " - ref : specify ref with status action will define the current status as the reference status of the ihs"
echo "         specify ref with start action will start the ihs only if the reference status is 'STARTED'"
echo "-------------------------------------------------------------"

echo ""
echo "Examples:"
echo " $(basename ${0}) stop sw-12345_abcde"
echo " $(basename ${0}) status all"
echo " $(basename ${0}) start sw-12345_abcde ref"
echo ""
exit 1
}


# SYSTEMD SERVICES
systemd_stop()
{
service_to_stop=$1
systemctl stop ${service_to_stop}
if [[ $? -eq 0 ]];then
  if [ -f ${pidfile_ihs} ];then
    echo "Error: IHS ${ihs_serv} fail to stop with the ${service_to_stop} systemd service"
    RC=1
  else
    echo "The IHS ${ihs_serv} has been stopped successfully with ${service_to_stop} systemd service"
    RC=0
  fi
else
  echo "Error: IHS ${ihs_serv} fail to stop with the ${service_to_stop} systemd service"
  RC=1
fi
}

systemd_start()
{
service_to_start=$1
systemctl status ${service_to_start} | grep 'active (running)'  1>/dev/null 2>&1
if [[ $? -eq 0 ]];then
  echo "The IHS ${ihs_serv} is already started with the ${service_to_start} systemd service"
else
  systemctl start ${service_to_start} 1>/dev/null 2>&1
  if [[ $? -eq 0 ]];then
    systemctl status ${service_to_start} | grep 'active (running)'  1>/dev/null 2>&1
    if [[ $? -eq 0 ]];then
      echo "The IHS ${ihs_serv} has been started successfully with ${service_to_start} systemd service"
      RC=0
    else
      echo "Error: IHS ${ihs_serv} fail to start with the ${service_to_start} systemd service"
      RC=1
    fi
  else
    echo "Error: IHS ${ihs_serv} fail to start with the ${service_to_start} systemd service"
    RC=1
  fi
fi
}

systemd_restart()
{
service_to_restart=$1
systemctl restart ${service_to_restart} 1>/dev/null 2>&1
if [[ $? -eq 0 ]];then
  systemctl status ${service_to_restart} | grep 'active (running)'  1>/dev/null 2>&1
  if [[ $? -eq 0 ]];then
    echo "The IHS ${ihs_serv} has been restarted successfully with ${service_to_restart} systemd service"
    RC=0
  else
    echo "Error: IHS ${ihs_serv} fail to restart with the ${service_to_restart} systemd service"
    RC=1
  fi
else
  echo "Error: IHS ${ihs_serv} fail to restart with the ${service_to_restart} systemd service"
  RC=1
fi
}

ihs_start()
{
IHS_START=$(${IHS_dirname}/start 2>/dev/null)
sleep 1
echo "${IHS_START}" | grep "started" >/dev/null 2>&1
if [[ $? -eq 0 ]];then
  echo "${IHS_START}" | grep already >/dev/null 2>&1
  if [[ $? -eq 0 ]];then
    echo "The IHS ${ihs_serv} is already started"
  else
    echo "The IHS ${ihs_serv} has been started successfully"
  fi
else
  echo "Error: Unexpected result while running script ${IHS_dirname}/start"
  RC=1
fi
}

ihs_manage_without_systemd()
{
if [[ "${operation}" == "status" ]];then
  IHS_STATUS=$(${IHS_dirname}/status 2>/dev/null)
  echo "${IHS_STATUS}" | grep "is STARTED" 1>/dev/null 2>&1
  if [[ $? -eq 0 ]];then
    echo "The IHS ${ihs_serv} is STARTED"
    if [[ "${ref}" == "ref" ]];then
      rm -f /var/tmp/ihs_ref_status_stopped_${ihs_serv}
      echo "STARTED" > /var/tmp/ihs_ref_status_started_${ihs_serv}
    fi
  else
    echo ${IHS_STATUS} | grep "is STOPPED" 1>/dev/null 2>&1
    if [[ $? -eq 0 ]];then
      echo "The IHS ${ihs_serv} is STOPPED"
      if [[ "${ref}" == "ref" ]];then
        rm -f /var/tmp/ihs_ref_status_started_${ihs_serv}
         echo "STOPPED" > /var/tmp/ihs_ref_status_stopped_${ihs_serv}
      fi
    else
      echo "Error: Unexpected result while running script ${IHS_dirname}/status"
      RC=1
    fi
  fi
elif [[ "${operation}" == "start" ]];then
  if [[ "${ref}" == "ref" ]];then
    if [ -f /var/tmp/ihs_ref_status_stopped_${ihs_serv} ];then
      echo "The IHS ${ihs_serv} will not be started because reference status is stopped"
    else
      ihs_start
    fi
  else
    ihs_start
  fi
elif [[ "${operation}" == "stop" ]];then
  IHS_STOP=$(${IHS_dirname}/stop 2>/dev/null)
  sleep 1
  echo "${IHS_STOP}" | grep "stopped" >/dev/null 2>&1
  if [[ $? -eq 0 ]];then
    echo "${IHS_STOP}" | grep "No process found"  >/dev/null 2>&1
    if [[ $? -eq 0 ]];then
      echo "The IHS ${ihs_serv} is already stopped"
    else
      echo "The IHS ${ihs_serv} has been stopped successfully"
    fi
  else
    echo "Error: Unexpected result while running script ${IHS_dirname}/stop"
    RC=1
  fi
elif [[ "${operation}" == "restart" ]];then
  IHS_RESTART=$(${IHS_dirname}/restart 2>/dev/null)
  sleep 1
  echo "${IHS_RESTART}" | grep "started" >/dev/null 2>&1
  if [[ $? -eq 0 ]];then
    echo "The IHS ${ihs_serv} has been restarted successfully"
  else
    echo "Error: Unexpected result while running script ${IHS_dirname}/restart"
    RC=1
  fi
fi
}


global_ihs_manage()
{
if [ -f /etc/systemd/system/app_${ihs_serv}.ksh.service ];then
  pidfile_ihs=$(cat /etc/systemd/system/app_${ihs_serv}.ksh.service | grep -i ^pidfile | awk -F '=' '{print$2}')
  if [[ "${pidfile_ihs}" == "" ]];then
    echo "Error: IHS ${ihs_serv} systemd service is not conform: app_${ihs_serv}.ksh.service : Mandatory PIDFile parameter is not set in the service"
    RC=1
  else
    if [[ "${operation}" == "start" ]];then
      if [[ "${ref}" == "ref" ]];then
        if [ -f /var/tmp/app_${ihs_serv}.ksh.service_ref_status_stopped ];then
          echo "The IHS ${ihs_serv} will not be started with app_${ihs_serv}.ksh.service systemd service because reference status is stopped for this service"
        else
          systemd_start app_${ihs_serv}.ksh.service
        fi
      else
        systemd_start app_${ihs_serv}.ksh.service
      fi
    elif [[ "${operation}" == "stop" ]];then
      systemctl status app_${ihs_serv}.ksh.service | grep 'active (running)' 1>/dev/null 2>&1
      if [[ $? -eq 0 ]];then
        systemd_stop app_${ihs_serv}.ksh.service
      else
        if [ -f ${pidfile_ihs} ];then
          PID_ihs=$(cat ${pidfile_ihs} 2>/dev/null)
          ps -f -p ${PID_ihs} 2>/dev/null | grep -w ${ihs_serv} 1>/dev/null 2>&1
          if [[ $? -eq 0 ]];then
            systemctl start app_${ihs_serv}.ksh.service
            systemctl status app_${ihs_serv}.ksh.service | grep 'active (running)' 1>/dev/null 2>&1
            if [[ $? -ne 0 ]];then
              echo "Error: IHS ${ihs_serv} fail to stop with the app_${ihs_serv}.ksh.service systemd service"
              RC=1
            else
              systemd_stop app_${ihs_serv}.ksh.service
            fi
          else
            echo "The IHS ${ihs_serv} is already stopped with the app_${ihs_serv}.ksh.service systemd service"
          fi
        else
          echo "The IHS ${ihs_serv} is already stopped with the app_${ihs_serv}.ksh.service systemd service"
        fi
      fi
    elif [[ "${operation}" == "restart" ]];then
      systemctl status app_${ihs_serv}.ksh.service | grep 'active (running)' 1>/dev/null 2>&1
      if [[ $? -eq 0 ]];then
        systemd_restart app_${ihs_serv}.ksh.service
      else
        if [ -f ${pidfile_ihs} ];then
          PID_ihs=$(cat ${pidfile_ihs} 2>/dev/null)
          ps -f -p ${PID_ihs} 2>/dev/null | grep -w ${ihs_serv} 1>/dev/null 2>&1
          if [[ $? -eq 0 ]];then
            systemctl start app_${ihs_serv}.ksh.service
            systemctl status app_${ihs_serv}.ksh.service | grep 'active (running)' 1>/dev/null 2>&1
            if [[ $? -ne 0 ]];then
              echo "Error: IHS ${ihs_serv} failed to restart with the app_${ihs_serv}.ksh.service systemd service"
              RC=1
            else
              systemd_restart app_${ihs_serv}.ksh.service
            fi
          else
            systemd_restart app_${ihs_serv}.ksh.service
          fi
        else
          systemd_restart app_${ihs_serv}.ksh.service
        fi
      fi
    fi
  fi
else
  ihs_manage_without_systemd
  RC=$?
fi
}

#################
# MAIN
#################

if [[ "${operation}" != "stop" && "${operation}" != "start" && "${operation}" != "status" && "${operation}" != "restart" ]];then
  usage
fi

if [[ "${ihs_name}" == "" ]];then
  usage
fi

if [[ "${ihs_name}" == "all" ]];then
  ihs_name="sw-*"
fi

if [[ "${ref}" != "" && "${ref}" != "ref" ]];then
  usage
fi

IHS_list=$(find /applis/*/ihs/ -type d -name "${ihs_name}" 2>/dev/null | awk -F '/' '{print$NF}' | sort -u)
if [[ -z $IHS_list ]];then
  echo "Error: IHS have not been found (${ihs_name})"
  exit 1
fi

if [[ "${ihs_name}" != "sw-*" ]];then
  for Num_IHS in $(find /applis/*/ihs/ -type d -name "${ihs_name}" 2>/dev/null | awk -F '/' '{print"/"$2"/"$3"/"$4"/"$5}' | sort -u | wc -l );do
    if [[ ${Num_IHS} -gt 1 ]];then
      echo "Error: There are more than one IHS directory with the same name: $(find /applis/*/ihs/ -type d -name "${ihs_name}" 2>/dev/null | awk -F '/' '{print$NF}' | sort | uniq -c | grep -v ' 1 ' | awk '{print$2}')"
      exit 1
    elif [[ "${Num_IHS}" == "" ]];then
      echo "Error: No directory have been found for this IHS ($ihs_name)"
      exit 1
    fi
  done
fi

for IHS_dirname in $(find /applis/*/ihs/ -type d -name "${ihs_name}" 2>/dev/null | awk -F '/' '{print"/"$2"/"$3"/"$4"/"$5}'  | sort -u);do
  ihs_serv=$(echo ${IHS_dirname} |  awk -F '/' '{print$NF}')
  if [[ "${SYSTEMD}" == "False" ]];then
    if [ -f ${IHS_dirname}/${operation} ];then
      ihs_manage_without_systemd
    else
      echo "Error: ${IHS_dirname}/${operation} mandatory script is missing"
      RC=1
    fi
  else
    if [[ "${operation}" == "status" ]];then
      if [ -f /etc/systemd/system/app_${ihs_serv}.ksh.service ];then
        systemctl status app_${ihs_serv}.ksh.service  | grep 'active (running)' 1>/dev/null 2>&1
        if [[ $? -eq 0 ]];then
          echo "The IHS ${ihs_serv} is STARTED with app_${ihs_serv}.ksh.service systemd service"
          if [[ "${ref}" == "ref" ]];then
            rm -f /var/tmp/app_${ihs_serv}.ksh.service_ref_status_* 2>/dev/null
            echo "STARTED" > /var/tmp/app_${ihs_serv}.ksh.service_ref_status_started
          fi
        else
          echo "The IHS ${ihs_serv} is STOPPED with app_${ihs_serv}.ksh.service systemd service"
          if [[ "${ref}" == "ref" ]];then
            rm -f /var/tmp/app_${ihs_serv}.ksh.service_ref_status_* 2>/dev/null
            echo "STOPPED" > /var/tmp/app_${ihs_serv}.ksh.service_ref_status_stopped
          fi
        fi
      else
        if [ -f ${IHS_dirname}/${operation} ];then
          ihs_manage_without_systemd
        else
          echo "Error: ${IHS_dirname}/${operation} mandatory script is missing"
          RC=1
        fi
      fi
    else
      global_ihs_manage
    fi
  fi
done

exit $RC

