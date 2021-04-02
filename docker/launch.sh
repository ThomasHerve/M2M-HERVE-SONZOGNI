#!/bin/bash
# NodeRED app for collect sensors data

name_to_ipaddress(){
  ip a | grep "inet " |awk '{ if ( $1 == "inet" ) { print $2 } else if ( $2 == "Link" ) { printf "%s:" ,$1 } }' | grep -v "127.0.0.1" | head -1
}

NODERED_WEB_PORT=1880
NODERED_ADMIN_PASSWORD="MUST_BE_CHANGED"
# Note : Password can be crypt and set into settings.js with node-red-admin hash-pw

GF_PORT=3600
GF_PASSWORD="MUST_BE_CHANGED"

MQTT_BROKER_1=mqtt01
MQTT_BROKER_2=mqtt02
MQTT_BROKER_1=test.mosquitto.org
MQTT_BROKER_2=test.mosquitto.org
LOCAL_HOST=$(name_to_ipaddress localhost)
echo $LOCAL_HOST


# -------------------------------
# Clean
# -------------------------------

docker rm -f mosquitto_for_iot
docker rm -f influxdb_for_iot
docker rm -f mongodb_for_iot
docker rm -f nodered_for_iot
docker rm -f grafana_for_iot
docker rm -f chronograf_for_iot

rm -fr influxdb mongo grafana chronograf
rm -f lib/flows/*



# -------------------------------
# Mosquitto
# -------------------------------
docker pull eclipse-mosquitto
docker run -d --name nodered_for_iot \
      -p 1883:1883 -p 9001:9001 \
      mosquitto_for_iot


# -------------------------------
# Influx DB
# -------------------------------
mkdir influxdb
docker pull influxdb
docker run -d --name influxdb_for_iot \
      -p 8086:8086 \
      -p 8083:8083 \
      -v influxdb:/var/lib/influxdb \
      influxdb

# -------------------------------
# MongoDB
# -------------------------------
docker run -d --name mongodb_for_iot \
      -p 27017:27017 \
      mongo

# -------------------------------
# NodeRED
# -------------------------------
docker pull nodered/node-red-docker

LOCALDIR=$(pwd)
docker run -d --name nodered_for_iot \
      -v $LOCALDIR:/data \
      -p $NODERED_WEB_PORT:1880  \
      -p 1680:1680/udp  \
      -p 7080:8080  \
      --add-host=influxdb-1:$LOCAL_HOST  \
      --add-host=mongodb-1:$LOCAL_HOST  \
      -e FLOWS=lora.flow.json \
      -e NODE_OPTIONS="--max_old_space_size=128" \
      nodered/node-red-docker

npm install node-red-contrib-influxdb
npm install node-red-node-mongodb
npm install node-red-contrib-pubnub
npm install node-red-contrib-ifttt
npm install node-red-contrib-kafka-node
npm install node-red-contrib-web-worldmap
npm install node-red/node-red-dashboard


npm install -g node-red-admin
node-red-admin target http://localhost:$PORT
node-red-admin list
node-red-admin install node-red-contrib-influxdb

# -------------------------------
# Grafana
# -------------------------------

docker run -d --name grafana_for_iot \
  -p $GF_PORT:3000 \
  --add-host=influxdb-1:$LOCAL_HOST  \
  -e "GF_SECURITY_ADMIN_PASSWORD=$GF_PASSWORD" \
  grafana/grafana


# -------------------------------
# Chronograf
# -------------------------------

mkdir chronograf
docker run -d --name chronograf_for_iot \
      -p 18888:8888 \
      --add-host=influxdb-1:$LOCAL_HOST  \
      -v chronograf:/var/lib/chronograf \
      chronograf


# -------------------------------
# Huginn https://github.com/huginn/huginn
# -------------------------------
echo Browse http://localhost:3000
echo Log in to your Huginn instance using the username admin and password password

docker run -d --name huginn_for_iot \
       --hostname huginn \
       -p 3000:3000 \
       huginn/huginn

docker logs --follow huginn_for_iot
^C

# -------------------------------
# Nifi https://nifi.apache.org/
# -------------------------------
docker run --name nifi_for_iot \
  -p 9090:9090 \
  -d \
  -e NIFI_WEB_HTTP_PORT='9090' \
  apache/nifi:latest


# -------------------------------
# Logs
# -------------------------------
docker logs --follow nodered_for_iot
tail -f logfile.txt

# -------------------------------
# Stop then Start
# -------------------------------

docker stop mosquitto_for_iot
docker stop influxdb_for_iot
docker stop mongodb_for_iot
docker stop nodered_for_iot
docker stop grafana_for_iot
docker stop chronograf_for_iot
docker stop huginn_for_iot
docker stop nifi_for_iot

docker start mosquitto_for_iot
docker start influxdb_for_iot
docker start mongodb_for_iot
docker start nodered_for_iot
docker start grafana_for_iot
docker start chronograf_for_iot
docker start huginn_for_iot
docker start nifi_for_iot

