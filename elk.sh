#!/bin/bash

# ELASTICSEARCH INSTALLATION
mkdir -p elk && chmod 755 elk
wget -nc https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.8.0-linux-x86_64.tar.gz
tar -xzf elasticsearch-7.8.0-linux-x86_64.tar.gz -C elk

mkdir -p elk/elasticsearch-data elk/elasticsearch-logs

PWD=`pwd`
DATAPATH=elk/elasticsearch-data
LOGPATH=elk/elasticsearch-logs
ELASTICSEARCHPORT=9200
NETWORKHOST=127.0.0.1

sed -i '/cluster\.name/s/^#//g' elk/elasticsearch-7.8.0/config/elasticsearch.yml
sed -i '/node\.name/s/^#//g' elk/elasticsearch-7.8.0/config/elasticsearch.yml
sed -i -e '/^#path\.data\:/ s|^#.*$|path\.data\: '$PWD'\/'$DATAPATH'|g' elk/elasticsearch-7.8.0/config/elasticsearch.yml
sed -i -e '/^#path\.logs\:/ s|^#.*$|path\.logs\: '$PWD'\/'$LOGPATH'|g' elk/elasticsearch-7.8.0/config/elasticsearch.yml 
sed -i -e '/^#network\.host\:/ s|^#.*$|network\.host\: '$NETWORKHOST'|g' elk/elasticsearch-7.8.0/config/elasticsearch.yml 
sed -i -e '/^#http\.port\:/ s|^#.*$|http\.port\: '$ELASTICSEARCHPORT'|g' elk/elasticsearch-7.8.0/config/elasticsearch.yml

groupadd elk
useradd elk -g elk -p elk
chown -R elk:elk elk/elasticsearch-7.8.0
chmod o+x /root/ elk/elasticsearch-7.8.0
chgrp elk elk/elasticsearch-7.8.0
chown -R elk:elk elk/elasticsearch-data
chown -R elk:elk elk/elasticsearch-logs

/bin/su -c "cd $PWD/elk/elasticsearch-7.8.0/bin/ && ./elasticsearch -d" - elk



# KIBANA INSTALLATION
wget -nc https://artifacts.elastic.co/downloads/kibana/kibana-7.8.0-linux-x86_64.tar.gz
tar -xzf kibana-7.8.0-linux-x86_64.tar.gz -C elk

KIBANAPORT=5601
HOSTIP=`ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}'`

sed -i -e '/^#server\.port\:/ s|^#.*$|server\.port\: '$KIBANAPORT'|g' elk/kibana-7.8.0-linux-x86_64/config/kibana.yml
sed -i -e '/^#server\.host\:/ s|^#.*$|server\.host\: \"'$HOSTIP'\"|g' elk/kibana-7.8.0-linux-x86_64/config/kibana.yml
sed -i -e '/^#server\.name\:/ s|^#.*$|server\.name\: \"'$HOSTNAME'\"|g' elk/kibana-7.8.0-linux-x86_64/config/kibana.yml
sed -i '/elasticsearch\.hosts/s/^#//g' elk/kibana-7.8.0-linux-x86_64/config/kibana.yml

chown -R elk:elk elk/kibana-7.8.0-linux-x86_64/
chmod o+x /root/ elk/kibana-7.8.0-linux-x86_64/
chgrp elk elk/kibana-7.8.0-linux-x86_64/

/bin/su -c "cd $PWD/elk/kibana-7.8.0-linux-x86_64/bin/ && ./kibana &" - elk



# LOGSTASH INSTALLATION
wget -nc https://artifacts.elastic.co/downloads/logstash/logstash-7.10.0-linux-x86_64.tar.gz
tar -xzf logstash-7.10.0-linux-x86_64.tar.gz -C elk

cp logstash-sample.conf elk/logstash-7.10.0/config/logstash-sample.conf

grep -q "\- pipeline.id: testlogstash" "elk/logstash-7.10.0/config/pipelines.yml" || echo "- pipeline.id: test" >> elk/logstash-7.10.0/config/pipelines.yml
grep -q "  path.config: \"$PWD/elk/logstash-7.10.0/config/logstash-sample.conf\"" "elk/logstash-7.10.0/config/pipelines.yml" || echo "  path.config: \"$PWD/elk/logstash-7.10.0/config/logstash-sample.conf\"" >> elk/logstash-7.10.0/config/pipelines.yml
#grep -q "pipeline.workers: 1" "elk/logstash-7.10.0/config/pipelines.yml" || echo "pipeline.workers: 1" >> elk/logstash-7.10.0/config/pipelines.yml

cd elk/logstash-7.10.0/ && bin/logstash -f config/logstash-sample.conf





