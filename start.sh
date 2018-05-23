#!/bin/bash
#Petit script pour lancer la db couchdb via un docker
#zf180523.1843
# source: https://hub.docker.com/r/library/couchdb/ et http://couchdb.apache.org/

docker container stop my-couchdb
docker container rm my-couchdb

docker run -d -p 5984:5984 -v $(pwd):/opt/couchdb/data --name my-couchdb couchdb

echo ""
echo "après 2 minutes, vous pouvez le tester avec:"
echo ""
echo "curl http://127.0.0.1:5984/"
echo ""




