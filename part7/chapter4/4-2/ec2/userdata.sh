#!/bin/bash

echo "
#### install cloudwatch-agent ####
...
"
sudo yum install amazon-cloudwatch-agent -y
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
        "metrics_collection_interval": 60,
        "run_as_user": "root"
        "region": "ap-northeast-2",
        "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log",
        "debug": false
  },
  "metrics": {
    "namespace": "CWAgent",
    "metrics_collected": {
       "processes": {
        "measurement": [
          "running",
          "sleeping",
          "dead"
        ]
      },
      "cpu": {
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
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ],
        "totalcpu": true
      },
      "disk": {
        "measurement": [
          "inodes_free",
          "used_percent",
          "used",
          "total"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "diskio": {
        "measurement": [
          "io_time",
          "write_bytes",
          "read_bytes",
          "writes",
          "reads"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent",
          "mem_total",
          "mem_used",
          "mem_cached",
          "mem_free",
          "mem_inactive"
        ],
        "metrics_collection_interval": 10
      },
      "netstat": {
        "measurement": [
          "tcp_established",
          "tcp_time_wait"
        ],
        "metrics_collection_interval": 60
      },
      "swap": {
        "measurement": [
          "swap_used_percent"
        ],
        "metrics_collection_interval": 60
      }
    },
    "append_dimensions": {
      "ImageId": "${aws:ImageId}",
      "InstanceId": "${aws:InstanceId}",
      "InstanceType": "${aws:InstanceType}",
      "AutoScalingGroupName": "${aws:AutoScalingGroupName}"
    },
    "aggregation_dimensions": [
      [
        "ImageId"
      ],
      [
        "InstanceId",
        "InstanceType"
      ],
      [
        "d1"
      ],
      []
    ],
    "force_flush_interval": 30
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
          }
        ]
      }
    },
    "log_stream_name": "ec2_log_stream",
    "force_flush_interval": 15
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