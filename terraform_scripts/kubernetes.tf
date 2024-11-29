# create the aws-load-balancer-controller service accounts for cluster 2 and 3
resource "kubernetes_service_account" "alb_controller_sa" {
  for_each = { for k, v in var.clusters : k => v if k != "cluster1" }

  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller_role[each.key].arn
    }
  }
}

# create ebs-csi service account
resource "kubernetes_service_account" "ebs_csi_controller_sa" {
  for_each = var.clusters

  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.ebs_csi_driver_role[each.key].arn
    }
  }
}


# create argocd namespace
resource "kubernetes_namespace" "argocd" {
  for_each = { for k, v in var.clusters : k => v if k == "cluster1" }

  metadata {
    name = "argocd"
  }
}


