# Infrastructure as Code - Terraform Modules

This repository contains reusable Terraform modules for managing cloud infrastructure.

## Repository Structure

```
infra-as-code/
├── google/                    # Google Cloud Platform modules
│   └── cloudshell/           # Cloud Shell API enablement
└── modules/                  # Generic modules
    └── gh-repo/              # GitHub repository management
```

## Modules

### Google Cloud Platform

#### Cloud Shell (`google/cloudshell`)

Enables and configures Google Cloud Shell for GCP projects.

**Usage:**
```hcl
module "cloudshell" {
  source = "git::https://github.com/raksiv/infra-as-code.git//google/cloudshell?ref=1.46.0"

  project_id = "my-gcp-project"
  region     = "us-central1"
}
```

[Module Documentation](./google/cloudshell/README.md)

### GitHub Management

#### GitHub Repository (`modules/gh-repo`)

Creates and manages GitHub repositories with team/user access controls.

**Usage:**
```hcl
module "github_repo" {
  source = "git::https://github.com/raksiv/infra-as-code.git//modules/gh-repo?ref=2.6.0"

  name        = "my-repo"
  description = "My awesome repository"
  visibility  = "private"

  admins  = ["your-admin-team"]
  writers = ["your-dev-team"]

  topics = ["terraform", "iac"]
}
```

[Module Documentation](./modules/gh-repo/README.md)

## Usage with Terragrunt

This repository is designed to work seamlessly with Terragrunt. See the [terragrunt-sample](https://github.com/raksiv/terragrunt-sample) repository for complete examples.

### Module Versioning

This repository uses Git tags for versioning. Pin your modules to specific versions:

```hcl
# Specific version
source = "git::https://github.com/raksiv/infra-as-code.git//google/cloudshell?ref=1.46.0"

# Latest from main branch (not recommended for production)
source = "git::https://github.com/raksiv/infra-as-code.git//google/cloudshell?ref=main"
```

## Authentication

### HTTPS with Token

```bash
export TF_GITHUB_TOKEN="ghp_your_token_here"
source = "git::https://${TF_GITHUB_TOKEN}@github.com/raksiv/infra-as-code.git//module-path?ref=version"
```

### SSH

```bash
source = "git@github.com:raksiv/infra-as-code.git//module-path?ref=version"
```

Ensure your SSH key is configured:
```bash
ssh-add ~/.ssh/id_rsa
ssh -T git@github.com  # Test connection
```

## Module Development

### Adding a New Module

1. Create module directory under `google/` or `modules/`
2. Add standard Terraform files:
   - `main.tf` - Main resource definitions
   - `variables.tf` - Input variables
   - `outputs.tf` - Output values
   - `versions.tf` - Provider version constraints
   - `README.md` - Module documentation

3. Test the module locally
4. Create a git tag for versioning
5. Update this README

### Module Standards

All modules should follow these conventions:

- Use semantic versioning for tags (e.g., `1.0.0`, `2.1.5`)
- Include comprehensive documentation in module README
- Define clear input variables with descriptions
- Provide useful outputs
- Specify provider version constraints
- Include usage examples

## Testing Modules Locally

Test modules before committing:

```bash
# Navigate to module directory
cd google/cloudshell

# Initialize Terraform
terraform init

# Validate syntax
terraform validate

# Format code
terraform fmt -recursive
```

## Versioning Strategy

- **Major version** (`X.0.0`): Breaking changes to module interface
- **Minor version** (`1.X.0`): New features, backwards compatible
- **Patch version** (`1.0.X`): Bug fixes, backwards compatible

### Current Versions

- Cloud Shell: `1.46.0`
- GitHub Repo: `2.6.0`

## Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Update documentation
5. Create pull request
6. Tag with appropriate version after merge

## Requirements

- Terraform >= 1.0
- Appropriate provider credentials:
  - Google Cloud: `gcloud auth application-default login`
  - GitHub: Personal access token or SSH key

## License

MIT License - See LICENSE file for details

## Support

For issues or questions:
- Open an issue in this repository
- See related [terragrunt-sample](https://github.com/raksiv/terragrunt-sample) repository
