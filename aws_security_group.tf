# AWS security group
resource "aws_security_group" "vpn" {
  name        = "${var.project-name}-${terraform.workspace}-vpn-security-group"
  description = "${var.project-name}-${terraform.workspace}-vpn-security-group"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project-name}-${terraform.workspace}-vpn-security-group"
  }
}
