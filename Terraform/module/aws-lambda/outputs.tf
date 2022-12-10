output "lambda_arn" {
  value = "${aws_lambda_function.lambda.arn}"
}

output "invoke_arn" {
  value = "${aws_lambda_function.lambda.invoke_arn}"
}

output "role_id" {
  value = "${aws_iam_role.lambda_exec.id}"
}
