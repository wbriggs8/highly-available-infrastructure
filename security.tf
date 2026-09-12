data "aws_acm_certificate" "cert" {
  domain      = "wbsecurecloud.dev"
  statuses    = ["ISSUED"]
  most_recent = true
}
# looks inside acm for the cname certificate instead of hardcoding it

# create waf