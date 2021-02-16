#!/bin/bash

wget -nc https://artifacts.elastic.co/downloads/logstash/logstash-7.10.0-linux-x86_64.tar.gz
tar -xzf logstash-7.10.0-linux-x86_64.tar.gz -C elk

cp elk/logstash-sample.conf elk/logstash-7.10.0/config/logstash-sample.conf

grep -q "\- pipeline.id: testlogstash" "elk/logstash-7.10.0/config/pipelines.yml" || echo "- pipeline.id: test" >> elk/logstash-7.10.0/config/pipelines.yml
grep -q "path.config: \"$PWD/elk/logstash-7.10.0/config/logstash-sample.conf\"" "elk/logstash-7.10.0/config/pipelines.yml" || echo "path.config: \"$PWD/elk/logstash-7.10.0/config/logstash-sample.conf\"" >> elk/logstash-7.10.0/config/pipelines.yml
#grep -q "pipeline.workers: 1" "elk/logstash-7.10.0/config/pipelines.yml" || echo "pipeline.workers: 1" >> elk/logstash-7.10.0/config/pipelines.yml

cd elk/logstash-7.10.0/ && bin/logstash -f config/logstash-sample.conf


