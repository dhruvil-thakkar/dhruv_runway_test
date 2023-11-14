resource "aws_cloudwatch_metric_alarm" "http_80_monitoring" {
  alarm_name          = "http-80-monitoring"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "StatucCheckFailed"
  namespace           = "AWS/EC2"
  period              = 180  # 5 minutes
  statistic           = "Average"
  threshold           = 2  # Replace with your desired threshold

  dimensions = {
    AutoscalingGroupName = aws_autoscaling_group.example.name
  }

  alarm_description = "Alarm if NetworkOut on port 80 exceeds the threshold for 2 consecutive periods."

 # actions_enabled = true
 alarm_actions = []
 # alarm_actions = [aws_autoscaling_group.example.arn]
}
