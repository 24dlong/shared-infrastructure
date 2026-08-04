variable "aws_region" {
  description = "AWS region used for the bootstrap resources."
  type        = string
  default     = "us-east-2"
}

variable "name_prefix" {
  description = "Prefix used to name bootstrap resources."
  type        = string
  default     = "24dlong-shared-infrastructure-prod"
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default = {
    Project     = "24dlong-shared-infrastructure"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
