data "aws_iam_policy_document" "eks_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

module "eks_control_plane_role" {
  source             = "../__modules/aws-iam-roles"
  role_name          = "eks-cluster-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.eks_assume.json
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  ]
  tags = {
    Environment = var.environment
    Shared      = "true"
  }
}

data "aws_iam_policy_document" "node_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

module "eks_node_role" {
  source             = "../__modules/aws-iam-roles"
  role_name          = "eks-node-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.node_assume.json
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  tags = {
    Environment = var.environment
    Shared      = "true"
  }
}

data "aws_iam_policy_document" "pod_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole", "sts:TagSession"]
  }
}

module "eks_pod_identity_role" {
  source             = "../__modules/aws-iam-roles"
  role_name          = "eks-pod-identity-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.pod_assume.json
  policy_arns        = var.pod_policy_arns
  tags = {
    Environment = var.environment
    Shared      = "true"
  }
}

data "aws_iam_policy_document" "github_actions_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [var.github_arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:AAInternal/runway-kubernetes-cluster-automation"]
    }
  }
}

module "github_actions_role" {
  source             = "../__modules/aws-iam-roles"
  role_name          = "github-actions-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume.json
  policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
  tags = {
    Environment = var.environment
    Shared      = "true"
  }
}

data "aws_s3_bucket" "velero_s3_bucket" {
  bucket = var.velero_s3_bucket_name
}

module "s3_policy_velero" {
  source      = "../__modules/aws-iam-policy"
  policy_name = "s3-velero-policy-${var.environment}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = [
          "arn:aws:s3:::${data.aws_s3_bucket.velero_s3_bucket.id}",
          "arn:aws:s3:::${data.aws_s3_bucket.velero_s3_bucket.id}/*"
        ]
      }
    ]
  })
}

module "pod_identity_role_velero" {
  source             = "../__modules/aws-iam-roles"
  role_name          = "pod-identity-role-velero-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.pod_assume.json
  policy_arns        = [module.s3_policy_velero.arn]
  tags = {
    Environment = var.environment
    Shared      = "true"
  }
}

module "ack_eks_pod_identity_policy" {
  source      = "../__modules/aws-iam-policy"
  policy_name = "ack-eks-pod-identity-policy-${var.environment}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ackekspodidentitypolicy",
        "Effect" : "Allow",
        "Action" : [
          "eks:CreatePodIdentityAssociation",
          "eks:TagResource"
        ],
        "Resource" : "arn:aws:eks:*:${var.aws_account_id}:cluster/*"
      },
      {
        "Sid" : "ackekspodidentitypolicytag",
        "Effect" : "Allow",
        "Action" : [
          "eks:DescribePodIdentityAssociation",
          "eks:UpdatePodIdentityAssociation",
          "eks:DeletePodIdentityAssociation",
          "eks:TagResource"
        ],
        "Resource" : "arn:aws:eks:*:${var.aws_account_id}:podidentityassociation/*/*"
      },
      {
        "Sid" : "PassRoleToAnyRole",
        "Effect" : "Allow",
        "Action" : [
          "iam:PassRole",
          "iam:GetRole"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "EC2SubnetAccess",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeSubnets"
        ],
        "Resource" : "*"
      }
    ]
  })
}

module "cluster_autoscaler_policy" {
  source      = "../__modules/aws-iam-policy"
  policy_name = "cluster-autoscaler-policy-${var.environment}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ],
        "Resource" : ["*"]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ],
        "Resource" : ["*"]
      }
    ]
  })
}

module "ack_iam_pod_identity_policy" {
  source      = "../__modules/aws-iam-policy"
  policy_name = "ack-iam-pod-identity-policy-${var.environment}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "iam:GetGroup",
          "iam:CreateGroup",
          "iam:DeleteGroup",
          "iam:UpdateGroup",
          "iam:GetRole",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:UpdateRole",
          "iam:PutRolePermissionsBoundary",
          "iam:PutUserPermissionsBoundary",
          "iam:GetUser",
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:UpdateUser",
          "iam:GetPolicy",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicyVersion",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:ListPolicyVersions",
          "iam:ListPolicyTags",
          "iam:ListAttachedGroupPolicies",
          "iam:GetGroupPolicy",
          "iam:PutGroupPolicy",
          "iam:AttachGroupPolicy",
          "iam:DetachGroupPolicy",
          "iam:DeleteGroupPolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:GetRolePolicy",
          "iam:PutRolePolicy",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:ListAttachedUserPolicies",
          "iam:ListUserPolicies",
          "iam:GetUserPolicy",
          "iam:PutUserPolicy",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:DeleteUserPolicy",
          "iam:ListRoleTags",
          "iam:ListUserTags",
          "iam:TagPolicy",
          "iam:UntagPolicy",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:TagUser",
          "iam:UntagUser",
          "iam:RemoveClientIDFromOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviderTags",
          "iam:UpdateOpenIDConnectProviderThumbprint",
          "iam:UntagOpenIDConnectProvider",
          "iam:AddClientIDToOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider",
          "iam:CreateOpenIDConnectProvider",
          "iam:UpdateAssumeRolePolicy"
        ],
        "Resource" : "*"
      }
    ]
  })
}

module "ack_pod_identity_role" {
  source             = "../__modules/aws-iam-roles"
  role_name          = "ack-pod-identity-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.pod_assume.json
  policy_arns = [
    module.ack_eks_pod_identity_policy.arn,
    module.ack_iam_pod_identity_policy.arn
  ]
  tags = {
    Environment = var.environment
    Shared      = "true"
  }
}

module "cluster_autoscaler_role" {
  source             = "../__modules/aws-iam-roles"
  role_name          = "cluster-autoscaler-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.pod_assume.json
  policy_arns        = [module.cluster_autoscaler_policy.arn]
  tags = {
    Environment = var.environment
    Shared      = "true"
  }
}

module "ec2_eks_role" {
  source             = "../__modules/aws-iam-roles"
  role_name          = "ec2-eks-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.node_assume.json
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  tags = {
    Environment = var.environment
    Shared      = "true"
  }
}

module "containerRegistry_tokens_podIdentity_role" {
  source             = "../__modules/aws-iam-roles"
  role_name          = "containerRegistry-tokens-podIdentity-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.pod_assume.json
  policy_arns        = var.pod_policy_arns
  tags = {
    Environment = var.environment
    Shared      = "true"
  }
}

module "githubActions_deploy_role" {
  source               = "../__modules/aws-iam-roles"
  role_name            = "githubActions-deploy-role-${var.environment}"
  assume_role_policy   = data.aws_iam_policy_document.github_actions_assume.json
  max_session_duration = 7200 # 2 hours for long-running EKS operations
  policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
  tags = {
    Environment = var.environment
    Shared      = "true"
  }
}

module "velero_s3_policy" {
  source      = "../__modules/aws-iam-policy"
  policy_name = "velero-s3-policy-${var.environment}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = [
          "arn:aws:s3:::${data.aws_s3_bucket.velero_s3_bucket.id}",
          "arn:aws:s3:::${data.aws_s3_bucket.velero_s3_bucket.id}/*"
        ]
      }
    ]
  })
}

module "velero_s3_podIdentity_role" {
  source             = "../__modules/aws-iam-roles"
  role_name          = "velero-s3-podIdentity-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.pod_assume.json
  policy_arns        = [module.velero_s3_policy.arn]
  tags = {
    Environment = var.environment
    Shared      = "true"
  }
}

module "ack_eks_podIdentity_policy" {
  source      = "../__modules/aws-iam-policy"
  policy_name = "ack-eks-podIdentity-policy-${var.environment}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ackekspodidentitypolicy",
        "Effect" : "Allow",
        "Action" : [
          "eks:CreatePodIdentityAssociation",
          "eks:TagResource"
        ],
        "Resource" : "arn:aws:eks:*:${var.aws_account_id}:cluster/*"
      },
      {
        "Sid" : "ackekspodidentitypolicytag",
        "Effect" : "Allow",
        "Action" : [
          "eks:DescribePodIdentityAssociation",
          "eks:UpdatePodIdentityAssociation",
          "eks:DeletePodIdentityAssociation",
          "eks:TagResource"
        ],
        "Resource" : "arn:aws:eks:*:${var.aws_account_id}:podidentityassociation/*/*"
      },
      {
        "Sid" : "PassRoleToAnyRole",
        "Effect" : "Allow",
        "Action" : [
          "iam:PassRole",
          "iam:GetRole"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "EC2SubnetAccess",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeSubnets"
        ],
        "Resource" : "*"
      }
    ]
  })
}

