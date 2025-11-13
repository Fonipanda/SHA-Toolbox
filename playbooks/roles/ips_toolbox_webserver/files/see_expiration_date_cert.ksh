#!/bin/ksh
#set -x

#loading of the library of the useful functions and log

# Trace  logged
#CURRENT_DIR=`pwd`
CURRENT_DIR=/apps/toolboxes/web/ManageCertificates
export sv_NomScript='see_expiration_date_cert.ksh'
export sv_LOGFILE=`echo ${CURRENT_DIR}`'/logs/TRACE_'`echo ${sv_NomScript}`'_'`date +"%Y%m%d_%H%M"`'.log'

# call function trace log
. $CURRENT_DIR/lib/trace_log.ksh

# call function lib
. $CURRENT_DIR/lib/function_lib.ksh

#--------
#- Usage
#--------

usage()
{
echo "Syntax ERROR"
echo "Usage:"
echo "-------------------------------------------------------------"
echo " - 2 available modes: "
echo "          - cmd (command line)"
echo "          - no (interactive mode)"
echo "-------------------------------------------------------------"
echo "- cmd mode: $(basename ${0}) cmd KDB_PATH (KDB_Password in option) (quiet in option)"
echo "   - KDB_PATH: Full path to kdb file (example: /apps/toolboxes/web/ManageCertificates/generatecert/myapp.group.echonet//myapp.group.echonet.kdb)"
echo "   - KDB_Password (optionnal: if no stash file exists in the kdb repository)"
echo "   - quiet[optionnal]: display only result in command line"
echo "-------------------------------------------------------------"
echo "- interactive mode: $(basename ${0}) no"
echo "-------------------------------------------------------------"
exit 1
}

#################################
#                               #
#       FUNCTIONS               #
#                               #
#################################

# Ecrit la chaine de caractere passee en parametre avec la couleur indiquee
# USAGE : println %couleur% %chaine%
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

        if [ ${OS} == "Linux" ] ; then
                OPTION="-e"
        fi

        echo ${OPTION} "${TEXT}"
}

# Ecrit une chaine de caracteres encadree selon la longueur de la chaine
# et avec la couleur demandee (appel a la fonction println)
# USAGE : printTitle %couleur% %chaine%
printTitle()
{
        if [[ -z $2 ]] ; then
                COLORTITLE=""
                TEXTTITLE=$1
        else
                COLORTITLE=$1
                TEXTTITLE=$2
        fi

        LENGTH=${#TEXTTITLE}
        INDEX=0
        let INDEXMAX=${LENGTH}+6
        TOUR=""

        while [ ${INDEX} != ${INDEXMAX} ] ; do
                TOUR="${TOUR}-"
                let INDEX=${INDEX}+1
        done

        println ${COLORTITLE} ${TOUR}
        println ${COLORTITLE} "|  ${TEXTTITLE}  |"
        println ${COLORTITLE} ${TOUR}
}

exitProgram()
{
        case $1 in
                4) printTitle rouge "ERROR:Some parameters are missing "
                   if [[ "${ACTION_CERT}" != "cmd" ]];then
                     echo "Press enter key to continue..." && read
                   fi;;
                 5) printTitle rouge "Error during treatment";;
                13) printTitle rouge "Operation aborted by user"
                    echo "Press enter key to continue..." && read;;
                14) printTitle rouge "Unrecognized answer"
                    echo "Press enter key to continue..." && read;;
                *) printTitle rouge "Unknown error return code" ;;
        esac
        exit $1
}

list_kdb()
{
find /apps/toolboxes/web/ManageCertificates/generatecert -name *.kdb 2>/dev/null | awk -F '/' '{print$7}' | sort -u
}

validate_kdb_password()
{
${CMD_GSKCM} -cert -list all -db "${KDB_FULLPATH}" -pw "${PASSWRD}" 1>/var/tmp/list_certificate.txt 2>&1
if [[ $? -ne 0 ]] ; then
  fEcritLog "ERROR encountered while checking acces to the KDB ${KDB_FULLPATH}" $LOG_ERREUR
  printTitle rouge "ERROR encountered while checking acces to the KDB ${KDB_FULLPATH}"
  while read line;do
    println rouge "${line}"
  done </var/tmp/list_certificate.txt
  if [[ "${ACTION_CERT}" != "cmd" ]];then
    echo "Press enter key to continue..." && read
  fi
  exit 1
fi
}

