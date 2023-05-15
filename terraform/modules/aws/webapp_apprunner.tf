locals {
  apprunner_env_variables = {
    "PORT"       = "${var.webapp_port}",
    "AWS_BUCKET" = "${aws_s3_bucket.inbox.id}",
    "INBOX_PATH" = "inbox/",
  }
}

################################################################################
# App runner definition
################################################################################

resource "aws_apprunner_service" "webapp" {
  service_name = "webapp-${local.resource_suffix}"

  source_configuration {
    image_repository {
      image_configuration {
        port                          = var.webapp_port
        runtime_environment_variables = local.apprunner_env_variables
      }
      image_identifier      = "${aws_ecr_repository.webapp.repository_url}:latest"
      image_repository_type = "ECR"
    }

    auto_deployments_enabled = true

    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_access_role.arn
    }
  }

  instance_configuration {
    cpu               = 1024
    memory            = 2048
    instance_role_arn = aws_iam_role.apprunner_instance_role.arn
  }
}

resource "aws_apprunner_custom_domain_association" "webapp" {
  domain_name = var.domain_name
  service_arn = aws_apprunner_service.webapp.arn

  enable_www_subdomain = false
}

################################################################################
# App runner access role definition
################################################################################

resource "aws_iam_role" "apprunner_access_role" {
  name               = "app-runner-access-role-${local.resource_suffix}"
  assume_role_policy = data.aws_iam_policy_document.apprunner_access_assume_role.json
}
data "aws_iam_policy_document" "apprunner_access_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "build.apprunner.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy" "apprunner_access_policy" {
  role   = aws_iam_role.apprunner_access_role.name
  policy = data.aws_iam_policy_document.apprunner_access_role_policy.json
}
data "aws_iam_policy_document" "apprunner_access_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = [
      "*"
    ]
  }
}

################################################################################
# App runner instance role definition
################################################################################

resource "aws_iam_role" "apprunner_instance_role" {
  name               = "app-runner-instance-role-${local.resource_suffix}"
  assume_role_policy = data.aws_iam_policy_document.apprunner_instance_assume_role.json
}
data "aws_iam_policy_document" "apprunner_instance_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "tasks.apprunner.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy" "apprunner_instance_policy" {
  role   = aws_iam_role.apprunner_instance_role.name
  policy = data.aws_iam_policy_document.apprunner_instance_role_policy.json
}
data "aws_iam_policy_document" "apprunner_instance_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket*",
      "s3:GetObject*",
    ]
    resources = [
      aws_s3_bucket.inbox.arn,
      "${aws_s3_bucket.inbox.arn}/*"
    ]
  }
}