#!/bin/bash
#Petit script pour lancer la db couchdb via un docker
#zf180516.1113
# source: https://hub.docker.com/r/library/couchdb/ et http://couchdb.apache.org/

docker run -d -p 5984:5984 -v $(pwd):/opt/couchdb/data --name my-couchdb couchdb




