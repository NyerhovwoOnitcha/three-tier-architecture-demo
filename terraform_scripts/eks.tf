# create 3 clusters
module "eks_clusters" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"
  for_each = var.clusters

  cluster_name    = each.value.cluster_name
  cluster_version = each.value.cluster_version
  subnet_ids      = each.key == "cluster1" ? module.vpc[each.key].public_subnets : module.vpc[each.key].private_subnets
  vpc_id          = module.vpc[each.key].vpc_id
  enable_irsa     = true

  eks_managed_node_group_defaults = {
    ami_type               = "AL2023_x86_64_STANDARD"
    instance_types         = ["t3.medium"]
    vpc_security_group_ids = [aws_security_group.eks_node_sg_cluster1.id, aws_security_group.eks_node_sg_cluster2.id, aws_security_group.eks_node_sg_cluster3.id]
  }

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
    }
  }
}

