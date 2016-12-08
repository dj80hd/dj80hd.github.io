########################################################################
#  80HD Time Saving Aliases
#  Tip: To see all active functions and aliases use typeset -f and alias
########################################################################

#
# To NOT have sudo when using docker do this before sourcing this file:
# export DOCKER_CMD=docker
#
if [ -z "$DOCKER_CMD" ]; then
    DOCKER_CMD="sudo docker "
fi


#TODO
# - something to save last command to file for reference
# - alternative to ping that returns 0 if ping works (e.g. alive www.foo.com)

########################################################################
# AWS
########################################################################
function awslogout() {
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_ACCESS_KEY_ID
    unset aws_secret_access_key
    unset aws_access_key_id
}



########################################################################
# uptake                  
########################################################################
function uptunnel() {
  ssh -D 9666 -f -C -q -N -i ~/repos/p/other_keys/do_id_rsa root@104.236.232.3
}
function cijenkins() {
  ssh -i /t/creds/centos-dev2.pem centos@jenkins.ci.uptake.com
}
function bltlatest() {
    if [ -z "$1" ]; then
        echo "You must specify a blt product, e.g. blt-scm-git"
        return 1
    fi
    PLUGIN=$1
    PLUGIN=`echo $PLUGIN | tr . -`
    curl -s -X GET -H "Accept: application/json" https://jenkins.uptake.com/nexus/service/local/lucene/search?a=$PLUGIN |jq .data[0].latestRelease
}
########################################################################
# ffmpeg                  
########################################################################
#- FIXME: need function to check if ffmpeg installed and suggest how based
#- on OS

function wav2mp3() {
    for wavfile in "$@"
    do
        #- FIXME, check all args are .wav files
        #basefile=`basename $wavfile .wav`
        #echo "BASEFILE>>>$basefile"
        mp3file="$wavfile.mp3"
        #echo "WAVFILENAME>>>$wavfile"
        #echo "MP3FILENAME>>>$mp3file"
        ffmpeg -i "$wavfile" -vn -ar 44100 -ac 2 -ab 320k -f mp3 "$mp3file"
    done
}

########################################################################
# gradle                  
########################################################################
function gradle() {
    REAL_GRADLE=`which gradle`
    if [ -x ./gradlew ]; then
        ./gradlew $@
    else
        $REAL_GRADLE $@
    fi
}
function gb() {
    gradle build
}

function gt() {
    gradle test
}

function gw() {
    ./gradlew $@
}

function gwit() {
    gradle integrationTest $@
}
function gwp() {
    ./gradlew publishToMavenLocal $@
}

########################################################################
#  cassandra              
########################################################################
#- Run a sample query against cqlsh
#- pass optional params to override defaults.  e.g. dks 10.0.2.33 2229
function dks() { 
    echo "describe keyspaces;" | cqlsh "$@" 
}

########################################################################
#  Mesosphere         
########################################################################
function ma() {
    dcos marathon app add $1.json
}
########################################################################
#  zentry functions
########################################################################
#- apt install all packages required for zentry
function apt-install-zentry() {
    sudo apt-get install git curl wget build-essential python-dev python-pip python-virtualenv libev4 libev-dev libffi-dev libssl-dev -y
}


#- Perform unit tests for core-ui/core-api/authn
function utestit() {
    find . -name __pycache__ -type d -print0|xargs -0 rm -fr --
    /bin/cp local/__init__.py.default local/__init__.py
    python -m pytest --junitxml=./junit.xml --cov . tests
}
########################################################################
#  docker functions
########################################################################
#- cleans up space
function dclean() {
  $DOCKER_CMD rm $(docker ps -q -f 'status=exited')
  $DOCKER_CMD rmi $(docker images -q -f "dangling=true")
}
#- remove all images
function drma() {
    $DOCKER_CMD rmi -f $($DOCKER_CMD images -q) 
}
#- logout
function dlogout() {
    if [ -e ~/.docker/config.json ]; then
        rm ~/.docker/config.json
    fi
}

#- Restart Docker Daemon
function kickdocker() {
    sudo service docker.io restart
}

#- docker-machine alias
function dm() {
    docker-machine $@
}

#- Install latest docker
function dupgrade2() {
    sudo add-apt-repository ppa:docker-maint/testing
    sudo apt-get update
    sudo apt-get install docker.io -y
}

#- Shorthand for upgrading docker to latest version
function dupgrade() {
    wget -qO- https://get.docker.com/ | sh
}

