#!/bin/ksh
#set -x
#######################################<+>#####################################
# Name:        wasstartstop_cmd.ksh
# Version:     1.1 (2019/12/31)
#
# Initial Author:     David PERIN
#
# Environment: UNIX (AIX, LINUX),  WAS ND, WAS BASE and Liberty
#
# Modifications
#
#######################################<->#####################################

# Variables
script_current_dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

systemctl > /dev/null 2>&1
if [[ $? != 127 ]];then
  SYSTEMD="True"
else
  SYSTEMD="False"
fi

Manage_script=${script_current_dir}/WAS_Manage.ksh

if [ ! -f ${Manage_script} ];then
  echo "Error: The mandatory WAS_Manage.ksh script was not found in ${script_current_dir}"
  exit 1
fi

operation=$1
web_product=$2
jvm_name=$3
RC=0


#################
# Usage
#################

usage()
{
echo "Syntax ERROR"
echo "Usage: $(basename ${0}) action Websphere_product jvm_name"
echo "-------------------------------------------------------------"
echo " - actions available: "
echo "          - stop"
echo "          - start"
echo "          - status"
echo "          - restart"
echo "          - start_ref (get status and define it as reference status)"
echo "          - status_ref (start only if reference status is not 'STOPPED')"
echo "-------------------------------------------------------------"
echo " - Websphere product:"
echo "          - wlb (Was Liberty Base)"
echo "          - wlc (Was Liberty Core)"
echo "          - wba (Was Base)"
echo "          - wnd (Was ND)"
echo "-------------------------------------------------------------"
echo " - jvm_name/all_sa: name of the jvm or 'all_sa' to perform operation over all jvm detected on the WebSphere product selected"
echo "-------------------------------------------------------------"

echo ""
echo "Examples:"
echo " $(basename ${0}) stop wlb sa-12345_abcde"
echo " $(basename ${0}) status wba all_sa"
echo " $(basename ${0}) start_ref wlc sa-12345_abcde"
echo ""
exit 1
}

# SYSTEMD SERVICES
systemd_stop()
{
service_to_stop=$1
systemctl stop ${service_to_stop}
if [[ $? -eq 0 ]];then
  if [ -f ${pidfile_jvm} ];then
    echo "JVM ${app_serv} fail to stop with the ${service_to_stop} systemd service"
    RC=1
  else
    echo "JVM ${app_serv} has been STOPPED successfully with ${service_to_stop} systemd service"
    RC=0
  fi
else
  echo "JVM ${app_serv} fail to stop with the ${service_to_stop} systemd service"
  RC=1
fi
}

systemd_start()
{
service_to_start=$1
systemctl status ${service_to_start} | grep 'active (running)'  1>/dev/null 2>&1
if [[ $? -eq 0 ]];then
  echo "JVM ${app_serv} is already STARTED with the ${service_to_start} systemd service"
else
  systemctl start ${service_to_start} 1>/dev/null 2>&1
  if [[ $? -eq 0 ]];then
    systemctl status ${service_to_start} | grep 'active (running)'  1>/dev/null 2>&1
    if [[ $? -eq 0 ]];then
      echo "JVM ${app_serv} has been STARTED successfully with ${service_to_start} systemd service"
      RC=0
    else
      echo "JVM ${app_serv} fail to start with the ${service_to_start} systemd service"
      RC=1
    fi
  else
    echo "JVM ${app_serv} fail to start with the ${service_to_start} systemd service"
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
    echo "JVM ${app_serv} has been RESTARTED successfully with ${service_to_restart} systemd service"
    RC=0
  else
    echo "JVM ${app_serv} fail to restart with the ${service_to_restart} systemd service"
    RC=1
  fi
else
  echo "JVM ${app_serv} fail to restart with the ${service_to_restart} systemd service"
  RC=1
fi
}

