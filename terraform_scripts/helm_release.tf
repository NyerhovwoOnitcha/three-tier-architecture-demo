# Deploy aws lb controller
resource "helm_release" "aws_load_balancer_controller" {
  for_each = { for k, v in var.clusters : k => v if k != "cluster1" }

  name       = "aws-load-balancer-controller-${each.key}"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.2.3"  # Specify the desired version

  set {
    name  = "clusterName"
    value = each.value.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "region"
    value = "eu-north-1"
  }

  set {
    name  = "vpcId"
    value = module.vpc[each.key].vpc_id
  }
}

#Deploy ArgoCD
# Deploy ArgoCd
resource "helm_release" "argocd" {
  for_each = { for k, v in var.clusters : k => v if k == "cluster1" }

  name       = "argocd-${each.key}"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "3.35.0"  # Specify the desired version

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "server.ingress.enabled"
    value = "true"
  }

  set {
    name  = "server.ingress.hosts[0]"
    value = "argocd.${each.value.cluster_name}.example.com"
  }
}


