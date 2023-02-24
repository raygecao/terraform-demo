variable "external_port" {
  description = "External port for expose guestbook service"
  type = number
}

variable "guestbook_image_tag" {
  description = "The image tag for guestbook"
  type = string
}
