#!/bin/bash

sudo yum update -y
sudo yum install -y java-17-amazon-corretto git docker
sudo systemctl start docker

curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose 
chmod 755 /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

DD_API_KEY=<DATADOG_API_KEY> DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script_agent7.sh)"

cd /opt
mkdir datadog-agent
wget -O /opt/datadog-agent/dd-java-agent.jar https://dtdg.co/latest-java-tracer

git clone https://github.com/YoungJinJung/devops-lesson.git /opt/devops-lesson
git clone https://github.com/YoungJinJung/olympos.git /opt/olympos