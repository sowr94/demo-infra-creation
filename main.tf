resource "aws_s3_bucket" "this" {
  bucket              = var.bucket_name
  object_lock_enabled = var.enable_object_lock

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.server_side_encryption == "SSE-KMS" ? "aws:kms" : "AES256"
      kms_master_key_id = var.server_side_encryption == "SSE-KMS" ? var.kms_key_id : null
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_logging" "this" {
  count = var.enable_access_logging ? 1 : 0

  bucket        = aws_s3_bucket.this.id
  target_bucket = var.logging_target_bucket
  target_prefix = var.logging_prefix
}

resource "aws_s3_bucket_object_lock_configuration" "this" {
  count = var.enable_object_lock ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {
    default_retention {
      mode  = var.object_lock_mode
      days  = var.object_lock_retention_days
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = var.lifecycle_transition_after_days != null || var.lifecycle_expire_after_days != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "default-lifecycle"
    status = "Enabled"

    dynamic "transition" {
      for_each = var.lifecycle_transition_after_days == null ? [] : [var.lifecycle_transition_after_days]

      content {
        days          = transition.value
        storage_class = "STANDARD_IA"
      }
    }

    dynamic "expiration" {
      for_each = var.lifecycle_expire_after_days == null ? [] : [var.lifecycle_expire_after_days]

      content {
        days = expiration.value
      }
    }
  }
}