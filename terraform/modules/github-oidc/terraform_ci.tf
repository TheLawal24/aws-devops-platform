data "aws_iam_policy_document" "terraform_ci_assume_role" {
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
        "repo:TheLawal24@147694818/aws-devops-platform@1377097712:pull_request"
      ]
    }
  }
}

resource "aws_iam_role" "terraform_ci" {
  name = "${var.project_name}-${var.environment}-terraform-ci-role"

  assume_role_policy = data.aws_iam_policy_document.terraform_ci_assume_role.json

  tags = {
    Name = "${var.project_name}-${var.environment}-terraform-ci-role"
  }
}

resource "aws_iam_role_policy_attachment" "terraform_ci_readonly" {
  role       = aws_iam_role.terraform_ci.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

data "aws_iam_policy_document" "terraform_state" {
  statement {
    sid    = "ListStateBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::aws-devops-platform-tfstate-808935753572-eu-west-2"
    ]
  }

  statement {
    sid    = "ReadTerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::aws-devops-platform-tfstate-808935753572-eu-west-2/aws-devops-platform/dev/terraform.tfstate"
    ]
  }

  statement {
    sid    = "StateLocking"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::aws-devops-platform-tfstate-808935753572-eu-west-2/aws-devops-platform/dev/terraform.tfstate.tflock"
    ]
  }
}

resource "aws_iam_policy" "terraform_state" {
  name   = "${var.project_name}-${var.environment}-terraform-state-policy"
  policy = data.aws_iam_policy_document.terraform_state.json
}

resource "aws_iam_role_policy_attachment" "terraform_state" {
  role       = aws_iam_role.terraform_ci.name
  policy_arn = aws_iam_policy.terraform_state.arn
}
