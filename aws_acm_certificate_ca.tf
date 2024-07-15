# AWS ACM certificate CA 
resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name  = "${var.project-name}.${var.environment}.vpn.ca"
    organization = var.project-name
  }
  validity_period_hours = 87600
  is_ca_certificate     = true
  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

# AWS ACM certificate
resource "aws_acm_certificate" "ca" {
  private_key      = tls_private_key.ca.private_key_pem
  certificate_body = tls_self_signed_cert.ca.cert_pem
  tags             = merge(var.tags, )
}

# AWS SSM records
resource "aws_ssm_parameter" "vpn_ca_key" {
  name        = "/${var.project-name}/${var.environment}/acm/vpn/ca_key"
  description = "VPN CA key"
  type        = "SecureString"
  value       = tls_private_key.ca.private_key_pem
  tags        = merge(var.tags, )

}
resource "aws_ssm_parameter" "vpn_ca_cert" {
  name        = "/${var.project-name}/${var.environment}/acm/vpn/ca_cert"
  description = "VPN CA cert"
  type        = "SecureString"
  value       = tls_self_signed_cert.ca.cert_pem
  tags        = merge(var.tags, )
}