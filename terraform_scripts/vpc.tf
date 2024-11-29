module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"
  for_each = var.clusters

  name                 = "papi-eks-vpc-${each.key}"
  cidr                 = each.value.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = each.value.private_subnets
  public_subnets       = each.value.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "kubernetes.io/cluster/${each.value.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${each.value.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                           = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${each.value.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                  = "1"
  }
}
