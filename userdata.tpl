#!/bin/bash
sudo apt-get update -y &&
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
python3-pip \
curl \
gnupg-agent \
software-properties-common &&
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
# sudo apt-get update -y &&
# sudo sudo apt-get install docker-ce docker-ce-cli containerd.io -y &&
# sudo usermod -aG docker ubuntu

python3 -m pip install flask &&
cd /home/ubuntu &&
git clone https://github.com/ramibo/ssrf_aws_demo.git &&
cd ssrf_aws_demo/ssrf_vuln_app/ &&
python3 -m flask run --host=0.0.0.0 &&