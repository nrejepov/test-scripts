#!/bin/sh
yum install -y wget
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce-3:27.1.1-1.el9
mkdir -p /certs
wget -O /certs/ca.pem https://raw.githubusercontent.com/cloudacademy/docker-software-delivery/master/.certs/ca.crt
wget -O /certs/cert.pem https://raw.githubusercontent.com/cloudacademy/docker-software-delivery/master/.certs/reg.cert
wget -O /certs/key.pem https://raw.githubusercontent.com/cloudacademy/docker-software-delivery/master/.certs/reg.key
mkdir -p /etc/docker
echo '{"hosts":["unix:///var/run/docker.sock","tcp://0.0.0.0:2376"],"tls":true,"tlsverify":true,"tlscacert":"/certs/ca.pem","tlscert":"/certs/cert.pem","tlskey":"/certs/key.pem"}' > /etc/docker/daemon.json
sed -i "s#ExecStart=/usr/bin/dockerd -H fd://#ExecStart=/usr/bin/dockerd#g" /usr/lib/systemd/system/docker.service
systemctl enable docker
systemctl start docker
usermod -aG docker student
echo 10.0.0.5 registry.ca-labs.com >> /etc/hosts
echo 10.0.0.6 production.ca-labs.com >> /etc/hosts
mkdir -p /etc/docker/certs.d/registry.ca-labs.com:5000/
cp /certs/cert.pem /etc/docker/certs.d/registry.ca-labs.com:5000/ca.crt
curl -L https://github.com/docker/compose/releases/download/2.29.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose