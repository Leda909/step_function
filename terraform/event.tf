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

# Schedule Step Function
# resource "aws_scheduler_schedule" "step" {  ##TODO change the name
#   name       = "my-step-function-scheduler"
#   #group_name = "step-function-group"

#   flexible_time_window {
#     mode = "OFF"
#   }

#   schedule_expression = "rate(2 minute)"

#   target {
#     arn      = aws_sfn_state_machine.sfn_state_machine.arn
#     role_arn = aws_iam_role.step_function_role.arn
#   }
# }