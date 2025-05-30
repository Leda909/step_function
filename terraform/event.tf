# Schedule First Lambda Every 15 Minutes
resource "aws_cloudwatch_event_rule" "schedule_lambda_one" {
  name                = "schedule-lambda-one"
  description         = "Run Lambda One every 15 minutes"
  schedule_expression = "rate(15 minutes)"
}

# Link scheduled EventBridge rule to Lambda One
resource "aws_cloudwatch_event_target" "lambda_one_schedule_target" {
  rule      = aws_cloudwatch_event_rule.schedule_lambda_one.name
  target_id = "TriggerLambdaOne"
  arn       = aws_lambda_function.lambda_one.arn
}

# Allow EventBridge to invoke Lambda One
resource "aws_lambda_permission" "allow_eventbridge_schedule_lambda_one" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_one.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule_lambda_one.arn
}