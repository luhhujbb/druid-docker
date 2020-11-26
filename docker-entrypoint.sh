#!/bin/bash

set -x

#Configure server/cluster type

DEFAULT_PROCESSING_TMPDIR="var/druid/processing"

case "$1" in
  "single-large")
  CLUSTER_TYPE="single-server/large"
  SERVER_TYPE="single-server/large"
  DEFAULT_BROKER_XMX="12g"
  DEFAULT_BROKER_MAX_DMS="11g"
  DEFAULT_BROKER_PROC_BUFFER_SIZEBYTES="500000000"
  DEFAULT_BROKER_PROC_NUM_MERGEBUFFER="16"
  DEFAULT_BROKER_PROC_NUM_THREADS="1"
  DEFAULT_COORDINATOR_OVERLORD_XMX="15g"
  DEFAULT_HISTORICAL_XMX="16g"
  DEFAULT_HISTORICAL_MAX_DMS="25g"
  DEFAULT_HISTORICAL_PROC_BUFFER_SIZEBYTES="500000000"
  DEFAULT_HISTORICAL_PROC_NUM_MERGEBUFFER="8"
  DEFAULT_HISTORICAL_PROC_NUM_THREADS="31"
  DEFAULT_MIDDLEMANAGER_XMX="256m"
  DEFAULT_ROUTER_XMX="1g"
  DEFAULT_ROUTER_MAX_DMS="128m"
  DEFAULT_PEON_XMX="1g"

  ;;
  "micro-quickstart")
  CLUSTER_TYPE="single-server/micro-quickstart"
  SERVER_TYPE="single-server/micro-quickstart"
  DEFAULT_BROKER_XMX="512m"
  DEFAULT_BROKER_MAX_DMS="768m"
  DEFAULT_BROKER_PROC_BUFFER_SIZEBYTES="100000000"
  DEFAULT_BROKER_PROC_NUM_MERGEBUFFER="2"
  DEFAULT_BROKER_PROC_NUM_THREADS="1"
  DEFAULT_COORDINATOR_OVERLORD_XMX="256m"
  DEFAULT_HISTORICAL_XMX="512m"
  DEFAULT_HISTORICAL_MAX_DMS="1280m"
  DEFAULT_HISTORICAL_PROC_BUFFER_SIZEBYTES="200000000"
  DEFAULT_HISTORICAL_PROC_NUM_MERGEBUFFER="2"
  DEFAULT_HISTORICAL_PROC_NUM_THREADS="2"
  DEFAULT_MIDDLEMANAGER_XMX="64m"
  DEFAULT_ROUTER_XMX="128m"
  DEFAULT_ROUTER_MAX_DMS="128m"
  DEFAULT_PEON_XMX="1g"
  ;;
  "data")
  CLUSTER_TYPE="cluster"
  SERVER_TYPE="cluster/data"
  ;;
  "master-no-zk")
  CLUSTER_TYPE="cluster"
  SERVER_TYPE="cluster/master"
  ;;
  "master-with-zk")
  CLUSTER_TYPE="cluster"
  SERVER_TYPE="cluster/master"
  ;;
  "query")
  CLUSTER_TYPE="cluster"
  SERVER_TYPE="cluster/query"
  ;;
esac

if [ "$CLUSTER_TYPE" == "cluster" ];
  then
    DEFAULT_BROKER_XMX="12g"
    DEFAULT_BROKER_MAX_DMS="6g"
    DEFAULT_BROKER_PROC_BUFFER_SIZEBYTES="500000000"
    DEFAULT_BROKER_PROC_NUM_MERGEBUFFER="6"
    DEFAULT_BROKER_PROC_NUM_THREADS="1"
    DEFAULT_COORDINATOR_OVERLORD_XMX="15g"
    DEFAULT_HISTORICAL_XMX="8g"
    DEFAULT_HISTORICAL_MAX_DMS="13g"
    DEFAULT_HISTORICAL_PROC_BUFFER_SIZEBYTES="500000000"
    DEFAULT_HISTORICAL_PROC_NUM_MERGEBUFFER="4"
    DEFAULT_HISTORICAL_PROC_NUM_THREADS="15"
    DEFAULT_MIDDLEMANAGER_XMX="128m"
    DEFAULT_ROUTER_XMX="1g"
    DEFAULT_ROUTER_MAX_DMS="128m"
    DEFAULT_PEON_XMX="1g"
