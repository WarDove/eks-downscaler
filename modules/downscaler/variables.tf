variable "project_name" {
  default = "eks-downscaler"
}

variable "lambda_source" {}
variable "scale_in_schedule" {}
variable "scale_out_schedule" {}
variable "eks_cluster_name" {}
variable "namespaces" {}

