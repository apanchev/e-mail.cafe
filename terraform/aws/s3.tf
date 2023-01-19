resource "aws_s3_bucket" "mail" {
  bucket = "email-folder-${local.resource_suffix}"
}

resource "aws_s3_bucket_acl" "mail" {
  bucket = aws_s3_bucket.mail.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "mail" {
  bucket = aws_s3_bucket.mail.id
  policy = data.aws_iam_policy_document.mail_policy.json
}

data "aws_iam_policy_document" "mail_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      aws_s3_bucket.mail.arn,
      "${aws_s3_bucket.mail.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}
