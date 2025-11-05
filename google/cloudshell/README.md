# Cloud Shell Terraform Module

This module enables and configures Google Cloud Shell for a GCP project.

## Features

- Enables Cloud Shell API
- Configurable project and region

## Usage

```hcl
module "cloudshell" {
  source = "git::https://github.com/raksiv/infra-as-code.git//google/cloudshell?ref=1.0.0"

  project_id = "my-gcp-project"
  region     = "us-central1"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| google | >= 5.0 |
| null | >= 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_id | The GCP project ID where Cloud Shell will be enabled | `string` | n/a | yes |
| region | The GCP region for Cloud Shell configuration | `string` | `"us-central1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| project_id | The GCP project ID where Cloud Shell is enabled |
| region | The region configured for Cloud Shell |
| cloudshell_api_enabled | Whether the Cloud Shell API is enabled |
