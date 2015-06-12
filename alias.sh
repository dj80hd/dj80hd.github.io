########################################################################
#  80HD Time Saving Aliases
#  Tip: To see all active functions and aliases use typeset -f and alias
########################################################################

#TODO
# - something to save last command to file for reference
# - alternative to ping that returns 0 if ping works (e.g. alive www.foo.com)

########################################################################
#  docker functions
########################################################################

#- Conveniece method to run docer commands as sudo
function d() { sudo docker "$@" ;}

#- Conveniece method to execute a command in a container
function de() { sudo docker exec -t "$@" ;}

#- Conveniece method to create an interactive shell in a container
function dei() { sudo docker exec -i -t $1 bash ;}

#- Conveniece method to remove a container                         
function dr() { sudo docker rm $1 ;}

#- Conveniece method to show active containers                     
function dp() { sudo docker ps ;}

#- Conveniece method to build a container                          
function db() { sudo docker build -t $1 . ;}
function dbnc() { sudo docker build --no-cache -t $1 . ;}

#- Conveniece method to show logs in a given container             
function dl() { sudo docker logs $1 ;}

#- Conveniece method to run an interactive disposable container w/ /tmp mapped
function drt() { docker run --rm -v /tmp:/tmp -it ubuntu:trusty ;}
function drtp() { docker run --rm -v /tmp:/tmp -it dj80hd/privates:trustyplus ;}

#- Show report of volumes in each image (FIXME - IMPLEMENT)        
function dv() { 
    #FIXME - Do this for each image if no param
    docker inspect -f "{{ .Volumes }}" $1
}

#Backup all volumes of a given container.
#FIXME - Implement. dbv foo should leave a file foo_backup.tar in local dir
function dbv() {
   echo "ERROR: NOT IMPLEMENTED!"
# for each $dir
# docker run --rm --volumes-from $1 -v $(pwd):/backup ubuntu tar cvf /backup/$1_backup.tar $dir
}

#- Show all docker process, optional input match string
#- e.g. dpa flasky
function dpa() { 
    if [ -z "$1" ]; then
        sudo docker ps -a 
    else
        sudo docker ps -a |grep $1
    fi
}

#- Show all docker images with optional grep param
function di() { 
    if [ -z "$1" ]; then
        sudo docker images
    else
        sudo docker images | grep $1
    fi
}


#- Stop any containers matching input
function dps() {
    for p in `sudo docker ps|grep $1 |cut -d' ' -f 1` ; do 
        sudo docker stop $p 
    done
}

#- Stop and remove any containers matching input param
function dprm() {
    for p in `sudo docker ps -a|grep $1 |cut -d' ' -f 1` ; do 
        sudo docker stop $p 
        sudo docker rm $p 
    done
}

function dip() { 
    docker inspect --format '{{ .NetworkSettings.IPAddress }}' $1 
}

function dhostport() {
    docker inspect $1 |grep HostPort | cut -d '"' -f 4
}

########################################################################
# Ansible Stuff
########################################################################
#- Conveniece method to run ansible-playbook
function anp() { ansible-playbook "$@" ;}
function anpl() { ansible-playbook -c local "$@" ;}


########################################################################
#Git Stuff
########################################################################
function gpom() {
    git pull origin master
}
function gln() {
    if [ -z "$1" ]; then
        git log -n 1
    else
        git log -n $1
    fi
}
function gacp() {
    if [ -z "$1" ]; then
        echo "ERROR: You must specify a comment"
        echo "e.g. gacp \"This is a comment\""
    else
        git add -A .
        git commit -m "$1"
        git push origin master
    fi
}

########################################################################
# Vagrant
########################################################################
# Alias for vagrant global status
function vgs() {
    vagrant global-status
}

# Halt all running vagrant instances
function vhall() {
    for b in `vagrant global-status |grep running |cut -d' ' -f 1` ; do 
        vagrant halt $b
    done
}

########################################################################
# Misc
########################################################################
function aptall() {
    dpkg --get-selections | grep -v deinstall
}
########################################################################
# Misc
########################################################################
#python virtual envs
alias activate='source venv/bin/activate'

#my aliases
alias copy='cp'
alias h='history'
function pg() { ps aux |grep $1 ;}
function hg() { history |grep $1 ;}
function psa() { ps aux |grep $1 | grep -v grep ;}
function b() { cd .. ;}
function chx() { chmod +x *sh ;}
function mkcd {
    if [ -z "$1" ]; then
        echo "You must enter a directory to be created."
    else
        mkdir -p $1 
        cd $1
    fi   
}
function sbrc() {
    source ~/.bashrc
}
#my vars
LH=http://127.0.0.1
R=~/repos

#- find and grep                                                  
function fg() { 
    if [ -z "$2" ]; then
        grep -r $1 . 
    else
        grep --include="*.$2" -r $1 .
    fi
}
function fp() { find . -print |grep $1 ;}

function venv {
    virtualenv venv
    source venv/bin/activate
    pip install -r requirements.txt
}
########################################################################
# Alias management
########################################################################
# Reload these aliases
alias aupdate='curl -s -o alias.txt http://dj80hd.github.io/alias.sh ; source alias.txt ; rm alias.txt'

