module "cpu_usage" {
  source = "../_modules/datadog_monitor/"

  monitor_type = "metric alert"
  query        = "avg(last_5m):avg:aws.ec2.cpuutilization{name:${local.service_name}} by {host,name} > 80"


  monitor_name = "[${local.project}] ${local.service_name} - CPU usage is high"

  #Notification message
  message = <<EOF
>CPU usage is high for last 5m, please check {{host.env}} : {{host.name}} ({{host.ip}}) ({{host.instance-id}})
@slack-DevOps_Study-study
EOF

  #RE-Notification message
  escalation_message = "CPU usage is too high for last 5m, please check {{host.name}} ({{host.ip}}) ({{host.instance-id}})"

  renotify_interval = 10

  thresholds = {
    ok                = 50
    critical          = 80
    warning           = 60
    critical_recovery = 50
    warning_recovery  = 50
  }

  new_host_delay = 600

  datadog_monitor_tags = [local.project, local.service_name, "cpu_usage", "terraform"]

}
