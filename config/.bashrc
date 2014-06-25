export CLICOLOR=1
# Regular Colors
Black="\033[0;30m" # Black
Red="\033[0;31m" # Red
Green="\033[0;32m" # Green
Yellow="\033[0;33m" # Yellow
Blue="\033[0;34m" # Blue
Purple="\033[0;35m" # Purple
Cyan="\033[0;36m" # Cyan
White="\033[0;37m" # White

# High Intensty
BBlack="\033[0;90m" # Black
BRed="\033[0;91m" # Red
BGreen="\033[0;92m" # Green
BYellow="\033[0;93m" # Yellow
BBlue="\033[0;94m" # Blue
BPurple="\033[0;95m" # Purple
BCyan="\033[0;96m" # Cyan
BWhite="\033[0;97m" # White

# Background
On_Black="\033[40m" # Black
On_Red="\033[41m" # Red
On_Green="\033[42m" # Green
On_Yellow="\033[43m" # Yellow
On_Blue="\033[44m" # Blue
On_Purple="\033[45m" # Purple
On_Cyan="\033[46m" # Cyan
On_White="\033[47m" # White

NC="\033[0m"               # Color Reset


ALERT=${BWhite}${On_Red} # Bold White on red background
# -------------------------------------------------------------
# Shell Prompt - for many examples, see:
#       http://www.debian-administration.org/articles/205
#       http://www.askapache.com/linux/bash-power-prompt.html
#       http://tldp.org/HOWTO/Bash-Prompt-HOWTO
#       https://github.com/nojhan/liquidprompt
#-------------------------------------------------------------
# Current Format: [TIME USER@HOST PWD] >
# TIME:
#    Green     == machine load is low
#    Orange    == machine load is medium
#    Red       == machine load is high
#    ALERT     == machine load is very high
# USER:
#    Cyan      == normal user
#    Orange    == SU to user
#    Red       == root
# HOST:
#    Cyan      == local session
#    Green     == secured remote connection (via ssh)
#    Red       == unsecured remote connection
# PWD:
#    Green     == more than 10% free disk space
#    Orange    == less than 10% free disk space
#    ALERT     == less than 5% free disk space
#    Red       == current user does not have write privileges
#    Cyan      == current filesystem is size zero (like /proc)
# >:
#    White     == no background or suspended jobs in this shell
#    Cyan      == at least one background job in this shell
#    Orange    == at least one suspended job in this shell
#
#    Command is added to the history file each time you hit enter,
#    so it's available to all shells (using 'history -a').


# Test connection type:
if [ -n "${SSH_CONNECTION}" ]; then
    CNX=${Green}        # Connected on remote machine, via ssh (good).
elif [[ "${DISPLAY%%:0*}" != "" ]]; then
    CNX=${ALERT}        # Connected on remote machine, not via ssh (bad).
else
    CNX=${BCyan}        # Connected on local machine.
fi

# Test user type:
if [[ ${USER} == "root" ]]; then
    SU=${Red}           # User is root.
elif [[ ${USER} != $(logname) ]]; then
    SU=${BRed}          # User is not login user.
else
    SU=${BCyan}         # User is normal (well ... most of us are).
fi

# Test git repo:
if [[ -z "$(git status 2> /dev/null | grep 'fatal:')" ]]; then
    GIT=true
else
    GIT=false
fi


NCPU=$(sysctl -n hw.ncpu)    # Number of CPUs
SLOAD=$(( 100*${NCPU} ))        # Small load
MLOAD=$(( 200*${NCPU} ))        # Medium load
XLOAD=$(( 400*${NCPU} ))        # Xlarge load

# Returns system load as percentage, i.e., '40' rather than '0.40)'.
function load()
{
    local SYSLOAD=$(sysctl -n vm.loadavg | cut -d ' ' -f2 | tr -d '.')
    # System load of the current host.
    echo $((10#$SYSLOAD))       # Convert to decimal.
}

# Returns a color indicating system load.
function load_color()
{
    local SYSLOAD=$(load)
    if [ ${SYSLOAD} -gt ${XLOAD} ]; then
        echo -en ${ALERT}
    elif [ ${SYSLOAD} -gt ${MLOAD} ]; then
        echo -en ${Red}
    elif [ ${SYSLOAD} -gt ${SLOAD} ]; then
        echo -en ${Yellow}
    else
        echo -en ${Green}
    fi
}

function git_color()
{
    if [[ ${GIT} ]]; then
        local STATUS=$(git status 2> /dev/null)
        if [ "$(echo ${STATUS} | grep 'new file:\|modified:\|deleted:\|renamed:')" ]; then
           echo -en ${Yellow} 
        elif [ "$(echo ${STATUS} | grep 'conflict')" ]; then
            echo -en ${Red}
        else
            echo -en ${Green}
        fi
    fi
}

# Now we construct the prompt.
PROMPT_COMMAND="history -a"

# Time of day (with load info):
PS1="[\$(load_color)\w${NC}"
# Display git info:
if [[ ${GIT} ]]; then
    PS1=${PS1}" \$(git_color)\$(parse_git_branch)${NC}] "
else
    PS1=${PS1}"]"
fi
# User@Host (with connection type info):
PS1=${PS1}"${SU}\u${NC}@${CNX}\h${NC}\$ "


export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTIGNORE="&:bg:fg:ll:h"
export HISTTIMEFORMAT="$(echo -e ${BCyan})[%d/%m %H:%M:%S]$(echo -e ${NC}) "
export HISTCONTROL=ignoredups
export HOSTFILE=$HOME/.hosts    # Put a list of remote hosts in ~/.hosts

### Git mastery
parse_git_branch() {
      git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
  }


### Aliases
alias gits="git status --short"
alias ls="ls -G"
alias pippin='sudo ARCHFLAGS="-Wno-error=unused-command-line-argument-hard-error-in-future" pip install'
alias pycl='rm *.pyc'

### Dumb pip exports
export CFLAGS=-Qunused-arguments
export CPPFLAGS=-Qunused-arguments
