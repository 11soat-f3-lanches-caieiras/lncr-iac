data "aws_default_tags" "tags" {}
data "aws_caller_identity" "current" {}
# data "aws_ecrpublic_authorization_token" "token" {
#   provider = aws.virginia
# }
# data "external" "nlb_dns_name" {
#   program = ["bash", "${path.module}/get_nlb_dns.sh"]
# }