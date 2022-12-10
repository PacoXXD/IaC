resource "aws_cloudwatch_log_group" "slowquery" {
  name = "/aws/rds/instance/${var.rds_id}/slowquery"
}

resource "aws_cloudwatch_log_metric_filter" "slowquery" {
  name           = "BackendSlowQueryFilter"
  pattern        = ""
  log_group_name = "${aws_cloudwatch_log_group.slowquery.name}"

  metric_transformation {
    name      = "BackendSlowQuery"
    namespace = "RDSMetrics"
    value     = "1"
  }
}

resource "aws_sns_topic" "slowquery_topic" {
  name = "backend-slowquery-topic"
}

resource "aws_sns_topic_subscription" "sms_ryan" {
  topic_arn = "${aws_sns_topic.slowquery_topic.arn}"
  protocol  = "sms"
  endpoint  = "${var.sms_ryan}"
}

resource "aws_sns_topic_subscription" "sms_potato" {
  topic_arn = "${aws_sns_topic.slowquery_topic.arn}"
  protocol  = "sms"
  endpoint  = "${var.sms_potato}"
}

resource "aws_cloudwatch_metric_alarm" "slowquery" {
  alarm_name                = "backend-slowquery-alarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "BackendSlowQuery"
  namespace                 = "RDSMetrics"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "0"
  treat_missing_data        = "missing"
  insufficient_data_actions = []

  alarm_actions = ["arn:aws:sns:eu-west-1:726332586568:backend-slowquery-topic"]
}