fi

echo "##################### ROUTER CONFIG #####################################"

#configure ROUTER port
if [ "$ROUTER_PORT" != "" ];
  then
    sed -i "s|8888|$ROUTER_PORT|g" /opt/druid/conf/druid/$SERVER_TYPE/router/runtime.properties
    sed -i "s|8888|$ROUTER_PORT|g" /opt/druid/bin/verify-default-ports
fi
#configure memory : router
if [ -d "/opt/druid/conf/druid/$SERVER_TYPE/router" ];
  then
    cp /opt/jvm_config/router.jvm.config /opt/druid/conf/druid/$SERVER_TYPE/router/jvm.config
    ROUTER_JVM_CONF_PATH=/opt/druid/conf/druid/$SERVER_TYPE/router/jvm.config
    if [ "$ROUTER_XMX" != "" ];
      then
        sed -i "s|ROUTER_XMX|$ROUTER_XMX|g" $ROUTER_JVM_CONF_PATH
      else
        sed -i "s|ROUTER_XMX|$DEFAULT_ROUTER_XMX|g" $ROUTER_JVM_CONF_PATH
    fi
    if [ "$ROUTER_MAX_DMS" != "" ];
      then
        sed -i "s|ROUTER_MAX_DMS|$ROUTER_MAX_DMS|g" $ROUTER_JVM_CONF_PATH
      else
        sed -i "s|ROUTER_MAX_DMS|$DEFAULT_ROUTER_MAX_DMS|g" $ROUTER_JVM_CONF_PATH
    fi
fi

echo "##################### OVERLORD CONFIG ###################################"

#configure coordinator/overlord port
if [ "$OVERLORD_PORT" != "" ];
  then
    sed -i "s|8081|$OVERLORD_PORT|g" /opt/druid/conf/druid/$SERVER_TYPE/coordinator-overlord/runtime.properties
    sed -i "s|8081|$OVERLORD_PORT|g" /opt/druid/bin/verify-default-ports
fi
#configure memory
if [ -d "/opt/druid/conf/druid/$SERVER_TYPE/coordinator-overlord" ];
  then
    cp /opt/jvm_config/coordinator-overlord.jvm.config /opt/druid/conf/druid/$SERVER_TYPE/coordinator-overlord/jvm.config
    COORDINATOR_OVERLORD_JVM_CONF_PATH=/opt/druid/conf/druid/$SERVER_TYPE/coordinator-overlord/jvm.config
    if [ "$COORDINATOR_OVERLORD_XMX" != "" ];
      then
        sed -i "s|COORDINATOR_OVERLORD_XMX|$COORDINATOR_OVERLORD_XMX|g" $COORDINATOR_OVERLORD_JVM_CONF_PATH
      else
        sed -i "s|COORDINATOR_OVERLORD_XMX|$DEFAULT_COORDINATOR_OVERLORD_XMX|g" $COORDINATOR_OVERLORD_JVM_CONF_PATH
    fi
fi

echo "##################### BROKER CONFIG #####################################"

#configure broker port
if [ "$BROKER_PORT" != "" ];
  then
    sed -i "s|8082|$BROKER_PORT|g" /opt/druid/conf/druid/$SERVER_TYPE/broker/runtime.properties
    sed -i "s|8082|$BROKER_PORT|g" /opt/druid/bin/verify-default-ports
fi

if [ "$BROKER_CACHE_USECACHE" == "true" ] || [ "$BROKER_CACHE_POPULATECACHE" == "true" ];
  then
    BROKER_CACHE_ENABLED="true"
fi

if [ "$BROKER_CACHE_USECACHE" == "true" ];
  then
    sed -i "s|druid.broker.cache.useCache=false|druid.broker.cache.useCache=true|g" /opt/druid/conf/druid/$SERVER_TYPE/broker/runtime.properties
fi

