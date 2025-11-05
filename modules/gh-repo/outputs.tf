output "repository_name" {
  description = "The name of the created repository"
  value       = github_repository.repo.name
}

output "repository_full_name" {
  description = "The full name of the repository (owner/repo)"
  value       = github_repository.repo.full_name
}

output "repository_url" {
  description = "The URL of the repository"
  value       = github_repository.repo.html_url
}

output "repository_ssh_url" {
  description = "The SSH clone URL of the repository"
  value       = github_repository.repo.ssh_clone_url
}

output "repository_git_url" {
  description = "The Git clone URL of the repository"
  value       = github_repository.repo.git_clone_url
}

output "repository_node_id" {
  description = "The Node ID of the repository"
  value       = github_repository.repo.node_id
}
