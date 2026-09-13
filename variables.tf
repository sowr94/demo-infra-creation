variable "bucket_name" {
  description = "Globally unique S3 bucket name."
  type        = string
  default     = "s3-demo-bucket-qqaa"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must contain 3-63 lowercase letters, numbers, dots, or hyphens and start and end with a letter or number."
  }
}

variable "aws_region" {
  description = "AWS region in which to create the bucket."
  type        = string
  default     = "us-east-1"
}

variable "block_public_access" {
  description = "Enable all four S3 public access block settings."
  type        = bool
  default     = true
}

variable "object_ownership" {
  description = "S3 object ownership control."
  type        = string
  default     = "BucketOwnerEnforced"

  validation {
    condition     = contains(["BucketOwnerEnforced", "BucketOwnerPreferred", "ObjectWriter"], var.object_ownership)
    error_message = "object_ownership must be BucketOwnerEnforced, BucketOwnerPreferred, or ObjectWriter."
  }
}

variable "enable_versioning" {
  description = "Enable S3 versioning."
  type        = bool
  default     = true
}

variable "server_side_encryption" {
  description = "Default encryption type for objects."
  type        = string
  default     = "SSE-S3"

  validation {
    condition     = contains(["SSE-S3", "SSE-KMS"], var.server_side_encryption)
    error_message = "server_side_encryption must be SSE-S3 or SSE-KMS."
  }
}

variable "kms_key_id" {
  description = "KMS key ARN or ID used when SSE-KMS is selected."
  type        = string
  default     = ""

  validation {
    condition     = var.server_side_encryption == "SSE-S3" || trimspace(var.kms_key_id) != ""
    error_message = "kms_key_id is required when server_side_encryption is SSE-KMS."
  }
}

variable "enable_access_logging" {
  description = "Send S3 access logs to a target bucket."
  type        = bool
  default     = false
}

variable "logging_target_bucket" {
  description = "Existing bucket that receives S3 access logs."
  type        = string
  default     = ""

  validation {
    condition     = var.enable_access_logging == false || trimspace(var.logging_target_bucket) != ""
    error_message = "logging_target_bucket is required when enable_access_logging is true."
  }
}

variable "logging_prefix" {
  description = "Optional prefix for S3 access logs."
  type        = string
  default     = ""
}

variable "enable_object_lock" {
  description = "Enable S3 Object Lock at bucket creation time."
  type        = bool
  default     = false
}

variable "object_lock_mode" {
  description = "Default Object Lock retention mode."
  type        = string
  default     = ""

  validation {
    condition     = var.enable_object_lock == false || contains(["GOVERNANCE", "COMPLIANCE"], var.object_lock_mode)
    error_message = "object_lock_mode must be GOVERNANCE or COMPLIANCE when Object Lock is enabled."
  }
}

variable "object_lock_retention_days" {
  description = "Default Object Lock retention period in days."
  type        = number
  default     = 30

  validation {
    condition     = var.object_lock_retention_days > 0
    error_message = "object_lock_retention_days must be greater than zero."
  }
}

variable "lifecycle_transition_after_days" {
  description = "Move objects to STANDARD_IA after this many days; null disables the transition."
  type        = number
  default     = 30

  validation {
    condition     = var.lifecycle_transition_after_days == null || var.lifecycle_transition_after_days > 0
    error_message = "lifecycle_transition_after_days must be greater than zero when set."
  }
}

variable "lifecycle_expire_after_days" {
  description = "Expire objects after this many days; null disables expiration."
  type        = number
  default     = null

  validation {
    condition     = var.lifecycle_expire_after_days == null || var.lifecycle_expire_after_days > 0
    error_message = "lifecycle_expire_after_days must be greater than zero when set."
  }
}

variable "tags" {
  description = "Tags applied to the bucket."
  type        = map(string)
  default = {
    Environment = "dev"
    Owner       = "Sowmya"
  }

  validation {
    condition     = length(var.tags) <= 50
    error_message = "S3 supports a maximum of 50 user-defined tags."
  }
}