resource "aws_scheduler_schedule" "event_scale_in" {
  name                = "${var.project_name}-zeroscaler-scale-in"
  group_name          = "default"
  schedule_expression = var.scale_in_schedule

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.downscaler_lambda.arn
    role_arn = aws_iam_role.downscaler_invoke_role.arn
    input = jsonencode({
      "clusterName" = var.project_name
      "namespaces"  = var.namespaces
      "replicas"    = 0
    })
  }
}

resource "aws_scheduler_schedule" "event_scale_out" {
  name                = "${var.project_name}-zeroscaler-scale-out"
  group_name          = "default"
  schedule_expression = var.scale_out_schedule

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_lambda_function.downscaler_lambda.arn
    role_arn = aws_iam_role.downscaler_invoke_role.arn
    input = jsonencode({
      "clusterName" = var.project_name
      "namespaces"  = var.namespaces
      "replicas"    = 1
    })
  }
}