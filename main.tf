data "aws_vpc" "default" {
  default = true
}

# The domain in the private zone will literally be example.com
resource "aws_route53_zone" "private" {
  name = "example.com"

  vpc {
    vpc_id = data.aws_vpc.default.id
  }
}

data "aws_subnets" "instance" {
  filter {
    name   = "availability-zone"
    values = [var.instance_az]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create a "client" instance from which to do the DNS lookup
module "client" {
  source           = "git@github.com:skiscontent/terraform-library.git//modules/ec2"
  instance_name    = "client-${var.aws_region}"
  instance_type    = var.instance_type
  key_name         = null
  ami              = null
  vpc_id           = data.aws_vpc.default.id
  subnet_id        = data.aws_subnets.instance.ids[0]
  associate_public = true
  tags             = var.default_tags
}

# Create a "server" instance that will have the same DNS name in multiple zones
module "server" {
  source        = "git@github.com:skiscontent/terraform-library.git//modules/ec2"
  instance_name = "server-${var.aws_region}"
  instance_type = var.instance_type
  key_name      = null
  vpc_id        = data.aws_vpc.default.id
  subnet_id     = data.aws_subnets.instance.ids[0]
  tags          = var.default_tags
}

# Create the DNS record
resource "aws_route53_record" "server" {
  zone_id = aws_route53_zone.private.id
  name    = "foo.example.com"
  type    = "A"
  ttl     = 300
  records = [module.server.instance_ip]
}
