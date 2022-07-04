## template: jinja
#!/bin/sh

# install oci cli
echo "installing tools"
dnf -y install oraclelinux-developer-release-el8
dnf -y install python36-oci-cli

# get variables from cloud
echo "configuring variables"
export DOMAIN={{ ds.freeformTags.domain }}
export MAILGUN_DOMAIN={{ ds.freeformTags.mailgun_domain }}
export MAILGUN_SMTP_DOMAIN={{ ds.freeformTags.mailgun_smtp_domain }}
export MAILGUN_PASSWORD=`oci secrets secret-bundle get --auth instance_principal --secret-id {{ ds.freeformTags.mailgun_pass_oci }} --query='data."secret-bundle-content".content' --raw-output | base64 -d`

# configure firewall
echo "configuring firewall"
firewall-offline-cmd --zone=public --add-service=http
firewall-offline-cmd --zone=public --add-service=https

# setup utils
echo "configuring utils"
dnf install -y dnf-utils zip unzip git

# setup docker
echo "configuring docker"
yum remove -y docker docker-common docker-selinux docker-engine
dnf install -y docker-ce --nobest
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-compose-plugin --nobest
usermod -a -G docker opc
systemctl enable docker.service
systemctl start docker.service

# launch stack
echo "configuring stack"
su - opc -c "git clone https://github.com/alwaysmpe/ghost_stack.git"
su -p opc -c 'cd /home/opc/ghost_stack/ghost && printf "DOMAIN=${DOMAIN}\nMAILGUN_DOMAIN=${MAILGUN_DOMAIN}\nMAILGUN_SMTP_DOMAIN=${MAILGUN_SMTP_DOMAIN}\nMAILGUN_PASSWORD=${MAILGUN_PASSWORD}\n" > .env'
su - opc -c "cd ghost_stack/ghost && docker compose up --detach"
