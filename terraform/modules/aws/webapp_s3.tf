locals {
  webapp_path = "${path.module}/../../../webapp"
}

###############################################################################
# S3 bucket definition
###############################################################################

resource "aws_s3_bucket" "codebuild" {
  bucket = "codebuild-${local.resource_suffix}"
}

resource "aws_s3_bucket_acl" "codebuild" {
  bucket = aws_s3_bucket.codebuild.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "codebuild" {
  bucket = aws_s3_bucket.codebuild.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "archive_file" "webapp" {
  type        = "zip"
  source_dir  = local.webapp_path
  output_path = "${path.root}/archives/webapp.zip"

  excludes = [
    "dist",
    "node_modules",
    ".env"
  ]
}

resource "aws_s3_object" "webapp" {
  bucket = aws_s3_bucket.codebuild.id
  key    = "webapp.zip"
  source = data.archive_file.webapp.output_path
  etag   = filemd5(data.archive_file.webapp.output_path)
}
