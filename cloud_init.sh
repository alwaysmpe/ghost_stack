## template: jinja
#!/bin/sh

# get variables from cloud
export DOMAIN={{ ds.freeformTags.domain }}
export MAILGUN_USER={{ ds.freeformTags.mailgun_user }}
export MAILGUN_DOMAIN={{ ds.freeformTags.mailgun_domain }}
export MAILGUN_PASSWORD=`oci secrets secret-bundle get --secret-id {{ ds.freeformTags.mailgun_pass_oci }} --query='data."secret-bundle-content".content' --raw-output | base64 -d`

# configure firewall
sudo firewall-cmd --zone=public --add-service=http
sudo firewall-cmd --zone=public --add-service=http --permanent
sudo firewall-cmd --zone=public --add-service=https
sudo firewall-cmd --zone=public --add-service=https --permanent

# setup utils
sudo dnf install -y dnf-utils zip unzip git

# setup docker
sudo yum remove -y docker docker-common docker-selinux docker-engine
sudo dnf install -y docker-ce --nobest
sudo dnf config-manager -add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-compose-plugin --nobest
sudo usermod -a -G docker opc
newgrp docker

# launch stack
git clone https://github.com/alwaysmpe/ghost_stack.git
cd ghost_stack/ghost
docker compose up
