locals {
  zipped_lambda_path = "${path.module}/archives/email_process.zip"
}

data "archive_file" "email_process" {
  type        = "zip"
  source_file = "${path.module}/lambda/email_process.py"
  output_path = local.zipped_lambda_path
}

################################################################################
# Lambda function definition
################################################################################

resource "aws_lambda_function" "email_process" {
  filename      = local.zipped_lambda_path
  function_name = "email-process-${local.resource_suffix}"
  role          = aws_iam_role.email_process.arn
  handler       = "email_process.lambda_handler"

  source_code_hash = data.archive_file.email_process.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      BUCKET_NAME           = aws_s3_bucket.inbox.id,
      SES_OBJECT_KEY_PREFIX = local.ses_object_key_prefix
    }
  }

  depends_on = [
    data.archive_file.email_process,
  ]
}

resource "aws_lambda_permission" "email_process_allow_ses" {
  statement_id  = "AllowExecutionFromSES"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_process.function_name
  principal     = "ses.amazonaws.com"
}

################################################################################
# IAM role definition
################################################################################

resource "aws_iam_role" "email_process" {
  name               = "email-process-${local.resource_suffix}"
  assume_role_policy = data.aws_iam_policy_document.email_process_assume_role_policy.json
}
data "aws_iam_policy_document" "email_process_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "email_process_role_policy" {
  role   = aws_iam_role.email_process.name
  policy = data.aws_iam_policy_document.email_process_role_policy.json
}
data "aws_iam_policy_document" "email_process_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket*",
      "s3:GetBucket*",
    ]
    resources = [
      aws_s3_bucket.inbox.arn,
    ]
  }
  statement {
    effect  = "Allow"
    actions = ["s3:Put*"]
    resources = [
      "${aws_s3_bucket.inbox.arn}/inbox/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject*",
      "s3:DeleteObject*",
    ]
    resources = [
      "${aws_s3_bucket.inbox.arn}/${local.ses_object_key_prefix}*",
    ]
  }
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  name = "AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy_attachment" "email_process_role_attachment" {
  role       = aws_iam_role.email_process.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}