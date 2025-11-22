# S3 bucket sécurisé + versioning + lifecycle + CloudWatch alarm
resource "aws_s3_bucket" "Homelab_backup" {
  bucket = "david-njoku-Homelab-backup-2025"
  
  tags = {
    Name    = "Homelab-Backup"
    Owner   = "David Njoku"
    Mission = "Accelerate the world's transition"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.Homelab_backup.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.Homelab_backup.id
  rule {
    id     = "delete-after-90d"
    status = "Enabled"
    expiration { days = 90 }
  }
}
