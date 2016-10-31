#!/bin/bash -
#===============================================================================
#
#          FILE: docker_run.sh
#
#         USAGE: ./docker_run.sh ncs
#
#   DESCRIPTION: Run Asterix Docker containers
#
#       OPTIONS:    
#                   ncs: number of nc. 
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Jianfeng Jia (), jianfeng.jia@gmail.com
#  ORGANIZATION: ics.uci.edu
#       CREATED: 10/27/2015 11:06:01 AM PDT
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

ncs=$1 # number of ncs
mnt=$2 # local disk path to mount for db data

docName=dbstore

echo "build the new container"
docker run -d --name=cc \
   -p 19000:19000 -p 19001:19001 -p 19002:19002 -p 19006:19006 -p 8888:8888 \
    jianfeng/asterixdb cc $ncs

ccip=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cc `


sleep 2s

for ((n=1; $n <= $ncs; n=$n+1 ))
do
    port=$((10000+n))
    docker run -d -v $mnt:/db -p $port:$port  \
      --name "nc${n}" \
        jianfeng/asterixdb nc ${n} $ccip $ncs
done


