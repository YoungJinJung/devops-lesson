resource "aws_dynamodb_table" "datadog_metrics" {
  name         = "datadog-metrics"
  hash_key     = "MetricName"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "MetricName"
    type = "S"
  }

  attribute {
    name = "MetricUrl"
    type = "S"
  }

  attribute {
    name = "TimeStamp"
    type = "N"
  }

  global_secondary_index {
    name            = "MetricUrlIndex"
    hash_key        = "MetricUrl"
    range_key       = "TimeStamp"
    projection_type = "ALL"
  }
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}
