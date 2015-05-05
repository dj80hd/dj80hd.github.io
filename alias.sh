
#docker functions
function d() { sudo docker "$@" ;}
function dpa() { sudo docker ps -a ;}
function dp() { sudo docker ps ;}

function dip() { 
    docker inspect --format '{{ .NetworkSettings.IPAddress }}' $1 
}



#my aliases
alias copy='cp'
alias h='history'

#my vars
LH=http://127.0.0.1