#- Conveniece method to run docer commands as sudo
function d() { $DOCKER_CMD "$@" ;}

#- Conveniece method to execute a command in a container
function de() { $DOCKER_CMD exec -t "$@" ;}

#- Conveniece method to create an interactive shell in a container
function dei() { $DOCKER_CMD exec -i -t $1 bash ;}

#- Conveniece method to remove a container                         
function dr() { $DOCKER_CMD rm $1 ;}

#- Conveniece method to show active containers                     
function dp() { $DOCKER_CMD ps ;}

#- Conveniece method to run containers
#- e.g. drit alpine env
function drit() { $DOCKER_CMD run --rm -it $@ ;}

#- Convenience method to stop and kill any running docker containers by name
#- e.g. dkill jenkins
function dkill() {
    $DOCKER_CMD kill $1 2>&1 > /dev/null
    $DOCKER_CMD rm $1 2>&1 > /dev/null
}

#-
#- Kill everything in docker
#-
function dkilla() {
    $DOCKER_CMD ps -a | awk '{print $1}' |grep -v CONTAINER | xargs docker kill
    $DOCKER_CMD ps -a | awk '{print $1}' |grep -v CONTAINER | xargs docker rm
    drma
}

#- Bump docker toolbox
function docker-machine-restart() {
    docker-machine restart default    
    eval $(docker-machine env default)
}


#- Show all docker process, optional input match string e.g. dpa flasky
function dpa() { 
    if [ -z "$1" ]; then
        $DOCKER_CMD ps -a 
    else
        $DOCKER_CMD ps -a |grep $1
    fi
}

#- Conveniece method to build a container                          
function db() { $DOCKER_CMD build -t $1 . ;}
function dbnc() { $DOCKER_CMD build --no-cache -t $1 . ;}

#- Conveniece method to show logs in a given container             
function dl() { $DOCKER_CMD logs $1 ;}

#- Conveniece method to run an interactive disposable container w/ /tmp mapped
function drt() { $DOCKER_CMD run --rm -v /tmp:/tmp -it ubuntu:trusty ;}
function drtp() { $DOCKER_CMD run --rm -v /tmp:/tmp -it dj80hd/privates:trustyplus ;}

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

#- Show all docker images with optional grep param (e.g di bm_)
function di() { 
    if [ -z "$1" ]; then
        $DOCKER_CMD images
    else
        $DOCKER_CMD images | grep $1
    fi
}

#- Stop any containers matching input, no input -> stop all
function dps() {
    if [ -z "$1" ]; then
        for p in `$DOCKER_CMD ps|grep -v IMAGE | cut -d' ' -f 1` ; do 
            $DOCKER_CMD stop $p 
        done
    else
        for p in `$DOCKER_CMD ps|grep $1 |cut -d' ' -f 1` ; do 
            $DOCKER_CMD stop $p 
        done
    fi
}

#- Stop and remove any containers matching input param
function dprm() {
    for p in `$DOCKER_CMD ps -a|grep $1 |cut -d' ' -f 1` ; do 
        $DOCKER_CMD stop $p 
        $DOCKER_CMD rm $p 
    done
}

#- Delete all conatainers both running and stopped.
function dprma() {
    for p in `$DOCKER_CMD ps -a|grep -v CONTAINER |cut -d' ' -f 1` ; do 
        $DOCKER_CMD stop $p 
        $DOCKER_CMD rm $p 
    done
}

#- Get the IP address of a container.
function dip() { 
    $DOCKER_CMD inspect --format '{{ .NetworkSettings.IPAddress }}' $1 
}

#- Get IP address and ports of a container
function dipa() { 
    $DOCKER_CMD inspect --format '{{ .NetworkSettings.IPAddress }}' $1 
    $DOCKER_CMD inspect --format '{{  .NetworkSettings.Ports  }}' $1
}

#- Get a cqlsh shell on a running container.  Input = container name.
function cqltest() {
    if [ -z "$1" ]; then
       echo "USAGE: cqltest <docker name>"
       echo "e.g.   cqltest dse"
       exit 1
    fi                    
    P=`$DOCKER_CMD port $1 9160 |cut -d':' -f2`
    cqlsh 127.0.0.1 $P
}

#-
function dipp() {
    #This did not work http://stackoverflow.com/questions/30342796/how-to-get-env-variable-when-doing-docker-inspect/30353018#30353018
    if [ -z "$1" ]; then
       echo "USAGE: dipp <docker name> <exposed port>"
       echo "e.g.   dipp baremetal 22                 "
       exit 1
    fi                    
    $DOCKER_CMD port $1 $2 |cut -d':' -f2
}

