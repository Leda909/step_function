# Step Functions State Machine
resource "aws_sfn_state_machine" "etl_workflow" {
  name     = "ETL_Data_Orchestra"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = <<EOF
{
  "Comment": "ETL data process through two S3 bucket(s)",
  "StartAt": "LambdaOne",
  "States": {
    "LambdaOne": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.lambda_one.arn}",
      "Next": "LambdaTwo"
    },
    "LambdaTwo": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.lambda_two.arn}",
      "Next": "LambdaThree"
    },
    "LambdaThree": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.lambda_three.arn}",
      "End": true
    }
  }
}
EOF
}