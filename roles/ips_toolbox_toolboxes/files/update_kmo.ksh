#!/bin/ksh

##------------------------------------------------------------------------------##
## inc_variable.ksh
#-----------------------------------------------------------------------------#
# Definition des variables
#-----------------------------------------------------------------------------#

# Dossier racine d'exploitation
typeset -x __DIR__TOOLBOXES="/apps/toolboxes"
typeset -x __DIR__TBX_EXPLOIT="${__DIR__TOOLBOXES}/exploit"
typeset -x __DIR__EXP_LOG="${__DIR__TBX_EXPLOIT}/logs"
typeset -x __DIR__EXP_INC="${__DIR__TBX_EXPLOIT}/include"

# Dossier d'administration
typeset -x __DIR__EXP_ADMIN="${__DIR__TBX_EXPLOIT}"
typeset -x __DIR__EXP_ADMIN_BIN="${__DIR__TBX_EXPLOIT}/bin"
typeset -x __DIR__EXP_ADMIN_EXP="${__DIR__TBX_EXPLOIT}/export"
typeset -x __DIR__EXP_ADMIN_CFG="${__DIR__TBX_EXPLOIT}/conf"
typeset -x __DIR__EXP_ADMIN_BAN="${__DIR__TBX_EXPLOIT}/banner"
typeset -x __DIR__EXP_ADMIN_TMP="${__DIR__TBX_EXPLOIT}/tmp"

# Dossier pour l'ordonnancement
typeset -x __DIR__EXP_SCHED="${__DIR__TBX_EXPLOIT}/sched"
typeset -x __DIR__EXP_SCHED_DEF="${__DIR__TBX_EXPLOIT}/sched/definition"
typeset -x __DIR__EXP_SCHED_CAL="${__DIR__TBX_EXPLOIT}/sched/definition/calendar"
typeset -x __DIR__EXP_SCHED_JOB="${__DIR__TBX_EXPLOIT}/sched/definition/jobset"
typeset -x __DIR__EXP_SCHED_STA="${__DIR__TBX_EXPLOIT}/sched/definition/station"
typeset -x __DIR__EXP_SCHED_VIS="${__DIR__TBX_EXPLOIT}/sched/definition/visio"
typeset -x __DIR__EXP_SCHED_SUB="${__DIR__TBX_EXPLOIT}/sched/subcmd"

# Variables du script appelant
typeset __SCRIPT__NAME="$(basename ${0})"
typeset __SCRIPT__SHORTNAME="$(basename ${0%.*})"
typeset __SCRIPT__PATH="$(dirname ${0})"
typeset __SCRIPT__ABSOLUTEPATH="$(cd ${__SCRIPT__PATH}; pwd)"

# Variable systeme
typeset __SYSTEM__OS="$(uname)"
typeset __SYSTEM__HOSTNAME="$(hostname)"

##### SCHEDULER
typeset -x TOOLBOX_SCHEDULER=${__DIR__TOOLBOXES}/scheduler
typeset -x TOOLBOX_SCHEDULER_CONTROLM_EM=${TOOLBOX_SCHEDULER}/controlm/em
typeset -x TOOLBOX_SCHEDULER_CONTROLM_SERVER=${TOOLBOX_SCHEDULER}/controlm/server
typeset -x TOOLBOX_SCHEDULER_CONTROLM_AGENT=${TOOLBOX_SCHEDULER}/controlm/agent
typeset -x TOOLBOX_SCHEDULER_AUTOSYS=${TOOLBOX_SCHEDULER}/autosys

##### SGBD
typeset -x __DIR__TBX_SGBD="${__DIR__TOOLBOXES}/sgbd"
typeset -x __DIR__TBX_ORACLE="${__DIR__TBX_SGBD}/oracle"
typeset -x TOOLBOX_SGBD_ORACLE_START_STOP="${__DIR__TBX_ORACLE}/exploitation/start_stop"


#-----------------------------------------------------------------------------#
# Gestion des alias
#-----------------------------------------------------------------------------#
unalias ls
if  [ "${__SYSTEM__OS}" = "Linux" ]; then
  alias awk='awk --posix'
fi

#-----------------------------------------------------------------------------#
# Definition des fonctions
#-----------------------------------------------------------------------------#

# -------------------------------------
# Creation des dossiers __DIR__
#
create_directoryTree() {
  typeset -x | grep "^__DIR__" | sort |
    while read varname; do
      varvalue=$(eval printf "\${${varname}}")
      if [ ! -d  ${varvalue} ]; then
        print_info "Creation dossier : ${varvalue}"
        mkdir -p "${varvalue}"
      else
        print_info "Dossier deja present : ${varvalue}"
      fi
    done
}

# -------------------------------------
# verifie la presence des scripts appeles par le script courant
#
use() {
  file="${1}"
  if [ ! -f "${file}" ]; then
    print_error "Required file not found : ${file}"
    exit 20
  fi
}

# ------------------------------------- #
#****f* inc_variable.ksh/die
# NAME
#   die -- Interruption globale sur erreur avec un code retour personnalisable
#
# DESCRIPTION
#    Affiche une message d'erreur et interrompt l'execution courante avec le code <rc> si indique, 2 sinon
#
# SYNOPSIS
#   die <msg> <rc>
#
# INPUTS
#   * msg -- le message d'erreur a afficher
#   * rc -- le code retour a retrouner
#
# RESULT
#   * STDOUT -- Le message d'erreur formate
#   * $? <rc> si indique, 2 sinon
#
#******
die() {
  typeset msg="${1}"
  typeset rc="${2}"
  [ -z "${rc}" ] && typeset rc=2
  [ ! -z "${msg}" ] && echo "${msg}"
  exit ${rc}
}

##-----------------------------------------------------------------------------##
## inc_terminal.ksh
#-----------------------------------------------------------------------------#
# Definition des variables
#-----------------------------------------------------------------------------#

typeset __TERM__FORMFEED="\014"
typeset __TERM__ESCAPE="\033"
typeset __TERM__FORMAT="${__TERM__ESCAPE}[%sm"
typeset __TERM__CLR_DATA="${__TERM__ESCAPE}[2J"
typeset __TERM__CLR_LINE="${__TERM__ESCAPE}[K"
typeset __TERM__CURSOR_POSITION="${__TERM__ESCAPE}[%sH"
typeset __TERM__CURSOR_HORIZONTAL="${__TERM__ESCAPE}[%sG"

typeset __TERM__STYLE_OFF=0
typeset __TERM__STYLE_BOLD=1
typeset __TERM__STYLE_UNDERLINE=4
typeset __TERM__STYLE_BLINK=5
typeset __TERM__STYLE_REVERSE=7
typeset __TERM__STYLE_CONCEAL=8
typeset __TERM__STYLE_REVEAL=28
typeset __TERM__STYLE_DEFAULT=${__TERM__STYLE_OFF}

typeset __TERM__COLOR_BLACK=30
typeset __TERM__COLOR_RED=31
typeset __TERM__COLOR_GREEN=32
typeset __TERM__COLOR_YELLOW=33
typeset __TERM__COLOR_BLUE=34
typeset __TERM__COLOR_MAGENTA=35
typeset  __TERM__COLOR_CYAN=36
typeset  __TERM__COLOR_WHITE=37

typeset __TERM__COLOR_LBLACK="${__TERM__STYLE_BOLD};30"
typeset __TERM__COLOR_LRED="${__TERM__STYLE_BOLD};31"
typeset __TERM__COLOR_LGREEN="${__TERM__STYLE_BOLD};32"
typeset __TERM__COLOR_LYELLOW="${__TERM__STYLE_BOLD};33"
typeset __TERM__COLOR_LBLUE="${__TERM__STYLE_BOLD};34"
typeset __TERM__COLOR_LMAGENTA="${__TERM__STYLE_BOLD};35"
typeset __TERM__COLOR_LCYAN="${__TERM__STYLE_BOLD};36"
typeset __TERM__COLOR_LWHITE="${__TERM__STYLE_BOLD};37"