if [ "$BROKER_CACHE_POPULATECACHE" == "true" ];
  then
    sed -i "s|druid.broker.cache.populateCache=false|druid.broker.cache.populateCache=true|g" /opt/druid/conf/druid/$SERVER_TYPE/broker/runtime.properties
fi

#result cache is only available on broker so populate and use are both activated
if [ "$BROKER_RESULT_CACHE_ENABLED" == "true" ];
  then
    echo "druid.broker.cache.useResultLevelCache=true" >> /opt/druid/conf/druid/$SERVER_TYPE/broker/runtime.properties
    echo "druid.broker.cache.populateResultLevelCache=true" >> /opt/druid/conf/druid/$SERVER_TYPE/broker/runtime.properties
fi

# if redis or memcached, use hybrid caching for broker

if [ "$BROKER_CACHE_ENABLED" == "true" ] || [ "$BROKER_RESULT_CACHE_ENABLED" == "true" ];
  then
    if [ "$BROKER_CACHE_TYPE" == "" ];
      then
        BROKER_CACHE_TYPE="caffeine"
    fi
    if [ "$BROKER_CACHE_SIZE" != "" ];
      then
        BROKER_CACHE_SIZE="10000000"
    fi
    echo "druid.cache.type=$BROKER_CACHE_TYPE" >> /opt/druid/conf/druid/$SERVER_TYPE/broker/runtime.properties
    #caffeine cache
    if [ "$BROKER_CACHE_TYPE" == "caffeine" ];
      then
        echo "druid.cache.sizeInBytes=$BROKER_CACHE_SIZE" >> /opt/druid/conf/druid/$SERVER_TYPE/broker/runtime.properties
    fi
    #memcached cache
    if [ "$BROKER_CACHE_TYPE" == "memcached" ];
      then
        if [ "$BROKER_CACHE_MEMCACHED_HOSTS" != "" ];
          then
            echo "druid.cache.hosts=$BROKER_CACHE_MEMCACHED_HOSTS" >> /opt/druid/conf/druid/$SERVER_TYPE/broker/runtime.properties
        fi
    fi
    #redis cache
    if [ "$BROKER_CACHE_TYPE" == "redis" ];
      then
        #enable druid-redis-cache extensions
        sed -i "s|druid.extensions.loadList=\\[|druid.extensions.loadList=\\[\"druid-redis-cache\",|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
        echo "druid.cache.host=$BROKER_CACHE_REDIS_HOST" >> /opt/druid/conf/druid/$SERVER_TYPE/broker/runtime.properties
        if [ "$BROKER_CACHE_REDIS_PORT" == "" ]
          then
            BROKER_CACHE_REDIS_PORT="6379"
        fi
        echo "druid.cache.port=$BROKER_CACHE_REDIS_PORT" >> /opt/druid/conf/druid/$SERVER_TYPE/broker/runtime.properties
    fi
fi

#configure processing
#comment config
sed -i "s|druid.processing|#druid.processing|g" /opt/druid/conf/druid/$SERVER_TYPE/broker/runtime.properties

#set vars
if [ "$BROKER_PROC_BUFFER_SIZEBYTES" == "" ];
  then
    BROKER_PROC_BUFFER_SIZEBYTES="$DEFAULT_BROKER_PROC_BUFFER_SIZEBYTES"
fi
if [ "$PROCESSING_TMPDIR" == "" ];
  then
    PROCESSING_TMPDIR="$DEFAULT_PROCESSING_TMPDIR"
fi
if [ "$BROKER_PROC_NUM_MERGEBUFFER" == "" ];
  then
    BROKER_PROC_NUM_MERGEBUFFER="$DEFAULT_BROKER_PROC_NUM_MERGEBUFFER"
fi
if [ "$BROKER_PROC_NUM_THREADS" == "" ];
  then
    BROKER_PROC_NUM_THREADS="$DEFAULT_BROKER_PROC_NUM_THREADS"
fi

