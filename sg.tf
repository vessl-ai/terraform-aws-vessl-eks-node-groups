resource "aws_security_group" "allow_node_ports" {
  name   = "${var.cluster_name}-allow-node-ports"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-allow-node-ports"
  })
}

