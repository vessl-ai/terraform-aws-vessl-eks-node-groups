data "aws_region" "current" {}

# ----------------------------
# EKS self-managed node groups
# ----------------------------
module "worker_node_groups" {
  source  = "terraform-aws-modules/eks/aws//modules/self-managed-node-group"
  version = "19.15.3"

  for_each = var.self_managed_node_groups_data

  name                 = each.key
  iam_role_name        = each.key
  launch_template_name = each.key

  use_name_prefix                 = false
  iam_role_use_name_prefix        = false
  launch_template_use_name_prefix = false

  ami_id        = each.value["ami_id"]
  instance_type = each.value["instance_type"]
  bootstrap_extra_args = join(" ", [
    "--kubelet-extra-args",
    "'",
    length(try(each.value["node_template_labels"], {})) == 0 ? "--node-labels=v1.k8s.vessl.ai/managed=true" : "--node-labels=v1.k8s.vessl.ai/managed=true,${join(",", [for k, v in each.value["node_template_labels"] : "${k}=${v}"])}",
    length(try(each.value["taints"], [])) == 0 ? "" : "--register-with-taints=${join(",", each.value["taints"])}",
    "'",
  ])

  cluster_name        = var.cluster_name
  cluster_version     = var.cluster_version
  cluster_endpoint    = var.cluster_endpoint
  cluster_auth_base64 = var.cluster_certificate_authority_data

  subnet_ids = each.value["subnet_ids"]

  create_iam_instance_profile = false
  iam_instance_profile_arn    = var.iam_instance_profile_arn

  // The following variables are necessary if you decide to use the module outside of the parent EKS module context.
  // Without it, the security groups of the nodes are empty and thus won't join the cluster.
  vpc_security_group_ids = var.security_group_ids

  min_size     = each.value["min_size"]
  max_size     = each.value["max_size"]
  desired_size = try(each.value["desired_size"], 0)

  # Pre-propagate necessary k8s node labels to autoscaling group tags in order to implement scale-to-zero
  # https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#how-can-i-scale-a-node-group-to-0
  autoscaling_group_tags = merge(
    {
      for k, v in try(each.value["node_template_labels"], {}) : "k8s.io/cluster-autoscaler/node-template/label/${k}" => v
    },
    {
      for k, v in try(each.value["node_template_resources"], {}) : "k8s.io/cluster-autoscaler/node-template/resources/${k}" => v
    },
    {
      "k8s.io/cluster-autoscaler/enabled" : true,
      "k8s.io/cluster-autoscaler/${var.cluster_name}" : "owned",
      "k8s.io/cluster-autoscaler/node-template/label/topology.kubernetes.io/region"    = data.aws_region.current.name
      "k8s.io/cluster-autoscaler/node-template/label/topology.kubernetes.io/zone"      = each.value["availability_zone"]
      "k8s.io/cluster-autoscaler/node-template/label/node.kubernetes.io/instance-type" = each.value["instance_type"]
    },
  )

  block_device_mappings = {
    xvda = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = each.value["disk_size"]
        volume_type           = "gp3"
        iops                  = 3000 # Baseline
        throughput            = 125  # Baseline
        delete_on_termination = true
      }
    }
  }

  instance_market_options = try(each.value["instance_market_options"], {})

  tags = merge(var.tags, {
    Name = each.key
  })
}

module "manager_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/self-managed-node-group"
  version = "19.15.3"

  name                 = "${var.cluster_name}-manager-node-group"
  iam_role_name        = "${var.cluster_name}-manager-node-group"
  launch_template_name = "${var.cluster_name}-manager-node-group"

  use_name_prefix                 = false
  iam_role_use_name_prefix        = false
  launch_template_use_name_prefix = false

  ami_id        = var.manager_node_ami_id
  instance_type = var.manager_node_instance_type
  bootstrap_extra_args = join(" ", [
    "--kubelet-extra-args",
    "'",
    "--node-labels=v1.k8s.vessl.ai/managed=true,v1.k8s.vessl.ai/dedicated=manager",
    "--register-with-taints=v1.k8s.vessl.ai/dedicated=manager:NoSchedule",
    "'",
  ])

  cluster_name        = var.cluster_name
  cluster_version     = var.cluster_version
  cluster_endpoint    = var.cluster_endpoint
  cluster_auth_base64 = var.cluster_certificate_authority_data

  subnet_ids = var.manager_node_subnet_ids

  create_iam_instance_profile = false
  iam_instance_profile_arn    = var.iam_instance_profile_arn

  // The following variables are necessary if you decide to use the module outside of the parent EKS module context.
  // Without it, the security groups of the nodes are empty and thus won't join the cluster.
  vpc_security_group_ids = concat(var.security_group_ids, [aws_security_group.allow_node_ports.id])

  min_size     = var.manager_node_count
  max_size     = var.manager_node_count
  desired_size = var.manager_node_count

  block_device_mappings = {
    xvda = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = var.manager_node_disk_size
        volume_type           = "gp3"
        iops                  = 3000 # Baseline
        throughput            = 125  # Baseline
        delete_on_termination = true
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-manager-node-group"
  })
}
