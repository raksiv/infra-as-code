# Terraform Modules

Reusable Terraform modules for GCP infrastructure.

## Modules

- **google/cloudshell** (v1.46.0) - Cloud Shell API
- **google/storage-bucket** (v1.47.0) - GCS buckets
- **google/cloud-run-service** (v1.48.0) - Cloud Run services
- **modules/gh-repo** (v2.6.0) - GitHub repos

## Usage

```hcl
module "bucket" {
  source = "git::https://github.com/raksiv/infra-as-code.git//google/storage-bucket?ref=1.47.0"

  project_id  = "my-project"
  bucket_name = "my-bucket"
  location    = "US"
}
```

See [terragrunt-sample](https://github.com/raksiv/terragrunt-sample) for complete examples.

## Versioning

Pin to tagged versions:

```hcl
?ref=1.47.0  # Specific version
?ref=main    # Latest (not recommended)
```
