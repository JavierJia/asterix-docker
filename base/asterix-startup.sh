#!/bin/bash
# Intended to be the ENTRYPOINT of a Docker AsterixDB cluster image

# First argument is either "nc" or "cc", and comes from the Dockerfile itself
type=$1

# Second argument is numeric, either the number of NCs (for "cc") or the
# number of the NC to start (for "nc"). It is required.
arg=$2

# Third argument is the IP of the CC. Only required for NCs.
ccip=$3

# Total number of ncs, Only required for NCs.
ncend=$4

# Fourth argument is the publicly-routable IP address. Only required for NCs.
pubip=`ifconfig eth0 2>/dev/null | awk '/inet addr:/ {print $2}'|sed 's/addr://'`

# Check arguments.
case "$type" in
    cc)
        if [ -z "$arg" ]
        then
            echo Please provide the number of NCs as an argument.
            exit 10
        fi
        ;;
    nc)
        if [ -z "$arg" -o -z "$ccip" -o -z "$pubip" ]
        then
            echo "Usage: asterix-nc <index> <cc ip> <public ip>"
            echo "  <index> - the number of this NC (1, 2, ..)"
            echo "  <cc ip> - the IP address to contact the CC"
            echo "  <public ip> - the publicly-routable IP address where"
            echo "  <total ncs> - total number of NCs" 
            exit 10
        fi
        ;;
esac

# Configuration file to be constructed
CONFFILE=asterix-configuration.xml


add_nc_to_conf() {
    ncnum=$1
    ncid="nc$ncnum"

    # NCs store all artifacts in subdirectories of /nc
    cat <<EOF >> ${CONFFILE}
  <store>
    <ncId>${ncid}</ncId>
    <storeDirs>storage</storeDirs>
  </store>
  <coredump>
    <ncId>${ncid}</ncId>
    <coredumpPath>/nc/coredump</coredumpPath>
  </coredump>
  <transactionLogDir>
    <ncId>${ncid}</ncId>
    <txnLogDirPath>/nc/txnLogs</txnLogDirPath>
  </transactionLogDir>

EOF
}

# Write out asterix-configuration.xml header
# nc1 is always the metadata node
cat <<EOF > ${CONFFILE}
<asterixConfiguration xmlns="asterixconf">
  <metadataNode>nc1</metadataNode>
EOF

# Write out the appropriate set of NC entries
case "$type" in
   cc)
       ncend=$arg
       ;;
   nc)
       ;;
esac

for ((i=1; i<=$ncend; i++))
do
    add_nc_to_conf $i
done

# Add in the (currently fixed) properties
cat /asterix/asterix-properties.xml >> ${CONFFILE}

# And close it out
cat <<EOF >> ${CONFFILE}
</asterixConfiguration>
EOF

# Last but not least, execute the appropriate command
case "$type" in
    cc)
        exec /asterix/bin/asterixcc \
            -cluster-net-ip-address 127.0.0.1 -cluster-net-port 19000 \
            -client-net-ip-address 127.0.0.1
        ;;
    nc)
        export JAVA_OPTS="-Djava.rmi.server.hostname=${pubip}"
        exec /asterix/bin/asterixnc \
            -node-id nc${arg} -iodevices /nc/iodevice \
            -cc-host ${ccip} -cc-port 19000 \
            -cluster-net-ip-address 0.0.0.0 \
            -cluster-net-public-ip-address ${pubip} \
            -cluster-net-port 502${arg} -cluster-net-public-port 502${arg} \
            -data-ip-address 0.0.0.0 -data-public-ip-address ${pubip} \
            -data-port 500${arg} -data-public-port 500${arg} \
            -result-ip-address 0.0.0.0 -result-public-ip-address ${pubip} \
            -result-port 501${arg} -result-public-port 501${arg} \
            -- -metadata-port 503${arg}
        ;;
esac
