locals {
  iam_resource_name        = "${var.cluster_name}-node-group"
  iam_role_policy_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
}

# --------------------
# Node group IAM Roles
# --------------------
resource "aws_iam_role" "node_group" {
  name        = local.iam_resource_name
  path        = "/"
  description = "[${var.cluster_name}] IAM role for EKS cluster node group"

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
  force_detach_policies = true

  tags = var.tags
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "node_group" {
  for_each = { for k, v in toset(compact([
    "${local.iam_role_policy_prefix}/AmazonEKSWorkerNodePolicy",
    "${local.iam_role_policy_prefix}/AmazonEC2ContainerRegistryReadOnly",
    "${local.iam_role_policy_prefix}/AmazonEKS_CNI_Policy",
  ])) : k => v }

  policy_arn = each.value
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_instance_profile" "node_group" {
  role = aws_iam_role.node_group.name
  name = local.iam_resource_name
  path = "/"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
