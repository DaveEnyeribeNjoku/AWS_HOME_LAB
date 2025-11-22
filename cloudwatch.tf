# Alarme CloudWatch – Taille du bucket S3 trop importante (simulation prod)
resource "aws_cloudwatch_metric_alarm" "s3_high_size_alert" {
  alarm_name          = "homelab-s3-high-size-alert-david-njoku"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = 86400           # 24 heures
  statistic           = "Average"
  threshold           = 1000000000      # 1 GB (ajustable selon besoin)
  alarm_description   = "Alerte déclenchée quand le bucket dépasse 1 GB – David Njoku Cloud Homelab"

  dimensions = {
    BucketName  = aws_s3_bucket.backup_bucket.bucket        # ← change le nom du bucket ici
    StorageType = "StandardStorage"
  }

  alarm_actions     = []   # tu peux ajouter un SNS topic plus tard
  ok_actions        = []
  treat_missing_data = "missing"

  tags = {
    Name  = "homelab-s3-size-alert"
    Owner = "David Njoku"
  }
}
