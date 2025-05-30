variable "first_bucket_prefix" {
  type    = string
  default = "first-bucket-"
}

variable "second_bucket_prefix" {
  type    = string
  default = "second-bucket-"
}

variable "lambda_one" {
  type    = string
  default = "one"
}

variable "lambda_two" {
  type    = string
  default = "two"
}

variable "lambda_three" {
  type    = string
  default = "three"
}

variable "python_runtime" {
  type    = string
  default = "python3.13"
}