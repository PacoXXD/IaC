# output "bucket_name" {
#   value = "${aws_s3_bucket.bucket.bucket}"
# }

output "dns" {
  value = "${element(aws_route53_record.bastion_record_name.*.name, 0)}"
}

output "sg_id" {
  value = "${module.sg.this_security_group_id}"
}

# data "aws_subnet" "subnet" {
#   # TODO: terraform 0.12
#   count = "${var.subnet_count}"


#   # count = "${length(var.subnet_ids)}"
#   id = "${element(var.subnet_ids, count.index)}"
# }


# output "cidrs" {
#   value = ["${data.aws_subnet.subnet.*.cidr_block}"]
# }