global_jvm_manage()
{
if [ -f /etc/systemd/system/app_${web_product}_${app_serv}.ksh.service ];then
  pidfile_jvm=$(cat /etc/systemd/system/app_${web_product}_${app_serv}.ksh.service | grep -i ^pidfile | awk -F '=' '{print$2}')
  if [[ "${pidfile_jvm}" == "" ]];then
    echo "JVM ${app_serv} systemd service is not conform: app_${web_product}_${app_serv}.ksh.service : Mandatory PIDFile parameter is not set in the service"
    RC=1
  else
    if [[ "${operation}" == "start" ]];then
      systemd_start app_${web_product}_${app_serv}.ksh.service
    elif [[ "${operation}" == "start_ref" ]];then 
      if [ -f /var/tmp/app_${web_product}_${app_serv}.ksh.service_ref_status_stopped ];then
        echo "JVM ${app_serv} will not be started with app_${web_product}_${app_serv}.ksh.service systemd service because reference status is stopped for this service"
      else
        systemd_start app_${web_product}_${app_serv}.ksh.service
      fi      
    elif [[ "${operation}" == "stop" ]];then
      systemctl status app_${web_product}_${app_serv}.ksh.service | grep 'active (running)' 1>/dev/null 2>&1
      if [[ $? -eq 0 ]];then
        systemd_stop app_${web_product}_${app_serv}.ksh.service
      else
        if [ -f ${pidfile_jvm} ];then
          PID_jvm=$(cat ${pidfile_jvm} 2>/dev/null)
          ps -f -p ${PID_jvm} 2>/dev/null | grep -w ${app_serv} 1>/dev/null 2>&1
          if [[ $? -eq 0 ]];then
            systemctl start app_${web_product}_${app_serv}.ksh.service
            systemctl status app_${web_product}_${app_serv}.ksh.service | grep 'active (running)' 1>/dev/null 2>&1
            if [[ $? -ne 0 ]];then
              echo "JVM ${app_serv} fail to stop with the app_${web_product}_${app_serv}.ksh.service systemd service"
              RC=1
            else
              systemd_stop app_${web_product}_${app_serv}.ksh.service
            fi
          else
            echo "JVM ${app_serv} is already STOPPED with the app_${web_product}_${app_serv}.ksh.service systemd service"
          fi
        else
          echo "JVM ${app_serv} is already STOPPED with the app_${web_product}_${app_serv}.ksh.service systemd service"
        fi
      fi
    elif [[ "${operation}" == "restart" ]];then
      systemctl status app_${web_product}_${app_serv}.ksh.service | grep 'active (running)' 1>/dev/null 2>&1
      if [[ $? -eq 0 ]];then
        systemd_restart app_${web_product}_${app_serv}.ksh.service
      else
        if [ -f ${pidfile_jvm} ];then
          PID_jvm=$(cat ${pidfile_jvm} 2>/dev/null)
          ps -f -p ${PID_jvm} 2>/dev/null | grep -w ${app_serv} 1>/dev/null 2>&1
          if [[ $? -eq 0 ]];then
            systemctl start app_${web_product}_${app_serv}.ksh.service
            systemctl status app_${web_product}_${app_serv}.ksh.service | grep 'active (running)' 1>/dev/null 2>&1
            if [[ $? -ne 0 ]];then
              echo "JVM ${app_serv} failed to restart with the app_${web_product}_${app_serv}.ksh.service systemd service"
              RC=1
            else
              systemd_restart app_${web_product}_${app_serv}.ksh.service
            fi
          else
            systemd_restart app_${web_product}_${app_serv}.ksh.service
          fi
        else
          systemd_restart app_${web_product}_${app_serv}.ksh.service
        fi
      fi
    fi
  fi
else
  ${Manage_script} ${operation} ${app_serv} ${web_product} quiet
  RC=$?
fi
}

#################
# MAIN
#################

if [[ "${operation}" != "stop" && "${operation}" != "start" && "${operation}" != "status" && "${operation}" != "restart" && "${operation}" != "status_ref" && "${operation}" != "start_ref" ]];then
  usage
fi

if [[ "${web_product}" != "wnd" && "${web_product}" != "wba" && "${web_product}" != "wlc" && "${web_product}" != "wlb" ]];then
  usage
fi

WEB_PRODUCT=$(echo ${web_product} | tr 'a-z' 'A-Z')

if [[ "${jvm_name}" == "" ]];then
  usage
fi

if [[ "${jvm_name}" == "all_sa" ]];then
 jvm_name=all_sa_${web_product} 
fi

verif_jvm=$(${Manage_script} list ${jvm_name} ${web_product} quiet 2>/dev/null)

echo "${verif_jvm}" | grep ' found ' 1>/dev/null 2>&1
if [[ $? -eq 0 ]];then
  echo "Error: ${verif_jvm}"
  exit 1
fi

if [[ "${SYSTEMD}" == "False" ]];then
    ${Manage_script} ${operation} ${jvm_name} ${web_product} quiet 2>/dev/null
else
  if [[ "${operation}" == "status" || "${operation}" == "status_ref" ]];then
    for app_serv in $(${Manage_script} list ${jvm_name} ${web_product} quiet | awk -F ': ' '{print$2}' | awk '{print$1}');do
      if [ -f /etc/systemd/system/app_${web_product}_${app_serv}.ksh.service ];then
        systemctl status app_${web_product}_${app_serv}.ksh.service  | grep 'active (running)' 1>/dev/null 2>&1
        if [[ $? -eq 0 ]];then
          echo "$WEB_PRODUCT: ${app_serv} is STARTED through app_${web_product}_${app_serv}.ksh.service systemd service"
          if [[ "${operation}" == "status_ref" ]];then
            rm -f /var/tmp/app_${web_product}_${app_serv}.ksh.service_ref_status_* 2>/dev/null
            echo "STARTED" > /var/tmp/app_${web_product}_${app_serv}.ksh.service_ref_status_started 
          fi
        else
          echo "WEB_PRODUCT: ${app_serv} is STOPPED through app_${web_product}_${app_serv}.ksh.service systemd service"
          if [[ "${operation}" == "status_ref" ]];then
            rm -f /var/tmp/app_${web_product}_${app_serv}.ksh.service_ref_status_* 2>/dev/null
            echo "STOPPED" > /var/tmp/app_${web_product}_${app_serv}.ksh.service_ref_status_stopped
          fi
        fi
      else
        ${Manage_script} ${operation} ${app_serv} ${web_product} quiet 2>/dev/null
      fi
    done 
  else
    for app_serv in $(${Manage_script} list ${jvm_name} ${web_product} quiet | awk -F ': ' '{print$2}' | awk '{print$1}');do
      global_jvm_manage
    done
  fi
fi
exit $RC
