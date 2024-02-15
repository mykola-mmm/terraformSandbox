resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_ssh_key" {
  key_name   = "ssh_key"
  public_key = tls_private_key.rsa-4096.public_key_openssh
}

resource "local_file" "ssh_key" {
  content  = tls_private_key.rsa-4096.private_key_pem
  filename = "${path.module}//ssh_key.pem"
  file_permission = "0400"
}