output "bastion_public_ip" {
  value = aws_instance.bastion_server.public_ip
}

output "username" {
    value = var.username
}

output "bastion_ssh_key" {
    value = local_file.bastion_ssh_filekey.filename
}

output "backend_ssh_key" {
    value = local_file.backend_ssh_filekey.filename
}