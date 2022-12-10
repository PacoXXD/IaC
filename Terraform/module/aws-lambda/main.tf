resource "aws_lambda_function" "lambda" {
  function_name = "${var.function_name}"
  description   = "${var.description}"

  runtime = "${var.runtime}"
  handler = "${var.handler}"

  memory_size = "${var.memory_size}"
  timeout     = "${var.timeout}"

  role = "${aws_iam_role.lambda_exec.arn}"

  s3_bucket = "${aws_s3_bucket.lambda_repo.bucket}"
  s3_key    = "${aws_s3_bucket_object.lambda_dist.key}"

  environment {
    variables = "${var.environment_variables}"
  }
}

resource "aws_s3_bucket" "lambda_repo" {
  bucket = "${var.code_s3_bucket}"
  acl    = "${var.code_s3_bucket_visibility}"
}

resource "aws_s3_bucket_object" "lambda_dist" {
  bucket = "${aws_s3_bucket.lambda_repo.bucket}"
  key    = "${format("%s/%s", var.code_version, var.code_s3_key)}"
  source = "${var.zip_path}"
  etag   = "${md5(file(var.zip_path))}"
}

resource "aws_iam_role" "lambda_exec" {
  name = "${format("%s-ga-role-policy", var.name)}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_exec_role_policy" {
  role = "${aws_iam_role.lambda_exec.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}
