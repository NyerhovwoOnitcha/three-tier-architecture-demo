# cluster 1 allowing traffic for NodePort range for ArgoCD
resource "aws_security_group" "eks_node_sg_cluster1" {
  name        = "cluster1-eks-node-sg"
  description = "Security group for EKS nodes in cluster1"
  vpc_id      = module.vpc["cluster1"].vpc_id

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cluster1-eks-node-sg"
  }
}

# cluster 2 and 3 using ingress

resource "aws_security_group" "eks_node_sg_cluster2" {
  name        = "cluster2-eks-node-sg"
  description = "Security group for EKS nodes in cluster2"
  vpc_id      = module.vpc["cluster2"].vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cluster2-eks-node-sg"
  }
}


resource "aws_security_group" "eks_node_sg_cluster3" {
  name        = "cluster3-eks-node-sg"
  description = "Security group for EKS nodes in cluster3"
  vpc_id      = module.vpc["cluster3"].vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cluster3-eks-node-sg"
  }
}


