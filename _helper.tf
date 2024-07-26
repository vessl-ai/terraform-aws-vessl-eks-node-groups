// _helper.tf: Helpers that convert variables into useful values, which can be used in `main.tf`.

locals {
  initial_node_taints_in_kubelet_arg_form = {
    for name, ng in var.self_managed_node_groups_data: name => [
      for taint in ng.node_template_taints:
        "${taint.key}=${taint.value}:${taint.effect}"
    ]
  }

  persistent_node_taints_in_cluster_autoscaler_asg_tag_form = {
    for name, ng in var.self_managed_node_groups_data: name => {
      for taint in ng.node_template_taints:
      "k8s.io/cluster-autoscaler/node-template/taint/${taint.key}" => taint.value
      if !taint.is_transient
    }
  }
}