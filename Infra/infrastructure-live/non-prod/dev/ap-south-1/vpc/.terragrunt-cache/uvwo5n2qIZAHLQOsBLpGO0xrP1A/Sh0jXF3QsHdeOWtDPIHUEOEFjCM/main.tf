
locals{
    subnet_map = {
        for subnet in var.subnets : "${subnet.private ? "private" : "public"}-subnet-${substr("${subnet.az}", -2, -1)}" => subnet
    }
    route_tables = {"0": "private", "1": "public"}

    private_route_map = { for route in var.nat_gw_routes : "private" => route }
    public_route_map = { for route in var.igw_routes : "public" => route }

    route_map = merge(local.private_route_map, local.public_route_map)
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { 
    Name = "${var.deduced_name}-vpc"
  })
}

resource "aws_subnet" "this" {
  for_each          = local.subnet_map
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.deduced_name}-${each.key}"
  })
}

resource "aws_eip" "this" {
  tags = merge(var.tags, { 
    Name = "${var.deduced_name}-nat-ip"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { 
    Name = "${var.deduced_name}-igw"
  })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = aws_subnet.this["public-subnet-${substr(var.subnets[0].az, -2, -1)}"].id

  tags = merge(var.tags, { 
    Name = "${var.deduced_name}-nat-gw"
  })
}

resource "aws_route_table" "this" {
  for_each = local.route_tables

  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.deduced_name}-${each.value}-route-table"
  })
}

resource "aws_route_table_association" "this" {
  for_each = local.subnet_map

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = each.value.private ? aws_route_table.this["0"].id : aws_route_table.this["1"].id
}

resource "aws_route" "this" {
  for_each = local.route_map
  route_table_id          = each.key == "private" ? aws_route_table.this["0"].id : aws_route_table.this["1"].id
  destination_cidr_block  = each.value
  nat_gateway_id          = each.key == "private" ? aws_nat_gateway.this.id : null
  gateway_id              = each.key == "public" ? aws_internet_gateway.this.id : null
}