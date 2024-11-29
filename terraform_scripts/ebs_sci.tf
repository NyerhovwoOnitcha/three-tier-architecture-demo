data "aws_eks_cluster" "robotshop" {
  for_each = var.clusters
  name     = module.eks_clusters[each.key].cluster_name
}


module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"
  for_each = var.clusters

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${each.value.cluster_name}"
  provider_url                  = data.aws_eks_cluster.robotshop[each.key].identity[0].oidc[0].issuer
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_eks_addon" "ebs-csi" {
  for_each = var.clusters

  cluster_name             = module.eks_clusters[each.key].cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = module.irsa-ebs-csi[each.key].iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
}



data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}


