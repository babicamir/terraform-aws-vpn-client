# Terraform module for AWS VPC Client VPN endpoint
This terraform module creates all necessary AWS services, certificates, keys, and *.ovpn configurations files.

With this module, you avoid the need to manually generate ca, server, client keys, and certificates, everything is automated. After generating all required keys and certificates, they are stored in AWS ACM and AWS SSM Parameter store.

Also, *.ovpn configurations files for VPN users are created and stored in an S3 bucket. These *.ovpn configurations files are ready to be used without any customization (adding client certificate and key), you just need to download one of generated *.ovpn files, import it into a VPN client, and connect to the targeted VPC network.

This terraform module is for AWS VPC Client VPN mutual authentication only.

Recomanded VPN client is OpenVPN, latest version you can download here: [Community Downloads](https://openvpn.net/community-downloads/).


## Usage

```hcl
module "vpn-client" {
  source  = "babicamir/vpn-client/aws"
  version = "{version}"
  organization_name      = "OrganizationName"
  project-name           = "MyProject"
  aws-vpn-client-list    = ["root", "user-1", "user2"]
  vpc_id                 = "{VPC id}"
  subnet_id              = "{subnet id}"
  client_cidr_block      = "172.0.0.0/22" # It must be different from the primary VPC CIDR
  split_tunnel           = "true" # or false
  vpn_inactive_period = "300" # seconds
  session_timeout_hours  = "8"
  logs_retention_in_days = "7"
}
```
### Creating additional client or user *.ovpn configuration  

To generate additional *.ovpn configuration for new user, you just need add new value in `aws-vpn-client-list    = ["root", "user-1", "new-user????"]` input variable.



## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.4.0 |


## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.4.0 |
| <a name="provider_tls"></a> [aws](#provider\_tls) | >= 3.1.0 |


## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| organization_name | Organization name!? | `string` | `[]` | yes |
| project-name | Project name!? | `string` | `[]` | yes |
| aws-vpn-client-list | VPN client list!? | `list(string)` | `[]` | yes |
| vpc_id | VPC ID | `string` | `[]` | yes |
| subnet_id | Subnet for client vpn network association | `string` | `[]` | yes |
| client_cidr_block | AWS VPN client cidr block. It must be different from the primary VPC CIDR | `string` | `[]` | yes |
| split_tunnel | Split tunnel traffic (true or false) | `bool` | `[]` | yes |
| vpn_inactive_period | VPN inactive period in seconds | `number` | `[]` | yes |
| session_timeout_hours | Session timeout hours | `number` | `[]` | yes |
| logs_retention_in_days | VPN client list!? | `number` | `[]` | yes |


## Outputs
| Name | Description |
|------|-------------|
| <a name="aws_ec2_client_vpn_endpoint"></a> [aws_ec2_client_vpn_endpoint](#output\_aws_ec2_client_vpn_endpoint) | All attributes for resource for: aws_ec2_client_vpn_endpoint |
| <a name="aws_vpn_security_group"></a> [aws_vpn_security_group](#output\_aws_vpn_security_group) | All attributes for resource for: aws_vpn_security_group |
 
## Additional info
More info about AWS Client VPN and Terraform you can found on following links:
- [What is AWS Client VPN?](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/what-is.html)
- [How AWS Client VPN works?](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/how-it-works.html)
- [Mutual authentication](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html#mutual)
- [AWS Client VPN quotas](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/limits.html)
- [Troubleshooting Client VPN](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/troubleshooting.html)
- [Terraform Documentation](https://www.terraform.io/docs)


