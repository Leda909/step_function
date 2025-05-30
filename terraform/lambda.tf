# -----------------
# Package lambda source code(s)
# -----------------

data "archive_file" "lambda_one" {
  type        = "zip"
  source_dir  = "../lambdas/1_one/"
  output_path = "../lambdas/deployment/one.zip"
}

data "archive_file" "lambda_two" {
  type        = "zip"
  source_dir  = "../lambdas/2_two/"
  output_path = "../lambdas/deployment/two.zip"
}

data "archive_file" "lambda_three" {
  type        = "zip"
  source_dir  = "../lambdas/3_three/"
  output_path = "../lambdas/deployment/three.zip"
}

# ------------------------------------
# Lambda Function Definitions
# ------------------------------------

resource "aws_lambda_function" "lambda_one" {
  filename         = data.archive_file.lambda_one.output_path
  source_code_hash = data.archive_file.lambda_one.output_base64sha256
  function_name    = "lambda-${var.lambda_one}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.handler"
  runtime          = var.python_runtime
}

resource "aws_lambda_function" "lambda_two" {
  filename         = data.archive_file.lambda_two.output_path
  source_code_hash = data.archive_file.lambda_two.output_base64sha256
  function_name    = "lambda-${var.lambda_two}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.handler"
  runtime          = var.python_runtime
}

resource "aws_lambda_function" "lambda_three" {
  filename         = data.archive_file.lambda_three.output_path
  source_code_hash = data.archive_file.lambda_three.output_base64sha256
  function_name    = "lambda-${var.lambda_three}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.handler"
  runtime          = var.python_runtime
}
