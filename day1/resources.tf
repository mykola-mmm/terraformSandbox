resource "aws_instance" "bastion_server" {
  ami             = "ami-03cceb19496c25679"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.dmz_public_subnet.id
  security_groups = [aws_security_group.ssh_bastion_sg.id]
  key_name        = aws_key_pair.bastion_ssh_key.key_name

  tags = {
    Name = "bastion-server"
  }
}
