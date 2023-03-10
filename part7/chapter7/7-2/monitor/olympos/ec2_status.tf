module "ec2_status" {
  source = "../_modules/datadog_monitor/"

  monitor_type = "metric alert"
  query        = "avg(last_1m):sum:aws.ec2.status_check_failed{name:${local.service_name}}  by {stack,host} > 0"

  monitor_name = "[${local.project}] ${local.service_name} - ec2 status check failed"

  #Notification message
  message = <<EOF
>ec2 status check failed for last 1m, please check {{host.stack}} : {{host.name}} ({{host.ip}}) ({{host.instance-id}})
@slack-DevOps_Study-study
EOF

  #RE-Notification message
  escalation_message = "EC2 status check failed for last 1m, please check {{host.name}} ({{host.ip}}) ({{host.instance-id}})"

  renotify_interval = 10

  thresholds = {
    ok       = 0
    critical = 0
  }

  datadog_monitor_tags = [local.project, local.service_name, "ec2_status", "terraform"]

}
