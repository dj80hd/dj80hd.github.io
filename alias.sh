########################################################################
#  80HD Time Saving Aliases
#  Tip: To see all active functions and aliases use typeset -f and alias
########################################################################

#TODO
# - something to save last command to file for reference
# - alternative to ping that returns 0 if ping works (e.g. alive www.foo.com)

########################################################################
#  cassandra              
########################################################################
function dks() { 
    echo "describe keyspaces;" | cqlsh "$@" 
}
########################################################################
#  zentry functions
########################################################################
function apt-install-zentry() {
    sudo apt-get install git curl wget build-essential python-dev python-pip python-virtualenv libev4 libev-dev libffi-dev libssl-dev -y
}

function cloneall() {
   git clone ssh://git@aloha.icsl.net:2223/aloha/core-ui.git
   git clone ssh://git@aloha.icsl.net:2223/aloha/core-api.git
   git clone ssh://git@aloha.icsl.net:2223/aloha/authn-session-authz.git
}
#Perform unit tests for core-ui/core-api/authn
function utestit() {
    find . -name __pycache__ -type d -print0|xargs -0 rm -fr --
    /bin/cp local/__init__.py.default local/__init__.py
    python -m pytest --junitxml=./junit.xml --cov . tests
}
########################################################################
#  docker functions
########################################################################
function kickdocker() {
    sudo service docker.io restart
}
function dockerupdate() {
    sudo add-apt-repository ppa:docker-maint/testing
    sudo apt-get update
    sudo apt-get install docker.io -y
}
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
    sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $1 
}
function dipa() { 
    sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $1 
    sudo docker inspect --format '{{  .NetworkSettings.Ports  }}' $1
}
function cqltest() {
    if [ -z "$1" ]; then
       echo "USAGE: cqltest <docker name>"
       echo "e.g.   cqltest dse"
       exit 1
    fi                    
    P=`sudo docker port $1 9160 |cut -d':' -f2`
    cqlsh 127.0.0.1 $P
}
function dipp() {
    #This did not work http://stackoverflow.com/questions/30342796/how-to-get-env-variable-when-doing-docker-inspect/30353018#30353018
    if [ -z "$1" ]; then
       echo "USAGE: dipp <docker name> <exposed port>"
       echo "e.g.   dipp baremetal 22                 "
       exit 1
    fi                    
    sudo docker port $1 $2 |cut -d':' -f2
}

function dhostport() {
    sudo docker inspect $1 |grep HostPort | cut -d '"' -f 4
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

function blame() {
    git --no-pager blame $1
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
    git config --global user.name "Jimi Werwath"           
    git config branch.master.rebase true
    git config --global core.editor vi
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

function b() {
    LEVELS=1
    if [ ! -z "$1" ]; then
        LEVELS=$1
    fi
    for i in $(seq 1 $LEVELS); do cd ..; done

}
#python virtual envs
alias activate='source ENV/bin/activate'

function pd() {
    export D=$PWD
}
function ppd() {
    cd $D
}
# Recursively delete directories by name
function rdd() {
    if [ -z "$1" ]; then
        echo "ERROR: You must specify a directory name (e.g. ENV)"
    else
        find . -name $1 -type d -print0|xargs -0 rm -r --
    fi  
}
# Recusive ls sorted by size
function sortsize() {
    find . -type f -print0 | xargs -0 ls -la | awk '{print int($5/1000) " KB\t" $9}' | sort -n -r -k1
}

function zipdir2() {
    tar -cvzf $1.tgz $1
    echo "unzip with tar -xvzf $1.tgz"
}
function zipdir() {
    #better to use ?
    #tar -cvzf backup.tgz /home/user/project
    #tar -xvzf backup.tgz
    if [ -z "$1" ]; then
        echo "dir is required, e.g. zipdir foo/"
    else
        zip -r $1.zip $1  
    fi
}
function curli() {
    curl -L -i -k "$@"
}

# Curl a local secure port (shorthand for curl https://127.0.0.1:8443)
function curlslp() {
    if [ -z "$1" ]; then
        echo "port is required, e.g. curlslp 8443  "
    else
        curl -i -k -L https://127.0.0.1:$1
    fi
}
# Curl a local port (shorthand for curl http://127.0.0.1:8080)
function curllp() {
    if [ -z "$1" ]; then
        echo "port is required, e.g. curllp 80  "
    else
        curl -i -k http://127.0.0.1:$1
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

# Personal version of pkill that is more flexible
function mypkill() {
    [[ -z "$1" ]] && { echo "USAGE: mypkill <search_term>" ; return 1 ; }
    for KILLPID in `ps aux | grep $1 |grep -v grep | awk ' { print $2;}'`; do 
        echo "Killing process $KILLPID ..."
        kill -9 $KILLPID;
    done
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
#- recursively delete files of type                               
#- e.g. rmr pyc
function rmr() { 
    if [ -z "$1" ]; then
        echo "you must enter an extension like pyc"
    else
        find . -name "*.$1" -type f -delete
    fi
}

function fp() { find . -print |grep $1 ;}

function ENV() {
    #FIXME - check for deactivate function and call if it exists
    rm -fr ENV
    virtualenv ENV 
    source ENV/bin/activate
    pip install -r requirements.txt
    if [ -f test-requirements.txt ]; then
        pip install -r test-requirements.txt
    fi
}
function deact() {
    deactivate
    activate
}
function venv() { 
    ENV 
}
function getpip() {
    sudo curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | sudo python
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
function opscenter() {
    ssh -Nn -D 9090 james.werwath@mahalo.icsl.net
    echo "Set your SOCKS proxy to localhost:9090 for url *http://65.196.125.198:8888/*"
    
}
function kaiaulu2() {
    ssh james.werwath@kaiaulu2.icsl.net 
}
function k2() {
    kaiaulu2
}
function k2cmd() {
    ssh james.werwath@kaiaulu2.icsl.net "$@"
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
function install_java() {
    sudo add-apt-repository ppa:webupd8team/java -y
    sudo apt-get update
    sudo echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
    sudo apt-get install oracle-java7-installer -y --force-yes
}

# Env vars
function myenv() {
  export VS=~/home/boxes/vz/scripts
  export VZG=ssh://git@aloha.icsl.net:2223/aloha
}
function contains() {
# contains(string, substring)
#
# Returns 0 if the specified string contains the specified substring,
# otherwise returns 1.
# e.g.
# contains "abcd" "e" || echo "abcd does not contain e"
# (shamelesslly ripped off from http://tinyurl.com/nzg5hcm)
    string="$1"
    substring="$2"
    if test "${string#*$substring}" != "$string"
    then
        return 0    # $substring is in $string
    else
        return 1    # $substring is not in $string
    fi
}

######### BASH JEMS ###############
# - Current dir of script
#DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#
# - Here Doc:
#cat << EOF > /tmp/yourfilehere
#These contents will be written to the file.
#        This line is indented.
#EOF
# - Check for program
# command -v foo >/dev/null 2>&1 || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }
# - Grep command output (without grep)
# [[ $(/usr/local/bin/monit --version) != *5.5* ]]
#[[ $CORE_UI_TEST == *"$NEEDLE"* ]] && CORE_UI_STATUS="OK"
# - Test if ports open
# exec 6<>/dev/tcp/127.0.0.1/445 || echo "No one is listening!"
# exec 6>&- # close output connection
# exec 6<&- # close input connection
#
# - One line error exits
# test "0" = "$?" || { echo "ERROR: Copy error [2]" ; exit $?; }
# test -f $FILE|| { echo "ERROR: FILE does not exist: $FILE" ; exit $?; }
