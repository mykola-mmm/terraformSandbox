
# Implementing AWS bastion host over ssh tunnel

> [!WARNING]
> since I am working within wsl hosted at win machine the generated key always have "bad" permissions for ssh command. 

> [!TIP]
> moving file into wsl root allows to chmod to 400
```
cp ./ssh_key.pem ~/.ssh/ssh_key.pem
sudo chmod 400 ~/.ssh/ssh_key.pem
ssh -i ~/.ssh/ssh_key.pem <user>@<ip>
```

> [!TIP]
> since the *.tf were moved to ./terraform to configure terraform apply to work from root dir this command is needed (file moved just for the esthetic purpose)
```
terraform -chdir=terraform init
```

![Wat dis do](./assets/images/aws_bastion_example.png "Architecture reference")