#write config
echo "druid.processing.buffer.sizeBytes=$BROKER_PROC_BUFFER_SIZEBYTES" >> /opt/druid/conf/druid/$SERVER_TYPE/broker/runtime.properties
echo "druid.processing.numMergeBuffers=$BROKER_PROC_NUM_MERGEBUFFER" >> /opt/druid/conf/druid/$SERVER_TYPE/broker/runtime.properties
echo "druid.processing.numThreads=$BROKER_PROC_NUM_THREADS" >> /opt/druid/conf/druid/$SERVER_TYPE/broker/runtime.properties
echo "druid.processing.tmpDir=$PROCESSING_TMPDIR" >> /opt/druid/conf/druid/$SERVER_TYPE/broker/runtime.properties

#configure memory : broker
if [ -d "/opt/druid/conf/druid/$SERVER_TYPE/broker" ];
  then
    cp /opt/jvm_config/broker.jvm.config /opt/druid/conf/druid/$SERVER_TYPE/broker/jvm.config
    BROKER_JVM_CONF_PATH=/opt/druid/conf/druid/$SERVER_TYPE/broker/jvm.config
    if [ "$BROKER_XMX" != "" ];
      then
        sed -i "s|BROKER_XMX|$BROKER_XMX|g" $BROKER_JVM_CONF_PATH
      else
        sed -i "s|BROKER_XMX|$DEFAULT_BROKER_XMX|g" $BROKER_JVM_CONF_PATH
    fi
    if [ "$BROKER_MAX_DMS" != "" ];
      then
        sed -i "s|BROKER_MAX_DMS|$BROKER_MAX_DMS|g" $BROKER_JVM_CONF_PATH
      else
        sed -i "s|BROKER_MAX_DMS|$DEFAULT_BROKER_MAX_DMS|g" $BROKER_JVM_CONF_PATH
    fi
fi

echo "##################### HISTORICAL CONFIG #################################"


#configure historical port
if [ "$HISTORICAL_PORT" != "" ];
  then
    sed -i "s|8083|$HISTORICAL_PORT|g" /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties
    sed -i "s|8083|$HISTORICAL_PORT|g" /opt/druid/bin/verify-default-ports
fi

if [ "$HISTORICAL_CACHE_ENABLED" == "true" ];
  then
    if [ "$HISTORICAL_CACHE_TYPE" == "" ];
      then
        HISTORICAL_CACHE_TYPE="caffeine"
    fi
    if [ "$HISTORICAL_CACHE_SIZE" != "" ];
      then
        HISTORICAL_CACHE_SIZE="10000000"
    fi
    sed -i "s|caffeine|$HISTORICAL_CACHE_TYPE|g" /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties
    #caffeine cache
    if [ "$HISTORICAL_CACHE_TYPE" == "caffeine" ];
      then
        sed -i "s|druid.cache.sizeInBytes=[0-9+]|druid.cache.sizeInBytes=$HISTORICAL_CACHE_SIZE|g" /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties
    fi
    #memcached cache
    if [ "$HISTORICAL_CACHE_TYPE" == "memcached" ];
      then
        if [ "$HISTORICAL_CACHE_MEMCACHED_HOSTS" != "" ];
          then
            echo "druid.cache.hosts=$HISTORICAL_CACHE_MEMCACHED_HOSTS" >> /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties
        fi
    fi
    #redis cache
    if [ "$HISTORICAL_CACHE_TYPE" == "redis" ];
      then
        #enable druid-redis-cache extensions
        sed -i "s|druid.extensions.loadList=\\[|druid.extensions.loadList=\\[\"druid-redis-cache\",|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
        echo "druid.cache.host=$HISTORICAL_CACHE_REDIS_HOST" >> /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties
        if [ "$HISTORICAL_CACHE_REDIS_PORT" == "" ]
          then
            HISTORICAL_CACHE_REDIS_PORT="6379"
        fi
        echo "druid.cache.port=$HISTORICAL_CACHE_REDIS_PORT" >> /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties
    fi
else
  sed -i "s|druid.historical.cache.useCache=true|druid.historical.cache.useCache=false|g" /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties
  sed -i "s|druid.historical.cache.populateCache=true|druid.historical.cache.populateCache=false|g" /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties
fi

if [ "$HISTORICAL_CACHE_USECACHE" == "false" ];
  then
    sed -i "s|druid.historical.cache.useCache=true|druid.historical.cache.useCache=false|g" /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties
fi

