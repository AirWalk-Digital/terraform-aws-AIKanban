variable "project" {
  description = "Project name"
  type        = string
  default     = "aikanban"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "Default region for launch of resources"
  type        = string
  default     = "eu-west-2"
}
