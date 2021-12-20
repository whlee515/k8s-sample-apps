#!/bin/bash

docker pull mreferre/yelb-db:0.5
docker pull mreferre/yelb-appserver:0.5
docker pull redis:4.0.2
docker pull mreferre/yelb-ui:0.7

docker tag mreferre/yelb-db:0.5 harbor.test.virtuosity-lab.com/yelb/mreferre/yelb-db:0.5
docker tag mreferre/yelb-appserver:0.5 harbor.test.virtuosity-lab.com/yelb/mreferre/yelb-appserver:0.5
docker tag redis:4.0.2 harbor.test.virtuosity-lab.com/yelb/redis:4.0.2
docker tag mreferre/yelb-ui:0.7 harbor.test.virtuosity-lab.com/yelb/mreferre/yelb-ui:0.7

docker push harbor.test.virtuosity-lab.com/yelb/mreferre/yelb-db:0.5
docker push harbor.test.virtuosity-lab.com/yelb/mreferre/yelb-appserver:0.5
docker push harbor.test.virtuosity-lab.com/yelb/redis:4.0.2
docker push harbor.test.virtuosity-lab.com/yelb/mreferre/yelb-ui:0.7