if [ "$HISTORICAL_CACHE_POPULATECACHE" == "false" ];
  then
    sed -i "s|druid.historical.cache.populateCache=true|druid.historical.cache.useCache=false|g" /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties
fi


#Historical tier & priority
if [ "$HISTORICAL_TIER" != "" ];
  then
    echo "druid.server.tier=$HISTORICAL_TIER" >> /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties
fi
if [ "$HISTORICAL_PRIORITY" != "" ];
  then
    echo "druid.server.priority=$HISTORICAL_PRIORITY" >> /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties
fi

#max size
if [ "$MAX_VOLUME_SIZE" != "" ];
  then
    sed -i "s|300000000000|$MAX_VOLUME_SIZE|g" /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties
    sed -i "s|300g|$MAX_VOLUME_SIZE|g" /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties
fi

if [ "$HISTORICAL_DATA_DIR" != "" ]
  then
    sed -i "s|var/segment-cache|$HISTORICAL_DATA_DIR|g" /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties
fi
#configure processing
#comment config
sed -i "s|druid.processing|#druid.processing|g" /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties

#set vars
if [ "$HISTORICAL_PROC_BUFFER_SIZEBYTES" == "" ];
  then
    HISTORICAL_PROC_BUFFER_SIZEBYTES="$DEFAULT_HISTORICAL_PROC_BUFFER_SIZEBYTES"
fi
if [ "$PROCESSING_TMPDIR" == "" ];
  then
    PROCESSING_TMPDIR="$DEFAULT_PROCESSING_TMPDIR"
fi
if [ "$HISTORICAL_PROC_NUM_MERGEBUFFER" == "" ];
  then
    HISTORICAL_PROC_NUM_MERGEBUFFER="$DEFAULT_HISTORICAL_PROC_NUM_MERGEBUFFER"
fi
if [ "$HISTORICAL_PROC_NUM_THREADS" == "" ];
  then
    HISTORICAL_PROC_NUM_THREADS="$DEFAULT_HISTORICAL_PROC_NUM_THREADS"
fi

#write config
echo "druid.processing.buffer.sizeBytes=$HISTORICAL_PROC_BUFFER_SIZEBYTES" >> /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties
echo "druid.processing.numMergeBuffers=$HISTORICAL_PROC_NUM_MERGEBUFFER" >> /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties
echo "druid.processing.numThreads=$HISTORICAL_PROC_NUM_THREADS" >> /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties
echo "druid.processing.tmpDir=$PROCESSING_TMPDIR" >> /opt/druid/conf/druid/$SERVER_TYPE/historical/runtime.properties

#configure memory : historical
if [ -d "/opt/druid/conf/druid/$SERVER_TYPE/historical" ];
  then
    cp /opt/jvm_config/historical.jvm.config /opt/druid/conf/druid/$SERVER_TYPE/historical/jvm.config
    HISTORICAL_JVM_CONF_PATH=/opt/druid/conf/druid/$SERVER_TYPE/historical/jvm.config
    if [ "$HISTORICAL_XMX" != "" ];
      then
        sed -i "s|HISTORICAL_XMX|$HISTORICAL_XMX|g" $HISTORICAL_JVM_CONF_PATH
      else
        sed -i "s|HISTORICAL_XMX|$DEFAULT_HISTORICAL_XMX|g" $HISTORICAL_JVM_CONF_PATH
    fi
    if [ "$HISTORICAL_MAX_DMS" != "" ];
      then
        sed -i "s|HISTORICAL_MAX_DMS|$HISTORICAL_MAX_DMS|g" $HISTORICAL_JVM_CONF_PATH
      else
        sed -i "s|HISTORICAL_MAX_DMS|$DEFAULT_HISTORICAL_MAX_DMS|g" $HISTORICAL_JVM_CONF_PATH
    fi
fi

echo "##################### MIDDLEMANAGER CONFIG ##############################"


#configure middleManager port
if [ "$MIDDLEMANAGER_PORT" != "" ];
  then
    sed -i "s|8091|$MIDDLEMANAGER_PORT|g" /opt/druid/conf/druid/$SERVER_TYPE/middleManager/runtime.properties
    sed -i "s|8091|$MIDDLEMANAGER_PORT|g" /opt/druid/bin/verify-default-ports
