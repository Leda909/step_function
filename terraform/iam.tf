# ------------------------------
# IAM Policy for Lambda(s)
# ------------------------------

# Define IAM role for lambda
data "aws_iam_policy_document" "trust_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create IAM role for lambda(s)
resource "aws_iam_role" "lambda_role" {
  name               = "shared-IAM-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

# ------------------------------
# Lambda IAM Policy to write in both S3 bucket(s)
# ------------------------------

# Define policy to allow writing to S3 bucket(s)
data "aws_iam_policy_document" "s3_data_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.first_bucket.arn}/*",
      "${aws_s3_bucket.second_bucket.arn}/*"
    ]
  }
}

# Create the policy to writeing to S3 bucket(s)
resource "aws_iam_policy" "s3_write_policy" {
  name   = "lambda-s3-write-policy"
  policy = data.aws_iam_policy_document.s3_data_policy_doc.json
}

# Attach the s3 write policy to the shared lambda role
resource "aws_iam_role_policy_attachment" "lambda_s3_write_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_write_policy.arn
}

# ------------------------------
# Lambda IAM Policy for CloudWatch
# ------------------------------

# Define CloudWatch Logs, Streams, Logevents access policy document
data "aws_iam_policy_document" "cw_document" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

# Create the general CloudWatch policy
resource "aws_iam_policy" "cw_policy" {
  name   = "cloudwatch-policy"
  policy = data.aws_iam_policy_document.cw_document.json
}

# Attach the CloudWatch policy to shared Lambda IAM role
resource "aws_iam_role_policy_attachment" "lambda_cw_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.cw_policy.arn
}

# ------------------------------
# IAM Policy for Step Function to invoke lambdas
# ------------------------------

# Define policy that allows the Step Function to invokes any lambda(s)
data "aws_iam_policy_document" "lambda_access_policy" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:*"
    ]
    resources = ["*"]    ## potential vulnerability
  }
}

# Create IAM policy for Step Function
resource "aws_iam_role" "step_functions_role" {
  name = "step_functions_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

# Create IAM policy for using the document
resource "aws_iam_policy" "step_functions_policy_lambda" {
  name   = "policy-stepfunction-invoke-lambdas"
  policy = data.aws_iam_policy_document.lambda_access_policy.json
}


# Attach IAM policy to Step Function IAM role
resource "aws_iam_role_policy_attachment" "step_functions_to_lambda" {
  role       = aws_iam_role.step_functions_role.name
  policy_arn = aws_iam_policy.step_functions_policy_lambda.arn
}