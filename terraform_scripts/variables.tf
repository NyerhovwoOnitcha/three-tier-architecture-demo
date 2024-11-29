variable "clusters" {
  type = map(object({
    cluster_name    = string
    cluster_version = string
    private_subnets = list(string)
    public_subnets  = list(string)
    vpc_cidr        = string
  }))
  default = {
    cluster1 = {
      cluster_name    = "cluster1"
      cluster_version = "1.31"
      private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
      public_subnets  = ["10.0.4.0/24", "10.0.5.0/24"]
      vpc_cidr        = "10.0.0.0/16"
    }
    cluster2 = {
      cluster_name    = "cluster2"
      cluster_version = "1.31"
      private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
      public_subnets  = ["10.1.4.0/24", "10.1.5.0/24"]
      vpc_cidr        = "10.1.0.0/16"
    }
    cluster3 = {
      cluster_name    = "cluster3"
      cluster_version = "1.31"
      private_subnets = ["10.2.1.0/24", "10.2.2.0/24"]
      public_subnets  = ["10.2.4.0/24", "10.2.5.0/24"]
      vpc_cidr        = "10.2.0.0/16"
    }
  }
}
