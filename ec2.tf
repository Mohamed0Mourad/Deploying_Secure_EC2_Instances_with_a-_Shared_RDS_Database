resource "aws_instance" "app_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.app_subnet_1.id
  security_groups = [aws_security_group.app_sg.name]

  tags = {
    Name = "AppInstance"
  }
}
