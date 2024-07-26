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
  type = map(object({
    ami_id = string
    instance_type = string

    node_template_labels = optional(map(string), {})
    node_template_resources = optional(map(string), {})
    node_template_taints = optional(list(object({
      key = string
      value = string
      effect = string

      // `is_transient` denotes whether this taint will be automatically removed after some time.
      // Examples of "transient" taints include:
      //   - initialization flags ("I am not ready, please initialize me")
      // Examples of "non-transient" (i.e. "persistent") taints include:
      //   - GPU flags in some configurations
      //       ("I have a costly resource, so don't schedule pods to me
      //         unless they specifically tolerated me")
      // This is required by cluster-autoscaler, because it simulates pod scheduling with hypothetical nodes,
      // and therefore it has to know whether the taint will eventually go away or not.
      is_transient = optional(bool, false)
    })), [])

    min_size = number
    max_size = number
    desired_size = number
  }))
  default = {}
}

variable "iam_instance_profile_arn" {}
variable "iam_role_arn" {}
variable "tags" {
  default = {}
}
