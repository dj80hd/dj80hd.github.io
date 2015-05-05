
#docker functions
function d() { sudo docker "$@" ;}
function de() { sudo docker exec -t "$@" ;}
function di() { sudo docker exec -i -t $1 bash ;}
function dr() { sudo docker rm $1 ;}
function dpa() { sudo docker ps -a ;}
function dp() { sudo docker ps ;}
function dl() { sudo docker logs $1 ;}

function dip() { 
    docker inspect --format '{{ .NetworkSettings.IPAddress }}' $1 
}



#my aliases
alias copy='cp'
alias h='history'

#my vars
LH=http://127.0.0.1
