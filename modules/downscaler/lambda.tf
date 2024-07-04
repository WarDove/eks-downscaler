resource "null_resource" "lambda_build" {
  provisioner "local-exec" {
    working_dir = var.lambda_source
    command     = "go mod tidy && GOARCH=amd64 GOOS=linux go build -o bootstrap main.go"
  }

  triggers = {
    ci_env    = var.ci_env
    file_hash = md5(file("${var.lambda_source}/main.go"))
  }
}

data "archive_file" "lambda_zip" {
  depends_on  = [null_resource.lambda_build]
  type        = "zip"
  source_file = "${var.lambda_source}/bootstrap"
  output_path = "${var.lambda_source}/main.zip"
}

resource "aws_lambda_function" "downscaler_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = var.project_name
  handler          = "main"
  runtime          = "provided.al2023"
  role             = aws_iam_role.lambda_role.arn

  environment {
    variables = { CLUSTER_NAME = var.eks_cluster_name }
  }
}

resource "aws_eks_access_entry" "lambda" {
  cluster_name      = var.eks_cluster_name
  principal_arn     = aws_iam_role.lambda_role.arn
  kubernetes_groups = var.eks_groups
  type              = "STANDARD"
}