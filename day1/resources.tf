resource "aws_instance" "bastion_server" {
  ami             = "ami-03cceb19496c25679"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.dmz_public_subnet.id
  security_groups = [aws_security_group.ssh_bastion_sg.id]
  key_name        = aws_key_pair.bastion_ssh_key.key_name

  tags = {
    Name = "bastion-server"
  }


  provisioner "file" {
    source = local_file.backend_ssh_filekey.filename
    destination = "/home/ec2-user/.ssh/"
    connection {
      type        = "ssh"
      user        = var.username
      private_key = tls_private_key.rsa-4096.private_key_pem
      host        = self.public_ip
    }
  }

  # provisioner "local-exec" {
  #   command = "cp ${local_file.bastion_ssh_filekey.filename} ~/.ssh/test_provisioner.pem"
  
  # }
}

resource "aws_instance" "backend_instance" {
  ami             = "ami-03cceb19496c25679"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.backend_private_subnet.id
  security_groups = [aws_security_group.backend_private_sg.id]
  key_name        = aws_key_pair.backend_ssh_key.key_name
  tags = {
    Name = "backend-instance"
  }
}
