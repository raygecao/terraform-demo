terraform {
  source = "../../../modules/docker"
}

inputs = {
  external_port = "13000"
  guestbook_image_tag = "v2"
}
