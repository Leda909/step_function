# ------------------------------
# Step Function Schedule
# ------------------------------

resource "aws_cloudwatch_event_rule" "schedule_step_function" {
  name                = "schedule-stepfunction"
  description         = "Run Step Function every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "trigger_step_function" {
  rule      = aws_cloudwatch_event_rule.schedule_step_function.name
  target_id = "StepFunctionTarget"
  arn       = aws_sfn_state_machine.etl_workflow.arn
  role_arn  = aws_iam_role.eventbridge_to_step_function.arn
}