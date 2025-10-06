#set -x

web_product=$1
ear_war_file_name=$2
deploy_xml_name=$3
files_path=$4

# check variables
if [[ "${web_product}" != "wlc" && "${web_product}" != "wlb" && "${web_product}" != "wnd" && "${web_product}" != "wba" ]];then
  echo "web_product (fisrt parameter) must be: wlc, wlb, wba or wnd" && exit 1
fi

[ "${ear_war_file_name}" == "" ] && echo "Error:No ear/war file was specified" && exit 1

[ "${deploy_xml_name}" == "" ] && echo "Error:No xml file was specified" && exit 1

[ "${files_path}" == "" ] && echo "Error:The files path was not specified" && exit 1


# Delete last slash in the files path if exists
files_path2=${files_path%/}

# set variables and control files
ear_war_file_path="${files_path2}/${ear_war_file_name}"
deploy_xml_path="${files_path2}/${deploy_xml_name}"

[ ! -f ${ear_war_file_path} ] && echo "Error:ear/war file does not exist" && exit 1
[ ! -f ${deploy_xml_path} ] && echo "Error:xml file does not exist" && exit 1

Count_xml=$(ls ${files_path2}/*applicationPropertiesWAS*.xml | wc -l)
[[ "${Count_xml}" != "1" ]] && echo "Error:More than one xml file in ${files_path2}" && exit 1

check_xml_1=$(grep -w WAS_VI ${deploy_xml_path} | grep value | head -1)
[ "${check_xml_1}" == "" ] && echo "Error:WAS_VI not specified in the xml file" && exit 1

VI_xml=$(grep -w WAS_VI ${deploy_xml_path} | grep value | head -1 | awk -F "\"" '{print$4}')

# Check WebSphere binaries

if [[ "${web_product}" == "wlc" ]];then
  find /apps/WebSphere${VI_xml}/ -name LibertyCore -type d 1>/dev/null 2>&1
  if [ $? == 0 ];then
    VI_1=wlc
    if [[ "${VI_xml}" == "" ]];then
      VI_2=LibertyCore
    else
      VI_2=${VI_xml}
    fi
  else
    echo "Error: Liberty Core product not installed in /apps/WebSphere${VI_xml}"
    exit 1
  fi
fi

if [[ "${web_product}" == "wlb" ]];then
  find /apps/WebSphere${VI_xml}/ -name LibertyBase -type d 1>/dev/null 2>&1
  if [ $? == 0 ];then
    VI_1=wlb
    if [[ "${VI_xml}" == "" ]];then
      VI_2=LibertyBase
    else
      VI_2=${VI_xml}
    fi
  else
    echo "Error: Liberty Base product not installed in /apps/WebSphere${VI_xml}"
    exit 1
  fi
fi

if [[ "${web_product}" == "wnd" ]];then
  VI_1="No"
  for product in $(ls /apps/WebSphere${VI_xml}/AppServer*/bin/versionInfo.sh);do
    $product | grep ND | grep installed 1>/dev/null
    if [ $? == 0 ];then
      VI_1=${VI_xml}
      VI_2=${VI_xml}
      break
    fi
  done
  if [[ "${VI_1}" == "No" ]];then
    echo "Error: WAS ND product not installed in /apps/WebSphere${VI_xml}"
    exit 1
  else
    /apps/toolboxes/web/WasOperating/WAS_Manage.ksh start dmgr_${VI_xml}
    /apps/toolboxes/web/WasOperating/WAS_Manage.ksh start nodeagent_${VI_xml}
    if ps -ef | grep -v grep | grep java | grep "was " | grep /apps/WebSphere${VI_xml} | grep -q dmgr ; then
      PID=`ps -efd | grep -v grep |grep -v DUSER_INSTALL_ROOT|grep -v bp2i-perfservlet_server| grep java |grep "was "|grep -w dmgr | grep /apps/WebSphere${VI_xml} | awk -F" " '{print $2}'`
      if [[ -z ${PID} ]] ; then
        echo "Error: DMGR seems to be stopped. You need to start it before deploying any ear or war. If the DMGR is already started, try ro restart it."
        exit 1
      fi
    else
      echo "Error: DMGR seems to be stopped. You need to start it before deploying any ear or war. If the DMGR is already started, try ro restart it"
      exit 1
    fi
    if ps -ef | grep -v grep | grep java | grep "was " | grep /apps/WebSphere${VI_xml} | grep -q nodeagent ; then
      PID=`ps -efd | grep -v grep |grep -v DUSER_INSTALL_ROOT|grep -v bp2i-perfservlet_server| grep java |grep "was "|grep -w nodeagent | grep /apps/WebSphere${VI_xml} | awk -F" " '{print $2}'`
      if [[ -z ${PID} ]] ; then
        echo "Error: Nodeagent seems to be stopped. You need to start it before deploying any ear or war. If the nodeagent is already started, try ro restart it."
        exit 1
      fi
    else
      echo "Error: Nodeagent seems to be stopped. You need to start it before deploying any ear or war. If the nodeagent is already started, try ro restart it."
      exit 1
    fi  
  fi
fi

if [[ "${web_product}" == "wba" ]];then
  VI_1="No"
  for product in $(ls /apps/WebSphere${VI_xml}/AppServer*/bin/versionInfo.sh);do
    $product | grep BASE | grep installed  1>/dev/null
    if [ $? == 0 ];then
      VI_1=${VI_xml}
      VI_2=${VI_xml}
      break
    fi
  done
  if [[ "${VI_1}" == "No" ]];then
    echo "Error: WAS Base product not installed in /apps/WebSphere${VI_xml}"
    exit 1
  else
    /apps/toolboxes/web/WasOperating/WAS_Manage.ksh start admserver_${VI_xml}
    if ps -ef | grep -v grep | grep java | grep "was " | grep /apps/WebSphere${VI_xml} | grep -q admserver ; then
      PID=`ps -efd | grep -v grep |grep -v DUSER_INSTALL_ROOT|grep -v bp2i-perfservlet_server| grep java |grep "was "|grep -w admserver | grep /apps/WebSphere${VI_xml} | awk -F" " '{print $2}'`
      if [[ -z ${PID} ]] ; then
        echo "Error: admserver seems to be stopped. You need to start it before deploying any ear or war. If the admserver is already started, try ro restart it."
        exit 1
      fi
    else
      echo "Error: admserver seems to be stopped. You need to start it before deploying any ear or war. If the admserver is already started, try ro restart it."
      exit 1
    fi
  fi
fi

# Launch Deployement

chown -R root:web ${files_path2}
chmod -R 775 ${files_path2}

su - was -c "cd /apps/toolboxes/web/ManageDeployEarWas/DeployEarWas; ./launcher_deploy.ksh ${VI_2} ${files_path2} y ${VI_1} 1>/dev/null 2>&1"
if [[ $? != 0 ]];then
  echo "Error(s) encountered during EAR/WAR Deployment"
  exit 1
else
  echo "Application ${ear_war_file_name} has been succesfully deployed"
  exit 0
fi

