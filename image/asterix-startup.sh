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

VOLUMN="/db"
CC_JVM_MEM=${CC_JVM_MEM:-1024} # in mega bytes
NC_JVM_MEM=${NC_JVM_MEM:-4096} # in mega bytes
PAGE_SIZE=${PAGE_SIZE:-131072} #in bytes

# Fourth argument is the publicly-routable IP address. 
pubip=`ifconfig eth0 2>/dev/null | awk '/inet / {print $2}'`
echo $pubip

function add_nc_to_conf() {
    ncnum=$1
    ncid="nc$ncnum"

    # NCs store all artifacts in subdirectories of /nc
    cat <<-EOF >> ${CONFFILE}
    <store>
    <ncId>${ncid}</ncId>
    <storeDirs>${VOLUMN}/${ncid}/io/storage</storeDirs>
    </store>
    <coredump>
    <ncId>${ncid}</ncId>
    <coredumpPath>${VOLUMN}/${ncid}/coredump</coredumpPath>
    </coredump>
    <transactionLogDir>
    <ncId>${ncid}</ncId>
    <txnLogDirPath>${VOLUMN}/${ncid}/txnLogs</txnLogDirPath>
    </transactionLogDir>
EOF
}

# Check arguments.
case "$type" in
    cc)
        if [ -z "$arg" ]
        then
            echo "Please provide the number of NCs as an argument."
            exit 10
        fi
        ;;
    nc)
        if [ -z "$arg" -o -z "$ccip" -o -z "$pubip" -o -z "$ncend" ]
        then
            echo "Args: index: $arg"
            echo "      ccip : $ccip"
            echo "      pubip: $pubip"
            echo "      ncend: $ncend"
            echo "Usage: asterix-nc <index> <cc ip> <total ncs>"
            echo "  <index> - the number of this NC (1, 2, ..)"
            echo "  <cc ip> - the IP address to contact the CC"
            echo "  <total ncs> - total number of NCs" 
            exit 10
        fi
        ;;
esac

# Configuration file to be constructed
CONFFILE=asterix-configuration.xml

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

for((i=1; i<=$ncend; i++));do
    add_nc_to_conf $i
done


ONE_THIRD=$((NC_JVM_MEM*1024*1024/3/PAGE_SIZE*PAGE_SIZE))
CMP_SIZE=$((ONE_THIRD/PAGE_SIZE/50)) # should enable 50 datasets
cat <<EOF >> ${CONFFILE}
<property>
    <name>max.wait.active.cluster</name>
    <value>600</value>
    <description>Maximum wait (in seconds) for a cluster to be ACTIVE (all nodes are available)
        before a submitted query/statement can be executed. (Default = 60 seconds)
    </description>
</property>

