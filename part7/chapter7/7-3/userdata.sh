#!/bin/bash

sudo yum update -y
sudo yum install -y java-17-amazon-corretto git docker
sudo systemctl start docker

curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose 
chmod 755 /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

git clone https://github.com/YoungJinJung/devops-lesson.git /opt/devops-lesson
git clone https://github.com/YoungJinJung/olympos.git /opt/olympos