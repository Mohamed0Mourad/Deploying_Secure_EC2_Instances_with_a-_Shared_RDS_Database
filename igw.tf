resource "aws_internet_gateway" "AppIGW" {
  vpc_id = aws_vpc.AppVPC.id

  tags = {
    Name = "AppInternetGateway"
  }
}

resource "aws_route_table" "AppRouteTable" {
  vpc_id = aws_vpc.AppVPC.id
  tags = {
    Name = "AppRouteTable"
  }
}

output "route_table_ID" {
  value = aws_route_table.AppRouteTable.id
}


resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.AppRouteTable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.AppIGW.id
}

