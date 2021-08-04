# Deploy Workadventure

This repo aims to document our effort to run thecodingmachine/workadventure on an AWS EC2 instance behind nginx as a reverse proxy.

## steps to reproduce

- Create a terraform cloud account
- Create an AWS account
- Install terraform (see [this tutorial](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started))
- Setup your aws cli and credentials (see [this tutorial](https://learn.hashicorp.com/tutorials/terraform/aws-build?in=terraform/aws-get-started))
- Create an ssh key
- Add the public key to `iac/dev/data/key`
- Run `cd iac/dev`
- Run `terraform init`
- Run `terraform apply`
- ssh into your new ec2 instance
- Is nginx running (tbd)?
- Get a domain
- Create a DNS entry that points to your public (elastic) IP
- Install snap, certbot and run it (see [this tutorial](https://certbot.eff.org/lets-encrypt/ubuntufocal-nginx))
- Unlink the default nginx config `sudo unlink /etc/nginx/sites-enabled/default`
- Copy `nginx/pixel.conf` to `/etc/nginx/sites-enabled/pixel.conf`
- Adjust the domain name in `pixel.conf` with your domain. (Compare it also with `/etc/nginx/sites-enabled/default`)
- (For now\*) Clone the original repo `git clone -b v1.4.12 –depth 1 https://github.com/thecodingmachine/workadventure.git.`
- Copy the file `docker-compose.single-domain-from-source.yml` (tbd) into the root of the repo.
- Copy the file `.env.template` to `.env` in the root of the cloned repo
- Run `sudo docker-compose.single-domain-from-source.yml up`
- Visit your domain



\* We hope to have a docker-compose setup that uses the images rather then building from source.


## Todo

- [ ] Remove dependency to source. (Use prebuild images only)
- [ ] Give the ec2 some more disk space
- [ ] Test the cloud-init setup

