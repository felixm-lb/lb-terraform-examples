#!/bin/bash

sudo apt update -y && sudo apt upgrade -y
sudo apt install -y linux-modules-extra-aws
sudo modprobe nvme-tcp
sudo apt install -y nvme-cli