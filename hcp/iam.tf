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
  name               = "${var.name}-terraform"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.vault.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  ]
}
