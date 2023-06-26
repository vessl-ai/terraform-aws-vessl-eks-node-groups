variable "cluster_name" {}
variable "cluster_version" {}
variable "cluster_endpoint" {}
variable "cluster_certificate_authority_data" {}
variable "security_group_ids" {}

variable "manager_node_ami_id" {}
variable "manager_node_instance_type" {}
variable "manager_node_disk_size" {}
variable "manager_node_subnet_ids" {}

variable "self_managed_node_groups_data" {
  default = {}
}

variable "iam_instance_profile_arn" {}
variable "tags" {}
