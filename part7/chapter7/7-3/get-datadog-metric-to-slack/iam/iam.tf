# IAM Roles
resource "aws_iam_role" "lambda_datadog_metric_to_slack" {
  name = "lambda-datadog-metric-to-slack"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": [
                "lambda.amazonaws.com",
                "events.amazonaws.com"
            ]
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_datadog_metric_to_slack" {
  name = "lambda-datadog-metric-to-slack"
  role = aws_iam_role.lambda_datadog_metric_to_slack.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*",
            "Effect": "Allow",
            "Sid": "Logging"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:*"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "xray:PutTraceSegments",
                "xray:PutTelemetryRecords"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "AllowKMSAccess",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": [
                "<KMS_ARN>"
            ],
            "Effect": "Allow"
        },
        {
            "Sid": "AllowSsmParameterAccess",
            "Action": [
              "ssm:GetParameter",
              "ssm:GetParameters"
            ],
            "Effect": "Allow",
            "Resource": [
              "arn:aws:ssm:*:*:parameter/DATADOG_API_KEY",
              "arn:aws:ssm:*:*:parameter/DATADOG_APP_KEY",
              "arn:aws:ssm:*:*:parameter/DATADOGBOT_SLACK_TOKEN"
            ]
        },
        {
          "Sid": "AllowDynamoDBAccess",
          "Action": [
            "dynamodb:PutItem",
            "dynamodb:GetItem",
            "dynamodb:Scan"
            ],
          "Effect": "Allow",
          "Resource": [
            "arn:aws:dynamodb:ap-northeast-2:<account-id>:table/datadog-metrics"
          ]
        }
    ]
}
EOF
}

