# Public subnets (2 AZs)
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.azs[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index) # 10.0.0.0/24, 10.0.1.0/24
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-public-${count.index + 1}"
    Tier = "public"
  })
}

# Private subnets (2 AZs)
resource "aws_subnet" "private" {
  count                   = 2
  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.azs[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 10) # 10.0.10.0/24, 10.0.11.0/24
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.project}-${var.env}-private-${count.index + 1}"
    Tier = "private"
  })
}
