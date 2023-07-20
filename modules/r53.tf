resource "aws_route53_zone" "objectbased" {
  name = "objectbased.net"
}

resource "aws_route53_record" "splunk_ec2" {
  zone_id = aws_route53_zone.objectbased.zone_id
  name    = "splunk.objectbased.net"
  type    = "A"

  records = [
    aws_instance.splunk_single_node.public_ip
  ]

  ttl = "300"
}