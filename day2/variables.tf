variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "bucket_prefix" {
  description = "The unique name for the bucket"
  type        = string
}

variable "github_repo_url" {
  description = "The GitHub URL for the repository"
  type        = string
}

variable "github_master_branch_url" {
  description = "The GitHub master branch"
  type        = string
}
