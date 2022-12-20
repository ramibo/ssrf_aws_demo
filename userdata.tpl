#!/bin/bash
sudo apt-get update -y &&
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
python3-pip \
curl \
gnupg-agent \
software-properties-common &&
sudo apt-get update -y &&
python3 -m pip install flask &&
cd /home/ubuntu &&
rm -rf ssrf_aws_demo &&
git clone https://github.com/ramibo/ssrf_aws_demo.git &&
cd ssrf_aws_demo/ssrf_vuln_app/ &&
python3 -m flask run --host=0.0.0.0