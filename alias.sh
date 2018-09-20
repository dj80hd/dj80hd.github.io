########################################################################
#  80HD Time Saving Aliases
#  Tip: To see all active functions and aliases use typeset -f and alias
########################################################################
# Tools i should learn:
# strace, tcpdump, grep, tshark, ss, socat lsof pgrep 
#
alias f1="awk '{print \$1}'"
alias f2="awk '{print \$2}'"
alias f3="awk '{print \$3}'"
############################# GOLANG ################################
alias gf="go fmt ./..."
############################# K8S ################################
export KS="--namespace=kube-system"
export KC="--namespace=core"
export KN="--namespace=spinnaker"

alias getdig='curl -L https://github.com/sequenceiq/docker-alpine-dig/releases/download/v9.10.2/dig.tgz|tar -xzv -C /usr/local/bin/'
function kdocs() {
  k8s_website_dir=$R/website

  if [[ ! -d $k8s_website_dir ]]; then
    cd $R
    git clone git@github.com:kubernetes/website.git
  else
    echo "exists:" $k8s_website_dir
  fi
  cd $k8s_website_dir


  docker build .  --tag kubernetes-hugo --build-arg HUGO_VERSION=0.40.3
  docker run --rm -it -v $(PWD):/src kubernetes-hugo:latest hugo

  cd $k8s_website_dir/public

  python -m SimpleHTTPServer &

  sleep 2 && open http://localhost:8000
}

function kctx() {
  kubectx $1
}

function kkill() {
  kubectl delete service $@ || true
  kubectl delete deployment $@ || true
  kubectl delete ingress $@ || true
  kubectl delete serviceaccount $@ || true
  kubectl delete rollbinding $@ || true
}

function kb() {
  kustomize build ${1:-.}
}
# run a bash shell in a given pod substring
function kbash() {
  local substring=$1; shift
  local pod=$(kubectl get pods $@ | awk '{print $1}' | grep $substring | head -n 1)
  kubectl exec -it ${pod} -- /bin/bash
}

# remove all CrashLoopBackOff
function kclean() { 
  if [[ -z "$1" ]]; then
    kubectl delete pod $(kubectl get pods | awk '$3 == "CrashLoopBackOff" {print $1}') 
    kubectl delete pod $(kubectl get pods | awk '$3 == "Unknown" {print $1}') 
  else
    kubectl get svc -n $1 --no-headers | awk '{print $1}' | xargs -n 1 kubectl delete svc -n $1
    kubectl get deployment -n $1 --no-headers | awk '{print $1}' | xargs -n 1 kubectl delete deployment -n $1
  fi
}

function kd() {
  kubectl describe $@ 
}

# Get vault init container logs
kvault() {
  k get pods ${@:2}  | grep $1 | grep Init | awk '{print $1}' | xargs kubectl logs -c vault-pod-init ${@:2}
}

function ka() {
  kubectl apply -f $@
}

function kg() {
  kubectl get $@ 
}

function kgy() {
  kubectl get $@ -o yaml
}

function ks() {
  kubectl get pods $@
}

function ksl() {
  kubectl get pods --show-labels $@
}


function ksn() {
  kubectl get pods -n core $@
}

function kss() {
  kubectl get pods --all-namespaces $@
}

function getk8s() {
  export KUBERNETES_PROVIDER=vagrant
  export NUM_MINIONS=2
  curl -sS https://get.k8s.io |bash
}
function kpods() {
  kubectl get pods --all-namespaces | grep "$1" | grep "$2"
}
function kpods2() {
kubectl get pods --all-namespaces -o=jsonpath='{range .items[*]}{"\n"}{.metadata.namespace}{","}{.metadata.name}{","}{.spec.containers[*].image}{","}{.status.hostIP}{","}{.status.phase}{","}{.status.containerStatuses[*].ready}{","}{.status.containerStatuses[*].restartCount}{","}{.status.containerStatuses[*].state.running.startedAt}{","}{end}' | sed '/^$/d' | sed 's/ /_/g'
}

kgpod() {
  kubectl get pods --all-namespaces | grep "$1" | grep Running | awk '{print $2, "-n", $1}' | xargs kubectl get pod -o json
}

