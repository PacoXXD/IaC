resource "aws_iam_policy" "policy" {
  name_prefix = var.name
  description = var.description

  policy = var.policy
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role       = var.role
  policy_arn = aws_iam_policy.policy.arn
}
