#!/bin/bash

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

/bin/su -c "cd $PWD/elk/kibana-7.8.0-linux-x86_64/bin/ && ./kibana -q" - elk