fi

#configure middlemanager number of workers
if [ "$MIDDLEMANAGER_WORKERS" != "" ];
  then
    sed -i "s|druid.worker.capacity=[0-9]|druid.worker.capacity=$MIDDLEMANAGER_WORKERS|g" /opt/druid/conf/druid/$SERVER_TYPE/middleManager/runtime.properties
fi

#configure middlemanager number of workers
if [ "$PEON_XMX" != "" ];
  then
    sed -i "s|1g|$PEON_XMX|g" /opt/druid/conf/druid/$SERVER_TYPE/middleManager/runtime.properties
  else
    sed -i "s|1g|$DEFAULT_PEON_XMX|g" /opt/druid/conf/druid/$SERVER_TYPE/middleManager/runtime.properties
fi

#configure memory
if [ -d "/opt/druid/conf/druid/$SERVER_TYPE/middleManager" ];
  then
    cp /opt/jvm_config/middleManager.jvm.config /opt/druid/conf/druid/$SERVER_TYPE/middleManager/jvm.config
    MIDDLEMANAGER_JVM_CONF_PATH=/opt/druid/conf/druid/$SERVER_TYPE/middleManager/jvm.config
    if [ "$MIDDLEMANAGER_XMX" != "" ];
      then
        sed -i "s|MIDDLEMANAGER_XMX|$MIDDLEMANAGER_XMX|g" $MIDDLEMANAGER_JVM_CONF_PATH
      else
        sed -i "s|MIDDLEMANAGER_XMX|$DEFAULT_MIDDLEMANAGER_XMX|g" $MIDDLEMANAGER_JVM_CONF_PATH
    fi
fi

echo "##################### METADATA CONFIG ###################################"

#configure metadata stoarge port
if [ "$METADATA_STORAGE_PORT" != "" ];
  then
    sed -i "s|1527|$METADATA_STORAGE_PORT|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    sed -i "s|1527|$METADATA_STORAGE_PORT|g" /opt/druid/bin/verify-default-ports
fi

echo "##################### TRANQUILITY CONFIG ################################"

#configure tranquility port
if [ "$TRANQUILITY_PORT" != "" ];
  then
    sed -i "s|8200|$TRANQUILITY_PORT|g" /opt/druid/conf/tranquility/server.json
    sed -i "s|8200|$TRANQUILITY_PORT|g" /opt/druid/conf/tranquility/wikipedia-server.json
    sed -i "s|8200|$TRANQUILITY_PORT|g" /opt/druid/bin/verify-default-ports
fi


echo "##################### COMMON CONFIG #####################################"

if [ "$DRUID_HOST" != "" ];
  then
    sed -i "s|druid.host=localhost|druid.host=$DRUID_HOST|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
fi

#configure s3 deep storage
if [ "$S3_STORAGE_BUCKET" != "" -a "$S3_STORAGE_PATH" ];
  then
    if [ "$S3_STORAGE_INDEXER_PATH" == "" ];
      then
        S3_STORAGE_INDEXER_PATH="logs"
    fi
    if [ "$DRUID_STORAGE_TYPE" == "" ];
      then
        DRUID_STORAGE_TYPE="s3"
    fi
    ENABLE_S3_EXTENSION="true"
    sed -i "s|druid.storage.storageDirectory|#druid.storage.storageDirectory|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties

    #Configure storage
    echo "" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "druid.storage.bucket=$S3_STORAGE_BUCKET" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "druid.storage.baseKey=$S3_STORAGE_PATH" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "druid.storage.storageDirectory=$S3_STORAGE_BUCKET/$S3_STORAGE_PATH" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties

    #configure s3 custom endpoints
    # to configure key use : AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY env vars
    if [ "$S3_STORAGE_ENDPOINT" != "" ];
      then
        echo "druid.s3.endpoint.url=$S3_STORAGE_ENDPOINT" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    fi
    if [ "$S3_STORAGE_PROTOCOL" != "" ];
      then
        echo "druid.s3.protocol=$S3_STORAGE_PROTOCOL" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    else
        echo "druid.s3.protocol=https" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    fi
    if [ "$S3_STORAGE_REGION" != "" ];
      then
        echo "druid.s3.endpoint.signingRegion=$S3_STORAGE_REGION" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    fi

    #Configure indexing logs
    sed -i "s|druid.indexer.logs.directory|#druid.indexer.logs.directory|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "druid.indexer.logs.s3Bucket=$S3_STORAGE_BUCKET" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "druid.indexer.logs.s3Prefix=$S3_STORAGE_INDEXER_PATH" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