#- ?
function dhostport() {
    $DOCKER_CMD inspect $1 |grep HostPort | cut -d '"' -f 4
}

########################################################################
# Ansible Stuff
########################################################################
#- Conveniece method to run ansible-playbook
function anp() { ansible-playbook "$@" ;}

#- Convenience method to run ansible playbook locally
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
#- Quick checkin of Jenkninsfile for Pipeline:
function gjenkins() {
  git add Jenkinsfile && git commit --amend --no-edit && git push -f
}
#-Recusively remove all git info from a dir
function gremove() {
    #- FIXME: do an exact match for git dir ?
    find . | grep .git | xargs rm -rf
}
function gsize() {
  git count-objects -vH
}
function gpom() {
    git pull origin master
}
function gdiff2() {
    git diff HEAD^ HEAD
}
function grebase() {
    git pull --rebase origin master
}
#- execute any git command with --no-pager so we can pipe the output
function gitnp() {
    git --no-pager "$@"
}

#- git blame with no pager - suitable to piping to other commands
function blame() {
    git --no-pager blame $1
}

#- Find all files touched by git user
function blameuser() {
    if [ -z "$1" ]; then
        echo "You must specify a git user"
        exit 1
    else
        git log --pretty="%H" --author="$1" | while read commit_hash; do git show --oneline --name-only $commit_hash | tail -n+2; done | sort | uniq
    fi
}

#- Worker function for blamealls
function blameall() {
    for f in `git ls-tree --full-tree -r HEAD |awk '{print $4}'`; do
        git --no-pager blame $f
    done
}

#- Print summary of who has worked in a repo
function blamealls() {
    #Sucks name out of git blame output
    #trims leading/tailing whitespace
    blameall |perl -e 'while(<>){ print "$1\n" if /\(([\w ]+)\s+20/;}'|sort -n |awk '{$1=$1};1'|uniq -c
}
function gs() {
    git status
}

#- Convenience method to use git log
function gln() {
    if [ -z "$1" ]; then
        git log -n 1
    else
        git log -n $1
    fi
}

#- Git add -A + git commit <input> + git push origin master
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

#- Update README
function greadme() {
    BRANCH=master
    if [ ! -z "$1" ]; then
        BRANCH=$1
    fi
    git add README.md
    git commit -m "README"
    git push origin $BRANCH
}

#- Configure my default settings for git
function gitme() {
    git config --global user.email "werwath@gmail.com"
    git config --global user.name "Jimi Werwath"           
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config branch.master.rebase true
    git config --global core.editor vi
}

#- Squash last n local commits:
function gsquash() {
    if [ -z "$1" ]; then
        echo "you must specify the number of commits to squash. e.g. 3 = last 3 commits"
        return 1
    fi
    git reset --soft HEAD~$1 &&
    git commit ${@:2}
}

#- Delete a branch locally and remotely
function gdbranch() {
    if [ -z "$1" ]; then
        echo "you must specify a branch name"
        exit 1
    fi
    git branch -d $1
    git push origin --delete $1
}

#- Ammend a commit without changing message
function gmend() {
    git commit --amend --no-edit
}

#- Push current branch to origin
#- DOES NOT WORK GREAT YET
function gpushc() {
  git config --global push.default matching
  #-FIXME use origin as default but allow a different remote to be passed
  THIS_BRANCH=$(git status|head -n 1|sed 's/On branch //')
  echo "THIS BRANCH: ${THIS_BRANCH}"
  git push --set-upstream origin $THIS_BANCH
}

function current_branch() {
  git status |head -n 1 | sed 's/.*On branch //'
}

#- Clone all remote branches
function gbranches() {
  for x in $(git branch -r |grep -v HEAD |grep -v master | grep origin |awk -F "/" '{print $2}'); do git checkout -b $x origin/$x ; done;
}
########################################################################
# Vagrant
########################################################################
#- Alias for vagrant global status
function vgs() {
    vagrant global-status
}

function vkill() {
    vagrant halt && vagrant destroy -f
}
function vreset() {
    vagrant halt && vagrant destroy -f
    vagrant up
}

#- Halt all running vagrant instances
function vhall() {
    for b in `vagrant global-status |grep running |cut -d' ' -f 1` ; do 
        vagrant halt $b
    done
}

########################################################################
# Apt
########################################################################
#- Print all installed apt packages
function aptall() {
    dpkg -l
}

