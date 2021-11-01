resource "consul_config_entry" "product_api_intentions" {
  name = "${var.name}-product-api"
  kind = "service-intentions"

  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = "${var.name}-public-api"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
}

resource "consul_config_entry" "public_api_intentions" {
  name = "${var.name}-public-api"
  kind = "service-intentions"

  config_json = jsonencode({
    Sources = [
      {
        Action     = "allow"
        Name       = "${var.name}-frontend"
        Precedence = 9
        Type       = "consul"
      }
    ]
  })
}