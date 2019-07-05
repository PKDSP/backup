#!/bin/bash
sudo apt-get update
sudo apt-get install -y curl
sudo curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -
sudo apt-get install -y nodejs 