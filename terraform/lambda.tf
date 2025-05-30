# ------------
# Lambda layer
# ------------

# ziping the packeges to lambda layer
data "archive_file" "lambda_layer" {
  type             = "zip"
  source_dir       = "${path.module}/../lambdas/packages"
  output_path      = "${path.module}/../deployment/layers/extract_layer.zip"
}

# creating the lambda layer
resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name          = "extact_layer"
  filename = data.archive_file.lambda_layer.output_path
  source_code_hash    = data.archive_file.lambda_layer.output_base64sha256
  compatible_runtimes = ["python3.10"]
}

# -----------------
# Package lambda source code(s)
# -----------------

data "archive_file" "lambda_one" {
  type        = "zip"
  source_dir  = "../lambdas/1_one/"
  output_path = "../deployment/one.zip"
}

data "archive_file" "lambda_two" {
  type        = "zip"
  source_dir  = "../lambdas/2_two/"
  output_path = "../deployment/two.zip"
}

data "archive_file" "lambda_three" {
  type        = "zip"
  source_dir  = "../lambdas/3_three/"
  output_path = "../deployment/three.zip"
}

# ------------------------------------
# Lambda Function Definitions
# ------------------------------------

resource "aws_lambda_function" "lambda_one" {
  filename         = data.archive_file.lambda_one.output_path
  source_code_hash = data.archive_file.lambda_one.output_base64sha256
  function_name    = var.lambda_one
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = var.python_runtime

  layers = [aws_lambda_layer_version.lambda_layer.arn]

  environment {
    variables = {
      s3_bucket = aws_s3_bucket.first_bucket.bucket
    #add the .env? 
    }
  }
}

resource "aws_lambda_function" "lambda_two" {
  filename         = data.archive_file.lambda_two.output_path
  source_code_hash = data.archive_file.lambda_two.output_base64sha256
  function_name    = var.lambda_two
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = var.python_runtime

  layers = [aws_lambda_layer_version.lambda_layer.arn]

  environment {
    variables = {
      s3_bucket = aws_s3_bucket.second_bucket.bucket
    }
  }
}

resource "aws_lambda_function" "lambda_three" {
  filename         = data.archive_file.lambda_three.output_path
  source_code_hash = data.archive_file.lambda_three.output_base64sha256
  function_name    = var.lambda_three
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = var.python_runtime

  layers = [aws_lambda_layer_version.lambda_layer.arn]
}