function _kpod() {
  local substring=$1
  shift
  if [ -n $substring ]; then 
  kubectl get pods --all-namespaces $@ | grep $substring | awk '{print $2}' | head -n 1
  else
  echo
  fi
}

# get last termination message of a pod substring
function kterm() {
  local substring=$1; shift
  local pod=$(_kpod $substring $@)
  shift
  [[ -n $pod ]] && kubectl get pod ${pod} -o go-template="{{range .status.containerStatuses}}{{.lastState.terminated.message}}{{end}}" $@
}

function certinfo() {
cfssl certinfo -domain $1
}
function klog() {
  local substring=$1
  shift
  local pod=$(_kpod $substring $@)
  [[ -n $pod ]] && kubectl logs ${pod} $@
}
function kpod() {
  local pod=$(_kpod $1)
  shift
  kubectl describe pod ${pod} $@
}

function kdel() {
  local pod=$(_kpod $1)
  shift
  kubectl delete pod ${pod}
}

function krm() {
  kubectl delete service $@
  kubectl delete deployment $@
  kubectl delete ingress $@
  kubectl delete serviceaccount $@
}

function knode() {
  kubectl get nodes --no-headers | grep Ready | head -n 1 | awk '{print $1}'
}


function kexe() {
  kubectl exec -it $(_kpod $1) bash
}

function kbump() {
  local f=$1
  kubectl delete -f ${f}
  kubectl create -f ${f}
}
function ksvc() {
  kubectl get svc | grep "$1"
}
function kweave() {


kubectl port-forward -n weave "$(kubectl get -n weave pod --selector=weave-scope-component=app -o jsonpath='{.items..metadata.name}')" 4040 && open http:/localhost:4040
}
#
# To NOT have sudo when using docker do this before sourcing this file:
# export DOCKER_CMD=docker
#
if [ -z "$DOCKER_CMD" ]; then
    DOCKER_CMD="sudo docker "
fi

function cf() {
  tr -s ' ' | cut -d ' ' -f $1
}

# f X Y : get the Xth whitespace separated field from the Yth line
function f() {
  local line=${2:-1}
  awk "{print \$${1}}" | sed "${line}q;d"
}
##################### URLS ##################
function url_ok {
  curl -siLk $1  2>&1 > /dev/null
  return $?
}
function httpcode() {
  curl -sL -w "%{http_code}\\n" $1 -o /dev/null
}
function url_exists() {
  local respcode=$(curl -ikLs --write-out "%{http_code}\n" --output /dev/null $1)
  return `expr $respcode - 200`
}

function rr() {
  find . -type f -name '*.yaml' -exec sed -i '' s/$1/$2/ {} +
}

function rwhitespace() {
#find . -type f -exec grep -Il "" {} \; 
find . -type f -print0 | xargs -0 perl -pi -e 's/ +$//'
}

#TODO
# - something to save last command to file for reference
# - alternative to ping that returns 0 if ping works (e.g. alive www.foo.com)

