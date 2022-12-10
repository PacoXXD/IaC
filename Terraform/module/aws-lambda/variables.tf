variable "name" {
  type = "string"
}

variable "environment_variables" {
  type        = "map"
  description = "Environment variables"
}

variable "function_name" {
  type        = "string"
  description = "The name of the Lambda function"
}

variable "description" {
  type        = "string"
  description = "Lambda description"
}

variable "runtime" {
  type        = "string"
  description = "The runtime of the Lambda to create"
}

variable "handler" {
  type        = "string"
  description = "The name of Lambda function handler"
}

variable "timeout" {
  type        = "string"
  description = "Maximum runtime for Lambda"
}

variable "code_s3_bucket" {
  type        = "string"
  description = "S3 bucket with source code"
}

variable "code_version" {
  type        = "string"
  description = "S3 bucket with source code"
}

variable "code_s3_key" {
  type        = "string"
  description = "The S3 key of source code"
}

variable "code_s3_bucket_visibility" {
  type        = "string"
  description = "S3 bucket ACL"
}

variable "zip_path" {
  type        = "string"
  description = "Local path to Lambda source dist"
}

variable "memory_size" {
  type        = "string"
  description = "Lambda memory size"
}
