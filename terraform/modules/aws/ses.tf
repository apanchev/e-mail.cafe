locals {
  ses_object_key_prefix = "ses_receipt_mail_queue/"
}

resource "aws_ses_domain_identity" "main" {
  domain = var.domain_name
}

resource "aws_ses_domain_identity_verification" "main" {
  domain = aws_ses_domain_identity.main.id

  depends_on = [
    aws_route53_record.ses_verification_record
  ]
}

resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

resource "aws_ses_receipt_rule_set" "main" {
  rule_set_name = "main-rule-set"
}

resource "aws_ses_receipt_rule" "store" {
  name          = "store"
  rule_set_name = aws_ses_receipt_rule_set.main.id
  enabled       = true

  s3_action {
    bucket_name       = aws_s3_bucket.inbox.id
    object_key_prefix = local.ses_object_key_prefix
    position          = 1
  }

  lambda_action {
    function_arn = aws_lambda_function.email_process.arn
    position     = 2
  }
}

resource "aws_ses_active_receipt_rule_set" "main" {
  rule_set_name = aws_ses_receipt_rule_set.main.id
}