see_expiration_date_certificat_nolist()
{
println vert "Looking for KDB generated with toolbox...:"
list_kdb
echo ""
println vert "Enter a kdb name beyond the kdb found above"
read URL

if [[ -z $URL ]] ; then
  fEcritLog "ERROR: kdb parameter is mandatory" $LOG_ERREUR
  printTitle rouge "ERROR: kdb parameter is mandatory"
  echo "Press enter key to continue..." && read
  exit 1
fi

println vert "Enter path of the directory containing the kdb file (if kdb in /apps/toolboxes/web/ManageCertificates/generatecert/${URL}, just press Enter):"
if [[ "${OS}" == "Linux" ]];then
  KDBPATH=$(${DIR_CERT_TOOLS}/read_bash)
else
  read KDBPATH
fi

if [[ -z $KDBPATH ]]; then
  KDBPATH=/apps/toolboxes/web/ManageCertificates/generatecert/${URL}
  find ${KDBPATH} -name ${URL}.kdb 2>/dev/null | grep kdb 1>/dev/null 2>&1
  if [[ $? -ne 0 ]] ; then
    fEcritLog "No KDB has been found in /apps/toolboxes/web/ManageCertificates/generatecert/${URL}" $LOG_ERREUR
    printTitle rouge "No KDB has been found in /apps/toolboxes/web/ManageCertificates/generatecert/${URL}"
    echo "Press enter key to continue..." && read
    exit 1
  else
    KDBPATH=/apps/toolboxes/web/ManageCertificates/generatecert/${URL}
  fi
else
  KDBPATH=$(echo "$KDBPATH" | sed 's#/$##g')
  echo "$KDBPATH" | grep .kdb 1>/dev/null 2>&1
  if [[ $? -eq 0 ]] ; then
    ls $KDBPATH 1>/dev/null 2>&1
    if [[ $? -eq 0 ]] ; then
      KDBPATH=$(dirname $KDBPATH)
    else
      fEcritLog "$KDBPATH not found" $LOG_ERREUR
      printTitle rouge "$KDBPATH not found"
      echo "Press enter key to continue..." && read
      exit 1
    fi
  else
    find ${KDBPATH} -name ${URL}.kdb 2>/dev/null | grep kdb 1>/dev/null 2>&1
    if [[ $? -ne 0 ]] ; then
      fEcritLog "No KDB has been found in ${KDBPATH}" $LOG_ERREUR
      printTitle rouge "No KDB has been found in ${KDBPATH}"
      echo "Press enter key to continue..." && read
      exit 1
    fi
  fi
fi
KDB_FULLPATH=${KDBPATH}/${URL}.kdb

PASSWRD=$(ls ${KDBPATH}/${URL}.sth 2>/dev/null)

if [[ -z ${PASSWRD} ]] ; then
  println vert "Stash file (${KDBPATH}/${URL}.sth) doesn't exist. Enter the password set when the kdb file was generated:"
  PASSWRD=$(${DIR_CERT_TOOLS}/silent_pwd)
  if [[ -z $PASSWRD ]] ; then
    fEcritLog "The password of the kdb file is empty" $LOG_ERREUR
    printTitle rouge "Password is a mandatory parameter"
    echo "Press enter key to continue..." && read
    exit 1
  else
    validate_kdb_password
  fi
fi

test_variables

changeDir ${KDBPATH}

see_expiration_date_certificats_kdb ${URL} ${PASSWRD} ${KDBPATH}

changeDir ${HOME_CERT}

}

see_expiration_date_certificat_command()
{
KDB_FULLPATH=$1
PASSWRD=$2

echo "$KDB_FULLPATH" | grep .kdb 1>/dev/null 2>&1
if [[ $? -eq 0 ]] ; then
  ls $KDB_FULLPATH 1>/dev/null 2>&1
  if [[ $? -ne 0 ]] ; then
    fEcritLog "KDB $KDB_FULLPATH can not be found" $LOG_ERREUR
    printTitle rouge "KDB $KDB_FULLPATH can not be found"
    exit 1
  fi
else
  fEcritLog "You must enter the full KDB path (example: /applis/XXXX/test.kdb)" $LOG_ERREUR
  printTitle rouge "You must enter the full KDB path (example: /applis/XXXX/test.kdb)"
  exit 1
fi

URL=$(echo $KDB_FULLPATH | awk -F "/" '{print$NF}' | sed 's/.kdb//g')
KDBPATH=$(dirname $KDB_FULLPATH)

if [[ -z ${PASSWRD} ]] ; then
PASSWRD=$(ls ${KDBPATH}/${URL}.sth 2>/dev/null)
else
  validate_kdb_password
fi

if [[ -z ${PASSWRD} ]] ; then
  printTitle rouge "Stash file (${KDBPATH}/${URL}.sth) doesn't exist. You have to provide the KDB Password or put the stash file in ${KDBPATH}"
  exit 1
fi

see_expiration_date_certificats_kdb ${URL} ${PASSWRD} ${KDBPATH}

changeDir ${HOME_CERT}
}

