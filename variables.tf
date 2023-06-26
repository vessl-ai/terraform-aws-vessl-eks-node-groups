variable "cluster_name" {}
variable "cluster_version" {}
variable "cluster_endpoint" {}
variable "cluster_certificate_authority_data" {}
variable "tags" {}
variable "iam_instance_profile_arn" {}
variable "security_group_ids" {}

variable "self_managed_node_groups_data" {
  default = {}
}