fi

if [ "$ENABLE_S3_EXTENSION" == "true" ];
  then
    sed -i "s|druid.extensions.loadList=\\[|druid.extensions.loadList=\\[\"druid-s3-extensions\",|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
fi

# OSS storage extensions
if [ "$OSS_STORAGE_BUCKET" != "" -a "$OSS_STORAGE_PATH" ];
  then
    if [ "$OSS_STORAGE_INDEXER_PATH" == "" ];
      then
        OSS_STORAGE_INDEXER_PATH="logs"
    fi
    if [ "$DRUID_STORAGE_TYPE" == "" ];
      then
        DRUID_STORAGE_TYPE="oss"
    fi
    ENABLE_OSS_EXTENSION="true"
    sed -i "s|druid.storage.storageDirectory|#druid.storage.storageDirectory|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties

    #Configure storage
    echo "" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "druid.storage.oss.bucket=$OSS_STORAGE_BUCKET" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "druid.storage.oss.prefix=$OSS_STORAGE_PATH" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "druid.storage.storageDirectory=$OSS_STORAGE_BUCKET/$OSS_STORAGE_PATH" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties

    #configure oss custom endpoints
    if [ "$OSS_ACCESS_KEY" != "" ];
      then
        echo "druid.oss.accessKey=$OSS_ACCESS_KEY" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    fi
    if [ "$OSS_SECRET_KEY" != "" ];
      then
        echo "druid.oss.secretKey=$OSS_SECRET_KEY" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    fi
    if [ "$OSS_STORAGE_ENDPOINT" != "" ];
      then
        echo "druid.oss.endpoint=$OSS_STORAGE_ENDPOINT" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    fi

    #Configure indexing logs
    sed -i "s|druid.indexer.logs.directory|#druid.indexer.logs.directory|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "druid.indexer.logs.oss.bucket=$OSS_STORAGE_BUCKET" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "druid.indexer.logs.oss.prefix=$OSS_STORAGE_INDEXER_PATH" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
fi

if [ "$ENABLE_OSS_EXTENSION" == "true" ];
then
  sed -i "s|druid.extensions.loadList=\\[|druid.extensions.loadList=\\[\"aliyun-oss-extensions\",|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
fi

#Configure gcs storage (need GOOGLE_APPLICATION_CREDENTIALS to be sourced)
if [ "$GCS_STORAGE_BUCKET" != "" -a "$GCS_STORAGE_PATH" ];
  then
    if [ "$GCS_STORAGE_INDEXER_PATH" == "" ];
      then
        GCS_STORAGE_INDEXER_PATH="logs"
    fi
    if [ "$DRUID_STORAGE_TYPE" == "" ];
      then
        DRUID_STORAGE_TYPE="google"
    fi
    ENABLE_google_EXTENSION="true"
    sed -i "s|druid.storage.storageDirectory|#druid.storage.storageDirectory|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties

    #Configure storage
    echo "" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "druid.google.bucket=$GCS_STORAGE_BUCKET" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "druid.google.prefix=$GCS_STORAGE_PATH" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "druid.storage.storageDirectory=$OSS_STORAGE_BUCKET/$OSS_STORAGE_PATH" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties


    #Configure indexing logs
    sed -i "s|druid.indexer.logs.directory|#druid.indexer.logs.directory|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "druid.indexer.logs.bucket=$GCS_STORAGE_BUCKET" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "druid.indexer.logs.prefix=$GCS_STORAGE_INDEXER_PATH" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
fi

if [ "$ENABLE_GCS_EXTENSION" == "true" ];
then
  sed -i "s|druid.extensions.loadList=\\[|druid.extensions.loadList=\\[\"druid-google-extensions\",|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