define_pwd_type()
{
echo "${PASSWD}" | grep ${URL}.sth >/dev/null
if [[ $? -eq 0 ]];then
  pass_type="-stashed"
else
  pass_type="-pw ${PASSWD}"
fi
}


see_expiration_date_certificats_kdb()
{
URL=$1
PASSWD=$2
KDBPATH=$3
CURRENT_DATE=$(date +"%Y-%m-%d")

deletefile $DIR_CERT_LOG expiration_date_certificat_in_kdb.log

changeDir ${KDBPATH}

fEcritLog "see the expiration date of the certificates in the kdb file"

fEcritLog "---------------------------------------------------------------"
fEcritLog "-    KDB name : ${URL}.kdb                                 "
fEcritLog "-    KDB file path: ${KDBPATH}                        "
fEcritLog "---------------------------------------------------------------"

define_pwd_type
if [[ "${QUIET}" != "yes" ]];then
  print "======================================================================================"
  echo " Expiration date for all certificates in ${URL}.kdb: (date format YYYY-MM-DD)"
  echo ""
fi
${CMD_GSKCM} -cert -list all -db "${KDB_FULLPATH}" ${pass_type} | grep -v 'Certificates in database' > /var/tmp/list_certificate.txt

while read line;do
  echo "SPLIT_LINE:${line} "
  CMD="${CMD_GSKCM} -cert -details -db "${KDB_FULLPATH}" -label ${line} ${pass_type} "
  echo "$CMD" > $DIR_CERT_TMP/checkdatecertif.ksh
  chmod 755 $DIR_CERT_TMP/checkdatecertif.ksh
  $DIR_CERT_TMP/checkdatecertif.ksh | grep Valid | awk '{ print " SPLIT_LINE:" $12 " " $13 " " $14}'
done </var/tmp/list_certificate.txt > /var/tmp/test_result.txt


awk 'BEGIN{ORS=""} /^SPLIT_LINE/ {print "\n"} {print}' /var/tmp/test_result.txt | grep SPLIT_LINE > /var/tmp/Work_file.txt

while read line;do
  echo $line | egrep -wi "January|February|March|April|May|June|July|August|September|October|November|December" >/dev/null
  if [[ $? -ne 0 ]];then
    println magenta "Error encountered"
    cat /var/tmp/Work_file.txt | sed 's/SPLIT_LINE://g' | sed "/^[ \t]*$/d"
    break
  else
    DATE=$(echo $line | awk -F':' '{print $NF}')
    DATE2=$($DATE_BIN -d "$DATE" +%Y-%m-%d 2>/dev/null)
    if [[ "${DATE2}" == "" ]];then
      DATE2_MONTH=$(echo "$DATE" | awk '{print$1}' | sed s/January/01/g | sed s/February/02/g | sed s/March/03/g | sed s/April/04/g | sed s/May/05/g | sed s/June/06/g | sed s/July/07/g | sed s/August/08/g | sed s/September/09/g | sed s/October/10/g | sed s/November/11/g | sed s/December/12/g)
      DATE2_YEAR=$(echo "$DATE" | awk '{print$NF}')
      DATE2_DAY=$(echo "$DATE" | awk '{print$2}' | sed s/,//g)
      DATE2=$(echo "${DATE2_YEAR}-${DATE2_MONTH}-${DATE2_DAY}")
    fi
    echo $line | sed "s/${DATE}/${DATE2}/g"
  fi
done < /var/tmp/Work_file.txt > /var/tmp/Work_file2.txt

cat /var/tmp/Work_file2.txt | grep "Error encountered" 1>/dev/null 2>&1
if [[ $? -eq 0 ]];then
  cat /var/tmp/Work_file2.txt
  if [[ "${ACTION_CERT}" != "cmd" ]];then
    echo "Press enter key to continue..." && read
  fi
  exitProgram 5
fi

while read line;do
  certificate=$(echo $line | sed 's/^SPLIT_LINE://g' | awk -F " SPLIT_LINE:" '{print$1}')
  date_expire=$(echo $line | awk  -F " SPLIT_LINE:" '{print $2}')
  if [[ "$CURRENT_DATE" < "$date_expire" ]];then
     println vert "$certificate $date_expire"
  else
     println magenta "$certificate $date_expire (EXPIRED)"
  fi
done < /var/tmp/Work_file2.txt

if [[ "${QUIET}" != "yes" ]];then
  print "======================================================================================"
fi
}


test_variables()
{
        if [[ -z ${URL} || -z ${PASSWRD} || -z ${KDBPATH} ]] ; then

                fEcritLog "-----------------------------------------------------" $LOG_ERREUR
                fEcritLog "|    The variables are not correctly defined          |" $LOG_ERREUR
                fEcritLog "-----------------------------------------------------" $LOG_ERREUR
                println magenta "--------------------------------------------"
                println magenta "| The variables are not correctly defined  |"
                println magenta "--------------------------------------------"

                if [[ -z ${URL} ]] ; then stdout="rouge" ; else stdout="magenta" ; fi
                println magenta "|          `println $stdout 'URL:'` `println blanc $URL`"

                if [[ -z ${PASSWRD} ]] ; then stdout="rouge" ; else stdout="magenta" ; fi
                println magenta "|          `println $stdout 'PASSWRD:'` `println blanc "##########"`"

                if [[ -z ${KDBPATH} ]] ; then stdout="rouge" ; else stdout="magenta" ; fi
                println magenta "|          `println $stdout 'KDB FILE PATH:'` `println blanc $KDBPATH`"

                println magenta "\\-----------------------------------------------------/"
                exitProgram 4
        else

                println magenta "----------------------------------------------------------------------"
                println magenta "|           The variables are correctly defined   :                  |"
                println magenta "----------------------------------------------------------------------"
                println magenta "|                      KDB NAME: `println blanc $URL`"
                println magenta "|                   KDB PASSWRD: `println blanc "##########"`"
                println magenta "|                 KDB FILE PATH: `println blanc $KDBPATH`"
                println magenta "----------------------------------------------------------------------"

                println blanc "\t Would you like to see expiration date of the certificates in the kdb file...........[y,Y|n,N]\t:\c"

                read response
                case ${response} in
                      y|Y) println vert "\nCheck expiration date in progress...";;
                      n|N) println rouge "Operation Aborted by user"
                             exitProgram 13;;
                      *) exitProgram 14;;
                esac
        fi
}

