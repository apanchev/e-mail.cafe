resource "aws_s3_bucket" "inbox" {
  bucket = "inbox-${local.resource_suffix}"
}

resource "aws_s3_bucket_acl" "inbox" {
  bucket = aws_s3_bucket.inbox.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "inbox" {
  bucket = aws_s3_bucket.inbox.id
  policy = data.aws_iam_policy_document.inbox_policy.json
}

data "aws_iam_policy_document" "inbox_policy" {
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
      aws_s3_bucket.inbox.arn,
      "${aws_s3_bucket.inbox.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "delete" {
  bucket = aws_s3_bucket.inbox.id

  rule {
    id     = "delete-rule"
    status = "Enabled"

    filter {
      prefix = "inbox/"
    }

    expiration {
      days = 2
    }
  }
}
