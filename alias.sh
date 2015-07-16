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

#- Shorthand for upgrading docker to latest version
function dupgrade() {
    wget -qO- https://get.docker.com/ | sh
}

#- Conveniece method to remove a container                         
function dr() { sudo docker rm $1 ;}

#- Conveniece method to show active containers                     
function dp() { sudo docker ps ;}
#- Show all docker process, optional input match string
#- e.g. dpa flasky
function dpa() { 
    if [ -z "$1" ]; then
        sudo docker ps -a 
    else
        sudo docker ps -a |grep $1
    fi
}

#- Conveniece method to build a container                          
function db() { sudo docker build -t $1 . ;}
function dbnc() { sudo docker build --no-cache -t $1 . ;}

#- Conveniece method to show logs in a given container             
function dl() { sudo docker logs $1 ;}

#- Conveniece method to run an interactive disposable container w/ /tmp mapped
function drt() { sudo docker run --rm -v /tmp:/tmp -it ubuntu:trusty ;}
function drtp() { sudo docker run --rm -v /tmp:/tmp -it dj80hd/privates:trustyplus ;}

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


#- Show all docker images with optional grep param
function di() { 
    if [ -z "$1" ]; then
        sudo docker images
    else
        sudo docker images | grep $1
    fi
}


#- Stop any containers matching input, no input -> stop all
function dps() {
    if [ -z "$1" ]; then
        for p in `sudo docker ps|grep -v IMAGE | cut -d' ' -f 1` ; do 
            sudo docker stop $p 
        done
    else
        for p in `sudo docker ps|grep $1 |cut -d' ' -f 1` ; do 
            sudo docker stop $p 
        done
    fi
}

#- Stop and remove any containers matching input param
function dprm() {
    for p in `sudo docker ps -a|grep $1 |cut -d' ' -f 1` ; do 
        sudo docker stop $p 
        sudo docker rm $p 
    done
}
# Delete all
function dprma() {
    for p in `sudo docker ps -a|grep -v CONTAINER |cut -d' ' -f 1` ; do 
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

#- Dump all the playbooks in a given root directory
function andump() {
    for f in `find -f . |grep "\.yml"` ; do 
        echo $f             
        echo "-----------------------------------------------------"
        cat $f
        echo
    done
}


########################################################################
#Git Stuff
########################################################################
function gpom() {
    git pull origin master
}

function blameall() {
    for f in `git ls-tree --full-tree -r HEAD |awk '{print $4}'`; do
        git --no-pager blame $f
    done
}
function blamealls() {
    #Sucks name out of git blame output
    #trims leading/tailing whitespace
    blameall |perl -e 'while(<>){ print "$1\n" if /\(([\w ]+)\s+20/;}'|sort -n |awk '{$1=$1};1'|uniq -c
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

function gitme() {
    git config --global user.email "werwath@gmail.com"
    git config --global user.name "80HD"           
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
# Cassandra
########################################################################
function dk() {
    echo "describe keyspaces;" | cqlsh $1 $2 
}
########################################################################
# Apt
########################################################################
function aptall() {
    dpkg -l
}
########################################################################
# Misc
########################################################################
#python virtual envs
alias activate='source ENV/bin/activate'

function zipdir() {
    if [ -z "$1" ]; then
        echo "dir is required, e.g. zipdir foo/"
    else
        zip -r $1.zip $1  
    fi
}
function curli() {
    curl -i -k "$@"
}

# Curl a local secure port (shorthand for curl https://127.0.0.1:8443)
function curlslp() {
    if [ -z "$1" ]; then
        echo "port is required, e.g. curlslp 8443  "
    else
        curl -k https://127.0.0.1:$1
    fi
}
# Curl a local port (shorthand for curl http://127.0.0.1:8080)
function curllp() {
    if [ -z "$1" ]; then
        echo "port is required, e.g. curllp 80  "
    else
        curl http://127.0.0.1:$1
    fi
}
function port() {
    if [ -z "$1" ]; then
        echo "A port number is required, i.e. port 8080"
    else
        sudo lsof -i :$1
    fi
}
#
# Detailed directory list with optional grep paramter
# e.g. lsl pyc
#
function lsl() {
    if [ -z "$1" ]; then
        ls -al
    else
        ls -al | grep $1
    fi
}
#
# Creates http server in this directory running on port
# $1 - port (optional) 5000 by default
#
function httphere() {
    python -m SimpleHTTPServer $1
}

#
# kills any process running on the given port
# $1 - Port Number (e.g. 8080)
function lsofkill() {
   PID=`lsof -t -i :$1`
   if [ ! "$PID" = "" ]; then
       kill -9 $PID
   fi             
}
#
# Gather up all requirements.txt in this and any sub directory, print
# it all as a unique list of requirements
#
function all_requirements() {
    # ignore, comments, whitespace, handle special case of things like
    # -e git+ssh://git@aloha.icsl.net:2223/aloha/vzlogs3.git@v0.1.0#egg=vzlogs3
    for f in $(fp requirements.txt|grep -v ENV); do cat $f; done |sort |perl -e 'while(<>){ print "$1\n" if /^(\S+)/ && !/^#/ && !/^-/; print "$1\n" if /(-e \S+)/;}' |uniq
}
#
# tinyurl (from http://wtanaka.com/node/7750)
#
function tinyurl() {
wget -q -O - \
-U "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.8) Gecko/20071008 Firefox/2.0.0.8" \
--header="Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1" \
--header="Accept-Language: en" \
--header="Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7" \
--referer="http://tinyurl.com/" \
--header="Content-Type: application/x-www-form-urlencoded" \
--post-data="url=$*" \
http://tinyurl.com/create.php \
| sed -n 's/.*\(http:\/\/tinyurl.com\/[a-z0-9][a-z0-9]*\).*/\1/p' \
| uniq
}

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
#- e.g. fg selenium py
function fg() { 
    if [ -z "$2" ]; then
        grep -r $1 . 
    else
        grep --include="*.$2" -r $1 .
    fi
}
function fp() { find . -print |grep $1 ;}

function ENV() {
    #FIXME - check for deactivate function and call if it exists
    rm -fr ENV
    virtualenv ENV 
    source ENV/bin/activate
    pip install -r requirements.txt
}
function venv() { 
    ENV 
}

########################################################################
# Alias management
########################################################################
# Reload these aliases
alias aupdate='curl -s -o /tmp/alias.txt http://dj80hd.github.io/alias.sh ; source /tmp/alias.txt ; rm /tmp/alias.txt'

########################################################################
# VZ stuff            
########################################################################
function kepolo() {
  ssh james.werwath@kepolo.icsl.net
}
function mahalo() {
  ssh james.werwath@mahalo.icsl.net
}
function luau() {
  ssh james.werwath@luau.icsl.net
}
function vztun() {
    if [ -z "$1" ]; then
        echo "You must specifiy a host e.g. vztun mahalo 5003"
    elif [ -z "$2" ]; then
        echo "You must specifiy a host e.g. vztun mahalo 5003"
    else
        USED=`lsof -i :$2`
        #FIXME - Make sure we are not on the host we are tunneling to!
        if [ -z "$USED" ]; then
            ssh -fNT -L $2:localhost:$2 james.werwath@$1.icsl.net
        else 
            echo "ERROR: Looks like port $2 is used.  lsof -i :$2 to find PID" 
        fi                     
    fi                     
        

}


