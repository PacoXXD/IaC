output "name" {
  value = "${aws_s3_bucket.s3.id}"
}

output "arn" {
  value = "${aws_s3_bucket.s3.arn}"
}

output "dns" {
  value = "${local.cname}"
}
