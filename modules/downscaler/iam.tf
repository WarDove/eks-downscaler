data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.project_name}-lambda-role"
  tags               = local.default_tags
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "describe_cluster_policy" {
  statement {
    actions   = ["eks:DescribeCluster"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "describe_cluster_policy" {
  name   = "${var.project_name}-describe-cluster"
  policy = data.aws_iam_policy_document.describe_cluster_policy.json
  tags   = local.default_tags
}

resource "aws_iam_role_policy_attachment" "lambda_describe_cluster_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.describe_cluster_policy.arn
}

data "aws_iam_policy_document" "lambda_logging_policy" {

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name   = "${var.project_name}-lambda-logging"
  policy = data.aws_iam_policy_document.lambda_logging_policy.json
  tags   = local.default_tags
}

resource "aws_iam_role_policy_attachment" "lambda_logging_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}

data "aws_iam_policy_document" "downscaler_invoke_policy" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.downscaler_lambda.arn]
  }
}

resource "aws_iam_policy" "lambda_invoke_policy" {
  name        = "${var.project_name}-scheduler-policy"
  description = "Allow function execution for scheduler role"
  policy      = data.aws_iam_policy_document.downscaler_invoke_policy.json
}

data "aws_iam_policy_document" "downscaler_invoke_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "downscaler_invoke_role" {
  name               = "${var.project_name}-scheduler-role"
  assume_role_policy = data.aws_iam_policy_document.downscaler_invoke_role.json
}

resource "aws_iam_role_policy_attachment" "downscaler_invoke_role" {
  policy_arn = aws_iam_policy.lambda_invoke_policy.arn
  role       = aws_iam_role.downscaler_invoke_role.name
}