# TLS certificate and key
resource "tls_private_key" "client" {
  count     = length(var.aws-vpn-client-list)
  algorithm = "RSA"
}
resource "tls_cert_request" "client" {
  count           = length(var.aws-vpn-client-list)
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.client[count.index].private_key_pem
  subject {
    common_name  = "${var.project-name}.${terraform.workspace}.vpn.${var.aws-vpn-client-list[count.index]}-client"
    organization = var.project-name
  }
}
resource "tls_locally_signed_cert" "client" {
  count                 = length(var.aws-vpn-client-list)
  cert_request_pem      = tls_cert_request.client[count.index].cert_request_pem
  ca_key_algorithm      = "RSA"
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = 87600
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}

# AWS ACM certificate
resource "aws_acm_certificate" "client" {
  count             = length(var.aws-vpn-client-list)
  private_key       = tls_private_key.client[count.index].private_key_pem
  certificate_body  = tls_locally_signed_cert.client[count.index].cert_pem
  certificate_chain = tls_self_signed_cert.ca.cert_pem
  tags = {
    Tier         = "Private"
    CostType     = "AlwaysCreated"
    BackupPolicy = "n/a"
  }
}

# AWS VPN config files generated to s3 bucket *.ovpn
resource "aws_s3_object" "vpn-config-file" {
  count                  = length(var.aws-vpn-client-list)
  bucket                 = aws_s3_bucket.vpn-config-files.id
  server_side_encryption = "aws:kms"
  key                    = "${var.aws-vpn-client-list[count.index]}-${lower(var.project-name)}-${terraform.workspace}-vpn.ovpn"
  content_base64 = base64encode(<<-EOT
client
dev tun
proto ${aws_ec2_client_vpn_endpoint.vpn-client.transport_protocol}
remote ${aws_ec2_client_vpn_endpoint.vpn-client.id}.prod.clientvpn.${data.aws_region.current.name}.amazonaws.com ${aws_ec2_client_vpn_endpoint.vpn-client.vpn_port}
remote-random-hostname
resolv-retry infinite
nobind
remote-cert-tls server
cipher AES-256-GCM
--inactive ${var.vpn_inactive_period} 100
verb 3

<ca>
${aws_ssm_parameter.vpn_ca_cert.value}
</ca>

reneg-sec 0

<cert>
${aws_ssm_parameter.vpn_client_cert[count.index].value}
</cert>

<key>
${aws_ssm_parameter.vpn_client_key[count.index].value}
</key>
    EOT
  )
}

# AWS SSM records
resource "aws_ssm_parameter" "vpn_client_key" {
  count       = length(var.aws-vpn-client-list)
  name        = "/${var.project-name}/${terraform.workspace}/acm/vpn/${var.aws-vpn-client-list[count.index]}_client_key"
  description = "VPN ${var.aws-vpn-client-list[count.index]} client key"
  type        = "SecureString"
  value       = tls_private_key.client[count.index].private_key_pem
  tags = {
    Name         = "VPN ${var.aws-vpn-client-list[count.index]} client key imported in AWS ACM"
    Tier         = "Private"
    CostType     = "AlwaysCreated"
    BackupPolicy = "n/a"
  }
}
resource "aws_ssm_parameter" "vpn_client_cert" {
  count       = length(var.aws-vpn-client-list)
  name        = "/${var.project-name}/${terraform.workspace}/acm/vpn/${var.aws-vpn-client-list[count.index]}_client_cert"
  description = "VPN ${var.aws-vpn-client-list[count.index]} client cert"
  type        = "SecureString"
  value       = tls_locally_signed_cert.client[count.index].cert_pem
  tags = {
    Name         = "VPN ${var.aws-vpn-client-list[count.index]} client cert imported in AWS ACM"
    Tier         = "Private"
    CostType     = "AlwaysCreated"
    BackupPolicy = "n/a"
  }
}
