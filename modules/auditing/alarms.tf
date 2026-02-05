# 1) Root user activity
resource "aws_cloudwatch_log_metric_filter" "root_activity" {
  name           = "${var.project}-${var.env}-root-activity"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  pattern = "{ ($.userIdentity.type = \"Root\") && ($.userIdentity.invokedBy NOT EXISTS) }"

  metric_transformation {
    name      = "RootActivityCount"
    namespace = "${var.project}/${var.env}/Security"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_activity" {
  alarm_name          = "${var.project}-${var.env}-ALARM-RootActivity"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "RootActivityCount"
  namespace           = "${var.project}/${var.env}/Security"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  alarm_actions = [var.alerts_topic_arn]
}

# 2) CloudTrail stopped/updated/deleted
resource "aws_cloudwatch_log_metric_filter" "cloudtrail_changes" {
  name           = "${var.project}-${var.env}-cloudtrail-changes"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  pattern = "{ ($.eventSource = \"cloudtrail.amazonaws.com\") && (( $.eventName = \"StopLogging\") || ($.eventName = \"DeleteTrail\") || ($.eventName = \"UpdateTrail\") ) }"

  metric_transformation {
    name      = "CloudTrailChangeCount"
    namespace = "${var.project}/${var.env}/Security"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudtrail_changes" {
  alarm_name          = "${var.project}-${var.env}-ALARM-CloudTrailChanges"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CloudTrailChangeCount"
  namespace           = "${var.project}/${var.env}/Security"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  alarm_actions = [var.alerts_topic_arn]
}

# 3) Security Group changes
resource "aws_cloudwatch_log_metric_filter" "sg_changes" {
  name           = "${var.project}-${var.env}-sg-changes"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name

  pattern = "{ ($.eventSource = \"ec2.amazonaws.com\") && (( $.eventName = \"AuthorizeSecurityGroupIngress\") || ($.eventName = \"RevokeSecurityGroupIngress\") || ($.eventName = \"CreateSecurityGroup\") || ($.eventName = \"DeleteSecurityGroup\") ) }"

  metric_transformation {
    name      = "SecurityGroupChangeCount"
    namespace = "${var.project}/${var.env}/Security"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "sg_changes" {
  alarm_name          = "${var.project}-${var.env}-ALARM-SecurityGroupChanges"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "SecurityGroupChangeCount"
  namespace           = "${var.project}/${var.env}/Security"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  alarm_actions = [var.alerts_topic_arn]
}
