data "aws_route53_zone" "main" {
  name = var.domain_name
}

################################################################################
# Mail DNS configuration
################################################################################

resource "aws_route53_record" "ses_mx_config" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "MX"
  ttl     = "60"
  records = ["10 inbound-smtp.${var.region}.amazonaws.com"]
}

resource "aws_route53_record" "ses_verification_record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "_amazonses.${var.domain_name}"
  type    = "TXT"
  ttl     = "60"
  records = [aws_ses_domain_identity.main.verification_token]
}

resource "aws_route53_record" "ses_dkim_record" {
  count = 3

  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${aws_ses_domain_dkim.main.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_ses_domain_dkim.main.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

################################################################################
# Apprunner DNS configuration
################################################################################

resource "aws_route53_record" "apprunner" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    evaluate_target_health = false
    name                   = aws_apprunner_custom_domain_association.webapp.dns_target
    zone_id                = "Z087551914Z2PCAU0QHMW" # Ref => https://docs.aws.amazon.com/general/latest/gr/apprunner.html
  }
}

resource "aws_route53_record" "apprunner_acm_val_record0" {
  for_each = {
    for record in tolist(aws_apprunner_custom_domain_association.webapp.certificate_validation_records): record.name => record
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.value]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}