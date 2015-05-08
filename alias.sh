
#docker functions
function d() { sudo docker "$@" ;}
function de() { sudo docker exec -t "$@" ;}
function di() { sudo docker exec -i -t $1 bash ;}
function dr() { sudo docker rm $1 ;}

#Show all docker process, optional input match string
function dpa() { 
    if [ -z "$1" ]; then
        sudo docker ps -a 
    else
        sudo docker ps -a |grep $1
    fi
}

function dp() { sudo docker ps ;}
function dl() { sudo docker logs $1 ;}

#Stop any containers matching input
function dps() {
    for p in `sudo docker ps|grep $1 |cut -d' ' -f 1` ; do 
        sudo docker stop $p 
    done
}

#Stop and remove any containers matching input
function dprm() {
    for p in `sudo docker ps -a|grep $1 |cut -d' ' -f 1` ; do 
        sudo docker stop $p 
        sudo docker rm $p 
    done
}

function dip() { 
    docker inspect --format '{{ .NetworkSettings.IPAddress }}' $1 
}



#my aliases
alias copy='cp'
alias h='history'

#my vars
LH=http://127.0.0.1
R=~/repos
