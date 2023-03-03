terraform {
  source = "../../../modules/docker"
}

inputs = {
  external_port = 14000
  guestbook_image_tag = "v2"
  guestbook_env = "dev"
}
