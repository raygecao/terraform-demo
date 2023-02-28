variable "available_zone" {
  description = "the az for the region"
  type = string
  default = "ap-northeast-1a"
}

variable "vpc_cidr_block" {
  description = "the cidr block for the vpc"
  type = string
}

variable "subnet_cidr_block" {
  description = "the cidr block for the subnet"
  type = string
}