<property>
    <name>storage.buffercache.pagesize</name>
    <value>${PAGE_SIZE}</value>
    <description>The page size in bytes for pages in the buffer cache.
        (Default = "131072" // 128KB)
    </description>
</property>

<property>
    <name>storage.buffercache.size</name>
    <value>${ONE_THIRD}</value>
    <description>The size of memory allocated to the disk buffer cache.
        The value should be a multiple of the buffer cache page size(Default
        = "536870912" // 512MB)
    </description>
</property>

<property>
    <name>storage.buffercache.maxopenfiles</name>
    <value>214748364</value>
    <description>The maximum number of open files in the buffer cache.
        (Default = "214748364")
    </description>
</property>

<property>
    <name>storage.memorycomponent.pagesize</name>
    <value>${PAGE_SIZE}</value>
    <description>The page size in bytes for pages allocated to memory
        components. (Default = "131072" // 512KB)
    </description>
</property>

<property>
    <name>storage.memorycomponent.numpages</name>
    <value>${CMP_SIZE}</value>
    <description>The number of pages to allocate for a memory component.
        (Default = 256)
    </description>
</property>

<property>
    <name>storage.metadata.memorycomponent.numpages</name>
    <value>8</value>
    <description>The number of pages to allocate for a memory component.
        (Default = 64)
    </description>
</property>

<property>
    <name>storage.memorycomponent.numcomponents</name>
    <value>2</value>
    <description>The number of memory components to be used per lsm index.
        (Default = 2)
    </description>
</property>

<property>
    <name>storage.memorycomponent.globalbudget</name>
    <value>${ONE_THIRD}</value>
    <description>The total size of memory in bytes that the sum of all
        open memory
        components cannot exceed. (Default = "536870192" // 512MB)
    </description>
</property>

<property>
    <name>storage.lsm.bloomfilter.falsepositiverate</name>
    <value>0.01</value>
    <description>The maximum acceptable false positive rate for bloom
        filters associated with LSM indexes. (Default = "0.01" // 1%)
    </description>
</property>

<property>
    <name>txn.log.buffer.numpages</name>
    <value>2</value>
    <description>The number of in-memory log buffer pages. (Default = "8")
    </description>
</property>

<property>
    <name>txn.log.buffer.pagesize</name>
    <value>${PAGE_SIZE}</value>
    <description>The size of pages in the in-memory log buffer. (Default =
        "131072" // 128KB)
    </description>
</property>

<property>
    <name>txn.log.partitionsize</name>
    <value>2147483648</value>
    <description>The maximum size of a log file partition allowed before
        rotating the log to the next partition. (Default = "2147483648" //
        2GB)
    </description>
</property>

<property>
    <name>txn.log.checkpoint.lsnthreshold</name>
    <value>67108864</value>
    <description>The size of the window that the maximum LSN is allowed to
        be ahead of the checkpoint LSN by. (Default = ""67108864" // 64M)
    </description>
</property>

<property>
    <name>txn.log.checkpoint.pollfrequency</name>
    <value>120</value>
    <description>The time in seconds between that the checkpoint thread
        waits between polls. (Default = "120" // 120s)
    </description>
</property>

<property>
    <name>txn.log.checkpoint.history</name>
    <value>0</value>
    <description>The number of old log partition files to keep before
        discarding. (Default = "0")
    </description>
</property>

<property>
    <name>txn.lock.escalationthreshold</name>
    <value>1000</value>
    <description>The number of entity level locks that need to be acquired
        before the locks are coalesced and escalated into a dataset level
        lock. (Default = "1000")
    </description>
</property>

<property>
    <name>txn.lock.shrinktimer</name>
    <value>5000</value>
    <description>The time in milliseconds to wait before deallocating
        unused lock manager memory. (Default = "5000" // 5s)
    </description>
</property>

<property>
    <name>txn.lock.timeout.waitthreshold</name>
    <value>60000</value>
    <description>The time in milliseconds to wait before labeling a
        transaction which has been waiting for a lock timed-out. (Default =
        "60000" // 60s)
    </description>
</property>

<property>
    <name>txn.lock.timeout.sweepthreshold</name>
    <value>10000</value>
    <description>The time in milliseconds the timeout thread waits between
        sweeps to detect timed-out transactions. (Default = "10000" // 10s)
    </description>
</property>

<property>
    <name>txn.job.recovery.memorysize</name>
    <value>64MB</value>
    <description>The memory allocated per job during recovery.
     (Default = "67108864" // 64MB)
    </description>
</property>

<property>
    <name>compiler.sortmemory</name>
    <value>134217728</value>
    <description>The amount of memory in bytes given to sort operations.
        (Default = "33554432" // 32mb)
    </description>
</property>

<property>
    <name>compiler.joinmemory</name>
    <value>134217728</value>
    <description>The amount of memory in bytes given to join operations.
        (Default = "33554432" // 32mb)
    </description>
</property>

<property>
    <name>compiler.framesize</name>
    <value>${PAGE_SIZE}</value>
    <description>The Hyracks frame size that the compiler configures per
        job. (Default = "131072" // 128KB)
    </description>
</property>

<property>
    <name>web.port</name>
    <value>19001</value>
    <description>The port for the ASTERIX web interface. (Default = 19001)
    </description>
</property>

<property>
    <name>api.port</name>
    <value>19002</value>
    <description>The port for the ASTERIX API server. (Default = 19002)
    </description>
</property>

<property>
    <name>web.queryinterface.port</name>
    <value>19006</value>
    <description>The port for the ASTERIX web query interface. (Default = 19006)
    </description>
 </property>

<property>
    <name>log.level</name>
    <value>INFO</value>
    <description>The minimum log level to be displayed. (Default = INFO)
    </description>
</property>

<property>
    <name>plot.activate</name>
    <value>false</value>
    <description>Enabling plot of Algebricks plan to tmp folder. (Default = false)
    </description>
</property>

</asterixConfiguration>
EOF

# Last but not least, execute the appropriate command
case "$type" in
    cc) #
        export JAVA_OPTS="-Xmx${CC_JVM_MEM}m -Dorg.eclipse.jetty.server.Request.maxFormContentSize=-1"
        exec /asterix/bin/asterixcc \
            -cluster-net-ip-address ${pubip} -cluster-net-port 19000 \
            -client-net-ip-address ${pubip} 
        ;;
    nc) #
        export JAVA_OPTS="-Xmx${NC_JVM_MEM}m -Djava.rmi.server.hostname=${pubip}"
        port=$((5000+arg*10))
        exec /asterix/bin/asterixnc \
            -node-id nc${arg} -iodevices "${VOLUMN}/nc${arg}/io" \
            -cc-host ${ccip} -cc-port 19000 \
            -cluster-net-ip-address ${pubip} \
            -cluster-net-public-ip-address ${pubip} \
            -cluster-net-port $((port+0)) -cluster-net-public-port $((port+0))\
            -data-ip-address ${pubip} -data-public-ip-address ${pubip} \
            -data-port $((port+1)) -data-public-port $((port+1)) \
            -result-ip-address ${pubip} -result-public-ip-address ${pubip} \
            -result-port $((port+2)) -result-public-port $((port+2)) > ${VOLUMN}/nc${arg}.log 2>&1
        ;;
esac


