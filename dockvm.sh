#!/bin/sh
yum install -y wget
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce-3:27.1.1-1.el9
mkdir -p /certs
wget -O /certs/ca.pem https://raw.githubusercontent.com/cloudacademy/docker-software-delivery/master/.certs/ca.crt
wget -O /certs/cert.pem https://raw.githubusercontent.com/cloudacademy/docker-software-delivery/master/.certs/server.cert
wget -O /certs/key.pem https://raw.githubusercontent.com/cloudacademy/docker-software-delivery/master/.certs/server.key
mkdir -p /etc/docker
echo '{"hosts":["unix:///var/run/docker.sock","tcp://0.0.0.0:2376"],"tls":true,"tlsverify":true,"tlscacert":"/certs/ca.pem","tlscert":"/certs/cert.pem","tlskey":"/certs/key.pem"}' > /etc/docker/daemon.json
sed -i 's#^ExecStart=/usr/bin/dockerd -H fd://#ExecStart=/usr/bin/dockerd#g' /usr/lib/systemd/system/docker.service
systemctl enable docker
systemctl start docker
usermod -aG docker student
echo 10.0.0.5 registry.ca-labs.com >> /etc/hosts
echo 10.0.0.6 production.ca-labs.com >> /etc/hosts
mkdir -p /etc/docker/certs.d/registry.ca-labs.com:5000/
wget -O /etc/docker/certs.d/registry.ca-labs.com:5000/ca.crt https://raw.githubusercontent.com/cloudacademy/docker-software-delivery/master/.certs/reg.cert
curl -SL https://github.com/docker/compose/releases/download/v2.29.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
sed -i 's/^GSSAPIAuthentication yes/#GSSAPIAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd
