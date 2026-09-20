data "aws_iam_policy_document" "terraform_apply_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:TheLawal24@147694818/aws-devops-platform@1377097712:environment:infrastructure"
      ]
    }
  }
}

resource "aws_iam_role" "terraform_apply" {
  name = "${var.project_name}-${var.environment}-terraform-apply-role"

  assume_role_policy = data.aws_iam_policy_document.terraform_apply_assume_role.json

  tags = {
    Name = "${var.project_name}-${var.environment}-terraform-apply-role"
  }
}

resource "aws_iam_role_policy_attachment" "terraform_apply_readonly" {
  role       = aws_iam_role.terraform_apply.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

data "aws_iam_policy_document" "terraform_apply" {
  statement {
    sid    = "ManageNetwork"
    effect = "Allow"

    actions = [
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:ModifyVpcAttribute",
      "ec2:CreateSubnet",
      "ec2:DeleteSubnet",
      "ec2:ModifySubnetAttribute",
      "ec2:CreateInternetGateway",
      "ec2:DeleteInternetGateway",
      "ec2:AttachInternetGateway",
      "ec2:DetachInternetGateway",
      "ec2:CreateRouteTable",
      "ec2:DeleteRouteTable",
      "ec2:AssociateRouteTable",
      "ec2:DisassociateRouteTable",
      "ec2:CreateRoute",
      "ec2:ReplaceRoute",
      "ec2:DeleteRoute",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageLoadBalancing"
    effect = "Allow"

    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageECS"
    effect = "Allow"

    actions = [
      "ecs:CreateCluster",
      "ecs:DeleteCluster",
      "ecs:UpdateClusterSettings",
      "ecs:RegisterTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "ecs:CreateService",
      "ecs:UpdateService",
      "ecs:DeleteService",
      "ecs:TagResource",
      "ecs:UntagResource"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageECR"
    effect = "Allow"

    actions = [
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:PutLifecyclePolicy",
      "ecr:DeleteLifecyclePolicy",
      "ecr:PutImageScanningConfiguration",
      "ecr:PutImageTagMutability",
      "ecr:TagResource",
      "ecr:UntagResource"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageObservability"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:PutRetentionPolicy",
      "logs:TagResource",
      "logs:UntagResource",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:TagResource",
      "cloudwatch:UntagResource",
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:SetTopicAttributes",
      "sns:TagResource",
      "sns:UntagResource"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageProjectIAM"
    effect = "Allow"

    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:SetDefaultPolicyVersion",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PassRole",
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:UpdateOpenIDConnectProviderThumbprint",
      "iam:AddClientIDToOpenIDConnectProvider",
      "iam:RemoveClientIDFromOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:UntagOpenIDConnectProvider"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "TerraformState"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::aws-devops-platform-tfstate-808935753572-eu-west-2"
    ]
  }

  statement {
    sid    = "TerraformStateObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::aws-devops-platform-tfstate-808935753572-eu-west-2/aws-devops-platform/dev/terraform.tfstate",
      "arn:aws:s3:::aws-devops-platform-tfstate-808935753572-eu-west-2/aws-devops-platform/dev/terraform.tfstate.tflock"
    ]
  }
}

resource "aws_iam_policy" "terraform_apply" {
  name   = "${var.project_name}-${var.environment}-terraform-apply-policy"
  policy = data.aws_iam_policy_document.terraform_apply.json
}

resource "aws_iam_role_policy_attachment" "terraform_apply" {
  role       = aws_iam_role.terraform_apply.name
  policy_arn = aws_iam_policy.terraform_apply.arn
}
