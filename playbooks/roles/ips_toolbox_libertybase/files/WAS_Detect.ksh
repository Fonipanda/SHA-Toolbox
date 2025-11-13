#!/bin/ksh
#==============================================================================
# 2018/08/03 : David PERIN : Script pour detecter les produits WAS installés
#==============================================================================
# set -x

#------------
#- Variables
#------------

WLC="No"
WLB="No"
WND="No"
WBA="No"
DMGR="No"
ADMSERVER="No"


chk_was="$1"
[[ "${chk_was}" = "" ]] && chk_was="all" && echo "===================================" && echo " Detections des produits WebSphere:"

#------------------------------------------------------------
#- Detection des produits installes et recuperation du WAS_VI
#------------------------------------------------------------

ls /apps/WebSphere* > /dev/null 2>&1
if [ $? -ne 0 ];then
  echo "No WebSphere product was detected (/apps/WebSphere*)"
  exit
fi

# Liberty Core
if [[ "${chk_was}" = "all" || "${chk_was}" = "wlc" ]];then
  test -f /apps/WebSphere*/LibertyCore/bin/productInfo
  if [ $? -eq 0 ];then
    WLC="Yes"
    WLC_VI=$(find /apps/WebSphere*/LibertyCore/bin/ -name productInfo  | awk -F"/" '{print $3}' | sed -e s/WebSphere//)
    if [ "${WLC_VI}" = "" ];then
      WLC_VI=LibertyCore
    fi
    echo "  - WLC=${WLC}"
    echo "  - WLC_VI=${WLC_VI}"
  else
    echo "  - WLC=${WLC}"
  fi
fi

# Liberty Base
if [[ "${chk_was}" = "all" || "${chk_was}" = "wlb" ]];then
  test -f /apps/WebSphere*/LibertyBase/bin/productInfo
  if [ $? -eq 0 ];then
    WLB="Yes"
    WLB_VI=$(find /apps/WebSphere*/LibertyBase/bin/ -name productInfo  | awk -F"/" '{print $3}' | sed -e s/WebSphere//)
    if [ "${WLC_VI}" = "" ];then
      WLB_VI=LibertyBase
    fi
    echo "  - WLB=${WLB}"
    echo "  - WLB_VI=${WLB_VI}"
  else
    echo "  - WLB=${WLB}"
  fi
fi

# WAS ND & Base(& admserver)
if [[ "${chk_was}" = "all" || "${chk_was}" = "wnd" || "${chk_was}" = "wba" || "${chk_was}" = "dmgr" ]];then
  for product in $(ls /apps/WebSphere*/AppServer*/bin/versionInfo.sh 2>/dev/null);do
    $product | grep ND | grep installed 1>/dev/null
    if [ $? == 0 ];then
      WND="Yes"
      WND_VI=$(echo $product | awk -F"/" '{print $3}' | sed -e s/WebSphere//)
    fi
    $product | grep BASE | grep installed  1>/dev/null
    if [ $? == 0 ];then
      ADMSERVER="Yes"
      WBA="Yes"
      WBA_VI=$(echo $product | awk -F"/" '{print $3}' | sed -e s/WebSphere//)
    fi
  done
fi

if [[ "${chk_was}" = "all" || "${chk_was}" = "wba" ]];then
  if [[ "${WBA}" = "Yes" ]];then
    echo "  - WBA=${WBA}"
    echo "  - WBA_VI=${WBA_VI}"
    echo "  - ADMSERVER=${ADMSERVER}"
  else
    echo "  - WBA=${WBA}"
    echo "  - ADMSERVER=${ADMSERVER}"
  fi
fi

if [[ "${chk_was}" = "all" || "${chk_was}" = "wnd" ]];then
  if [[ "${WND}" = "Yes" ]];then
    echo "  - WND=${WND}"
    echo "  - WND_VI=${WND_VI}"
  else
    echo "  - WND=${WND}"
  fi
fi

# DMGR
if [[ "${chk_was}" = "all" || "${chk_was}" = "dmgr" ]];then
  ls /apps/WebSphere${WND_VI}/profiles/dmgr/bin/dmgradmin 1>/dev/null 2>&1
  if [ $? -eq 0 ];then
    DMGR="Yes"
  fi
  echo "  - DMGR=${DMGR}"
fi

