variable "organization_name" {
  description = "Organization name!?"
  type        = string
}
variable "project-name" {
  description = "Project name!?"
  type        = string
}
variable "aws-vpn-client-list" {
  description = "VPN client list!?"
  type        = set(string)
}
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
variable "subnet_id" {
  description = "Subnet for client vpn network association"
  type        = string
}
variable "client_cidr_block" {
  description = "AWS VPN client cidr block"
  type        = string
}
variable "split_tunnel" {
  description = "Split tunnel traffic"
  type        = bool
}
variable "vpn_inactive_period" {
  description = "VPN inactive period in seconds"
  type        = number
}
variable "session_timeout_hours" {
  description = "Session timeout hours"
  type        = number
}
variable "logs_retention_in_days" {
  description = "VPN client list!?"
  type        = number
}