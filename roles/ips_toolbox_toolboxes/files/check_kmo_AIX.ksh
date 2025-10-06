#!/bin/ksh
#set -x

#-----------------------------------------------------------------------------#
# Usage
#-----------------------------------------------------------------------------#

usage()
{
printf "\nSyntax: "
printf "\n\n\033[36m update_kmo.ksh\033[33m url_source\033[0m\n\n"
printf "OPTIONS"
printf "\n  \033[33m url_source \033[0m     : Optionnal: To specify another URL http than the standard one\n\n"
exit 1
}

#-----------------------------------------------------------------------------#
# Variables definition
#-----------------------------------------------------------------------------#
# --- Connection data ---
SRC_SERVER="10.255.19.200"    # NIMPROD
HTTP_PORT="8080"
HTTP_URL="http://${SRC_SERVER}:${HTTP_PORT}/toolboxes"
# -----------------------

# --- Misc variables ---
CURL_CMD=$(which curl 2> /dev/null)

# ----------------------

# --- Parameter ---
if [[ -n $1 ]];then
  echo $1 | grep 'http' >/dev/null
  if [[ $? -eq 0 ]];then
    HTTP_URL=${1}
  else
    echo "ERROR : URL syntax error ($1)"
    usage
  fi
fi

# -----------------

# --- Package infos ---
LATEST_VER=""
ALL_VER=""
# ---------------------

# -----
# MAIN
# -----

# Reset default color when programm is interupted
trap "clear_style ; exit 1" 2 3 6 15

# Checking versions
# -----------------
# Getting the version of the latest package from the repository
# - Try with curl
if [[ -n "${CURL_CMD}" ]];then
  LATEST_VER=$(${CURL_CMD} -s ${HTTP_URL}/ --list-only 2>/dev/null | grep IPS_TOOLBOXES | grep -v _IPS | grep LINUX-AIX_GEN_BE-FR-IT | grep _1.0_ | awk -F ' href="' '{print$2}' | awk -F '">' '{print$1}' | awk -F '_' '{print$3" "$4}' | sed 's/ 1.0//g' | sed 's/^1.0 //g' | sort -u | sort -nr | head -1 )
  if [[ "${LATEST_VER}" != "" ]];then
    YEAR=$(echo "${LATEST_VER}" | awk -F '.' '{print$1}')
    SEMESTER=$(echo "${LATEST_VER}" | awk -F '.' '{print$2}')
    GREP_VER="${YEAR}.${SEMESTER}"
    if [[ "${SEMESTER}" != "2" && "${SEMESTER}" != "1" ]];then
      echo "ERROR : unable to retrieve the current toolbox version. Verify the repository (${HTTP_URL})"
      exit 1
    fi
    if [[ "${SEMESTER}" == "2" ]];then
      GREP_OLD_VER="${YEAR}.1"
    else
      YEAR_OLD=$((YEAR-1))
      GREP_OLD_VER="${YEAR_OLD}.2"
    fi
  else
    echo "ERROR : unable to retrieve the current toolbox version. Verify access to the repo (${HTTP_URL})"
    exit 1
  fi
   OTHER_VER1=$(${CURL_CMD} -s ${HTTP_URL}/ --list-only | grep IPS_TOOLBOXES | grep -v _IPS | grep LINUX-AIX_GEN_BE-FR-IT | grep _1.0_ | awk -F ' href="' '{print$2}' | awk -F '">' '{print$1}' | awk -F '_' '{print$3" "$4}' | sed 's/ 1.0//g' | sed 's/^1.0 //g'| grep ${GREP_OLD_VER} | grep -v ${LATEST_VER} | sort -u | tr '\n' ' ' | sed 's/ $/\\n/' )
  OTHER_VER2=$(${CURL_CMD} -s ${HTTP_URL}/ --list-only | grep IPS_TOOLBOXES | grep -v _IPS | grep LINUX-AIX_GEN_BE-FR-IT | grep _1.0_ | awk -F ' href="' '{print$2}' | awk -F '">' '{print$1}' | awk -F '_' '{print$3" "$4}' | sed 's/ 1.0//g' | sed 's/^1.0 //g' | grep ${GREP_VER} | grep -v ${LATEST_VER} | sort -u | tr '\n' ' ' | sed 's/ $/\\n/')
else
  echo "ERROR : curl command is not available"
  exit 1
fi

OTHER_VER=$(echo "${OTHER_VER1} ${OTHER_VER2}" | sed 's/ $/\\n/')

echo "Last available version: ${LATEST_VER}"
echo "Other available versions: ${OTHER_VER}"

