data "aws_acm_certificate" "cert" {
  domain      = "wbsecurecloud.dev"
  statuses    = ["ISSUED"]
  most_recent = true
}
# looks inside certificate manager for the cname certificate instead of hardcoding it

resource "aws_wafv2_web_acl_association" "wordpres-waf-association" {
     resource_arn = aws_lb.load-balancer-us-east-1
     web_acl_arn = aws_wafv2_web_acl.wordpress-waf
}
# attaches the the WAF web ACL to the ALB
resource "aws_wafv2_web_acl" "wordpress-waf" {
   name = "wordpress-waf"
   scope = "REGIONAL" 
# defines the acl as a regional service as the ALB spans across all the AZs within the region
   default_action {
     allow {}
   }
   # for any action that doesnt match the block criteria (ON ALLOW BECAUSE ITS A PUBLIC WEBSITE)
   visibility_config {
     cloudwatch_metrics_enabled = true
     # sends WAF allowed + denied traffic counts to cloudwatch metrics for data
     metric_name = "wordpress-waf-metrics"
     sampled_requests_enabled = true
     # stores waf individual allowed + denied traffic for inspection
   }
   
}
resource "aws_wafv2_rule_group "wordpress-waf-rulegroup" {
    name = "wordpress-waf-rulegroup" 
    priority = 3

    overide_action {
      none {}
    }

    statement {}
}
# creates a group holding all of the rules associated with the WAF

