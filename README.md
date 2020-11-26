# Druid Docker Image

## Run a simple Druid cluster

Download and launch the docker image

```sh
docker build .
docker run --rm -i --network host micro-quickstart
```

## Run a cluster

See environnemnt variables to launch a cluster and add them to docker command using -e flag

1. Run master node x2

```sh
docker run --rm -i --network host master
```

2. Run query node x2 (minimum)

```sh
docker run --rm -i --network host query 
```

3. Run data node x2 and more

```sh
docker run --rm -i --network host data
```

## Environment variables

### Common

* DRUID_HOST = "your ip addres"
* S3_STORAGE_BUCKET = "s3 bucket"
* S3_STORAGE_PATH = "s3 path"
* ENABLE_JAVASCRIPT = "true"
* MAX_VOLUME_SIZE = "600000000"
* DB_META = "mysql"
* DB_META_NAME = "druid"
* DB_META_USER = "druid"
* DB_META_PASSWORD = "your super druid password"
* DB_META_HOST = " your db host"
* ZK_HOSTS = "zookeeper.lan"
* ENABLE_STATSD = "true"

S3 can be replace by either GCS (google storage) or OSS (alibaba storage):

* GCS_STORAGE_BUCKET = "your gcs bucket"
* GCS_STORAGE_PATH = "your gcs bucket path"

### Master: Overlord/Coordinator

Overlord/coordinator master process

* OVERLORD_PORT = "${NOMAD_PORT_coordinator}"
* COORDINATOR_OVERLORD_XMX="12g"

### Query (Router + Broker)

For Broker (service responsible for handling query)

* BROKER_PORT = "listening port"
* BROKER_RESULT_CACHE_ENABLED = "enable result cache or not"
* BROKER_CACHE_TYPE = "memcached|caffeine|redis"
* BROKER_CACHE_MEMCACHED_HOSTS = "memcahced.lan:11211"
* BROKER_XMX="1g"
* BROKER_MAX_DMS="1g"
* BROKER_PROC_BUFFER_SIZEBYTES="500000000"
* BROKER_PROC_NUM_MERGEBUFFER="4"
* BROKER_PROC_NUM_THREADS="4"

For router (service responsible for routing http call)

* ROUTER_PORT = "listening port"
* ROUTER_XMX = "1g"
* ROUTER_DMS = "1g"


### DATA (MiddleManager + Historical)

For MiddleManager (service responsible for managing peon worker which run druid tasks)

* MIDDLEMANAGER_PORT = "listening port"
* MIDDLEMANAGER_WORKERS = "number of workers"
* MIDDLEMANAGER_XMX="16g"
* PEON_XMX="2g"

For historical which host non realtime druid segments

* HISTORICAL_PORT = "listening port"
* HISTORICAL_CACHE_ENABLED = "true"
* HISTORICAL_CACHE_TYPE = "memcached|caffeine|redis"
* HISTORICAL_DATA_DIR = "/opt/druid/var/segment-cache"
* HISTORICAL_CACHE_MEMCACHED_HOSTS = "memcached.lan:11211"
* HISTORICAL_PROC_BUFFER_SIZEBYTES = "500000000"
* HISTORICAL_PROC_NUM_MERGEBUFFER = "6"
* HISTORICAL_PROC_NUM_THREADS = "6"
* HISTORICAL_XMX="16g"
* HISTORICAL_MAX_DMS="8g"

