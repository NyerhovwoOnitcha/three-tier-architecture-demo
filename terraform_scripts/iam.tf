data "aws_caller_identity" "current" {}
# service account, role for aws eks lb for clusters 2 and 3 


# create the aws-load-balancer-controller role for cluster 2 and 3
resource "aws_iam_role" "alb_controller_role" {
  for_each = { for k, v in var.clusters : k => v if k != "cluster1" }

  name = "AmazonEKSLoadBalancerControllerRole-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# attach the policy to the role created above
resource "aws_iam_role_policy_attachment" "alb_controller_policy" {
  for_each = { for k, v in var.clusters : k => v if k != "cluster1" }

  role       = aws_iam_role.alb_controller_role[each.key].name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AWSLoadBalancerControllerIAMPolicy"
}




# create role  for ebs_csi plugin for clusters 2 and 3 and attach policy to role 

resource "aws_iam_role" "ebs_csi_driver_role" {
  for_each = var.clusters

  name = "AmazonEKS_EBS_CSI_DriverRole-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  for_each = var.clusters

  role       = aws_iam_role.ebs_csi_driver_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}