########################################################################
# MAC ONLY
########################################################################
function term() {
open -a Terminal "`pwd`"
}
########################################################################
# AWS
########################################################################
function awslogout() {
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_ACCESS_KEY_ID
    unset aws_secret_access_key
    unset aws_access_key_id
}
function us-east-1() {
  export AWS_REGION=us-east-1
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
function mesosinfo() {
  dcos task log --follow $1
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
function ddump() {
docker history --no-trunc "$1" | \
sed -n -e 's,.*/bin/sh -c #(nop) \(MAINTAINER .*[^ ]\) *0 B,\1,p' | \
head -1
docker inspect --format='{{range $e := .Config.Env}}
ENV {{$e}}
{{end}}{{range $e,$v := .Config.ExposedPorts}}
EXPOSE {{$e}}
{{end}}{{range $e,$v := .Config.Volumes}}
VOLUME {{$e}}
{{end}}{{with .Config.User}}USER {{.}}{{end}}
{{with .Config.WorkingDir}}WORKDIR {{.}}{{end}}
{{with .Config.Entrypoint}}ENTRYPOINT {{json .}}{{end}}
{{with .Config.Cmd}}CMD {{json .}}{{end}}
{{with .Config.OnBuild}}ONBUILD {{json .}}{{end}}' "$1"
}
#- cleans up space
function dsize() {
  if [ -z "$1" ] ; then
    echo "You must specify a container name"
    return 
  fi
  local id=$(docker inspect -f "{{.Id}}" $1)
  du -d 2 -h /var/lib/docker/devicemapper | grep $id
}
function dcu() {
  docker-compose up
}
function dcd() {
  docker-compose down
}
function indocker() {
  IMAGE_NAME=docker_tmp_deleteme

  if [ ! -z "$1" ] ; then
    IMAGE_NAME=$1
  else
    if [ ! -e Dockerfile ] ; then
      echo "There is no Dockerfile in this directory."
      return
    fi
    $DOCKER_CMD build -t ${IMAGE_NAME} .
  fi
  $DOCKER_CMD run -v $PWD:/app --workdir /app --rm -it ${IMAGE_NAME} sh
}

function dclean() {
  $DOCKER_CMD rm $(docker ps -q -f 'status=exited')
  $DOCKER_CMD rmi $(docker images -q -f "dangling=true")
  $DOCKER_CMD images -aq | xargs -n 10 docker rmi
}
function dstopall() {
  $DOCKER_CMD stop $($DOCKER_CMD ps -a -q)
}

function dall() {
    $DOCKER_CMD images
    $DOCKER_CMD ps -a
}

function drm() {
  $DOCKER_CMD stop $($DOCKER_CMD ps -a -q)
  $DOCKER_CMD rm -f $($DOCKER_CMD ps -a -q)
}
function dps() {
 $DOCKER_CMD ps
 }
#- remove all images
function drma() {
    drm
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
function dstop() {
    if [ -z "$1" ]; then
        for p in `$DOCKER_CMD ps|grep -v IMAGE | cut -d' ' -f 1` ; do 
            echo "Stopping $p"
            $DOCKER_CMD stop $p 
        done
    else
        for p in `$DOCKER_CMD ps|grep $1 |cut -d' ' -f 1` ; do 
            echo "Stopping $p"
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

function dbandp() {
  if [ -z "$1" ]; then
    echo "you must specify a docker image"
  else
    $DOCKER_CMD build -t $1 .
    $DOCKER_CMD push $1
  fi
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
# GIT Stuff
########################################################################
function glog() {
  git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
}
function gpullall() {
  for b in `git branch -r | grep -v -- '->'`; do git branch --track ${b##origin/} $b; done
  git fetch --all
  git pull --all
}
function gpushall() {
  git push --all
  git push --tags
}

#Tag and push it
function gtag() {
  if [ -z "$1" ]; then
    echo "USAGE: gtag tag_name"
  else
    git tag $1
    git push origin --tags
  fi
}

function gmaster() {
  git checkout master
  [[ "0" != "$?" ]] && { return ; }
  git pull origin master
}

#- Put last commit on new branch
function lastcommitnewbranch() {
  git branch $1 jimi
  if [ -z "$1" ]; then
    echo "USAGE: lastcommitnewbranch newbranchname"
  else
    git branch $1
    git reset --hard HEAD~1
    git checkout $1
  fi
}

#- force push a file to branch
function gafp() {
  local BRANCH=$2

  if [ -z "${BRANCH}" ] ; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
  fi

  if [ "$1" = "" ] || [ "${BRANCH}" = "" ] ; then
    echo "You must specify a filename and a branch."
  else
    git add $1
    git commit --amend --no-edit
    git push origin ${BRANCH} --force-with-lease
  fi
}

#- Quick checkin of Jenkninsfile for Pipeline:
function gjenkins() {
  git add Jenkinsfile && \
  git commit --amend --no-edit && \
  git push origin $(git rev-parse --abbrev-ref HEAD) --force-with-lease
}

function jankins() {
  git add Jenkinsfile && git commit -m Jankins && git push origin master      
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

function gcm() {
  local comment="${@:-more}"
  git commit -m "${comment}"
}

function gmore() {
  git add .
  local comment="${@:-more}"
  git commit -m "${comment}"
  git push origin $(git rev-parse --abbrev-ref HEAD)
}

function realmaster() {
  git checkout master
  git fetch origin
  git reset --hard origin/master
}
function gdiff2() {
    git diff HEAD^ HEAD
}
function grebase() {
    git fetch
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
function glbranches() {
  git for-each-ref --format='%(authorname) %09 %(refname)' | sort -k3n -k4n
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
    pwd && git status
}

#- merge a branch
function gmerge() {
  if [ -z "$1" ]; then
    echo "You must specify a branch: $(git branch)"
  else
    git merge -m "$1" $1
  fi
}
function oldbranches() {
  for b in $(git branch -r | sed 's/origin\///') ; do
    git checkout $b > /dev/null 2>&1
    if [ -n "$(git log -1 --before='1 week ago' -s $b)" ]; then
      echo $b #git branch -D $b
    fi
  done
}
function goldbranches() {
  for x in $(git branch -r | grep -v 'origin/HEAD' | awk '{print $1}' ); do git show --pretty=format:"%ai $x %h %an %s" --no-patch $x; echo; done | sort
}
#- Reset last commit
function grlc() {
  git reset HEAD^
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
    git config --global core.editor /usr/local/bin/vim
    git config --global user.email "jim.werwath@uptake.com"
    git config --global user.name "Jimi Werwath"           
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config branch.master.rebase true
    git config --global core.editor vi
    git config --global core.excludesfile ~/.gitignore_global
    touch ~/.gitignore_global
    echo '*~' >> ~/.gitignore_global
    echo '.*~' >> ~/.gitignore_global
}

#- Squash last n local commits:
function gsquash() {
    if [ -z "$1" ]; then
        echo "you must specify the number of commits to squash:"
        echo "e.g. $0 3 commit message here"
        return 1
    fi
    if [ -z "$2" ]; then
        echo "you must specify a commit message:"
        echo "e.g. $0 3 commit message here"
        return 1
    fi
    git reset --soft HEAD~$1
    local msg="${@:2}"
    git commit -m "${msg}"
}
function gmakeremote() {
  git fetch orgin
  git reset --hard origin/$(git rev-parse --abbrev-ref HEAD)
}
function gapc() {
  FILES=.
  COMMENT=more
  if [ ! -z "$1" ]; then
    FILES=$1
  fi
  git add ${FILES}
  if [ ! -z "$2" ]; then
    COMMENT=$@
  fi
  git commit -m "${COMMENT}"             
  git push origin $(git rev-parse --abbrev-ref HEAD) 
}
# Git force push commit
function gfpc() {
  if [ ! -z "$1" ]; then
    git add $1
    git commit --amend --no-edit
  fi
  git push origin $(git rev-parse --abbrev-ref HEAD) --force-with-lease
}

function gplc() {
  git pull origin $(git rev-parse --abbrev-ref HEAD)
}
function gpc() {
  git push origin $(git rev-parse --abbrev-ref HEAD)
}

function cbranch() {
  git rev-parse --abbrev-ref HEAD
}

# delete remote branch
function gdrbranch() {
  if [ -z "$1" ]; then
    echo "you must specify a branch match string"
    echo "DANGER: DELETES MANY REMOTE BRANCHES BE CAREFUL!"
  else
    git branch -r | cut -c 10- |grep $1 | xargs git push origin --delete
  fi
}
#- Delete a tag
function gdtag() {
    if [ -z "$1" ]; then
        echo "you must specify a tag name"
        return 1
    fi
   git push --delete origin $1
   git tag -d $1
}
#- Delete a branch locally and remotely
function gdbranch() {
    if [ -z "$1" ]; then
        echo "you must specify a branch name"
        return 1
    fi
    git push origin --delete $1
    git branch -D $1
}
export -f gdbranch 

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

function gco() {
  if [ -z "$1" ] ; then 
    git commit -m $(current_branch)
  else 
    git commit -m "$@"
  fi 
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

function vkall() {
  for i in `vagrant global-status | grep virtualbox | awk '{ print $1 }'` ; do vagrant destroy -f $i ; done
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
# Get Nth field of last command
function lc() {
  local re='^[0-9]+$'
  if ! [[ $1 =~ $re ]] ; then
    echo "Usage: lc <number>"
    return 1
  fi
  # This does not work :(
  # echo $(!!) | xargs | tr -s ' ' | cut -d ' ' -f $1

  # Add one because history command's first field is a number
  n=$(( $1 + 1 ))
  arg=$(history | tail -n 2 | head -n 1 | tr -s ' ' | xargs | cut -d ' ' -f $n)

  # In case the arg had something like $GOPATH in it.
  eval "echo ${arg}" 
}

function c1() {
  history | tail -n 2 | head -n 1 | awk '{print $2}'
}

function c2() {
  history | tail -n 2 | head -n 1 | awk '{print $3}'
}

function c3() {
  history | tail -n 2 | head -n 1 | awk '{print $4}'
}

function c4() {
  history | tail -n 2 | head -n 1 | awk '{print $5}'
}

function lastcmd() {
  history | tail -n 2 |head -n 1 | awk '{print $2, $3, $4, $5, $6, $7, $8, $9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20}' | pbcopy
}
function clr() {
  clear
  reset
}
function myip() {
  dig +short myip.opendns.com @resolver1.opendns.com
}
function tmp() {
  local f="${1:-/tmp/x}"
  rm $f
  vi $f
}
#- Remove any tailing whitespace in a file
function notrailingspace() {
  ${1:?"Need to specify ext e.g. java"}
  find . -name "*.$1" -type f -print0 | xargs -0 sed -i 's/[[:space:]]*$//'
}

function trim() {
  while read a; do 
    echo "$a"| sed 's/^[[:blank:]]*$//' | sed 's/^[[:blank:]]*//'
  done
}
#- Slurps STDIN and removes any leading or trailing doublequotes
function noquotes() {
  while read a; do 
    echo "$a"| sed -e 's/^\"//' -e 's/\"$//'
  done
}

# Remove trailing and leading whitespace
function nowhitespace() {
  while read a; do 
    echo "$a"| awk '{$1=$1};1'
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

function dudir() {
  du -sh .[!.]* * | sort -r | head -n10
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
        echo "dir is required, e.g. zipdir foo"
    else
        zip -e --exclude '*.git*' -r $1.zip $1  
    fi
}

#- convenience for curl -i -k -L
function curli() {
    curl -siLk "$@"
}
function curls() {
    curl -iLks "$@"
}
function pcurl() {
    port=${1:-80}
    path=${2:-/}
    host=${3:-127.0.0.1}
    if [ -z "$1" ]; then
      echo "Usage pcurl <port> <path> <host>"
    else
      url=$host:$port/$path
      echo $url
      curl -i -k -L $url
    fi

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
    if [[ -z "$1" ]]; then
      chmod +x *sh 2>&1 >/dev/null || true
      chmod 600 *pem 2>&1 >/dev/null || true
      chmod 600 x 2>&1 >/dev/null || true
    else
      chmod +x $1
    fi
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
    source ~/.bash_profile
}

#- Alias for cat ~/.bashrc
function cbrc() {
    cat ~/.bashrc
    cat ~/.bash_profile
}

#- find and grep                                                  
#- e.g. fg selenium py
function fg() { 
    if [ -z "$2" ]; then
        grep -r $1 . 
    else
        grep --include="*$2" -r $1 .
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
    python3 -m virtualenv ENV 
    source ENV/bin/activate
    pip3 install -r requirements.txt
    if [ -f test-requirements.txt ]; then
        pip3 install -r test-requirements.txt
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
    fi
    if [ -z "$AWS_ACCESS_KEY_ID" ]; then 
        echo "Environment variable not set: AWS_ACCESS_KEY_ID" 
    fi
}

function vptest() {
  D=$PWD
  cd ~/repos/vinyl_pricer_test
  ./gradlew build --rerun-tasks
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
alias aupdate='eval "$(curl -s http://dj80hd.github.io/alias.sh)"'
alias asource='source ~/.bash_profile && source ~/repos/dj80hd.github.io/alias.sh && source ~/repos/p/uptake.sh'
alias avi='vi ~/repos/dj80hd.github.io/alias.sh'

yaml2json () {
        ruby -r yaml -r json -e 'puts YAML.load($stdin.read).to_json'
}

function apush() {
  D=$PWD
  cd ~/repos/dj80hd.github.io/
  git add .
  git commit -m auto_commit
  git push origin master
  cd $D
}

function httpcode() {
  if [ -z "$1" ]; then
    echo "url required"
  else
    curl -is $1|head -n 1|cut -d' ' -f2
  fi
}

function g() {
  ./gradlew $@
}

function vix() {
  chmod +x /tmp/x
  vi /tmp/x
}

function x() {
  chmod +x /tmp/x
  /tmp/x $@
}
alias cx="chmod +x"

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
alias t=terraform
alias ctool='$R/ctool/ctool'

LH=http://127.0.0.1




######### BASH JEMS ###############BASHHOLE
# -- backups
# rm repos.zip || true
# zip --encrypt -r repos.zip go/src/github.com/dj80hd go/src/git.uptake.com repos -x *.git*
# unzip -p password repos.zip
#
# - checking against regex:
# if (echo foo-bar2 |egrep -q '\w+-\w' ); then...
#
# - recursive string replacement
# find . -type f -name "*.yml" -exec gsed -i 's/ccccc/c/g' {} \;
# $ find . -type f -name "*.yml" -print0 | xargs -0 sed -i '' -e 's/  namespace: default/  namespace: core/g'
#
# - recursive string replacement
# find . -type f -print0 | xargs sed -i '' s/foo/bar/ DOES NOT WORK 

# - recursive line deletion
# find . -type f -print0 | xargs sed -i '' /nodePort/d
#
# - init a hash
# declare -A regions=(
#   [sa-east-1]="South America (Sao Paulo)"
#   [us-east-1]="US East (N. Virginia)"
# )
 
# - read from either STDIN or param
# set -- "${1:-$(</dev/stdin)}" "${@:2}"
 
# - read a char
#  echo -n "Press any key to continue..."
#  read -rsn 1
#  echo ''
#
# - Variables in single quotes:
# foo=bar ; cmd="echo '$foo' \"baz\"" ;  eval $cmd
# key=memory ; cmd="echo '{\"$key\": 669 }' | jq ." ; eval $cmd
#
# - Addition
# x=1 ; y=$(($x+1)) ;  echo $y
#
# - Default Assign
# GIGS=${1:-44}
# WITH_PERL=${WITH_PERL:-no}
#: ${AWS_SSH_KEY:?"Need to set AWS_SSH_KEY"}
#
# - stderr/out redirection
#   >&2 (same as 1>&2) = redirect stdout to stderr
#  
# - Checks / conditionals
#   [[ -n "${FOO}:-}" ]]            # if FOO non empty
#   [[ -z "${FOO}:-}" ]]            # if FOO empty
#   if [[ -z "$access" || -z "$secret" ]]; then ...
#   if [[ -z "${1:-}" ]] || [[ -z ${2:-} ]] || [[ -z ${3:-} ]]; then
#     echo "Usage: $(basename $0) ISLAND CLUSTER MANIFEST"
#     exit 1
#
# - GNU sed
# if [[ "$(uname)" = "Darwin" ]] && [[ -z "$(which gsed)" ]]; then
#   echo "This script requires GNU sed - please 'brew install gnu-sed' and try again"
#   exit 1
# fi
 
# - Prompt User:
#
# PS3='Select the tag you wish to rollback to: '
# select opt in "${OPTS_ARRAY[@]}" "Quit"; do
#   case $REPLOY in 
#   
# - Parse strings to arrays:
# a=($(echo "A B C" | tr ' ' '\n'))
# for i in "${a[@]}"; do echo $i ; done 
# 
# - Variable range
#   for (( i=1; i<=$DEPLOY_TIMEOUT_MINUTES; i++ )) ; do
#
# - Ensure oS:
# [[ $(lsb_release -a) =~ "14.04" ]] || { echo "You must run this on ubuntu 14.04" ; exit 1 ; }
#
#- Remove lead and trail double quotes 
# ' | sed -e 's/^\"//' -e 's/\"$//'"

# Convert iso3339 time to seconds:
# $ gdate -d"2017-09-20T19:31:29.782Z" +%s
#
# - See if command exists:
#if [[ -z $(which kustomize) ]]; then
#  echo 'Kustomize is required to use this script.'
#  echo 'https://github.com/kubernetes-sigs/kustomize/blob/master/INSTALL.md'
#  exit 1
# if ! type docker >/dev/null ; then { echo "docker must be installed " ; exit 1 ; } fi
# BEST WAY:
# foo >/dev/null 2>&1
# test "0" = "$?" || error_exit "BAD COMMAND foo" 
# [ -x "$(command -v docker)" ] || { echo "docker must be installed " ; exit 1 ; }
# command -v foo >/dev/null 2>&1 || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }
#
# - Current dir of script
#THISDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#
# - Here Doc:
#cat << EOF > /tmp/yourfilehere
#These contents will be written to the file.
#        This line is indented.
#EOF
# - Grep command output (without grep)
# [[ $(/usr/local/bin/monit --version) != *5.5* ]]
#[[ $CORE_UI_TEST == *"$NEEDLE"* ]] && CORE_UI_STATUS="OK"
# - Test if ports open
# exec 6<>/dev/tcp/127.0.0.1/445 || echo "No one is listening!"
# exec 6>&- # close output connection
# exec 6<&- # close input connection
#
#- One line ifs
#  if [ $RANDOM -lt 10000  ]; then echo ONE ; else echo TWO ; fi;
#  [ -n "$HTTPS_PORT" ] && PARAMS="$PARAMS --httpsPort=$HTTPS_PORT"
#
# - One line error exits
# test "0" = "$?" || { echo "ERROR: Copy error [2]" ; exit $?; }
# test -f $FILE|| { echo "ERROR: FILE does not exist: $FILE" ; exit $?; }
#[ ! -z "${BITBUCKET_PASSWORD}" ]  ||  { echo "no password!" ; exit 1;}
#[ ! -z "${BITBUCKET_USERNAME}" ]  ||  { echo "no username!" ; exit 1;}
# 
#- PROMPT
#while true; do
#    read -p "Do you wish to install this program?" yn
#    case $yn in
#        [Yy]* ) make install; break;;
#        [Nn]* ) exit;;
#        * ) echo "Please answer yes or no.";;
#    esac
#done
#
# - Slice $@
#
# - Colored outpu
#  echo_red() { tput setaf 1; echo $@; tput sgr0; }
#  echo_green() { tput setaf 2; echo $@; tput sgr0; }
#  echo_orange() { tput setaf 3; echo $@; tput sgr0; }

# - start_with?A
#   [[ $a == z* ]] 
#
#
#arg1="${1:-}"
# - Default values
# ZK_HOST=${ZK_HOST:-dockerhost}
# ZK_PORT=${ZK_PORT:-2181}``
# - Check if linux
# - Command output contains
# [[ $(/usr/local/bin/monit --version) =~ "5.5" ]] || echo "NOT OK"#
# 
# - Script Parms:
#while [[ $# -gt 0 ]]; do
#    key="$1"
#    case $key in
#        -f|--filename)
#        FILENAME="$2"
#        TMPDIR="/tmp/manicop-deploy"
#        rm -fr ${TMPDIR} && mkdir -p ${TMPDIR}
#        shift # past value
#        ;;
#        -k|--kubeconfigy)
#        KUBECONFIG="$2"
#        shift # past value
#        ;;
#        -d|--dryrun)
#        DRYRUN=YES
#        ;;
#        *)
#        usage
#        ;;
#    esac
#    shift # past argument or value
#done
#
# Top of every bash script:
##!/usr/bin/env bash
#set -eou pipefail
#[ ! -z "${TRACE:-}"  ] && set -o xtrace  # trace what gets executed
#__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # set current directory
#__PROGNAME="$(basename $0)"
#__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#__ROOT="$(cd "$(dirname "${__DIR}")" && pwd)"
#
# If $needle contains =
#    if echo $needle | grep -F = &>/dev/null
#
# e.g. color command --args
color()(set -o pipefail;"$@" 2>&1>&3|sed $'s,.*,\e[31m&\e[m,'>&2)3>&1
