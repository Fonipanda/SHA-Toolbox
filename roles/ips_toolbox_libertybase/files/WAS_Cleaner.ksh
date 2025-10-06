#!/bin/ksh
# set -x

#-----------
#- USAGE
#-----------

usage()
{
echo "Syntax ERROR"
echo "Usage:"
echo "--------------------------------------------------------------------------------------"
echo "- $(basename ${0}) WAS_PRODUCT WAS_APPLICATION(mandatory if WAS_PRODUCT is not 'ALL') "
echo "   - WAS_PRODUCT: ALL/wlc/wlb/wnd/wba"
echo "          - ALL will remove all webSphere applications on all product and all toolboxes param and logs"
echo "          - wlc will remove the Liberty Core WAS_APPLICATION defined"
echo "          - wlb will remove the Liberty Base WAS_APPLICATION defined"
echo "          - wnd will remove the WAS ND WAS_APPLICATION defined"
echo "          - wba will remove the WAS Base WAS_APPLICATION defined"
echo "   - WAS_APPLICATION: The full application name as defined in /applis/"
echo "                      --> WILDCARDS are not allowed"
echo "--------------------------------------------------------------------------------------"
exit 1
}


#-------------
#- Fonctions
#-------------

grep_aix()
{
awk -v direction="$1" -v offset="$2" -v pattern="$3" '

$0 ~ pattern {s=NR; _[NR]=$0; next}
{_[NR]=$0; next}

END{
        if( direction == "B" ){
                x=(s-offset)
                while( s >= x ){
                        print _[x]
                        x++
                }
        }
        if( direction == "A" ){
                x=(s+offset)
                while( s <= x ){
                        print _[s]
                        s++
                }
        }
}' $4
}

# -------------------------------------
# Check if a directory in in beeing used
# @param dirName: directory complete name
#
isDirBusy()
{
    typeset -i rc=0
    typeset dirName="${1}"
    typeset procList=""
    typeset lsofCmd=$(which lsof 2> /dev/null)

    if [ -n ${lsofCmd} ]
    then
        procList=$(${lsofCmd} ${dirName} | grep -v java | grep -v httpd | grep -v rotatelog | grep -v lsof | grep -v COMMAND | grep -v grep 2> /dev/null | awk '{ printf("%-20s %-9s %-20s %-50s\n", $1, $2, $3, $NF) }' | uniq)

        if [ ! -z ${procList} ]
        then
            echo "The directory: ${dirName} is beeing used by some processes: "
            echo "${procList}"
            rc=20
        fi
    else
        echo "Couldn't determine whether the directory: ${dirName} is in use"
    fi

    return ${rc}
}

#------------
#- Variables
#------------

JVM_WLC="No"
JVM_WLB="No"
JVM_WND="No"
JVM_WBA="No"
WLC_VI="None"
WLB_VI="None"

WAS_PRODUCT=$1
WAS_APPLICATION=$2

echo "_${WAS_PRODUCT}" | egrep -w '_ALL|_wlc|_wlb|_wnd|_wba' 1>/dev/null 2>&1
if [[ $? -ne 0 ]];then
  usage
fi

if [ "${WAS_PRODUCT}" != "ALL" ];then
  if [ "${WAS_APPLICATION}" == "" ];then
    usage
  else
    echo "${WAS_APPLICATION}" | egrep '\*|\$|\.' 1>/dev/null 2>&1
    if [[ $? -eq 0 ]];then
      echo "ERROR: The parameter 'WAS_APPLICATION' must not contain any wildcard"
      exit 1
    fi
  fi
  if [ ! -d /applis/${WAS_APPLICATION} ];then
     echo "${WAS_APPLICATION} directory not found in /applis/"
     exit 0
  else
    APP_DIR="/applis/${WAS_APPLICATION}"
    if [[ "${WAS_PRODUCT}" == "wnd" || "${WAS_PRODUCT}" == "wba" ]];then
      SA_WAS="$(ls ${APP_DIR}/was 2>/dev/null | grep ^sa- )"
      if [[ "${SA_WAS}" == "" ]];then
        echo "WAS BASE/ND: Application server not found in ${APP_DIR}/was"
        exit 0
      fi
    fi
  fi
  APP_LOG="/applis/logs/${WAS_APPLICATION}"
else
  APP_DIR="/applis/*"
  APP_LOG="/applis/logs/*"
  SA_WAS="sa-*"
fi


