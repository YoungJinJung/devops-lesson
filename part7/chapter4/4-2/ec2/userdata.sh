#!/bin/bash

sudo yum update -y

echo "
#### install cloudwatch-agent ####
...
"
sudo yum install amazon-cloudwatch-agent -y
sudo amazon-linux-extras install nginx1 -y 
sudo systemctl enable nginx
sudo systemctl start nginx

echo "
Success!
"

echo "
#### Create amazon-cloudwatch-agent.json ####
...
"
sudo touch /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo bash -c 'cat << EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
    "agent": {
    "metrics_collection_interval": 10,
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
    },
    "metrics": {
    "namespace": "MyCustomNamespace",
    "metrics_collected": {
        "cpu": {
        "resources": [
            "*"
        ],
        "measurement": [
            "cpu_usage_idle",
            "cpu_usage_iowait",
            "cpu_usage_user",
            "cpu_usage_system",
            "cpu_time_idle",
            "cpu_time_iowait",
            "cpu_time_user",
            "cpu_time_system"
        ],
        "totalcpu": true,
        "metrics_collection_interval": 10
        },
        "disk": {
        "resources": [
            "/",
            "/tmp"
        ],
        "measurement": [
          "inodes_free",
          "used_percent",
          "used",
          "total"
        ],
            "ignore_file_system_types": [
            "sysfs", "devtmpfs"
        ],
        "metrics_collection_interval": 60
        },
        "diskio": {
        "resources": [
            "*"
        ],
        "measurement": [
            "reads",
            "writes",
            "read_time",
            "write_time",
            "io_time"
        ],
        "metrics_collection_interval": 60
        },
        "swap": {
        "measurement": [
            "swap_used",
            "swap_free",
            "swap_used_percent"
        ]
        },
        "mem": {
        "measurement": [
            "mem_used",
            "mem_cached",
            "mem_total"
        ],
        "metrics_collection_interval": 1
        },
        "net": {
        "resources": [
            "eth0"
        ],
        "measurement": [
            "bytes_sent",
            "bytes_recv",
            "drop_in",
            "drop_out"
        ]
        },
        "netstat": {
        "measurement": [
            "tcp_established",
            "tcp_syn_sent",
            "tcp_close"
        ],
        "metrics_collection_interval": 60
        },
        "processes": {
        "measurement": [
            "running",
            "sleeping",
            "dead"
        ]
        }
    },
    "force_flush_interval" : 30
    },
    "logs": {
    "logs_collected": {
        "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/aws/ec2/var/log/messages",
            "log_stream_name": "{instance_id}",
            "auto_removal": false
          },
          {
            "file_path": "/var/log/secure",
            "log_group_name": "/aws/ec2/var/log/secure",
            "log_stream_name": "{instance_id}",
            "auto_removal": false
          },
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/aws/ec2/var/log/nginx/access",
            "log_stream_name": "{instance_id}",
            "auto_removal": false
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/aws/ec2/var/log/nginx/error",
            "log_stream_name": "{instance_id}",
            "auto_removal": false
          }
        ]
        }
    },
    "log_stream_name": "my_log_stream_name",
    "force_flush_interval" : 15
    }
}
EOF'


echo "
Success!
"

echo "
#### Start cloudwatch-agent ####
...
"
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo systemctl status amazon-cloudwatch-agent
echo "
Success!
"
