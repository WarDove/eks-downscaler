module "downscaler_lambda_client" {
  source             = "./modules/downscaler"
  eks_cluster_name   = var.cluster_name
  lambda_source      = "${path.root}/lambdas/downscaler"
  scale_out_schedule = "cron(00 09 ? * MON-FRI *)"
  scale_in_schedule  = "cron(00 18 ? * MON-FRI *)"
  eks_groups         = ["lambda-group"]
  namespaces         = ["development", "test"]
}