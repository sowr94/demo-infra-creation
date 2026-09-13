# S3 Bucket Infrastructure

This Terraform configuration creates a private, encrypted S3 bucket with versioning, optional access logging and Object Lock, lifecycle management, and tags.

## Usage

```powershell
terraform init
terraform plan
terraform apply
```

The default values mirror the S3 creation inputs used by the companion demo. Override them with a `terraform.tfvars` file or `-var` arguments. The bucket name must be globally unique.

`lifecycle_transition_after_days` defaults to 30 days and moves objects to `STANDARD_IA`. Set it and `lifecycle_expire_after_days` to `null` to disable lifecycle management.

Terraform validates required combinations such as KMS key selection, logging target configuration, and Object Lock retention mode before applying changes.