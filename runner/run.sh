#!/bin/bash -
#===============================================================================
#
#          FILE: docker_run.sh
#
#         USAGE: ./docker_run.sh tag ncs
#
#   DESCRIPTION: Run Asterix Docker containers
#
#       OPTIONS:    tag: master or specific versions, default is master
#                   ncs: number of nc. default is 2
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Jianfeng Jia (), jianfeng.jia@gmail.com
#  ORGANIZATION: ics.uci.edu
#       CREATED: 10/27/2015 11:06:01 AM PDT
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

tag="$1"
ncs=$2

echo "build the new container"
docker run -d --name=cc-${tag} \
   -p 19000:19000 -p 19001:19001 -p 19002:19002 \
    jianfeng/asterix-cc:${tag} $ncs

ccip=`docker inspect cc-${tag} | grep IPAddress | grep -o '[0-9.]*' | head -1`

sleep 2s
work_dir="$HOME/.asterix"
mkdir -p $work_dir

#myhost=`hostname -I | cut -d' ' -f1`
for ((n=1; $n <= $ncs; n=$n+1 ))
do
    ncdir=$work_dir/nc${n}
    port=$((10000+n))
    mkdir -p $ncdir
    docker run -v $HOME/data:/data -v /home/xiz:/xiz -v $ncdir:/nc${n} -p $port:$port -d \
      --name "nc-${tag}-${n}" \
        jianfeng/asterix-nc:${tag} ${n} $ccip ${ncs}
done

./log.sh $tag $ncs