########################################################################
# Misc
########################################################################
#

#- Slurps STDIN and removes any leading or trailing doublequotes
function noquotes() {
  while read a; do 
    echo "$a"| sed -e 's/^\"//' -e 's/\"$//'
  done
}
function escquotes() {
  while read a; do 
    echo "$a"| sed -e 's/\"/\\\"/g'
  done
}

#- Find disk usage.
function du1() {
  du -khx | egrep -v "\./.+/" | sort -n
}

#-Find disk usage  of old files
function du2() {
  find . -atime +120 -type f -exec du -csh '{}' + | tail -1
}
function rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o

  for (( pos=0 ; pos<strlen ; pos++  )); do
    c=${string:$pos:1}
    case "$c" in
      [-_.~a-zA-Z0-9] ) o="${c}" ;;
      * )               printf -v o '%%%02x' "'$c"
    esac
    encoded+="${o}"
  done
  echo "${encoded}"    # You can either set a return variable (FASTER) 
  REPLY="${encoded}"   #+or echo the result (EASIER)... or both... :p
}
#- recursively search for the smallest/biggest file
#- e.g.
# smallest wav
# if no extension is provied, all files are used.
#-
function smallest() {
    if [ -z "$1" ]; then
        find . -type f -exec stat -f "%z %N" {} \; | sort -n|head -n 1
    else
        find . -iname "*.$1" -type f -exec stat -f "%z %N" {} \; | sort -n|head -n 1
    fi
}
function bigest() {
    if [ -z "$1" ]; then
        find . -type f -exec stat -f "%z %N" {} \; | sort -n|tail -n 1
    else
        find . -iname "*.$1" -type f -exec stat -f "%z %N" {} \; | sort -n|tail -n 1
    fi
}
#- ???
function pgkill() {
    pgrep -f $1 | xargs sudo kill -9
}

#- cd to repos dir
function R() {
    cd ~/repos
}
#- push current dir as named dir (1,2,3,4...) 
#- default is 0
#
#- e.g. 
#- $ push 3
#- ...
#- $ pop 3
#
function dpush() {
    case "$1" in
        9)
            PUSHDIR9=$PWD
            ;;
         
        8)
            PUSHDIR8=$PWD
            ;;
         
        7)
            PUSHDIR7=$PWD
            ;;
         
        6)
            PUSHDIR6=$PWD
            ;;
         
        5)
            PUSHDIR5=$PWD
            ;;
         
        4)
            PUSHDIR4=$PWD
            ;;
         
        3)
            PUSHDIR3=$PWD
            ;;
         
        2)
            PUSHDIR2=$PWD
            ;;
         
        1)
            PUSHDIR1=$PWD
            ;;
         
        *)
            PUSHDIR0=$PWD
            ;;
esac
}

#- pop current dir as named dir (1,2,3,4...) 
#- default is 0
#
#- e.g. 
#- $ pop 3
#-
function dpop() {
    case "$1" in
        9)
            cd $PUSHDIR9
            ;;
         
        8)
            cd $PUSHDIR8
            ;;
         
        7)
            cd $PUSHDIR7
            ;;
         
        6)
            cd $PUSHDIR6
            ;;
         
        5)
            cd $PUSHDIR5
            ;;
         
        4)
            cd $PUSHDIR4
            ;;
         
        3)
            cd $PUSHDIR3
            ;;
         
        2)
            cd $PUSHDIR2
            ;;
         
        1)
            cd $PUSHDIR1
            ;;
         
        *)
            cd $PUSHDIR0
            ;;
esac
}

#- push current dir 
function dshow(){
    echo "0:$PUSHDIR0"
    echo "1:$PUSHDIR1"
    echo "2:$PUSHDIR2"
    echo "3:$PUSHDIR3"
    echo "4:$PUSHDIR4"
    echo "5:$PUSHDIR5"
    echo "6:$PUSHDIR6"
    echo "7:$PUSHDIR7"
    echo "8:$PUSHDIR8"
    echo "9:$PUSHDIR9"
}

#- debug ssl to a given host:port  e.g. ssldebug 47.222.21.83:2222
ssldebug() {
    [[ -z "$1" ]] && { echo "You must enter a host like 127.0.0.1:8443" ; return 1 ; }
    IP="$1"; shift
    openssl s_client -connect $IP -prexit -debug -msg $@
}

