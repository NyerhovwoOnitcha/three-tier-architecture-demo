output "cluster_name" {
  value = {
    for k, v in module.eks_clusters :
    k => v.cluster_name
  }
}

output "vpc_id" {
  value = {
    for k, v in module.vpc :
    k => v.vpc_id
  }
}

output "private_subnets" {
  value = {
    for k, v in module.vpc :
    k => v.private_subnets
  }
}

output "public_subnets" {
  value = {
    for k, v in module.vpc :
    k => v.public_subnets
  }
}

output "cluster_identity_oidc_issuer" {
  value = {
    for k, v in data.aws_eks_cluster.robotshop :
    k => v.identity[0].oidc[0].issuer
  }
}


output "alb_controller_service_account_arns" {
  value = {
    for k, v in kubernetes_service_account.alb_controller_sa :
    k => v.metadata[0].annotations["eks.amazonaws.com/role-arn"]
  }
}

output "ebs_csi_service_account_arns" {
  value = {
    for k, v in kubernetes_service_account.ebs_csi_controller_sa :
    k => v.metadata[0].annotations["eks.amazonaws.com/role-arn"]
  }
}

output "argocd_namespace" {
  value = {
    for k, v in kubernetes_namespace.argocd :
    k => v.metadata[0].name
  }
}

output "alb_controller_helm_release" {
  value = {
    for k, v in helm_release.aws_load_balancer_controller :
    k => v.name
  }
}

output "argocd_helm_release" {
  value = {
    for k, v in helm_release.argocd :
    k => v.name
  }
}
