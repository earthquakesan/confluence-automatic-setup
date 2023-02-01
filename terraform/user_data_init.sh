#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
systemctl restart ssh

USER_ID=1000
GROUP_ID=1000
groupadd -g ${GROUP_ID} user
useradd -m -u ${USER_ID} -g ${GROUP_ID} -s /bin/bash user
mkdir -p /home/user/.ssh/
cp /root/.ssh/authorized_keys /home/user/.ssh/authorized_keys
chown --recursive ${USER_ID}:${GROUP_ID} /home/user/.ssh/
echo "user ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release make
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
docker run hello-world

usermod -aG docker user