#- Backup n directory levels (default 1 level if no arg)   e.g. b 4 = backup 4 dirs
function b() {
    LEVELS=1
    if [ ! -z "$1" ]; then
        LEVELS=$1
    fi
    for i in $(seq 1 $LEVELS); do cd ..; done

}

#- "Push" current directory on a stack to be called up later
function pd() {
    export D=$PWD
}

#- Change back to directory saved with 'pd'
function ppd() {
    cd $D
}

#- Recursively delete directories by name
function rdd() {
    if [ -z "$1" ]; then
        echo "ERROR: You must specify a directory name (e.g. ENV)"
    else
        find . -name $1 -type d -print0|xargs -0 rm -r --
    fi  
}
function unzipurl() {
  set -x
  curl -sSL $1 | tar -C "." -zxf - 2>/dev/null
  set +x
}
#- Recusive ls sorted by size
function sortsize() {
    find . -type f -print0 | xargs -0 ls -la | awk '{print int($5/1000) " KB\t" $9}' | sort -n -r -k1
}

#- Zip up a directory to a .tgz file
function zipdir2() {
    tar -cvzf $1.tgz $1
    echo "unzip with tar -xvzf $1.tgz"
}

#- Zip up a directory to a .zip file
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

#- convenience for curl -i -k -L
function curli() {
    curl -L -i -k "$@"
}
function curls() {
    curl -s "$@"
}

#- Curl a local secure port (shorthand for curl https://127.0.0.1:8443)
function curlslp() {
    if [ -z "$1" ]; then
        echo "port is required, e.g. curlslp 8443  "
    else
        curli https://127.0.0.1:$1
    fi
}

#- Curl a local port (shorthand for curl http://127.0.0.1:8080)
function curllp() {
    if [ -z "$1" ]; then
        echo "port is required, e.g. curllp 80  "
    else
        curli http://127.0.0.1:$1
    fi
}

#- Find out what is using a given local port
function port() {
    if [ -z "$1" ]; then
        echo "A port number is required, i.e. port 8080"
    else
        sudo lsof -i :$1
    fi
}

#- Detailed directory list with optional grep paramter (e.g. lsl pyc)
function lsl() {
    if [ -z "$1" ]; then
        ls -al
    else
        ls -al | grep $1
    fi
}

#- Creates http server in this directory running on given port (or 5000 default)
function httphere() {
    python -m SimpleHTTPServer $1
}

#- Personal version of pkill that is more flexible
function mypkill() {
    [[ -z "$1" ]] && { echo "USAGE: mypkill <search_term>" ; return 1 ; }
    for KILLPID in `ps aux | grep $1 |grep -v grep | awk ' { print $2;}'`; do 
        echo "Killing process $KILLPID ..."
        kill -9 $KILLPID;
    done
}
 
#- kills any process running on the given port (e.g. lsofkill 8080)
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

#- obtain a tinyurl for the given url (from http://wtanaka.com/node/7750)
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

#- grep history for item
function hg() { history |grep $1 ;}

#- grep processes for keyword
function pg() { ps aux |grep $1 | grep -v grep ;}

#- make sure every .sh file in this dir is executable.
function chx() { 
    chmod +x *sh
    chmod 600 *pem
}
function mkcd {
    if [ -z "$1" ]; then
        echo "You must enter a directory to be created."
    else
        mkdir -p $1 
        cd $1
    fi   
}

#- Alias for source ~/.bashrc
function sbrc() {
    source ~/.bashrc
}

