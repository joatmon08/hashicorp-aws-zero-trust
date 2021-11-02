data "aws_iam_policy_document" "vault" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.trusted_role_arn]
    }
  }
}

resource "aws_iam_role" "terraform" {
  name                 = "${var.name}-terraform"
  path                 = "/"
  max_session_duration = var.sts_duration
  assume_role_policy   = data.aws_iam_policy_document.vault.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
  ]
  inline_policy {
    name = "HashiCupsPolicy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["kms:*"]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "iam:*Role*",
            "iam:*Policy*",
            "iam:*InstanceProfile",
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}