typeset FG_BLACK="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__COLOR_BLACK})"
typeset FG_RED="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__COLOR_RED})"
typeset FG_GREEN="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__COLOR_GREEN})"
typeset FG_YELLOW="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__COLOR_YELLOW})"
typeset FG_BLUE="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__COLOR_BLUE})"
typeset FG_MAGENTA="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__COLOR_MAGENTA})"
typeset FG_CYAN="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__COLOR_CYAN})"
typeset FG_WHITE="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__COLOR_WHITE})"

typeset FG_LBLACK="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__COLOR_LBLACK})"
typeset FG_LRED="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__COLOR_LRED})"
typeset FG_LGREEN="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__COLOR_LGREEN})"
typeset FG_LYELLOW="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__COLOR_LYELLOW})"
typeset FG_LBLUE="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__COLOR_LBLUE})"
typeset FG_LMAGENTA="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__COLOR_LMAGENTA})"
typeset FG_LCYAN="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__COLOR_LCYAN})"
typeset FG_LWHITE="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__COLOR_LWHITE})"

typeset FG_DEFAULT="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__STYLE_DEFAULT})"

typeset INVERT_BF="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__STYLE_REVERSE})"

typeset __TERM__FGCOLOR_DEFAULT=${__TERM__COLOR_WHITE}
typeset __TERM__BGCOLOR_DEFAULT=$((${__TERM__COLOR_BLACK} + 10))

typeset __TERM__BGCOLOR_BLACK=${__TERM__BGCOLOR_DEFAULT}
typeset __TERM__BGCOLOR_RED=$((${__TERM__COLOR_RED} + 10))
typeset __TERM__BGCOLOR_GREEN=$((${__TERM__COLOR_GREEN} + 10))
typeset __TERM__BGCOLOR_YELLOW=$((${__TERM__COLOR_YELLOW} + 10))
typeset __TERM__BGCOLOR_BLUE=$((${__TERM__COLOR_BLUE} + 10))
typeset __TERM__BGCOLOR_MAGENTA=$((${__TERM__COLOR_MAGENTA} + 10))
typeset __TERM__BGCOLOR_CYAN=$((${__TERM__COLOR_CYAN} + 10))
typeset __TERM__BGCOLOR_WHITE=$((${__TERM__COLOR_WHITE} + 10))

typeset __TERM__BGCOLOR_LBLACK=$((${__TERM__COLOR_BLACK} + 70))
typeset __TERM__BGCOLOR_LRED=$((${__TERM__COLOR_RED} + 70))
typeset __TERM__BGCOLOR_LGREEN=$((${__TERM__COLOR_GREEN} + 70))
typeset __TERM__BGCOLOR_LYELLOW=$((${__TERM__COLOR_YELLOW} + 70))
typeset __TERM__BGCOLOR_LBLUE=$((${__TERM__COLOR_BLUE} + 70))
typeset __TERM__BGCOLOR_LMAGENTA=$((${__TERM__COLOR_MAGENTA} + 70))
typeset __TERM__BGCOLOR_LCYAN=$((${__TERM__COLOR_CYAN} + 70))
typeset __TERM__BGCOLOR_LWHITE=$((${__TERM__COLOR_WHITE} + 70))

typeset BG_BLACK="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__BGCOLOR_BLACK})"
typeset BG_RED="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__BGCOLOR_RED})"
typeset BG_GREEN="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__BGCOLOR_GREEN})"
typeset BG_YELLOW="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__BGCOLOR_YELLOW})"
typeset BG_BLUE="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__BGCOLOR_BLUE})"
typeset BG_MAGENTA="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__BGCOLOR_MAGENTA})"
typeset BG_CYAN="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__BGCOLOR_CYAN})"
typeset BG_WHITE="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__BGCOLOR_WHITE})"

typeset BG_LBLACK="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__BGCOLOR_LBLACK})"
typeset BG_LRED="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__BGCOLOR_LRED})"
typeset BG_LGREEN="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__BGCOLOR_LGREEN})"
typeset BG_LYELLOW="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__BGCOLOR_LYELLOW})"
typeset BG_LBLUE="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__BGCOLOR_LBLUE})"
typeset BG_LMAGENTA="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__BGCOLOR_LMAGENTA})"
typeset BG_LCYAN="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__BGCOLOR_LCYAN})"
typeset BG_LWHITE="${__TERM__ESCAPE}$(printf ${__TERM__FORMAT} ${__TERM__BGCOLOR_LWHITE})"

typeset __TERM__SIZE_COLUMN=$(stty size 2>/dev/null | awk '{print $2}')
typeset __TERM__SIZE_LINE=$(stty size 2>/dev/null | awk '{print $1}')

typeset __TERM__TTYCONFIG=$(stty -g 2> /dev/null)
typeset __TERM__ECHOENABLE="true";

#-----------------------------------------------------------------------------#
# Definition des fonctions
#-----------------------------------------------------------------------------#

# -------------------------------------
# Verifie que l'interface d'entree est bien STDIN
# @return : 0 si actif
#
isSTDINActive()
{
    /bin/stty > /dev/null 2>&1
    return ${?}
}

# -------------------------------------
# Initialise le terminal
#     Desactive le buffer de saisie ligne par ligne
#     Desactive l'echo
#
initializeTerminal()
{
    __TERM__TTYCONFIG=$(stty -g);
    stty -icanon min 1
    disableEcho
}

# -------------------------------------
# Restaure la configuration original du terminal
#
restoreTerminal()
{
    if [ "${__TERM__TTYCONFIG}empty" != "empty" ]
    then
        stty "${__TERM__TTYCONFIG}"
    fi
}

# -------------------------------------
# Active l'echo du terminal
#
enableEcho()
{
    stty "echo"
    __TERM__ECHOENABLE="true"
}

# -------------------------------------
# Desactive l'echo du terminal
#
disableEcho()
{
    stty "-echo"
    __TERM__ECHOENABLE="false"
}

# -------------------------------------
# Verification du caractere utilise pour le retour chariot
#
backspaceDeleteSwitched()
{
    if [ "$(stty -g | awk -F ':|=' '{print $7}')" = "7f" ]
    then
        return 0
    fi

    return 1
}

# -------------------------------------
# Recupere la saisie d'une touche au clavier
#
readKey()
{
    initializeTerminal

    ESC=$(printf "\033")
    HT=$(printf "\011")
    BS=$(printf "\010")
    LF=$(printf "\012")
    DEL=$(printf "\0177")

    input=$(dd bs=10 count=1 2>/dev/null)

    if [ "${input}" = "${ESC}" ]
    then
        result="ESCAPE"
    elif [ "${input}" = "${HT}" ]
    then
        result="TAB"
    elif [ "${input}" = "${BS}" ]
    then
        backspaceDeleteSwitched

        if [ $? -eq 0 ]
        then
            result="DELETE"
        else
            result="BACKSPACE"
        fi
    elif [ "${input}" = "${DEL}" ]
    then
        backspaceDeleteSwitched

        if [ $? -eq 0 ]
        then
            result="BACKSPACE"
        else
            result="DELETE"
        fi
    elif [ "${input}" = "${LF}" ]
    then
        result="ENTER"
    elif [ "${input}" = "${ESC}[A" ]
    then
        result="CURSOR_UP"
    elif [ "${input}" = "${ESC}[B" ]
    then
        result="CURSOR_DOWN"
    elif [ "${input}" = "${ESC}[C" ]
    then
        result="CURSOR_RIGHT"
    elif [ "${input}" = "${ESC}[D" ]
    then
        result="CURSOR_LEFT"
    elif [ "${input}" = "${ESC}[1~" ]
    then
        result="HOME"
    elif [ "${input}" = "${ESC}[2~" ]
    then
        result="INSERT"
    elif [ "${input}" = "${ESC}[3~" ]
    then
        result="DELETE"
    elif [ "${input}" = "${ESC}[4~" ]
    then
        result="END"
    elif [ "${input}" = "${ESC}[5~" ]
    then
        result="PAGE_UP"
    elif [ "${input}" = "${ESC}[6~" ]
    then
        result="PAGE_DONW"
    elif [ "${input}" = "${ESC}[11~" ]
    then
        result="F1"
    elif [ "${input}" = "${ESC}[12~" ]
    then
        result="F2"
    elif [ "${input}" = "${ESC}[13~" ]
    then
        result="F3"
    elif [ "${input}" = "${ESC}[14~" ]
    then
        result="F4"
    elif [ "${input}" = "${ESC}[15~" ]
    then
        result="F5"
    elif [ "${input}" = "${ESC}[17~" ]
    then
        result="F6"
    elif [ "${input}" = "${ESC}[18~" ]
    then
        result="F7"
    elif [ "${input}" = "${ESC}[19~" ]
    then
        result="F8"
    elif [ "${input}" = "${ESC}[20~" ]
    then
        result="F9"
    elif [ "${input}" = "${ESC}[21~" ]
    then
        result="F10"
    elif [ "${input}" = "${ESC}[23~" ]
    then
        result="F11"
    elif [ "${input}" = "${ESC}[24~" ]
    then
        result="F12"
    else
        result="$(printf -- ${input} | head -c 1)"
    fi

    printf -- "${result}\n"
    restoreTerminal
}

