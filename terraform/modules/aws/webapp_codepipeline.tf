###############################################################################
# Code pipeline definition
###############################################################################

resource "aws_codepipeline" "codepipeline" {
  name     = "codepipeline-webapp-${local.resource_suffix}"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codebuild.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        S3Bucket             = aws_s3_bucket.codebuild.bucket
        S3ObjectKey          = "webapp.zip"
        PollForSourceChanges = true
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.webapp.name
      }
    }
  }
}

###############################################################################
# IAM role definition
###############################################################################

resource "aws_iam_role" "codepipeline" {
  name               = "codepipeline-${local.resource_suffix}"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
}
data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "codepipeline.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy" "codepipeline_role_policy" {
  role   = aws_iam_role.codepipeline.name
  policy = data.aws_iam_policy_document.codepipeline_role_policy_document.json
}
data "aws_iam_policy_document" "codepipeline_role_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = [
      aws_codebuild_project.webapp.arn
    ]
  }
  statement {
    sid    = "AccessWebappSourceInS3"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.codebuild.arn,
      "${aws_s3_bucket.codebuild.arn}/*"
    ]
  }
}
