# GitHub Repository Management Module
# This module creates and configures GitHub repositories with team access

resource "github_repository" "repo" {
  name        = var.name
  description = var.description
  visibility  = var.visibility

  has_issues      = true
  has_discussions = false
  has_projects    = true
  has_wiki        = true

  allow_merge_commit = true
  allow_squash_merge = true
  allow_rebase_merge = true

  delete_branch_on_merge = true
  auto_init              = true

  dynamic "topics" {
    for_each = length(var.topics) > 0 ? [1] : []
    content {
      topics = var.topics
    }
  }
}

# Add admin teams/users
resource "github_repository_collaborators" "collaborators" {
  repository = github_repository.repo.name

  dynamic "team" {
    for_each = var.admin_teams
    content {
      team_id    = team.value
      permission = "admin"
    }
  }

  dynamic "user" {
    for_each = var.admin_users
    content {
      username   = user.value
      permission = "admin"
    }
  }

  dynamic "team" {
    for_each = var.writer_teams
    content {
      team_id    = team.value
      permission = "push"
    }
  }

  dynamic "user" {
    for_each = var.writer_users
    content {
      username   = user.value
      permission = "push"
    }
  }
}

# Branch protection for main branch
resource "github_branch_protection" "main" {
  count = var.enable_branch_protection ? 1 : 0

  repository_id = github_repository.repo.node_id
  pattern       = "main"

  enforce_admins = false

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = false
    required_approving_review_count = 1
  }
}