fi

#disable local storage & enable s3/oss/gcs storage
sed -i "s|druid.storage.type=local|druid.storage.type=$DRUID_STORAGE_TYPE|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
sed -i "s|druid.indexer.logs.type=file|druid.indexer.logs.type=$DRUID_STORAGE_TYPE|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties

#configure statsd emitter
if [ "$ENABLE_STATSD" == "true" ];
  then
    sed -i "s|druid.extensions.loadList=\\[|druid.extensions.loadList=\\[\"statsd-emitter\",|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    if [ "$STATSD_HOST" == "" ];
      then
        STATSD_HOST="localhost"
    fi
    if [ "$STATSD_PORT" == "" ];
      then
        STATSD_PORT="8125"
    fi
    echo "druid.emitter=statsd" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "druid.emitter.statsd.hostname=$STATSD_HOST" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "druid.emitter.statsd.port=$STATSD_PORT" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
fi

if [ "$ENABLE_PARQUET" == "true" ];
  then
    sed -i "s|druid.extensions.loadList=\\[|druid.extensions.loadList=\\[\"druid-parquet-extensions\",|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
fi

if [ "$ENABLE_AVRO" == "true" ];
  then
    sed -i "s|druid.extensions.loadList=\\[|druid.extensions.loadList=\\[\"druid-avro-extensions\",|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
fi

if [ "$ENABLE_JAVASCRIPT" == "true" ];
  then
    echo "druid.javascript.enabled=true" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
fi

# Configure ZOOKEEPER hosts
if [ "$ZK_HOSTS" != "" ];
  then
    sed -i "s|druid.zk.service.host=localhost|druid.zk.service.host=$ZK_HOSTS|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
fi

if [ "$ZK_PATH" != "" ];
  then
    sed -i "s|druid.zk.paths.base=/druid|druid.zk.paths.base=$ZK_PATH|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
fi

# Metastore (mysql/postgresql support)
if [ "$DB_META" != "" -a "$DB_META" != "derby" ];
  then
    if [ "$DB_META_PORT" == "" ];
      then
        if [ "$DB_META" == "mysql" ];
          then
          DB_META_PORT="3306"
        elif [ "$DB_META" == "postgresql" ];
          then
            DB_META_PORT="5432"
        fi
    fi
    sed -i "s|druid.metadata.storage.connector|#druid.metadata.storage.connector|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    if [ "$DB_META" == "mysql" ];
      then
        sed -i "s|druid.extensions.loadList=\\[|druid.extensions.loadList=\\[\"mysql-metadata-storage\",|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
        sed -i "s|druid.metadata.storage.type=derby|druid.metadata.storage.type=mysql|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
        echo "druid.metadata.storage.connector.connectURI=jdbc:mysql://$DB_META_HOST:$DB_META_PORT/$DB_META_NAME" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    elif [ "$DB_META" == "postgresql" ];
      then
        sed -i "s|druid.extensions.loadList=\\[|druid.extensions.loadList=\\[\"postgresql-metadata-storage\",|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
        sed -i "s|druid.metadata.storage.type=derby|druid.metadata.storage.type=postgresql|g" /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
        echo "druid.metadata.storage.connector.connectURI=jdbc:postgresql://$DB_META_HOST:$DB_META_PORT/$DB_META_NAME" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    fi
    echo "druid.metadata.storage.connector.user=$DB_META_USER"  >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
    echo "druid.metadata.storage.connector.password=$DB_META_PASSWORD" >> /opt/druid/conf/druid/$CLUSTER_TYPE/_common/common.runtime.properties
fi



echo "$1"

case "$1" in
  "single-large")
  /opt/druid/bin/start-single-server-large
  ;;
  "micro-quickstart")
  /opt/druid/bin/start-micro-quickstart
  ;;
  "data")
  /opt/druid/bin/start-cluster-data-server
  ;;
  "master-no-zk")
  /opt/druid/bin/start-cluster-master-no-zk-server
  ;;
  "master-with-zk")
  /opt/druid/bin/start-cluster-master-with-zk-server
  ;;
  "query")
  /opt/druid/bin/start-cluster-query-server
  ;;
esac

sleep 600