######################
# VARIABLES GLOBALES #
######################

PAYS=FR
LOCALITE=PARIS
ETAT=PARIS
SOCIETE="BNP PARIBAS"
SOCIETEI="BNP PARIBAS SA"
KEY_SIZE=2048
ANNEE=$(date | awk '{print $6}')


########################
## MAIN PROGRAMM #######
#######################

export OS=`uname`

if [ ${OS} == "AIX" ] ; then
  DATE_BIN="/usr/linux/bin/date"
else
  DATE_BIN="date"
fi


# input variables
ACTION_CERT=$1

case $ACTION_CERT in
         cmd)
                if  [[ ! ($# -eq 2 || $# -eq 3 || $# -eq 4) ]] ; then
                  fEcritLog "Number of input parameters is not correct : $#" $LOG_ERREUR
                  usage
                fi
                KDB_FULLPATH=$2
                PASSWRD=$3
                QUIET=$4
                [[ "${PASSWRD}" == "quiet" ]] && QUIET="yes" && PASSWRD=""
                [[ "${QUIET}" == "quiet" ]] && QUIET="yes"
                ;;
esac

if [[ "${QUIET}" != "yes" ]];then
  printf "\033c"
fi

#export DIR_TOOLS=`pwd`
#export HOME_CERT=`pwd`
export HOME_CERT=/apps/toolboxes/web/ManageCertificates


# directory log path
DIR_CERT_LOG=$HOME_CERT/logs
DIR_CERT_PARAM=$HOME_CERT/param
DIR_CERT_TMP=$HOME_CERT/tmp
DIR_CERT_TOOLS=$HOME_CERT/tools
DIR_CERT_SAMPLES=$HOME_CERT/templates
DIR_CERT_LIB=$HOME_CERT/lib
DIR_CERT_BCK=$HOME_CERT/Backup
DIR_CERT_GENECERT=$HOME_CERT/generatecert
DIR_CERT_HIST=$HOME_CERT/historical
DIR_CERT_AUTOR=$HOME_CERT/Autorite


#Save the informations of the certificat URL
HISTORICAL_CERT=${DIR_CERT_HIST}/certificat_histo_file.txt

#Get the certificat Authority
CERTIFICAT_GROUP=$(ls ${DIR_CERT_AUTOR}/Group_base64.cer 2> /dev/null)
CERTIFICAT_APPLICATIONS=$(ls ${DIR_CERT_AUTOR}/Application_base64.cer 2> /dev/null)
CERTIFICAT_BNPPAPPLICATIONS=$(ls ${DIR_CERT_AUTOR}/BNPPApplications.cer 2> /dev/null)
CERTIFICAT_BNPPROOT=$(ls ${DIR_CERT_AUTOR}/BNPPRoot.cer 2> /dev/null)
CERTIFICAT_BNPPUSER=$(ls ${DIR_CERT_AUTOR}/BNPPUsersAuthentication.cer 2> /dev/null)
CERTIFICAT_USER=$(ls ${DIR_CERT_AUTOR}/User_base64.cer 2> /dev/null)

#setup the gsk7cmd path

DIR_GSKCMD_NOCLOUD=`ls -d /apps/IBMHTTPServer/WebServer*/bin 2>/dev/null |egrep 'WebServer[0-9]{1,}[A-Za-z][0-9]{1,}|WebServer[0-9]{1,}' |tail -1`
DIR_GSKCMD_CLOUD=`ls -d /apps/WebSphere*/WebServer/bin 2>/dev/null |egrep 'WebSphere[0-9]{1,}[A-Za-z][0-9]{1,}|WebSphere[0-9]{1,}|WebSphere/'|tail -1`


if [[ -f ${DIR_GSKCMD_NOCLOUD}/gsk7cmd || -f ${DIR_GSKCMD_NOCLOUD}/gskcmd ]]
then
        export PATH=$PATH:$DIR_GSKCMD_NOCLOUD
        if [[ -f ${DIR_GSKCMD_NOCLOUD}/gsk7cmd ]] ; then
                export CMD_GSKCM=${DIR_GSKCMD_NOCLOUD}/gsk7cmd
        elif [[ -f ${DIR_GSKCMD_NOCLOUD}/gskcmd ]] ; then
                export CMD_GSKCM=${DIR_GSKCMD_NOCLOUD}/gskcmd
        fi
elif [[ -f ${DIR_GSKCMD_CLOUD}/gsk7cmd || -f ${DIR_GSKCMD_CLOUD}/gskcmd ]]
then
        export PATH=$PATH:$DIR_GSKCMD_CLOUD
        if [[ -f ${DIR_GSKCMD_CLOUD}/gsk7cmd ]] ; then
                export CMD_GSKCM=${DIR_GSKCMD_CLOUD}/gsk7cmd
        elif [[ -f ${DIR_GSKCMD_CLOUD}/gskcmd ]] ; then
                export CMD_GSKCM=${DIR_GSKCMD_CLOUD}/gskcmd
        fi
else
        SYST_GSKCMD=`whereis gsk7cmd |awk -F":" '{print $2}'`
        if [[ -z ${SYST_GSKCMD} ]] then
            SYST_GSKCMD=`whereis gskcmd |awk -F":" '{print $2}'`
            if [[ -z ${SYST_GSKCMD} ]] then
                printTitle rouge "The gskcmd or gsk7cmd command could not be found on the server. Ensure that WEBSPHERE binaries are present (/apps/WebSphere*)"
                echo "Press any key to continue..." && read
                exit 1
            else
                export CMD_GSKCM=gskcmd
            fi
        else
            export CMD_GSKCM=gsk7cmd
        fi
fi


#Receive the certificat url in the kdb file

case $ACTION_CERT in

        N|n|no|NO) see_expiration_date_certificat_nolist;;
        cmd)   see_expiration_date_certificat_command ${KDB_FULLPATH} ${PASSWRD};;
                *) usage;;
esac

if [[ -z ${VAR_ALL} ]] ; then
  if [[ "${ACTION_CERT}" != "cmd" ]];then
   echo "Press enter key to continue..." && read
  fi
fi

