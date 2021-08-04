data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  # Main cloud-config configuration file.
  part {
    content_type = "text/cloud-config"
    content      = "packages: ['zsh', 'apt-transport-https', 'ca-certificates', 'curl' ,'software-properties-common', 'htop', 'nginx']"
  }

  part {
    content_type = "text/cloud-config"
    content      = "package_update: true"
  }

  part {
    content_type = "text/x-shellscript"
    content      = <<EOF
#!/usr/bin/env bash
set -euo pipefail
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install -y docker-ce
    EOF
  }
  part {
    content_type = "text/x-shellscript"
    content      = <<EOF
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

  EOF
  }

}
