 locals {
      security_groups = {
        cluster1 = aws_security_group.eks_node_sg_cluster1.id
        cluster2 = aws_security_group.eks_node_sg_cluster2.id
        cluster3 = aws_security_group.eks_node_sg_cluster3.id
      }
    }