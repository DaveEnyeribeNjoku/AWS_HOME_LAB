# S3 bucket sécurisé + versioning + lifecycle
resource "aws_s3_bucket" "homelab_backup" {
  bucket = "david-njoku-homelab-backup-2025"

  tags = {
    Name  = "homelab-backup"
    Owner = "David Njoku"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.homelab_backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.homelab_backup.id

  rule {
    id     = "delete-after-90d"
    status = "Enabled"
    expiration {
      days = 90
    }
  }
}