#- Alias for cat ~/.bashrc
function cbrc() {
    cat ~/.bashrc
}

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
function activate() { 
    source ENV/bin/activate 
}
function ENV() {
    #FIXME - check for deactivate function and call if it exists
    rm -fr ENV
    python2.7 -m virtualenv ENV 
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
# common            
########################################################################
function run_cmd() {
    echo "CMD: $@"
    eval $@
    if [ $? -eq 0 ]; then
        echo "Success from cmd: $@"
    else
        echo "Failure $? from cmd: $@"
    fi
}

function check_aws_env() {

    #- Check for lowercase versions of these vars.
    #-
    if [ ! -z "$aws_secret_access_key" ]; then
        export AWS_SECRET_ACCESS_KEY=$aws_secret_access_key
    fi
    if [ ! -z "$aws_access_key_id" ]; then 
        export AWS_ACCESS_KEY_ID=$aws_access_key_id
    fi

    #- Bomb out if no creds
    #-
    if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
        echo "Environment variable not set: AWS_SECRET_ACCESS_KEY"
        exit 1
    fi
    if [ -z "$AWS_ACCESS_KEY_ID" ]; then 
        echo "Environment variable not set: AWS_ACCESS_KEY_ID" 
        exit 1
    fi
}

function vptest() {
  D=$PWD
  cd ~/repos/vinyl_pricer_test
  ./gradlew build
  RET=$?
  cd $D
  return $RET
}

########################################################################
# Alias management
########################################################################
# Reload these aliases
#wget -qO- http://dj80hd.github.io/alias.sh > /tmp/x && source /tmp/x  <-- ANOTHER WAY
# 
alias aupdate='curl -s -o /tmp/alias.txt http://dj80hd.github.io/alias.sh ; source /tmp/alias.txt ; rm /tmp/alias.txt'
alias aupdate='eval "$(curl -s http://dj80hd.github.io/alias.sh)"'
alias asource='source ~/repos/dj80hd.github.io/alias.sh'
function apush() {
  D=$PWD
  cd ~/repos/dj80hd.github.io/
  git add .
  git commit -m auto_commit
  git push origin master
  cd $D
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

#########################################################
# My aliases and env vars
#########################################################
alias copy='cp'
alias h='history'
alias ctool='$R/ctool/ctool'

LH=http://127.0.0.1


######### BASH JEMS ###############
# - Ensure oS:
# [[ $(lsb_release -a) =~ "14.04" ]] || { echo "You must run this on ubuntu 14.04" ; exit 1 ; }
#
#- Remove lead and trail double quotes 
# ' | sed -e 's/^\"//' -e 's/\"$//'"

#- Getting part of line
#- get env var names:
# $ env |awk -F "=" '{print $1}'
#
#
# - See if command exists:
# if ! type docker >/dev/null ; then { echo "docker must be installed " ; exit 1 ; } fi
# BEST WAY:
# foo >/dev/null 2>&1
# test "0" = "$?" || error_exit "BAD COMMAND foo" 
#
# - Current dir of script
#DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#
# - Here Doc:
#cat << EOF > /tmp/yourfilehere
#These contents will be written to the file.
#        This line is indented.
#EOF
# - Check for program
# [ -x "$(command -v docker)" ] || { echo "docker must be installed " ; exit 1 ; }
# command -v foo >/dev/null 2>&1 || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }
# - Grep command output (without grep)
# [[ $(/usr/local/bin/monit --version) != *5.5* ]]
#[[ $CORE_UI_TEST == *"$NEEDLE"* ]] && CORE_UI_STATUS="OK"
# - Test if ports open
# exec 6<>/dev/tcp/127.0.0.1/445 || echo "No one is listening!"
# exec 6>&- # close output connection
# exec 6<&- # close input connection
#
#- One line ifs
#- if [ $RANDOM -lt 10000  ]; then echo ONE ; else echo TWO ; fi;
#- [ -n "$HTTPS_PORT" ] && PARAMS="$PARAMS --httpsPort=$HTTPS_PORT"
#
# - One line error exits
# test "0" = "$?" || { echo "ERROR: Copy error [2]" ; exit $?; }
# test -f $FILE|| { echo "ERROR: FILE does not exist: $FILE" ; exit $?; }
# 

## Set magic variables for current file & dir
#__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
#__base="$(basename ${__file} .sh)"
#__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

#- PROMPT
#while true; do
#    read -p "Do you wish to install this program?" yn
#    case $yn in
#        [Yy]* ) make install; break;;
#        [Nn]* ) exit;;
#        * ) echo "Please answer yes or no.";;
#    esac
#done
#arg1="${1:-}"
# - Default values
# ZK_HOST=${ZK_HOST:-dockerhost}
# ZK_PORT=${ZK_PORT:-2181}``
# - Check if linux
# - Command output contains
# [[ $(/usr/local/bin/monit --version) =~ "5.5" ]] || echo "NOT OK"#
# 
# - Script Parms:
#while [[ $# > 1 ]]; do
#    key="$1"
#    case $key in
#        -a|--action)
#        ACTION="$2"
#        shift # past argument
#        ;;
#        -d|--directory)
#        AUTOTEST_DIR="$2"
#        shift # past argument
#        ;;
#        --default)
#        DEFAULT=YES
#        ;;
#        *)
#            # unknown option
#        ;;
#    esac
#    shift # past argument or value
#done
#
# Top of every bash script:
##!/usr/bin/env bash
#[ ! -z "${TRACE:-}"  ] && set -o xtrace  # trace what gets executed
#set -o errexit # exit when a command fails.
#__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # set current directory
