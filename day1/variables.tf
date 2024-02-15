variable "region" {
  description = "The region where AWS resources will be created"
  type        = string
  default     = "eu-central-1"
}

variable "username" {
  description = "The username for the EC2 instances"
  type        = string
  default     = "ec2-user"
}