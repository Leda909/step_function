output "notification_email" {
  value       = var.notification_email
  description = "The email address receiving Lambda failure notifications"
  sensitive   = false
}

output "step_function_definition" {
  value = aws_sfn_state_machine.etl_workflow.definition
}