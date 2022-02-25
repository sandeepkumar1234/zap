#!/usr/bin/env bash

CONTAINER_ID=$(docker run --name zapcontainer -u zap -P -d owasp/zap2docker-weekly zap.sh -daemon -port 2375 -host 127.0.0.1 -config api.disablekey=true -config scanner.attackOnStart=true -config view.mode=attack -config connection.dnsTtlSuccessfulQueries=-1 -config api.addrs.addr.name=.* -config api.addrs.addr.regex=true)

# the target URL for ZAP to scan
# the target URL for ZAP to scan
TARGET_URL=targeturl
docker exec $CONTAINER_ID zap-cli -p 2375 status -t 120 && docker exec $CONTAINER_ID zap-cli -p 2375 open-url $TARGET_URL


docker exec $CONTAINER_ID zap-cli -p 2375 spider $TARGET_URL

docker exec $CONTAINER_ID zap-cli -p 2375 active-scan --recursive $TARGET_URL

#docker exec $CONTAINER_ID zap-cli -p 2375 Full-scan --recursive $TARGET_URL

docker exec $CONTAINER_ID zap-cli -p 2375 alerts -l Informational

docker exec $CONTAINER_ID zap-cli -p 2375 alerts -f json -l Informational >> result.json

docker exec $CONTAINER_ID zap-cli -p 2375 report -o result.html -f html

docker exec $CONTAINER_ID zap-cli -p 2375 report -o result.xml -f xml

docker cp $CONTAINER_ID:zap/result.html ./

docker cp $CONTAINER_ID:zap/result.xml ./

#echo "ELK stack"
#until curl esurl  ; do echo "Waiting for Elastic Search"; sleep 2; done
#mkdir zap1
#cp result.json zap1/ && cd  zap1
#echo "parse result.json - add indices"
#cat result.json | jq -c '.[] | {"index": {"_index": "zapindex", "_type": "zapindex",  "_id": "_id" }},  .' | curl -H 'Content-Type: application/json'   -XPOST esurl/_bulk --data-binary @-
# cat output.json | jq -c '.[] | {"index": {"_index": "zap7", "_type": "zap7", "_id": "_id"}}, .' | curl -H 'Content-Type: application/json'   -XPOST qaopselasticsearch.engazewell.com/_bulk --data-binary @-
# cat output.json | jq -c '.[] | {"index": {"_index": "bookmarks", "_type": "bookmark", "_id": .id}}, .' | curl -H 'Content-Type: application/json' -u elastic:changeme  -XPOST localhost:9200/_bulk --data-binary @-
#docker commit $CONTAINER_ID  dockerimage
#docker push dockerimage
#docker stop $CONTAINER_ID
docker rm -f zapcontainer
#docker rmi owasp/zap2docker-weekly

#docker rm -f $CONTAINER_ID
