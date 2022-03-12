output "aws_ec2_client_vpn_endpoint" {
  value = aws_ec2_client_vpn_endpoint.vpn-client
}
output "aws_vpn_security_group" {
  value = aws_security_group.vpn
}