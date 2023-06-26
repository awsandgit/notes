#!/bin/bash

#Modify_according_to_your_region_code
BUCKET_NAME="aws-codedeploy-us-east-1"
REGION_IDENTIFIER="us-east-1"

sudo apt update
sudo apt install ruby-full -y
sudo apt install wget -y
cd /tmp
wget "https://${BUCKET_NAME}.s3.${REGION_IDENTIFIER}.amazonaws.com/latest/install"
chmod +x ./install
sudo ./install auto
sudo systemctl start codedeploy-agent

#Install nodejs
sudo apt install curl -y
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
