variable "external_port" {
  description = "External port for expose guestbook service"
  type = number
}

variable "guestbook_version" {
  description = "The version for the guestbook app"
  type = string
  default = "v1"
}
