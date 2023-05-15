locals {
  codebuild_env_variables = {
    "PORT"        = "${var.webapp_port}",
    "AWS_BUCKET"  = "${aws_s3_bucket.inbox.id}",
    "AWS_ECR_URL" = "${aws_ecr_repository.webapp.repository_url}",
    "INBOX_PATH"  = "inbox/",
    "AWS_REGION"  = "${var.region}",
  }
  zip_webapp_path = "${path.root}/archives/webapp.zip"
}

###############################################################################
# Code Build definition
###############################################################################

resource "aws_codebuild_project" "webapp" {
  name           = "codebuild-webapp-${local.resource_suffix}"
  description    = "Builds ${var.project} webapp image."
  build_timeout  = "5"
  queued_timeout = "5"
  service_role   = aws_iam_role.codebuild.arn

  source {
    type     = "S3"
    location = "${aws_s3_bucket.codebuild.arn}/webapp.zip"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = "true"

    dynamic "environment_variable" {
      for_each = local.codebuild_env_variables
      content {
        name  = environment_variable.key
        value = environment_variable.value
        type  = "PLAINTEXT"
      }
    }
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }
  cache {
    type = "NO_CACHE"
  }
}

###############################################################################
# IAM role definition
###############################################################################

resource "aws_iam_role" "codebuild" {
  name               = "codebuild-${local.resource_suffix}"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}
data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "codebuild.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
  role   = aws_iam_role.codebuild.name
  policy = data.aws_iam_policy_document.codebuild_role_policy_document.json
}
data "aws_iam_policy_document" "codebuild_role_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "codebuild:*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AccessWebappSourceInS3"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:Get*"
    ]
    resources = [
      aws_s3_bucket.codebuild.arn,
      "${aws_s3_bucket.codebuild.arn}/*"
    ]
  }
  statement {
    sid    = "FullAccessECR"
    effect = "Allow"
    actions = [
      "ecr:*"
    ]
    resources = [
      aws_ecr_repository.webapp.arn
    ]
  }
  statement {
    sid    = "GetECRAuthorizationToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }
}
