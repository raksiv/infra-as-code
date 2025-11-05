# GitHub Repository Terraform Module

This module creates and manages GitHub repositories with team/user access controls and branch protection.

## Features

- Create GitHub repositories with configurable settings
- Manage team and user access (admin and write permissions)
- Optional branch protection on main branch
- Support for repository topics and descriptions

## Usage

```hcl
module "github_repo" {
  source = "git::https://github.com/raksiv/infra-as-code.git//modules/gh-repo?ref=2.6.0"

  name        = "my-awesome-repo"
  description = "An awesome repository"
  visibility  = "private"

  admins = [
    "team:platform-admins",
    "user:octocat"
  ]

  writers = [
    "team:developers",
    "user:contributor"
  ]

  topics = ["terraform", "infrastructure"]

  enable_branch_protection = true
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| github | ~> 6.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the GitHub repository | `string` | n/a | yes |
| description | A description of the repository | `string` | `""` | no |
| visibility | The visibility of the repository (public, private, or internal) | `string` | `"private"` | no |
| repoType | The type of repository (for categorization) | `string` | `"other"` | no |
| topics | List of topics for the repository | `list(string)` | `[]` | no |
| admins | List of GitHub teams or users with admin access | `list(string)` | `[]` | no |
| writers | List of GitHub teams or users with write access | `list(string)` | `[]` | no |
| enable_branch_protection | Whether to enable branch protection on main branch | `bool` | `true` | no |

### Access Control Format

The `admins` and `writers` variables accept entries in the following formats:
- Teams: `"team:team-slug"` or `"org-team-name"` (without prefix)
- Users: `"user:username"` or just `"username"`

## Outputs

| Name | Description |
|------|-------------|
| repository_name | The name of the created repository |
| repository_full_name | The full name of the repository (owner/repo) |
| repository_url | The URL of the repository |
| repository_ssh_url | The SSH clone URL of the repository |
| repository_git_url | The Git clone URL of the repository |
| repository_node_id | The Node ID of the repository |

## Branch Protection

When `enable_branch_protection = true`, the following rules are applied to the `main` branch:
- Requires pull request reviews (1 approval)
- Dismisses stale reviews automatically
- Does not enforce for admins
