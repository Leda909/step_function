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

# Lambda invoke permission policy document
data "aws_iam_policy_document" "lambda_access_policy" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      aws_lambda_function.lambda_one.arn,
      aws_lambda_function.lambda_two.arn,
      aws_lambda_function.lambda_three.arn
      ]    ## potential vulnerability to use only *
  }
}

# Assume role policy document for Step Functions
data "aws_iam_policy_document" "step_function_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create IAM role for Step Function
resource "aws_iam_role" "step_functions_role" {
  name = "step_functions_role"
  assume_role_policy = data.aws_iam_policy_document.step_function_assume_role_policy.json
}

# Create IAM policy for allow Lambda invocation
resource "aws_iam_policy" "step_functions_policy_lambda" {
  name   = "policy-stepfunction-invoke-lambdas"
  policy = data.aws_iam_policy_document.lambda_access_policy.json
}

# Attach IAM policy to Step Function IAM role
resource "aws_iam_role_policy_attachment" "step_functions_to_lambda" {
  role       = aws_iam_role.step_functions_role.name
  policy_arn = aws_iam_policy.step_functions_policy_lambda.arn
}

# ------------------------------
# IAM policy for EventBridge to invoke Step Functions
# ------------------------------

data "aws_iam_policy_document" "eventbridge_start_sf" {
  statement {
    effect = "Allow"
    actions = ["states:StartExecution"]
    resources = [aws_sfn_state_machine.etl_workflow.arn]
  }
}

resource "aws_iam_role" "eventbridge_to_step_function" {
  name               = "eventbridge-to-stepfunction-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "events.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "eventbridge_start_sf_policy" {
  name   = "eventbridge-start-sf-policy"
  role   = aws_iam_role.eventbridge_to_step_function.id
  policy = data.aws_iam_policy_document.eventbridge_start_sf.json
}