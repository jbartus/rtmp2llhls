# generate a two hex character random suffix to avoid namespace collisions
resource "random_id" "rid" {
  byte_length = 1
}

locals {
  rid = random_id.rid.hex
}