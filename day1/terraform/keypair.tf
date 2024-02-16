# Bastion Key Pair
resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_ssh_key" {
  key_name   = "ssh_key"
  public_key = tls_private_key.rsa-4096.public_key_openssh
}

resource "local_file" "bastion_ssh_filekey" {
  content         = tls_private_key.rsa-4096.private_key_pem
  filename        = "${path.module}/ssh_key.pem"
  file_permission = "0400"
}

# Backend Key Pair
resource "tls_private_key" "rsa-4096-backend" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "backend_ssh_key" {
  key_name   = "backend_ssh_key"
  public_key = tls_private_key.rsa-4096-backend.public_key_openssh
}

resource "local_file" "backend_ssh_filekey" {
  content         = tls_private_key.rsa-4096-backend.private_key_pem
  filename        = "${path.module}/ssh_key_backend.pem"
  file_permission = "0400"
}