module "ack_iam_podIdentity_policy" {
  source      = "../__modules/aws-iam-policy"
  policy_name = "ack-iam-podIdentity-policy-${var.environment}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "iam:GetGroup",
          "iam:CreateGroup",
          "iam:DeleteGroup",
          "iam:UpdateGroup",
          "iam:GetRole",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:UpdateRole",
          "iam:PutRolePermissionsBoundary",
          "iam:PutUserPermissionsBoundary",
          "iam:GetUser",
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:UpdateUser",
          "iam:GetPolicy",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicyVersion",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:ListPolicyVersions",
          "iam:ListPolicyTags",
          "iam:ListAttachedGroupPolicies",
          "iam:GetGroupPolicy",
          "iam:PutGroupPolicy",
          "iam:AttachGroupPolicy",
          "iam:DetachGroupPolicy",
          "iam:DeleteGroupPolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:GetRolePolicy",
          "iam:PutRolePolicy",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:ListAttachedUserPolicies",
          "iam:ListUserPolicies",
          "iam:GetUserPolicy",
          "iam:PutUserPolicy",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:DeleteUserPolicy",
          "iam:ListRoleTags",
          "iam:ListUserTags",
          "iam:TagPolicy",
          "iam:UntagPolicy",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:TagUser",
          "iam:UntagUser",
          "iam:RemoveClientIDFromOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviderTags",
          "iam:UpdateOpenIDConnectProviderThumbprint",
          "iam:UntagOpenIDConnectProvider",
          "iam:AddClientIDToOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider",
          "iam:CreateOpenIDConnectProvider",
          "iam:UpdateAssumeRolePolicy"
        ],
        "Resource" : "*"
      }
    ]
  })
}

module "ack_eks_podIdentity_role" {
  source             = "../__modules/aws-iam-roles"
  role_name          = "ack-eks-podIdentity-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.pod_assume.json
  policy_arns = [
    module.ack_eks_podIdentity_policy.arn,
    module.ack_iam_podIdentity_policy.arn
  ]
  tags = {
    Environment = var.environment
    Shared      = "true"
  }
}

module "autoscaler_eks_policy" {
  source      = "../__modules/aws-iam-policy"
  policy_name = "autoscaler-eks-policy-${var.environment}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ],
        "Resource" : ["*"]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ],
        "Resource" : ["*"]
      }
    ]
  })
}

module "autoscaler_eks_role" {
  source             = "../__modules/aws-iam-roles"
  role_name          = "autoscaler-eks-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.pod_assume.json
  policy_arns        = [module.autoscaler_eks_policy.arn]
  tags = {
    Environment = var.environment
    Shared      = "true"
  }
}

module "lb_controller_eks_policy" {
  source      = "../__modules/aws-iam-policy"
  policy_name = "lbController-eks-policy-${var.environment}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:CreateServiceLinkedRole"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "iam:AWSServiceName" : "elasticloadbalancing.amazonaws.com"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags",
          "ec2:GetCoipPoolUsage",
          "ec2:DescribeCoipPools",
          "ec2:GetSecurityGroupsForVpc",
          "ec2:DescribeIpamPools",
          "ec2:DescribeRouteTables",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeTrustStores",
          "elasticloadbalancing:DescribeListenerAttributes",
          "elasticloadbalancing:DescribeCapacityReservation"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "iam:ListServerCertificates",
          "iam:GetServerCertificate",
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateSecurityGroup"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags"
        ],
        "Resource" : "arn:aws:ec2:*:*:security-group/*",
        "Condition" : {
          "StringEquals" : {
            "ec2:CreateAction" : "CreateSecurityGroup"
          },
          "Null" : {
            "aws:RequestTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ],
        "Resource" : "arn:aws:ec2:*:*:security-group/*",
        "Condition" : {
          "Null" : {
            "aws:RequestTag/elbv2.k8s.aws/cluster" : "true",
            "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DeleteSecurityGroup"
        ],
        "Resource" : "*",
        "Condition" : {
          "Null" : {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup"
        ],
        "Resource" : "*",
        "Condition" : {
          "Null" : {
            "aws:RequestTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ],
        "Resource" : [
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
        ],
        "Condition" : {
          "Null" : {
            "aws:RequestTag/elbv2.k8s.aws/cluster" : "true",
            "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags"
        ],
        "Resource" : [
          "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
          "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:ModifyListenerAttributes",
          "elasticloadbalancing:ModifyCapacityReservation",
          "elasticloadbalancing:ModifyIpPools"
        ],
        "Resource" : "*",
        "Condition" : {
          "Null" : {
            "aws:ResourceTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:AddTags"
        ],
        "Resource" : [
          "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
          "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "elasticloadbalancing:CreateAction" : [
              "CreateTargetGroup",
              "CreateLoadBalancer"
            ]
          },
          "Null" : {
            "aws:RequestTag/elbv2.k8s.aws/cluster" : "false"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets"
        ],
        "Resource" : "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:SetWebAcl",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:SetRulePriorities"
        ],
        "Resource" : "*"
      }
    ]
  })
}

module "lb_controller_eks_role" {
  source             = "../__modules/aws-iam-roles"
  role_name          = "lbController-eks-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.pod_assume.json
  policy_arns        = [module.lb_controller_eks_policy.arn]
  tags = {
    Environment = var.environment
    Shared      = "true"
  }
}
