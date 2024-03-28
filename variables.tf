variable "cluster_name" {
  description = "The name of the EKS cluster (module.eks.cluster_name)"
}
variable "cluster_version" {
  description = "The Kubernetes version of the EKS cluster (module.eks.cluster_version)"
}
variable "cluster_endpoint" {
  description = "The endpoint of the EKS cluster (module.eks.cluster_endpoint)"
}
variable "cluster_certificate_authority_data" {
  description = "The certificate-authority-data for the EKS cluster (module.eks.cluster_certificate_authority_data)"
}
variable "cluster_service_cidr" {}
variable "security_group_ids" {
  description = "The security groups which the nodes will belong to"
}
variable "vpc_id" {}

variable "key_name" {
  description = "The name of the key pair to use for SSH access to the nodes"
  default     = null
}

variable "manager_node_count" {
  default = 2
}
variable "manager_node_ami_id" {
  default = ""
}
variable "manager_node_instance_type" {
  default = "m7i.large"
}
variable "manager_node_disk_size" {
  default = 500
}
variable "manager_node_subnet_ids" {
  default = []
}

variable "self_managed_node_groups_data" {
  default = {}
}

variable "iam_instance_profile_arn" {}
variable "iam_role_arn" {}
variable "tags" {
  default = {}
}
