# Schedule First Lambda Every 15 Minutes
resource "aws_cloudwatch_event_rule" "schedule_lambda_one" {
  name                = "schedule-lambda-one"
  description         = "Run Lambda One every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

# Link scheduled EventBridge/Cloudewatch rule to Lambda One
resource "aws_cloudwatch_event_target" "lambda_one_schedule_target" {
  rule      = aws_cloudwatch_event_rule.schedule_lambda_one.name
  target_id = "TriggerLambdaOne"
  arn       = aws_lambda_function.lambda_one.arn
}

# Allow EventBridge/CloudeWatch to invoke Lambda One
resource "aws_lambda_permission" "allow_schedule_lambda_one" {
  statement_id  = "AllowExecutionFromCloudeWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_one.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule_lambda_one.arn
  source_account = data.aws_caller_identity.current.account_id
}

# Allow EventBridge to invoke Lambda two
resource "aws_lambda_permission" "allow_eventbridge_schedule_lambda_one" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_two.function_name
  principal     = "events.amazonaws.com"
  source_arn    = # it is depends the lambda one, ha lambda one lefut fut akkor ezt is futtasd uttana. Nem tudom hogy mit kell ide irni
}

# Allow EventBridge to invoke Lambda Three
resource "aws_lambda_permission" "allow_eventbridge_schedule_lambda_one" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_three.function_name
  principal     = "events.amazonaws.com"
  source_arn    = # it is depends the lambda two, ha lambda two lefut fut akkor ezt is futtasd uttana. Nem tudom hogy mit kell ide irni
}