#----------------------------------------
#- Nettoyage des fichiers de parametrage
#----------------------------------------
if [ "${WAS_PRODUCT}" == "ALL" ];then
  rm -f /apps/toolboxes/web/CreateEnvWas/param/* 1>/dev/null 2>&1
  mv /apps/toolboxes/web/ManageDeployEarWas/DeployEarWas/livrables/DevWorkSample.war  /apps/Deploy/Formation/LibertyCore/war/DevWorkSample.war 1>/dev/null 2>&1
  mv /apps/toolboxes/web/ManageDeployEarWas/DeployEarWas/livrables/DevWorkSample.ear /apps/Deploy/Formation/WAS/2Tiers/Livraison_ear/DevWorkSample.ear 1>/dev/null 2>&1
  rm -fr /apps/toolboxes/web/ManageDeployEarWas/DeployEarWas/livrables/* 1>/dev/null 2>&1
  rm -f /apps/toolboxes/web/CreateEnvWas/tmp/*
  rm -f /apps/toolboxes/web/CreateEnvWas/logs/*
  rm -fr /apps/toolboxes/web/ManageDeployEarWas/DeployEarWas/logs/*.log 1>/dev/null 2>&1
fi

#------------------------------------------------------------
#- Detection des produits installes et recuperation du WAS_VI
#------------------------------------------------------------

ls /apps/WebSphere* 1>/dev/null 2>&1
if [ $? -ne 0 ];then
 echo "ERROR: WebSphere product not detected"
 exit 1
fi

if [[ "${WAS_PRODUCT}" == "ALL" || "${WAS_PRODUCT}" == "wlc" ]];then
  check_wlcdir=$(ls /apps/WebSphere*/LibertyCore/bin/productInfo 2>/dev/null | wc -l)
  if [[ "${check_wlcdir}" -eq "0" ]];then
    echo "Liberty Core binaries not found"
    if [[ "${WAS_PRODUCT}" == "wlc" ]];then
      exit 0
    fi
  elif [[ "${check_wlcdir}" -eq "1" ]];then
    WLC_VI=$(find /apps/WebSphere*/LibertyCore/bin/ -name productInfo  | awk -F"/" '{print $3}' | sed -e s/WebSphere//)
    if [ "${WLC_VI}" = "" ];then
      WLC_VI=LibertyCore
    fi
  else
    WLC_VI="multi_instance"
    for instance in $(find /apps/WebSphere*/LibertyCore/bin/ -name productInfo);do
      WLC_VI_temp=$(echo "${instance}" | awk -F"/" '{print $3}' | sed -e s/WebSphere//)
      if [ "${WLC_VI_temp}" = "" ];then
        WLC_VI_temp=LibertyCore
      fi
      WLC_VI="${WLC_VI} ${WLC_VI_temp}"
    done
  fi
fi

if [[ "${WAS_PRODUCT}" == "ALL" || "${WAS_PRODUCT}" == "wlb" ]];then
  check_wlbdir=$(ls /apps/WebSphere*/LibertyBase/bin/productInfo 2>/dev/null | wc -l)
  if [[ "${check_wlbdir}" -eq "0" ]];then
    echo "Liberty Base binaries not found"
    if [[ "${WAS_PRODUCT}" == "wlb" ]];then
     exit 0
    fi
  elif [[ "${check_wlbdir}" -eq "1" ]];then
    WLB_VI=$(find /apps/WebSphere*/LibertyBase/bin/ -name productInfo  | awk -F"/" '{print $3}' | sed -e s/WebSphere//)
    if [ "${WLB_VI}" = "" ];then
      WLB_VI=LibertyBase
    fi
  else
    WLB_VI="multi_instance"
    for instance in $(find /apps/WebSphere*/LibertyBase/bin/ -name productInfo);do
      WLB_VI_temp=$(echo "${instance}" | awk -F"/" '{print $3}' | sed -e s/WebSphere//)
      if [ "${WLB_VI_temp}" = "" ];then
        WLB_VI_temp=LibertyBase
      fi
      WLB_VI="${WLB_VI} ${WLB_VI_temp}"
    done
  fi
fi

WND_VI="not_found"
WBA_VI="not_found"

if [[ "${WAS_PRODUCT}" == "ALL" || "${WAS_PRODUCT}" == "wnd" || "${WAS_PRODUCT}" == "wba" ]];then
  for product in $(ls /apps/WebSphere*/AppServer*/bin/versionInfo.sh);do
    $product | grep ND | grep installed 1>/dev/null
    if [ $? == 0 ];then
      WND_VI=$(echo $product | awk -F"/" '{print $3}' | sed -e s/WebSphere//)
    fi
    $product | grep BASE | grep installed  1>/dev/null
    if [ $? == 0 ];then
      WBA_VI=$(echo $product | awk -F"/" '{print $3}' | sed -e s/WebSphere//)
    fi
  done
  if [[ "${WAS_PRODUCT}" == "wnd" && "${WND_VI}" == "not_found" ]];then
    echo "WAS ND binaries not found"
    exit 0
  fi
  if [[ "${WAS_PRODUCT}" == "wba" && "${WBA_VI}" == "not_found" ]];then
    echo "WAS Base binaries not found"
    exit 0
  fi
fi

#-------------------------------
#- recherche des JVM presentes
#-------------------------------

if [[ "${WAS_PRODUCT}" == "ALL" || "${WAS_PRODUCT}" == "wlc" ]];then
  find ${APP_DIR}/wlc/ -name sa* -print 2>/dev/null | grep -v temp | grep -v servers | grep -v pid | awk -F"/" '{print $5 }' | grep sa- 1>/dev/null 2>&1
  if [ $? -eq 0 ];then
    JVM_WLC="Yes"
  else
    echo "Liberty Core: Application server not found in ${APP_DIR}/wlc"
  fi
fi

if [[ "${WAS_PRODUCT}" == "ALL" || "${WAS_PRODUCT}" == "wlb" ]];then
  find ${APP_DIR}/wlb/ -name sa* -print 2>/dev/null | grep -v temp | grep -v servers | grep -v pid | awk -F"/" '{print $5 }' | grep sa- 1>/dev/null 2>&1
  if [ $? -eq 0 ];then
   JVM_WLB="Yes"
  else
    echo "Liberty Base: Application server not found in ${APP_DIR}/wlb"
  fi
fi

if [[ "${WAS_PRODUCT}" == "ALL" || "${WAS_PRODUCT}" == "wnd" ]];then
  if [[ "${SA_WAS}" != "" ]];then
    if [ "${WND_VI}" != "" ];then
      for was_app_serv in $(ls /applis/*/was 2>/dev/null | grep ${SA_WAS} );do
        find /apps/WebSphere${WND_VI}/profiles/dmgr/ -name server.xml  2>/dev/null | grep ${was_app_serv} 1>/dev/null 2>&1
        if [ $? -eq 0 ];then
          JVM_WND="Yes"
        else
          echo "WAS ND:${was_app_serv} Application server.xml not found in /apps/WebSphere${WND_VI}/profiles/dmgr/"
        fi
      done
    fi
  fi
fi

if [[ "${WAS_PRODUCT}" == "ALL" || "${WAS_PRODUCT}" == "wba" ]];then
  if [[ "${SA_WAS}" != "" ]];then
    if [ "${WBA_VI}" != "" ];then
      for was_app_serv in $(ls /applis/*/was 2>/dev/null | grep ${SA_WAS} );do
        find /apps/WebSphere${WBA_VI}/ -name server.xml  2>/dev/null | grep ${was_app_serv} 1>/dev/null 2>&1
        if [ $? -eq 0 ];then
          JVM_WBA="Yes"
        else
          echo "WAS Bas:${was_app_serv} Application server.xml not found in /apps/WebSphere${WBA_VI}/"
        fi
      done
    fi
  fi
fi

if [[ "${WAS_PRODUCT}" == "wlc" && "${JVM_WLC}" == "No" ]];then
  exit 0
fi

if [[ "${WAS_PRODUCT}" == "wlb" && "${JVM_WLB}" == "No" ]];then
  exit 0
fi

if [[ "${WAS_PRODUCT}" == "wnd" && "${JVM_WND}" == "No" ]];then
  exit 0
fi

if [[ "${WAS_PRODUCT}" == "wba" && "${JVM_WBA}" == "No" ]];then
  exit 0
fi

if [[ "${JVM_WLC}" == "No" && "${JVM_WLB}" == "No" && "${JVM_WND}" == "No" && "${JVM_WBA}" == "No" ]];then
  echo "Application server was not found"
  exit 0
fi

if [[ "${WAS_PRODUCT}" != "ALL" ]];then
  isDirBusy /applis/${WAS_APPLICATION} 1>/dev/null 2>&1
  if [[ $? -eq 20 ]];then
    echo "ERROR: The filesystem /applis/${WAS_APPLICATION} is busy. Filesystem deletion could not be performed"
    exit 1
  fi
  isDirBusy /applis/logs/${WAS_APPLICATION} 1>/dev/null 2>&1
  if [[ $? -eq 20 ]];then
    echo "ERROR: The filesystem /applis/logs/${WAS_APPLICATION} is busy. Filesystem deletion could not be performed"
    exit 1
  fi
fi

#-------------------------------
#- recherche des IHS presentes
#-------------------------------
ihs_wlc="NO"
ihs_wlb="NO"
ihs_nd="NO"
ihs_base="NO"


for Webserver_dir in $(ls -d ${APP_DIR}/ihs/* | grep sw);do
  Webserver_name=$(echo ${Webserver_dir} | awk -F'/' '{print$NF}' | grep sw-)
  HttpdWebServer="${Webserver_dir}/conf/httpd.conf"
  if [[ -f ${HttpdWebServer} ]];then
    Server_root_VI=$(grep ^ServerRoot ${HttpdWebServer} | awk '{print$2}'| awk -F"/" '{print $3}' | sed -e s/WebSphere// 2>/dev/null)
    if [[ "${Server_root_VI}" != "" ]];then
      echo ${WND_VI} | grep -w ${Server_root_VI} 1>/dev/null 2>&1
      if [ $? == 0 ];then
        ihs_nd="YES"
      else
        echo ${WBA_VI} | grep -w ${Server_root_VI} 1>/dev/null 2>&1
        if [ $? == 0 ];then
          ihs_base="YES"
        else
          echo ${WLC_VI} | grep -w ${Server_root_VI} 1>/dev/null 2>&1
          if [ $? == 0 ];then
            ihs_wlc="YES"
          else
            echo ${WLB_VI} | grep -w ${Server_root_VI} 1>/dev/null 2>&1
            if [ $? == 0 ];then
              ihs_wlb="YES"
            fi
          fi
        fi
      fi
    else
      echo "${WLC_VI}" | grep LibertyCore >/dev/null
      if [ $? == 0 ];then
        ihs_wlc="YES"
      else
        echo "${WLB_VI}" | grep LibertyBase >/dev/null
        if [ $? == 0 ];then
          ihs_wlb="YES"
        fi
      fi
    fi
  fi
done

# Arret des IHS


if [[ "${WAS_PRODUCT}" == "ALL" ]] ;then
  if [[ "${ihs_wlc}" == "YES" || "${ihs_wlb}" == "YES" || "${ihs_nd}" == "YES" || "${ihs_base}" == "YES" ]];then
    echo " "
    echo "Stopping IHS..."
    cd /apps/toolboxes/web/WasOperating
    ./ihsmanage_cmd.ksh stop all 1>/dev/null 2>&1
    if [ $? -eq 0 ];then
      echo "IHS stopped SUCCESSFULLY"
    else
      cd /apps/toolboxes/web/WasOperating/ihsstartstop
      ./ihsstartstop.ksh stop all root 1>/dev/null 2>&1
      if [ $? -eq 0 ];then
        echo "IHS stopped SUCCESSFULLY"
      else
        echo "ERROR encountered during IHS Stopping"
        exit 1
      fi
    fi
    echo " "
  fi
else
  if [[ "${ihs_wlc}" == "YES" || "${ihs_wlb}" == "YES" || "${ihs_nd}" == "YES" || "${ihs_base}" == "YES" ]];then
    echo " "
    echo "Stopping IHS..."
    cd /apps/toolboxes/web/WasOperating
    ./ihsmanage_cmd.ksh stop ${Webserver_name} 1>/dev/null 2>&1
    if [ $? -eq 0 ];then
      echo "IHS stopped SUCCESSFULLY"
    else
      cd /apps/toolboxes/web/WasOperating/ihsstartstop
      ./ihsstartstop.ksh stop ${Webserver_name} root 1>/dev/null 2>&1
      if [ $? -eq 0 ];then
        echo "IHS stopped SUCCESSFULLY"
      else
        echo "ERROR encountered during IHS Stopping"
        exit 1
      fi
    fi
    echo " "
  fi
fi

# Arret des JVM et suppression des filesystems
### Liberty Core

if [[ "${WAS_PRODUCT}" == "ALL" || "${WAS_PRODUCT}" == "wlc" ]];then
  if [[ "${JVM_WLC}" == "Yes" ]];then
    for WLC_SA in `find ${APP_DIR}/wlc/ -name sa* -print 2>/dev/null | awk -F '/' '{print"/"$2"/"$3"/"$4"/"$5}' | sort -u | grep -v temp | grep -v servers | grep -v pid | awk -F"/" '{print $5 }'`; do
      echo "Stopping Liberty Core Application server ${WLC_SA}..."
      cd /apps/toolboxes/web/WasOperating
      /apps/toolboxes/web/WasOperating/WAS_Manage.ksh stop ${WLC_SA} wlc 1>/dev/null 2>&1
      if [ $? -eq 0 ];then
        echo " "
        echo "The Application server ${WLC_SA} has been successfully stopped"
        # Si OK, on supprime les FS correspondants
        systemctl daemon-reload > /dev/null 2>&1
        WLC_FS_LOG=$(find ${APP_LOG}/wlc/ -name ${WLC_SA} -print 2>/dev/null | awk -F '/' '{print"/"$2"/"$3"/"$4"/"$5"/"$6}' | sort -u | grep -v temp | grep -v servers | grep -v pid | awk -F '/wlc' '{print$1}')
        WLC_FS=$(find ${APP_DIR}/wlc/ -name ${WLC_SA} -print 2>/dev/null | awk -F '/' '{print"/"$2"/"$3"/"$4"/"$5}' | sort -u | grep -v temp | grep -v servers | grep -v pid | awk -F '/wlc' '{print$1}')
        echo " "
        echo "Removing filesystems for Application server ${WLC_SA}..."
        if [[ "${WLC_FS_LOG}" != "" ]];then
          cd ${WLC_FS_LOG}
          WLC_LV_LOG=lv_$(df . | grep 'lv_log' | grep -v rootvg | awk -F 'lv_' '{print$2}'| awk '{print$1}')
          cd /apps/toolboxes/exploit/bin
          sleep 1
          if [[ "${WLC_LV_LOG}" == "lv_" ]];then
            echo "The logs Logical Volume may be on rootvg"
            echo "${WLC_FS_LOG}" | grep /applis/logs/ 1>/dev/null 2>&1
            if [ $? -eq 0 ];then
              echo "Removing directory ${WLC_FS_LOG}..."
              rm -ri ${WLC_FS_LOG}
              if [ $? -ne 0 ];then
                echo "ERROR encountered while removing directory ${WLC_FS_LOG}"
                exit 1
              fi
            fi
          else
            /apps/toolboxes/exploit/bin/exploit_remove-fs.ksh lv=${WLC_LV_LOG}
            if [ $? -eq 0 ];then
              echo "The ${WLC_LV_LOG} logical volume has been deleted SUCCESSFULLY"
            else
              echo "ERROR encountered while deleting logical volume ${WLC_LV_LOG}"
              exit 1
            fi
          fi
        else
          echo "No log directory was found for ${WLC_SA}"
        fi
        if [[ "${WLC_FS}" != "" ]];then
          cd ${WLC_FS}
          WLC_LV=lv_$(df . | grep 'lv_' | grep -v rootvg | awk -F 'lv_' '{print$2}' | awk '{print$1}')
          cd /apps/toolboxes/exploit/bin
          sleep 1
          if [[ "${WLC_LV}" == "lv_" ]];then
            echo "The Application server Logical Volume may be on rootvg"
            echo "${WLC_FS}" | grep /applis/ 1>/dev/null 2>&1
            if [ $? -eq 0 ];then
              echo "Removing directory ${WLC_FS}..."
              rm -ri ${WLC_FS}
              if [ $? -ne 0 ];then
                echo "ERROR encountered while removing directory ${WLC_FS}"
                exit 1
              fi
            fi
          else
            /apps/toolboxes/exploit/bin/exploit_remove-fs.ksh lv=${WLC_LV}
            if [ $? -eq 0 ];then
              echo "The ${WLC_LV} logical volume has been deleted SUCCESSFULLY"
            else
              echo "ERROR encountered while deleting logical volume ${WLC_LV}"
              exit 1
            fi
          fi
        else
          echo "No directory was found for ${WLC_SA}"
        fi
      else
        echo "ERROR encountered while stopping Application server ${WLC_SA}"
        exit 1
      fi
    done
  fi
fi

### Liberty Base

if [[ "${WAS_PRODUCT}" == "ALL" || "${WAS_PRODUCT}" == "wlb" ]];then
  if [[ "${JVM_WLB}" == "Yes" ]];then
    for WLB_SA in `find ${APP_DIR}/wlb/ -name sa* -print 2>/dev/null | awk -F '/' '{print"/"$2"/"$3"/"$4"/"$5}' | sort -u | grep -v temp | grep -v servers | grep -v pid | awk -F"/" '{print $5 }'`; do
      echo "Stopping Liberty Base Application server ${WLB_SA}..."
      cd /apps/toolboxes/web/WasOperating
      /apps/toolboxes/web/WasOperating/WAS_Manage.ksh stop ${WLB_SA} wlb 1>/dev/null 2>&1
      if [ $? -eq 0 ];then
        echo " "
        echo "The Application server ${WLB_SA} has been successfully stopped"
        # Si OK, on supprime les FS correspondants
        systemctl daemon-reload > /dev/null 2>&1
        WLB_FS_LOG=$(find ${APP_LOG}/wlb/ -name ${WLB_SA} -print 2>/dev/null | awk -F '/' '{print"/"$2"/"$3"/"$4"/"$5"/"$6}' | sort -u | grep -v temp | grep -v servers | grep -v pid | awk -F '/wlb' '{print$1}')
        WLB_FS=$(find ${APP_DIR}/wlb/ -name ${WLB_SA} -print 2>/dev/null | awk -F '/' '{print"/"$2"/"$3"/"$4"/"$5}' | sort -u | grep -v temp | grep -v servers | grep -v pid | awk -F '/wlb' '{print$1}')
        echo " "
        echo "Removing filesystems for Application server ${WLB_SA}..."
        if [[ "${WLB_FS_LOG}" != "" ]];then
          cd ${WLB_FS_LOG}
          WLB_LV_LOG=lv_$(df . | grep 'lv_log' | grep -v rootvg | awk -F 'lv_' '{print$2}'| awk '{print$1}')
          cd /apps/toolboxes/exploit/bin
          sleep 1
          if [[ "${WLB_LV_LOG}" == "lv_" ]];then
            echo "The logs Logical Volume may be on rootvg"
            echo "${WLB_FS_LOG}" | grep /applis/logs/ 1>/dev/null 2>&1
            if [ $? -eq 0 ];then
              echo "Removing directory ${WLB_FS_LOG}..."
              rm -ri ${WLB_FS_LOG}
              if [ $? -ne 0 ];then
                echo "ERROR encountered while removing directory ${WLB_FS_LOG}"
                exit 1
              fi
            fi
          else
            /apps/toolboxes/exploit/bin/exploit_remove-fs.ksh lv=${WLB_LV_LOG}
            if [ $? -eq 0 ];then
              echo "The ${WLB_LV_LOG} logical volume has been deleted SUCCESSFULLY"
            else
              echo "ERROR encountered while deleting logical volume ${WLB_LV_LOG}"
              exit 1
            fi
          fi
        else
          echo "No log directory was found for ${WLB_SA}"
        fi
        if [[ "${WLB_FS}" != "" ]];then
          cd ${WLB_FS}
          WLB_LV=lv_$(df . | grep 'lv_' | grep -v rootvg | awk -F 'lv_' '{print$2}' | awk '{print$1}')
          cd /apps/toolboxes/exploit/bin
          sleep 1
          if [[ "${WLB_LV}" == "lv_" ]];then
            echo "The Application server Logical Volume may be on rootvg"
            echo "${WLB_FS}" | grep /applis/ 1>/dev/null 2>&1
            if [ $? -eq 0 ];then
              echo "Removing directory ${WLB_FS}..."
              rm -ri ${WLB_FS}
              if [ $? -ne 0 ];then
                echo "ERROR encountered while removing directory ${WLB_FS}"
                exit 1
              fi
            fi
          else
            /apps/toolboxes/exploit/bin/exploit_remove-fs.ksh lv=${WLB_LV}
            if [ $? -eq 0 ];then
              echo "The ${WLB_LV} logical volume has been deleted SUCCESSFULLY"
            else
              echo "ERROR encountered while deleting logical volume ${WLB_LV}"
              exit 1
            fi
          fi
        else
          echo "No directory was found for ${WLB_SA}"
        fi
      else
        echo "ERROR encountered while stopping Application server ${WLB_SA}"
        exit 1
      fi
    done
  fi
fi

### WAS BASE

if [[ "${WAS_PRODUCT}" == "ALL" || "${WAS_PRODUCT}" == "wba" ]];then
  if [ "${JVM_WBA}" == "Yes" ];then
    for WBA_SA in $(find /apps/WebSphere${WBA_VI}/ -name server.xml 2>/dev/null | grep ${SA_WAS} | awk -F"/" '{print $(NF-1)}' | sort -u ); do
    # on arrete les JVM
      echo "Stopping WAS Base Application server ${WBA_SA}..."
      cd /apps/toolboxes/web/WasOperating
      /apps/toolboxes/web/WasOperating/WAS_Manage.ksh stop ${WBA_SA} wba 1>/dev/null 2>&1
      if [ $? -eq 0 ];then
        echo " "
        echo "The Application server ${WBA_SA} has been successfully stopped"
        # Si OK, on s'assure que l'admserver est bien up
        echo "Starting admserver"
        /apps/toolboxes/web/WasOperating/WAS_Manage.ksh start admserver 1>/dev/null 2>&1
        if [ $? -eq 0 ];then
          echo "Application Server ${WBA_SA} cleaning..."
          cd /apps/toolboxes/web/CreateEnvWas
          /apps/toolboxes/web/CreateEnvWas/deleteEnvWasCMD.ksh jvm ${WBA_VI} ${WBA_SA} y 1>/dev/null 2>&1
          if [ $? -eq 0 ];then
            for wba_dir_sa in $(find /apps/WebSphere${WBA_VI}/profiles/ -type d -name ${WBA_SA} 2>/dev/null);do
              echo "Removing directory ${wba_dir_sa}..."
              rm -fr ${wba_dir_sa}
              if [ $? -ne 0 ];then
                echo "ERROR encountered while removing directory ${wba_dir_sa}"
                mkdir /apps/WebSphere${WBA_VI}/profiles/node/servers/${wba_dir_sa} 1>/dev/null 2>&1
                exit 1
              fi
            done
            echo "Application Server ${WBA_SA} SUCCESSFULLY Cleaned"
          else
            echo "ERROR encountered while cleaning Application Server ${WBA_SA}"
            echo "Check with the following command: /apps/toolboxes/web/CreateEnvWas/deleteEnvWasCMD.ksh jvm ${WBA_VI} ${WBA_SA} y "
            exit 1
          fi
        else
          echo "ERROR encountered while starting admserver"
          echo "Check with the following command: /apps/toolboxes/web/WasOperating/WAS_Manage.ksh start admserver"
          exit 1
        fi
      else
        echo "ERROR encountered while stopping Application Server ${WBA_SA}"
        echo "Check with the following command: /apps/toolboxes/web/WasOperating/WAS_Manage.ksh stop ${WBA_SA} wba"
        exit 1
      fi
    done
    # Nettoyage des IHS
    for WBA_SW in `find ${APP_DIR}/ihs/ -name sw* -print 2>/dev/null | awk -F '/' '{print"/"$2"/"$3"/"$4"/"$5}' | sort -u | grep -v temp | awk -F"/" '{print $5 }'`;do
      echo "IHS ${WBA_SW} cleaning..."
      cd /apps/toolboxes/web/CreateEnvWas
      /apps/toolboxes/web/CreateEnvWas/deleteEnvWasCMD.ksh web ${WBA_VI} ${WBA_SW} y 1>/dev/null 2>&1
      if [ $? -eq 0 ];then
        echo "IHS ${WBA_SW} SUCCESSFULLY Cleaned"
      else
      echo "ERROR encountered while cleaning IHS ${WBA_SW}"
      echo "Check with the following command: /apps/toolboxes/web/CreateEnvWas/deleteEnvWasCMD.ksh web ${WBA_VI} ${WBA_SW} y "
      exit 1
    fi
    done
    # Si OK, on supprime les FS correspondants
    systemctl daemon-reload > /dev/null 2>&1
    for WBA_SA in $(find ${APP_DIR}/was/ -name ${SA_WAS} -print 2>/dev/null | grep -v temp | awk -F"/" '{print $5 }' | sort -u); do
      echo " "
      echo "Removing filesystems for Application server ${WBA_SA}..."
      WBA_FS_LOG=$(find ${APP_LOG}/was/ -name ${WBA_SA} -print 2>/dev/null | awk -F '/' '{print"/"$2"/"$3"/"$4"/"$5"/"$6}' | sort -u | grep -v temp | grep -v servers | grep -v pid | awk -F '/was' '{print$1}')
      WBA_FS=$(find ${APP_DIR}/was/ -name ${WBA_SA} -print 2>/dev/null | awk -F '/' '{print"/"$2"/"$3"/"$4"/"$5}' | sort -u | grep -v temp | grep -v servers | grep -v pid | awk -F '/was' '{print$1}')
      echo " "
      if [[ "${WBA_FS_LOG}" != "" ]];then
        cd ${WBA_FS_LOG}
        WBA_LV_LOG=lv_$(df . | grep 'lv_log' | grep -v rootvg | awk -F 'lv_' '{print$2}' | awk '{print$1}')
        cd /apps/toolboxes/exploit/bin
        sleep 1
        if [[ "${WBA_LV_LOG}" == "lv_" ]];then
          echo "The logs Logical Volume may be on rootvg"
          echo "${WBA_FS_LOG}" | grep /applis/logs/ 1>/dev/null 2>&1
          if [ $? -eq 0 ];then
            echo "Removing directory ${WBA_FS_LOG}..."
            rm -ri ${WBA_FS_LOG}
            if [ $? -ne 0 ];then
              echo "ERROR encountered while removing directory ${WBA_FS_LOG}"
              exit 1
            fi
          fi
        else
          /apps/toolboxes/exploit/bin/exploit_remove-fs.ksh lv=${WBA_LV_LOG}
          if [ $? -eq 0 ];then
            echo "The ${WBA_LV_LOG} logical volume has been deleted SUCCESSFULLY"
          else
            echo "ERROR encountered while deleting logical volume ${WBA_LV_LOG}"
            exit 1
          fi
        fi
      else
        echo "No log directory was found for ${WBA_SA}"
        echo " "
      fi
      if [[ "${WBA_FS}" != "" ]];then
        cd ${WBA_FS}
        WBA_LV=lv_$(df . | grep 'lv_' | grep -v rootvg | awk -F 'lv_' '{print$2}' | awk '{print$1}')
        cd /apps/toolboxes/exploit/bin
        sleep 1
        if [[ "${WBA_LV}" == "lv_" ]];then
          echo "The Application server Logical Volume may be on rootvg"
          echo "${WBA_FS}" | grep /applis/ 1>/dev/null 2>&1
          if [ $? -eq 0 ];then
            echo "Removing directory ${WBA_FS}..."
            rm -ri ${WBA_FS}
            if [ $? -ne 0 ];then
              echo "ERROR encountered while removing directory ${WBA_FS}"
              exit 1
            fi
          fi
        else
          /apps/toolboxes/exploit/bin/exploit_remove-fs.ksh lv=${WBA_LV}
          if [ $? -eq 0 ];then
            echo "The ${WBA_LV} logical volume has been deleted SUCCESSFULLY"
          else
            echo "ERROR encountered while deleting logical volume ${WBA_LV}"
            exit 1
          fi
        fi
      else
        echo "No directory was found for ${WBA_FS}"
        echo " "
      fi
    done
  fi
fi

### WAS ND
if [[ "${WAS_PRODUCT}" == "ALL" || "${WAS_PRODUCT}" == "wnd" ]];then
  if [ "${JVM_WND}" == "Yes" ];then
    for WND_SA in $(find /apps/WebSphere${WND_VI}/ -name server.xml 2>/dev/null | grep ${SA_WAS} | awk -F"/" '{print$(NF-1)}' | sort -u);do
    # on arrete les JVM
      echo "Stopping WAS ND Application server ${WND_SA}..."
      cd /apps/toolboxes/web/WasOperating
      /apps/toolboxes/web/WasOperating/WAS_Manage.ksh stop ${WND_SA} wnd 1>/dev/null 2>&1
      if [ $? -eq 0 ];then
        echo " "
        echo "The Application server ${WND_SA} has been successfully stopped"
        # Si OK, on s'assure que le dmgr est bien up
        echo "Starting DMGR"
        /apps/toolboxes/web/WasOperating/WAS_Manage.ksh start dmgr 1>/dev/null 2>&1
        if [ $? -eq 0 ];then
          echo "Application Server ${WND_SA} cleaning..."
          cd /apps/toolboxes/web/CreateEnvWas
          /apps/toolboxes/web/CreateEnvWas/deleteEnvWasCMD.ksh jvm ${WND_VI} ${WND_SA} y 1>/dev/null 2>&1
          if [ $? -eq 0 ];then
            for wnd_dir_sa in $(find /apps/WebSphere${WND_VI}/profiles/ -type d -name ${WND_SA} 2>/dev/null);do
              echo "Removing directory ${wnd_dir_sa}..."
              rm -fr ${wnd_dir_sa}
              if [ $? -ne 0 ];then
                echo "ERROR encountered while removing directory ${wnd_dir_sa}"
                mkdir /apps/WebSphere${WND_VI}/profiles/node/servers/${wnd_dir_sa} 1>/dev/null 2>&1
                exit 1
              fi
            done
            echo "Application Server ${WND_SA} SUCCESSFULLY Cleaned"
          else
            echo "ERROR encountered while cleaning Application Server ${WND_SA}"
            echo "Check with the following command: /apps/toolboxes/web/CreateEnvWas/deleteEnvWasCMD.ksh jvm ${WND_VI} ${WND_SA} y "
            exit 1
          fi
        else
          echo "ERROR encountered while starting DMGR"
          echo "Check with the following command: /apps/toolboxes/web/WasOperating/WAS_Manage.ksh start dmgr"
          exit 1
        fi
      else
        echo "ERROR encountered while stopping Application Server ${WND_SA}"
        echo "Check with the following command: /apps/toolboxes/web/WasOperating/WAS_Manage.ksh stop ${WND_SA} wnd"
        exit 1
      fi
    done
    # Nettoyage des IHS
    for WND_SW in $(find ${APP_DIR}/ihs/ -name sw-* -print 2>/dev/null | grep -v temp | awk -F"/" '{print $5 }' | sort -u);do
      echo "IHS ${WND_SW} cleaning..."
      cd /apps/toolboxes/web/CreateEnvWas
      /apps/toolboxes/web/CreateEnvWas/deleteEnvWasCMD.ksh web ${WND_VI} ${WND_SW} y 1>/dev/null 2>&1
      if [ $? -eq 0 ];then
        for wnd_dir_sw in $(find /apps/WebSphere85/profiles/ -type d -name ${WND_SW} 2>/dev/null);do
            echo "Removing directory ${wnd_dir_sw}..."
            rm -fr ${wnd_dir_sw}
            if [ $? -ne 0 ];then
              echo "ERROR encountered while removing directory ${wnd_dir_sw}"
              exit 1
            fi
          done
        echo "IHS ${WND_SW} SUCCESSFULLY Cleaned"
      else
        echo "ERROR encountered while cleaning IHS ${WND_SW}"
        echo "Check with the following command: /apps/toolboxes/web/CreateEnvWas/deleteEnvWasCMD.ksh web ${WND_VI} ${WND_SW} y "
        exit 1
      fi
    done
    # Si OK, on supprime les FS correspondants
    systemctl daemon-reload > /dev/null 2>&1
    for WND_SA in $(find ${APP_DIR}/was/ -name ${SA_WAS} -print 2>/dev/null | grep -v temp | awk -F"/" '{print $5 }' | sort -u); do
      echo " "
      echo "Removing filesystems for Application server ${WND_SA}..."
      WND_FS_LOG=$(find ${APP_LOG}/was/ -name ${WND_SA} -print 2>/dev/null | awk -F '/' '{print"/"$2"/"$3"/"$4"/"$5"/"$6}' | grep -v temp | grep -v servers | grep -v pid | awk -F '/was' '{print$1}' | sort -u)
      WND_FS=$(find ${APP_DIR}/was/ -name ${WND_SA} -print 2>/dev/null | awk -F '/' '{print"/"$2"/"$3"/"$4"/"$5}' | grep -v temp | grep -v servers | grep -v pid | awk -F '/was' '{print$1}' | sort -u)
      echo " "
      if [[ "${WND_FS_LOG}" != "" ]];then
        cd ${WND_FS_LOG}
        WND_LV_LOG=lv_$(df . | grep 'lv_log' | grep -v rootvg | awk -F 'lv_' '{print$2}' | awk '{print$1}')
        cd /apps/toolboxes/exploit/bin
        sleep 1
        if [[ "${WND_LV_LOG}" == "lv_" ]];then
          echo "The logs Logical Volume was may be on rootvg"
          echo "${WND_FS_LOG}" | grep /applis/logs/ 1>/dev/null 2>&1
          if [ $? -eq 0 ];then
            echo "Removing directory ${WND_FS_LOG}..."
            rm -ri ${WND_FS_LOG}
            if [ $? -ne 0 ];then
              echo "ERROR encountered while removing directory ${WND_FS_LOG}"
              exit 1
            fi
          fi
        else
          /apps/toolboxes/exploit/bin/exploit_remove-fs.ksh lv=${WND_LV_LOG}
          if [ $? -eq 0 ];then
            echo "The ${WND_LV_LOG} logical volume has been deleted SUCCESSFULLY"
          else
            echo "ERROR encountered while deleting logical volume ${WND_LV_LOG}"
            exit 1
          fi
        fi
      else
        echo "No log directory was found for ${WND_SA}"
        echo " "
      fi
      if [[ "${WND_FS}" != "" ]];then
        cd ${WND_FS}
        WND_LV=lv_$(df . | grep 'lv_' | grep -v rootvg | awk -F 'lv_' '{print$2}' | awk '{print$1}')
        cd /apps/toolboxes/exploit/bin
        sleep 1
        if [[ "${WND_LV}" == "lv_" ]];then
          echo "The Application server Logical Volume may be on rootvg"
          echo "${WND_FS}" | grep /applis/ 1>/dev/null 2>&1
          if [ $? -eq 0 ];then
            echo "Removing directory ${WND_FS}..."
            rm -ri ${WND_FS}
            if [ $? -ne 0 ];then
              echo "ERROR encountered while removing directory ${WND_FS}"
              exit 1
            fi
          fi
        else
          /apps/toolboxes/exploit/bin/exploit_remove-fs.ksh lv=${WND_LV}
          if [ $? -eq 0 ];then
            echo "The ${WND_LV} logical volume has been deleted SUCCESSFULLY"
          else
            echo "ERROR encountered while deleting logical volume ${WND_LV}"
            exit 1
          fi
        fi
      else
        echo "No directory was found for ${WND_SA}"
        echo " "
      fi
    done
  fi
fi

if [ "${WAS_APPLICATION}" != "" ];then
  grep -w ${WAS_APPLICATION} /etc/bp2i_admweb.cfg 2>/dev/null | grep -v '#' 1>/dev/null 2>&1
  if [[ $? -eq 0 ]];then
    echo "WARNING: There is, at least, one reference to the provided was application in /etc/bp2i_admweb.cfg"
    echo "This file is used for the WebSphere components monitoring"
    echo "You should comment or delete the according lines to disable monitoring"
  fi
else
  echo "WARNING: You should read the /etc/bp2i_admweb.cfg file to check if there is no WebSphere application or ihs, currently, monitored"
fi