# -------------------------------------
# Affiche la liste des couleurs disponibles
#
list_colors()
{
    set | grep "^__TERM__COLOR" | awk -F '=' '{ print "$" $1}'
}


# -------------------------------------
# Change la couleur du premier plan
# @param v_color : code couleur
#
set_fgcolor()
{
    typeset v_color=${1}

    if [ ${v_color#*;} -ge ${__TERM__COLOR_BLACK} ] && [ ${v_color#*;} -le ${__TERM__COLOR_WHITE} ]
    then
        printf "${__TERM__FORMAT}" "${v_color}"
    fi
}


# -------------------------------------
# Change la couleur de l'arriere plan
# @param color : code couleur
#
set_bgcolor()
{
    typeset v_color=${1}

    if [ ${v_color#*;} -ge ${__TERM__COLOR_BLACK} ] && [ ${v_color#*;} -le ${__TERM__COLOR_WHITE} ]
    then
        printf "${__TERM__FORMAT}" "$((${v_color} + 10))"
    fi
}


# -------------------------------------
# Change le style de police
# @param style : code du style
#
set_style()
{
    typeset style=${1}

    if [ ${style} -ge ${__TERM__STYLE_OFF} ] && [ ${style} -le ${__TERM__STYLE_CONCEAL} ]
    then
        printf ${__TERM__FORMAT} ${style}
    fi
}


# -------------------------------------
# Modifie la position du curseur
# @param line : deplacement vertical
# @param column : deplacement horizontal
#
move_cursor()
{
    typeset line=${1}
    typeset column=${2}

    if [ ${line} -gt 0 ] && [ ${column} -gt 0 ]
    then
        printf ${__TERM__CURSOR_POSITION} "${line};${column}"
    fi
}


# -------------------------------------
# Modifie la position du curseur sur la ligne courante
# @param column : deplacement horizontal
#
move_toColumn()
{
    typeset column=${1}

    if [ ${column} -gt 0 ]
    then
        printf ${__TERM__CURSOR_HORIZONTAL} "${column}"
    fi
}


# -------------------------------------
# Retourne ne nombre de colonnes du TTY
#
getTerminalColumns()
{
    typeset colomns=$(stty size 2>/dev/null | awk '{print $2}')
    [[ "${colomns}empty" = "empty" ]] && colomns=${__TERM__SIZE_COLUMN}
    [[ "${colomns}empty" = "empty" ]] && colomns=80
    print -- "${colomns}"
}


# -------------------------------------
# Retourne ne nombre de lignes du TTY
#
getTerminalLines()
{
    typeset lines=$(stty size 2>/dev/null | awk '{print $1}')
    [[ "${lines}empty" = "empty" ]] && lines=${__TERM__SIZE_LINE}
    [[ "${lines}empty" = "empty" ]] && lines=30
    print -- "${lines}"
}


# -------------------------------------
# Efface l'ecran
#
clear_screen()
{
    printf ${__TERM__FORMFEED}
}


# -------------------------------------
# Efface la ligne courante
#
clear_line()
{
    printf ${__TERM__CLR_LINE}
}


# -------------------------------------
# Reinitialise le style et la couleur
#
clear_style()
{
    printf ${__TERM__FORMAT} ${__TERM__STYLE_DEFAULT}
}


# -------------------------------------
# Affiche un msg en couleur
# @param msg : le message a afficher
# @param color : la couleur de police a utiliser
#
printf_color()
{
    typeset v_msg="${1}"
    typeset v_color="${2}" && [[ "${v_color}empty" = "empty" ]] && v_color="${__TERM__FGCOLOR_DEFAULT}"
    typeset v_style="${3}" && [[ "${v_style}empty" = "empty" ]] && v_style="${__TERM__STYLE_OFF}"

    set_style "${v_style}"
    set_fgcolor "${v_color}"

    printf -- "${v_msg}"

    clear_style
}

print_color()
{
    typeset v_msg="${1}"
    typeset v_color="${2}"
    typeset v_style="${3}"

    printf_color "${v_msg}" "${v_color}" "${v_style}"
    print ""
}


# -------------------------------------
# Affiche un hordate (sans retour chariot)
#
print_horadate()
{
    printf "$(date '+[%d/%m/%Y %H:%M:%S]')"
}


# -------------------------------------
# Affiche une erreur
# @param msg : le message a afficher
#
print_error()
{
    typeset msg="${1}"

    print_color "${INVERT_BF}-E- ${msg}" ${__TERM__COLOR_RED}
}


# -------------------------------------
# Affiche un avertissement
# @param msg : le message a afficher
#
print_warning()
{
    typeset msg="${1}"

    print_color "-W- ${msg}" ${__TERM__COLOR_YELLOW}
}


# -------------------------------------
# Affiche une information
# @param msg : le message a afficher
#
print_info()
{
    typeset msg="${1}"

    print_color "-I- ${msg}" ${__TERM__FGCOLOR_DEFAULT}
}


# ------------------------------------- #
# Affiche un message uniquement si la variable ${__DEBUG__} = "true"
# @param msg : message
#
print_debug()
{
    if [ "${__DEBUG__}" = "true" ]
    then
        typeset msg="${1}"
        print_color "-D- ${msg}" ${__TERM__COLOR_LYELLOW}
    fi
}

# -------------------------------------
# Affiche une chaine centree sur la longueur de ligne definie
# @param value : le titre a afficher
# @param column : le nombre de colonne max (par defaut le nombre de colonnes du TTY courant)
#
printf_center()
{
    typeset v_value="${1}"
    typeset v_column="${2}" && [[ "${v_column}empty" = "empty" ]] && v_column=$(getTerminalColumns)
    typeset v_color="${3}" && [[ "${v_color}empty" = "empty" ]] && v_color=${__TERM__FGCOLOR_DEFAULT}
    typeset v_style="${4}" && [[ "${v_style}empty" = "empty" ]] && v_style=${__TERM__STYLE_OFF}
    typeset msgSize=${#v_value}

    if [ ${msgSize} -le ${v_column} ]
    then
        (( padding = (v_column / 2) - (msgSize / 2) ))
        move_toColumn ${padding}
    fi

    printf_color "${v_value}" "${v_color}" "${v_style}"
}


print_center()
{
    typeset v_value="${1}"
    typeset v_column="${2}" && [[ "${v_column}empty" = "empty" ]] && v_column=$(getTerminalColumns)
    typeset v_color="${3}" && [[ "${v_color}empty" = "empty" ]] && v_color=${__TERM__FGCOLOR_DEFAULT}
    typeset v_style="${4}" && [[ "${v_style}empty" = "empty" ]] && v_style=${__TERM__STYLE_OFF}

    # calcul des padding
    typeset msgSize=${#v_value}
    (( lpadding = (v_column / 2) - (msgSize / 2) ))
    (( rpadding = v_column - (lpadding + msgSize - 1) ))

    set_style "${v_style}"
    set_fgcolor "${v_color}"
    printf "%${lpadding}s" " "

    printf_center "${v_value}" "${v_column}" "${v_color}" "${v_style}"

    set_style "${v_style}"
    set_fgcolor "${v_color}"
    printf "%${rpadding}s" " "

    clear_style
    # retour chariot
    print ""
}


# -------------------------------------
# Affiche une chaine avec un alignement a droite
# @param v_title : Titre de l'ent▒te
# @param v_column : Nombre de colonnes (par defaut le nombre de colonnes du TTY courant)
# @param v_color : Couleur de la police
# @param v_style : Style d'affichage
#
printf_right()
{
    typeset v_value="${1}"
    typeset v_column="${2}" && [[ "${v_column}empty" = "empty" ]] && v_column=$(getTerminalColumns)
    typeset v_color="${3}" && [[ "${v_color}empty" = "empty" ]] && v_color=${__TERM__FGCOLOR_DEFAULT}
    typeset v_style="${4}" && [[ "${v_style}empty" = "empty" ]] && v_style=${__TERM__STYLE_OFF}
    typeset msgSize=${#v_value}

    if [ ${msgSize} -le ${v_column} ]
    then
        (( padding = v_column - msgSize ))
        move_toColumn ${padding}
    fi

    printf_color "${v_value}" "${v_color}" "${v_style}"
}

print_right()
{
    typeset v_value="${1}"
    typeset v_column="${2}"
    typeset v_color="${3}"
    typeset v_style="${4}"

    printf_right "${v_value}" "${v_column}" "${v_color}" "${v_style}"
    print ""
}


# ------------------------------------- #
# Affichage d'une entete
# @param v_value : Titre de l'ent▒te
# @param v_column : Nombre de colonnes (par defaut le nombre de colonnes du TTY courant)
# @param v_color : Couleur de la police
# @param v_style : Style d'affichage
#
print_header()
{
    typeset v_value=${1}
    typeset v_column="${2}" && [[ "${v_column}empty" = "empty" ]] && v_column=$(getTerminalColumns)
    typeset v_color="${3}" && [[ "${v_color}empty" = "empty" ]] && v_color=${__TERM__FGCOLOR_DEFAULT}
    typeset v_style="${4}" && [[ "${v_style}empty" = "empty" ]] && v_style=${__TERM__STYLE_REVERSE}

    set_style ${__TERM__STYLE_UNDERLINE}
    set_fgcolor "${v_color}"
    printf "%${v_column}s" ""
    clear_style
    print ""

    print_center "${v_value}" "${v_column}" "${v_color}" "${v_style}"
}


# ------------------------------------- #
# Affichage d'une sous-ent▒te
# @param v_title : Titre de l'ent▒te
# @param v_column : Nombre de colonnes (qui sera divise par 2)
# @param v_color : Couleur de la police
# @param v_style : Style d'affichage
#
print_subHeader()
{
    typeset v_title=${1}
    typeset v_column="${2}" && [[ "${v_column}empty" = "empty" ]] && v_column=$(getTerminalColumns)
    typeset v_color="${3}" && [[ "${v_color}empty" = "empty" ]] && v_color=${__TERM__FGCOLOR_DEFAULT}
    typeset v_style="${4}" && [[ "${v_style}empty" = "empty" ]] && v_style=${__TERM__STYLE_UNDERLINE}

    (( v_column = v_column / 2))

    print_header "${v_title}" "${v_column}" "${v_color}" "${v_style}"
}


# ------------------------------------- #
# Affichage d'une ent▒te simple
# @param v_title : Titre de l'ent▒te
# @param v_column : Nombre de colonnes
# @param v_char : Caractere de separation
#
print_simpleHeader()
{
    typeset v_title=${1}
    typeset v_column="${2}"
    typeset v_char="${3}"

    print_hr "${v_column}" "${v_char}"
    print_center "${v_title}" "${v_column}"
    print_hr "${v_column}" "${v_char}"
}

# ------------------------------------- #
# Affichage d'une ligne de separation
# @param v_column : Nombre de colonnes
# @param v_char : Caractere de separation
# @param v_pchar : Caractere de separation en debut et fin de ligne
#
print_hr()
{
    typeset v_column="${1}"
    typeset v_char="${2}"
    typeset v_pchar="${3}"

    [[ "${v_column}empty" = "empty" ]] && v_column=$(getTerminalColumns)
    [[ "${v_char}empty" = "empty" ]] && v_char="-"
    [[ "${v_pchar}empty" = "empty" ]] && v_pchar="${v_char}"

    printf -- "${v_pchar}%$((v_column-2))s${v_pchar}" "" | sed -e "s| |${v_char}|g"
    print ""
}

# ------------------------------------- #
# Pose une question
# @param question : Question a afficher
# @return : __ANSWER__
#
question()
{
    __ANSWER__=""
    typeset question="${1}"
    typeset default_answer="${2}"

    if [ "${default_answer}empty" = "empty" ]
    then
        while [ "${__ANSWER__}empty" = "empty" ]
        do
            printf -- "-Q- ${question} : " ; read __ANSWER__
        done
    else
        printf -- "-Q- ${question} [Default: ${default_answer}] : "; read __ANSWER__

        if [ "${__ANSWER__}empty" = "empty" ]
        then
            __ANSWER__=${default_answer}
        fi
    fi
}


# ------------------------------------- #
# Decale le texte sur ${size} colonnes
# @param : size : Nombre de colonnes (par defaut 2)
# @param : pchar : Caractere de debut de ligne
# @param : text flow
#
indent()
{
    typeset size="${1}"
    typeset pchar="${2}"

    awk -v size="${size}" \
      -v pchar="${pchar}" \
    '
    function print_ident() {
        printf( pchar )
        for ( i=1 ; i<=size ; i++ ) {
            printf(" ")
        }
    }

    BEGIN {
        if ( size == "" )
        size = 2
    }
    # MAIN
    {
        print_ident()
        print $0
    }
    END {}
    ' <&0
}


# ------------------------------------- #
# Reformate le texte sur ${size} colonnes
# @param : size : Nombre de colonnes (par defaut 80)
# @param : v_pchar : Caractere de separation en debut et fin de ligne
# @param : text flow
#
wordwrap()
{
    typeset size=${1}
    typeset pchar=${2}

    awk -v size="${size}" \
    -v pchar="${pchar}" \
    '
    function print_line( line) {
        if ( pchar != "" )
            printf( pchar" %-"size"s "pchar"\n", line)
        else
            print line
    }

    BEGIN {
        if ( size == "" )
            size = 80
        if ( pchar != "" )
            size = size-4
    }
    # MAIN
    {
        linebuffer = $0
        while ( length(linebuffer) > size) {
            line = substr(linebuffer, 0, size)
            match( line, " [^ ]*$")

            if ( RSTART != 0 ) {
                print_line(substr( line, 0, RSTART))
                linebuffer = substr(linebuffer, RSTART+1)
            } else {
                print_line(substr( line, 0, size))
                linebuffer = substr(linebuffer, size+1)
            }
        }
        print_line(linebuffer)
    }
    END {}
    ' <&0
}
wordwarp()
{
    wordwrap ${*}
}

# ------------------------------------- #
# Coupe chaques lignes sur ${size} colonnes
# @param : size : Nombre de colonnes (par defaut 80)
# @param : v_pchar : Caractere de separation en debut et fin de ligne
# @param : text flow
#
linecut()
{
    typeset size=${1}
    typeset pchar=${2}

    awk -v size="${size}" \
    -v pchar="${pchar}" \
    '
    function print_line( line) {
        if ( pchar != "" )
            printf( pchar" %-"size"s "pchar"\n", line)
        else
            print line
    }

    BEGIN {
        if ( size == "" )
            size = 80
        if ( pchar != "" )
            size = size-4
    }
    # MAIN
    {
        linebuffer = $0
        print_line(substr(linebuffer, 0, size))
    }
    END {}
    ' <&0
}


# ------------------------------------- #
# Colorise la sortie standard
#
color_output()
{
    while read ligne
    do
        eval "print -- \"$(print -- "${ligne}" |
        awk '
        BEGIN {
            TERMS["STOPPED"] = "${FG_RED}"
            TERMS["stopped"] = "${FG_RED}"
            TERMS["NOT RUNNING"] = "${FG_RED}"
            TERMS["not running"] = "${FG_RED}"
            TERMS["NOT STARTED"] = "${FG_RED}"
            TERMS["not started"] = "${FG_RED}"
            TERMS["not alive"] = "${FG_RED}"
            TERMS["not active"] = "${FG_RED}"
            TERMS["not loaded"] = "${FG_RED}"
            TERMS["not found"] = "${FG_RED}"
            TERMS["ERROR"] = "${FG_RED}"
            TERMS["error"] = "${FG_RED}"
            TERMS["UNSUCCESSFULLY"] = "${FG_RED}"
            TERMS["unsuccessfully"] = "${FG_RED}"
            TERMS["UNSUCCESSFUL"] = "${FG_RED}"
            TERMS["unsuccessful"] = "${FG_RED}"
            TERMS["NOT SYNCHRONIZED"] = "${FG_RED}"
            TERMS["KO"] = "${FG_RED}"

            TERMS["WARNING"] = "${FG_YELLOW}"
            TERMS["warning"] = "${FG_YELLOW}"

            TERMS["STARTED"] = "${FG_GREEN}"
            TERMS["started"] = "${FG_GREEN}"
            TERMS["RUNNING"] = "${FG_GREEN}"
            TERMS["running"] = "${FG_GREEN}"
            TERMS["alive"] = "${FG_GREEN}"
            TERMS["active"] = "${FG_GREEN}"
            TERMS["loaded"] = "${FG_GREEN}"
            TERMS["found"] = "${FG_GREEN}"
            TERMS["CHECK OK"] = "${FG_GREEN}"
            TERMS["SUCCESSFULLY"] = "${FG_GREEN}"
            TERMS["successfully"] = "${FG_GREEN}"
            TERMS["SUCCESSFUL"] = "${FG_GREEN}"
            TERMS["successful"] = "${FG_GREEN}"
            TERMS["SYNCHRONIZED"] = "${FG_GREEN}"
            TERMS["OK"] = "${FG_GREEN}"
        }
        {
            for (term in TERMS) {
                if ( $0 ~ term ) {
                    gsub(term, TERMS[term] term "${FG_DEFAULT}") ; print ; next
                }
            }
            print $0
        }
        ' |
        sed  \
        -e "s|'\(start[^']*\)'|'\\${FG_GREEN}\1\\${FG_DEFAULT}'|" \
        -e "s|'\(stop[^\']*\)'|'\\${FG_RED}\1\\${FG_DEFAULT}'|" \
        -e "s|'\(restart[^\']*\)'|'\\${FG_YELLOW}\1\\${FG_DEFAULT}'|" \
        -e "s|'\(status[^\']*\)'|'\\${FG_CYAN}\1\\${FG_DEFAULT}'|"
        )\"";
    done <&0
}


##-----------------------------------------------------------------------------##
## inc_log.ksh
#-----------------------------------------------------------------------------#
# Definition des variables
#-----------------------------------------------------------------------------#

typeset __LOG__CMD="${0} ${*}"
typeset __LOG__DAYMONTH="$(date +%d)"
typeset __LOG__DIRNAME="${__DIR__EXP_LOG}/${__LOG__DAYMONTH}"
typeset __LOG__FILENAME="$(basename ${0}).$(date +%Y%m%d-%H%M%S).log"
typeset __LOG__PIPE="$(basename ${0}).$(date +%Y%m%d-%H%M%S).$$.pipe"
typeset __LOG__PIPE1="${__LOG__PIPE}.1"
typeset __LOG__PIPE2="${__LOG__PIPE}.2"

[[ ! -d "${__LOG__DIRNAME}" ]] && mkdir -p "${__LOG__DIRNAME}" && chmod 777 "${__LOG__DIRNAME}"

#-----------------------------------------------------------------------------#
# Definition des fonctions
#-----------------------------------------------------------------------------#


# ------------------------------------- #
# Activation des traces :
# Affichage a la sortie standard (avec horodatage) + redirection dans un fichier de log (avec horodatage)
#
# Schema des flux et redirections :
#                                                      |--->[PIPE2]---horodate--->{FILE}
#                                                      |
#[STDERR]---exec--->[STDOUT]---exec--->[PIPE1]---tee---|
#                                                      |
#                                                      |---horodate--->[3]---exec--->{STDOUT}
active_traceDate()
{
    cat > "${__LOG__DIRNAME}/${__LOG__FILENAME}" <<EOF

###############################################################################
# $(who am i 2> /dev/null | awk '{ print $1 }') as $(whoami 2> /dev/null)@$(hostname): $(pwd) # ${__LOG__CMD}
###############################################################################

EOF

    mkfifo "${__LOG__DIRNAME}/${__LOG__PIPE1}"
    mkfifo "${__LOG__DIRNAME}/${__LOG__PIPE2}"

    exec 3>&1 # [3]---exec--->{STDOUT}
    exec 4>&2 # [4]---exec--->{STDERR}

    # [PIPE2]---horodate--->{FILE}
    flow_horodate < "${__LOG__DIRNAME}/${__LOG__PIPE2}" >> "${__LOG__DIRNAME}/${__LOG__FILENAME}" &
    # [PIPE1]---tee--->[PIPE2]
    # [PIPE1]---tee + horodate--->[3]
    tee -a "${__LOG__DIRNAME}/${__LOG__PIPE2}" < "${__LOG__DIRNAME}/${__LOG__PIPE1}" | flow_horodate >&3 &

    # [STDOUT]---exec--->[PIPE1]
    exec 1> "${__LOG__DIRNAME}/${__LOG__PIPE1}"
    # [STDERR]---exec--->[STDOUT]
    exec 2>&1

    # Nettoyage des fichiers PIPE suite a la sortie du script
    trap "sleep 1; rm -f \"${__LOG__DIRNAME}/${__LOG__PIPE1}\" \"${__LOG__DIRNAME}/${__LOG__PIPE2}\"" 0
}


# ------------------------------------- #
# Activation des traces :
# Affichage a la sortie standard + redirection dans un fichier de log (avec horodatage)
#
# Schema des flux et redirections :
#                                                      |--->[PIPE2]---horodate--->{FILE}
#                                                      |
#[STDERR]---exec--->[STDOUT]---exec--->[PIPE1]---tee---|
#                                                      |
#                                                      |--->[3]---exec--->{STDOUT}
active_trace()
{
    cat > "${__LOG__DIRNAME}/${__LOG__FILENAME}" <<EOF

###############################################################################
# $(who am i 2> /dev/null | awk '{ print $1 }') as $(whoami 2> /dev/null)@$(hostname): $(pwd) # ${__LOG__CMD}
###############################################################################

EOF

    mkfifo "${__LOG__DIRNAME}/${__LOG__PIPE1}"
    mkfifo "${__LOG__DIRNAME}/${__LOG__PIPE2}"

    exec 3>&1 # [3]---exec--->{STDOUT}
    exec 4>&2 # [4]---exec--->{STDERR}

    # [PIPE2]---horodate--->{FILE}
    flow_horodate < "${__LOG__DIRNAME}/${__LOG__PIPE2}" >> "${__LOG__DIRNAME}/${__LOG__FILENAME}" &

    # [PIPE1]---tee--->[PIPE2]
    # [PIPE1]---tee--->[3]
    tee -a "${__LOG__DIRNAME}/${__LOG__PIPE2}" < "${__LOG__DIRNAME}/${__LOG__PIPE1}" >&3 &

    # [STDOUT]---exec--->[PIPE1]
    exec 1> "${__LOG__DIRNAME}/${__LOG__PIPE1}"
    # [STDERR]---exec--->[STDOUT]
    exec 2>&1

    # Nettoyage des fichiers PIPE suite a la sortie du script
    trap "sleep 1; rm -f ${__LOG__DIRNAME}/${__LOG__PIPE1} ${__LOG__DIRNAME}/${__LOG__PIPE2}" 0
}


# ------------------------------------- #
# Redirection de tous les sorties dans un fichier de log (avec horodatage)
#
# Schema des flux et redirections :
# [STDERR]---exec--->[STDOUT]---exec--->[PIPE1]---horodate--->{FILE}
active_redirect()
{
    cat > "${__LOG__DIRNAME}/${__LOG__FILENAME}" <<EOF

###############################################################################
# $(who am i 2> /dev/null | awk '{ print $1 }') as $(whoami)@$(hostname): $(pwd) # ${__LOG__CMD}
###############################################################################

EOF

    mkfifo "${__LOG__DIRNAME}/${__LOG__PIPE1}"

    # [PIPE1]---horodate--->{FILE}
    flow_horodate < "${__LOG__DIRNAME}/${__LOG__PIPE1}" >> "${__LOG__DIRNAME}/${__LOG__FILENAME}" &

    # [STDOUT]---exec--->[PIPE1]
    exec 1> "${__LOG__DIRNAME}/${__LOG__PIPE1}"
    # [STDERR]---exec--->[STDOUT]
    exec 2>&1

    trap "sleep 1; rm -f ${__LOG__DIRNAME}/${__LOG__PIPE1} " 0
}


# ------------------------------------- #
# Enregistre en message uniquement dans le fichier log (pas d'affichage STDOUT)
# @param msg : message
#
log()
{
    typeset msg="${1}"
    print "${msg}" >> "${__LOG__DIRNAME}/${__LOG__FILENAME}"
}


# -------------------------------------
# Ajoute un horodatage a toutes les lignes d'un flux
#
flow_horodate()
{
    while IFS='\n' read ligne
    do
        print "\033[0m$(date '+[%Y-%m-%d %H:%M:%S]') ${ligne}\033[0m"
    done <&0
}

active_trace

##-----------------------------------------------------------------------------##
## .audit.ksh
#-----------------------------------------------------------------------------#

typeset -x __DIR__TBX_LOG="/apps/toolboxes/.logs"

#-----------------------------------------------------------------------------#
# Fonction pour comptage
#-----------------------------------------------------------------------------#
function compteurTbx
{
    typeset WHO_CPT=""
    typeset userElevPrivs=""
    typeset hostFrom=""
    typeset -x CPTLOG=${__DIR__TBX_LOG}/.realtime.log

    if [ -t 0 ]
    then
        WHO_CPT=$(who -m | awk '{print $1}')
        userElevPrivs=$(whoami)
        hostFrom=$(who -m | awk -F"[()]" '{ print $2 }')
    else
        WHO_CPT="root"
        userElevPrivs="root"
        hostFrom=$(hostname)
    fi

    if [ ! -s ${CPTLOG} ]
    then
        touch ${CPTLOG}
        chmod 666 ${CPTLOG}
    fi

    printf "[$(date +"%Y-%m-%d %H:%M:%S")][$(hostname)][${hostFrom}][${WHO_CPT}][${userElevPrivs}][${TBX_NAME}][${ENTREE}] Execution de $1\n" >> ${CPTLOG}
}

#-----------------------------------------------------------------------------#
# Usage
#-----------------------------------------------------------------------------#

usage()
{
printf "\nSyntax: "
printf "\n\n\033[36m update_kmo.ksh\033[33m target_path \033[35m force_install tbx_version url_source\033[0m\n\n"
printf "OPTIONS"
printf "\n  \033[33m target_path      : Optionnal: non relative path where to download the package"
printf "\n                            If this parameter is not specified the below options could not be used"
printf "\n  \033[35m force_install \033[0m  : Optionnal: 'yes' to automatically install the package after the download"
printf "\n  \033[35m tbx_version \033[0m    : Optionnal: The version you wish to install (example: 19.2.2)"
printf "\n  \033[35m url_source \033[0m     : Optionnal: To specify another URL http than the standard one\n\n"
die "ERROR : Syntax Error"
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
PERL_CMD=$(which perl 2> /dev/null)
[[ -n "${PERL_CMD}" ]] && PERL_OPT="-MLWP::Simple -e"
CURL_CMD=$(which curl 2> /dev/null)
[[ -f /usr/bin/wget ]] && WGET_CMD="/usr/bin/wget"

[[ -f ${__DIR__TOOLBOXES}/version ]] && INSTALLED_VERSION=$(awk -F "|" '/Version/ { print $2 }' ${__DIR__TOOLBOXES}/version) || INSTALLED_VERSION=0
RC=0
# ----------------------

# --- Parameter ---
if [[ -n $1 ]];then
  echo $1 | grep '^/' >/dev/null
  if [[ $? -eq 0 ]];then
    DWD_DIR=${1}
    if [[ -n $2 ]];then
      if [ "$2" = "YES" -o "$2" = "yes" -o "$2" = "y" -o "$2" = "Y" ];then
        FORCE_INSTALL_TBX=${2}
        if [[ -n $3 ]];then
          echo $3 | grep '^http' >/dev/null
          if [[ $? -ne 0 ]];then
            FORCE_OLD_VER=${3}
            if [[ -n $4 ]];then
              HTTP_URL=${4}
            fi
          else
            HTTP_URL=${3}
          fi
        fi
      else
        echo $2 | grep '^http' >/dev/null
        if [[ $? -ne 0 ]];then
          FORCE_OLD_VER=${2}
          if [[ -n $3 ]];then
            HTTP_URL=${3}
          fi
        else
          HTTP_URL=${2}
        fi
      fi
    fi
  else
    usage
  fi
fi

# -----------------

# --- Package infos ---
VERSION_FILE="version"
LATEST_VER=""
ALL_VER=""
PRODUCT_NAME="IPS_TOOLBOXES"
TARGET="LINUX-AIX_GEN_BE-FR-IT"
PACKAGE_EXT="tar"
PACKAGE_NAME=""
INST_PROPOSAL="no"
typeset -i PACKAGE_SIZE=300
(( INST_NEEDED_SIZE = ${PACKAGE_SIZE} * 2 ))
# ---------------------


#-----------------------------------------------------------------------------#
# Functions
#-----------------------------------------------------------------------------#

# -------------------------------------
# Comparing numeric version numbers
# returns 1 if curr_version > repo_version
#         0 otherwise
# @param curr_version: Installed version
# @param repo_version: Version on the repository
#
compareVersion()
{
    typeset curr_version="${1}"
    typeset repo_version="${2}"

    awk \
    -v currVer="${curr_version}" \
    -v repoVer="${repo_version}" \
    ' BEGIN {
        currSize = split( currVer, currVerTab, ".")
        repoSize = split( repoVer, repoVerTab, ".")

        if ( currSize > repoSize )
            maxSize = currSize
        else
            maxSize = repoSize

        for (idx = 1; idx <= maxSize; idx ++) {
            if ( currVerTab[idx] == repoVerTab[idx] )
                continue

            if ( currVerTab[idx] < repoVerTab[idx] )
                exit 0

            if ( currVerTab[idx] > repoVerTab[idx] )
                exit 1
        }
    }'
}


# -------------------------------------
# Downloading file from the repository
getFile()
{
    # Getting the latest package available on the repository
    if [ "${FORCE_OLD_VER}" != "" ];then
      LATEST_VER="${FORCE_OLD_VER}"
      PACKAGE_NAME=$(${CURL_CMD} -s ${HTTP_URL}/ --list-only | grep IPS_TOOLBOXES | grep -v _IPS | grep LINUX-AIX_GEN_BE-FR-IT | grep _1.0_ | awk -F ' href="' '{print$2}' | awk -F '">' '{print$1}' | grep ${LATEST_VER} | head -1)
    fi
    print_info "Starting to download ${PACKAGE_NAME} to ${DWD_DIR}/"
    cd ${DWD_DIR}

    if [ "${DWD_CMD}" = "curl" ]
    then
        ${CURL_CMD} ${HTTP_URL}/${PACKAGE_NAME} -O
        rc=$?
    elif [ "${DWD_CMD}" = "perl" ]
    then
        ${PERL_CMD} ${PERL_OPT} "getstore('${HTTP_URL}/${PACKAGE_NAME}', '${DWD_DIR}/${PACKAGE_NAME}')"
        rc=$?
    elif [ "${DWD_CMD}" = "wget" ]
    then
        ${WGET_CMD} -qP ${DWD_DIR} ${HTTP_URL}/${PACKAGE_NAME}
        rc=$?
    fi

    if [[ -f ${DWD_DIR}/${PACKAGE_NAME} && ${rc} -eq 0 ]]
    then
        return ${rc}
    else
        rc=1
    fi

    return ${rc}
}

# -----
# MAIN
# -----

# Reset default color when programm is interupted
trap "clear_style ; exit 1" 2 3 6 15

print -- ""

# Checking versions
# -----------------
# Getting the version of the latest package from the repository
# - Try with curl
if [[ -n "${CURL_CMD}" ]]
then

    LATEST_VER=$(${CURL_CMD} -s ${HTTP_URL}/ --list-only | grep IPS_TOOLBOXES | grep -v _IPS | grep LINUX-AIX_GEN_BE-FR-IT | grep _1.0_ | awk -F ' href="' '{print$2}' | awk -F '">' '{print$1}' | awk -F '_' '{print$3" "$4}' | sed 's/ 1.0//g' | sed 's/^1.0 //g' | sort -u | sort -nr | head -1 )
    DWD_CMD="curl"
    if [[ "${LATEST_VER}" != "" ]];then
      YEAR=$(echo "${LATEST_VER}" | awk -F '.' '{print$1}')
      SEMESTER=$(echo "${LATEST_VER}" | awk -F '.' '{print$2}')
      GREP_VER="${YEAR}.${SEMESTER}"
      if [[ "${SEMESTER}" != "2" && "${SEMESTER}" != "1" ]];then
        die "ERROR : Failed to retrieve current toolbox version"
      fi
      if [[ "${SEMESTER}" == "2" ]];then
        GREP_OLD_VER="${YEAR}.1"
      else
        YEAR_OLD=$((YEAR-1))
        GREP_OLD_VER="${YEAR_OLD}.2"
      fi
    else
      die "ERROR : Failed to retrieve current toolbox version"
    fi
    OTHER_VER1=$(${CURL_CMD} -s ${HTTP_URL}/ --list-only | grep IPS_TOOLBOXES | grep -v _IPS | grep LINUX-AIX_GEN_BE-FR-IT | grep _1.0_ | awk -F ' href="' '{print$2}' | awk -F '">' '{print$1}' | awk -F '_' '{print$3" "$4}' | sed 's/ 1.0//g' | sed 's/^1.0 //g'| grep ${GREP_OLD_VER} | grep -v ${LATEST_VER} | sort -u | tr '\n' ' ' | sed 's/ $/\n/' )
    OTHER_VER2=$(${CURL_CMD} -s ${HTTP_URL}/ --list-only | grep IPS_TOOLBOXES | grep -v _IPS | grep LINUX-AIX_GEN_BE-FR-IT | grep _1.0_ | awk -F ' href="' '{print$2}' | awk -F '">' '{print$1}' | awk -F '_' '{print$3" "$4}' | sed 's/ 1.0//g' | sed 's/^1.0 //g' | grep ${GREP_VER} | grep -v ${LATEST_VER} | sort -u | tr '\n' ' ' | sed 's/ $/\n/')
    OTHER_VER=$(echo "${OTHER_VER1} ${OTHER_VER2}" | sed 's/ $/\n/')
    ALL_VER=$( echo "${OTHER_VER} ${LATEST_VER}")
    PACKAGE_EXT=$(${CURL_CMD} -s ${HTTP_URL}/ --list-only | grep IPS_TOOLBOXES | grep -v _IPS | grep LINUX-AIX_GEN_BE-FR-IT | grep _1.0_ | awk -F ' href="' '{print$2}' | awk -F '">' '{print$1}' | grep ${LATEST_VER} | head -1 | awk -F '.' '{print$NF}' )
    PACKAGE_NAME=$(${CURL_CMD} -s ${HTTP_URL}/ --list-only | grep IPS_TOOLBOXES | grep -v _IPS | grep LINUX-AIX_GEN_BE-FR-IT | grep _1.0_ | awk -F ' href="' '{print$2}' | awk -F '">' '{print$1}' | grep ${LATEST_VER} | head -1 )
fi

# - Try with perl
if [[ -z "${LATEST_VER}" ]]
then
    [[ -n "${PERL_CMD}" ]] && LATEST_VER=$(${PERL_CMD} ${PERL_OPT} "getprint('${HTTP_URL}/${VERSION_FILE}')" 2> /dev/null)
    [ $? -eq 0 ] && LATEST_VER=$(echo "${LATEST_VER}" | awk -F "|" '/Version/ { print $2 }')
    DWD_CMD="perl"
    ALL_VER=$(${PERL_CMD} ${PERL_OPT} "getprint('${HTTP_URL}/all_supported_version')" 2> /dev/null)
    PACKAGE_NAME="${PRODUCT_NAME}_1.0_${LATEST_VER}_${TARGET}.${PACKAGE_EXT}"
fi

#- Try with wget
if [[ -z "${LATEST_VER}" ]]
then
    [[ -n "${WGET_CMD}" ]] && LATEST_VER=$(${WGET_CMD} -q ${HTTP_URL}/${VERSION_FILE} -O - 2> /dev/null)
    [ $? -eq 0 ] && LATEST_VER=$(echo "${LATEST_VER}" | awk -F "|" '/Version/ { print $2 }')
    DWD_CMD="wget"
    ALL_VER=$(${WGET_CMD} -q ${HTTP_URL}/all_supported_version -O - 2> /dev/null)
    PACKAGE_NAME="${PRODUCT_NAME}_1.0_${LATEST_VER}_${TARGET}.${PACKAGE_EXT}"
fi

[[ -z "${LATEST_VER}" ]] && die "ERROR : Failed to retrieve the latest package's version number from the repository!" "2"

if [ "${FORCE_OLD_VER}" != "" ];then
  echo "${ALL_VER}" | grep -w ${FORCE_OLD_VER} 1>/dev/null 2>&1
  if [ $? -ne 0 ];then
    die "ERROR : The version ${FORCE_OLD_VER} is not available on this repository"
  fi
fi


# Version comparison
if [ "${INSTALLED_VERSION}" = "${LATEST_VER}" ]
then
    if [ "${FORCE_OLD_VER}" == "" ];then
      printf "\t${INVERT_BF}The version installed ${FG_GREEN}v${INSTALLED_VERSION}${FG_DEFAULT}${INVERT_BF} is already the latest!${FG_DEFAULT}\n\n"
    fi
    if [ $# -eq 0 ];then
      printf "\t${INVERT_BF}Do you want to install an older version? [yes|no] : ${FG_GREEN}${INVERT_BF}"; read older
      printf "${FG_DEFAULT}\n"
      if [ "${older}" = "yes" ];then
        printf "\t${INVERT_BF}Enter the version you wish to install? ('q' to quit):${FG_DEFAULT}"
        printf "\n${ALL_VER}\n"
        printf "\n>> "; read older_version
        [[ "${older_version}" == "q" ]] && die "Operation aborted by user..."
        echo ${ALL_VER} | grep -w ${older_version}
        if [ $? -eq 0 ];then
          LATEST_VER=${older_version}
          PACKAGE_EXT=$(${CURL_CMD} -s ${HTTP_URL}/ --list-only | grep IPS_TOOLBOXES | grep -v _IPS | grep LINUX-AIX_GEN_BE-FR-IT | grep _1.0_ | awk -F ' href="' '{print$2}' | awk -F '">' '{print$1}' | grep ${LATEST_VER} | head -1 | awk -F '.' '{print$NF}' )
          PACKAGE_NAME=$(${CURL_CMD} -s ${HTTP_URL}/ --list-only | grep IPS_TOOLBOXES | grep -v _IPS | grep LINUX-AIX_GEN_BE-FR-IT | grep _1.0_ | awk -F ' href="' '{print$2}' | awk -F '">' '{print$1}' | grep ${LATEST_VER} | head -1 )
          FORCE_OLD_VER="${LATEST_VER}"
        else
          die "ERROR : Not a valid version. Please try again"
        fi
      else
        exit ${RC}
      fi
    elif [ "${FORCE_OLD_VER}" == "" ];then
      exit 0
    else
      if [ "${INSTALLED_VERSION}" = "${FORCE_OLD_VER}" ];then
        echo "The installed version is already the one you want to install"
        exit 0
      fi
    fi
else
    if [ "${FORCE_OLD_VER}" == "" ];then
      compareVersion ${INSTALLED_VERSION} ${LATEST_VER}
      RC=$?
      if [ ${RC} -eq 0 ]
      then
        printf "\t${INVERT_BF}A more recent version ${FG_GREEN}v${LATEST_VER}${FG_DEFAULT}${INVERT_BF} was found! Proceeding to download ...${FG_DEFAULT}\n\n"
      else
        die "ERROR : The version installed (v${INSTALLED_VERSION}) is newer than the version to download (v${LATEST_VER})!" ${RC}
      fi
    else
      if [ "${INSTALLED_VERSION}" = "${FORCE_OLD_VER}" ];then
        echo "The installed version is already the one you want to install"
        exit 0
      fi
    fi
fi


# Checking parameter
# ------------------
if [ $# -eq 0 ]
then
    printf "\nEnter the directory where to download the package (minimum size required is ${PACKAGE_SIZE} Mb) : ${FG_GREEN}${INVERT_BF}"; read downloadDir
    printf "${FG_DEFAULT}\n"
    [[ -z "${downloadDir}" ]] && die "ERROR : You typed an empty value!"

    DWD_DIR="${downloadDir}"
fi

# Checking download directory
# ---------------------------
if [ -d ${DWD_DIR} ]
then
    downloadDirSize=$(df -mP ${DWD_DIR} | awk '$0 ~ /Filesystem/ { next } { print $4 }' | cut -d '.' -f1)
    [[ ${PACKAGE_SIZE} -gt ${downloadDirSize} ]] && die "ERROR : Download directory: ${DWD_DIR} size(${downloadDirSize} Mb) is not enough! The size needed is ${PACKAGE_SIZE} Mb"
    [[ ${downloadDirSize} -ge ${INST_NEEDED_SIZE} ]] && INST_PROPOSAL="yes"
    if [[ -n ${FORCE_INSTALL_TBX} ]];then
      [ "${INST_PROPOSAL}" == "no" ] && die "ERROR : Download directory: ${DWD_DIR} size(${downloadDirSize} Mb) is not enough! The size needed to download and install is ${INST_NEEDED_SIZE} Mb"
    fi
else
    die "ERROR : Download directory: ${DWD_DIR} not found!"
fi

# Getting sources from NIMPROD server
# -----------------------------------
if [ "${INST_PROPOSAL}" == "no" ]
then
  print -- "${FG_RED}-------------------------------------------- /!\ WARNING /!\ ---------------------------------------------${FG_DEFAULT}"
  print_warning " --> There is not enough space to extract the toolbox package on ${DWD_DIR}."
  print_warning " --> You should abort this operation and extend the related filesystem and then try again."
  printf "${FG_RED}----------------------------------------------------------------------------------------------------------${FG_DEFAULT}\n"
  printf "\n\tAre you agree to abort installation? [yes|no] : ${FG_GREEN}${INVERT_BF}"; read answer_abort
  printf "${FG_DEFAULT}\n"
  if [ "${answer_abort}" != "yes" -a "${answer_abort}" != "no" ]
  then
    printf "${FG_RED} Unrecognized answer"
    exit
  elif [ "${answer_abort}" = "yes" ]
  then
    exit
  fi
fi

getFile
RC=$?

if [ ${RC} -eq 0 ]
then
    instDir=$(echo ${PACKAGE_NAME} | sed 's/.tar//g' | sed 's/.tgz//g' | sed 's/.gz//g')
    print -- ""
    print_info "The package was downloaded successfully:"
    printf "${FG_GREEN}"
    ls -l ${DWD_DIR}/${PACKAGE_NAME}
    printf "${FG_DEFAULT}\n"
    if [ "${INST_PROPOSAL}" == "no" ];then
      print -- "${FG_YELLOW}-------------------------------------------- /!\ WARNING /!\ ---------------------------------------------${FG_DEFAULT}"
      print_warning "/-1-/ Make sure you have enough space left on your device(about 300 Mb) before extracting the sources."
      print_warning "/-2-/ Unpack the 'tar' file and move to '${instDir}' directory."
      print_warning "/-3-/ Launch './Install_IPS_TOOLBOXES_MAN.ksh help' to see how to install the package."
      printf "${FG_YELLOW}----------------------------------------------------------------------------------------------------------${FG_DEFAULT}\n"
    fi

    if [ "${FORCE_INSTALL_TBX}" != "" ]
    then
         [ "${FORCE_INSTALL_TBX}" = "YES" -o "${FORCE_INSTALL_TBX}" = "yes" -o "${FORCE_INSTALL_TBX}" = "y" -o "${FORCE_INSTALL_TBX}" = "Y" ] && answer=yes
    else
         if [ "${INST_PROPOSAL}" = "yes" ]
         then
             printf "\n\tDo you want to start the installation? [yes|no] : ${FG_GREEN}${INVERT_BF}"; read answer
             printf "${FG_DEFAULT}\n"
         fi
    fi

    if [ "${answer}" = "yes" ]
    then
        cd ${DWD_DIR} || die "ERROR : Unable to move to directory: ${DWD_DIR}"
        [ ! -f ./${PACKAGE_NAME} ] && die "ERROR : Package not found ( ${DWD_DIR}/${PACKAGE_NAME} )"
        if [ "${PACKAGE_EXT}" == "tgz" ];then
          gzip -d ./${PACKAGE_NAME}
          if [ ${?} -eq 0 ];then
            PACKAGE_NAME=$(echo ${PACKAGE_NAME} | sed 's/.tgz/.tar/g')
            [ ! -f ./${PACKAGE_NAME} ] && die "ERROR : Package not found ( ${DWD_DIR}/${PACKAGE_NAME} ). Could be an unzip error"
          else
            die "ERROR : Failed to unzip package: ${PACKAGE_NAME}"
          fi
        fi
        if [ "${PACKAGE_EXT}" == "gz" ];then
          gzip -d ./${PACKAGE_NAME}
          if [ ${?} -eq 0 ];then
            PACKAGE_NAME=$(echo ${PACKAGE_NAME} | sed 's/.gz/.tar/g')
            [ ! -f ./${PACKAGE_NAME} ] && die "ERROR : Package not found ( ${DWD_DIR}/${PACKAGE_NAME} ). Could be an unzip error"
          else
            die "ERROR : Failed to unzip package: ${PACKAGE_NAME}"
          fi
        fi
        tar xf ${PACKAGE_NAME}
        [ ${?} -ne 0 ] && die "ERROR : Failed to extract tar file: ${PACKAGE_NAME}"
        cd ${instDir} || die "ERROR : Unable to move to directory: ${instDir}"
        if [ "${FORCE_OLD_VER}" != "" ];then
          echo "Version|1.2.3|Oct 2016" > /apps/toolboxes/version
          echo "Version|1.2.3|Oct 2016" > /apps/toolboxes/backup_restore/version
          echo "Version|1.2.3|Oct 2016" > /apps/toolboxes/exploit/version
          echo "Version|1.2.3|Oct 2016" > /apps/toolboxes/scheduler/version
          echo "Version|1.2.3|Oct 2016" > /apps/toolboxes/sgbd/oracle/version
          echo "Version|1.2.3|Oct 2016" > /apps/toolboxes/web/version
        fi
        ./Install_IPS_TOOLBOXES_MAN.ksh install all
        RC=$?
        rm -f /apps/toolboxes/exploit/tmp/*.cache 1>/dev/null 2>&1
        [ $RC -eq 40 ] && RC=0
        if [ $RC -eq 0 ];then
          echo "The toolbox has been successfully installed"
        else
          die "ERROR : Error while installing toolbox. You can find installation logs in /apps/Deploy/Logs/"
        fi
    fi
else
    die "ERROR : The download of ${PACKAGE_NAME} failed!" ${RC}
fi

exit ${RC}

