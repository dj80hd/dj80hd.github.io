
#docker functions
function d() { sudo docker "$@" ;}
function de() { sudo docker exec -t "$@" ;}
function di() { sudo docker exec -i -t $1 bash ;}
function dr() { sudo docker rm $1 ;}
function dpa() { 
    if [ -z "$1" ]; then
        sudo docker ps -a 
    else
        sudo docker ps -a |grep $1
    fi
}
function dp() { sudo docker ps ;}
function dl() { sudo docker logs $1 ;}
function ds() {
    for p in `sudo docker ps|grep $1 |cut -d' ' -f 1` ; do 
        udo docker stop $p 
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
