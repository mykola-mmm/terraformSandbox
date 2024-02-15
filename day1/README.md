
Implementing AWS bastion host over ssh tunnel

WARNING: since I am working within wsl hosted at win machine the generated key always have "bad" permissions for ssh command. 

[code-block]
cp ./ssh_key.pem ~/.ssh/ssh_key.pem
sudo chmod 400 ~/.ssh/ssh_key.pem
ssh -i ~/.ssh/ssh_key.pem <user>@<ip>

![Example Image](./assets/images/aws_bastion_example.png "Architecture reference")