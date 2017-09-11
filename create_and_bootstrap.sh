#!/bin/bash

set -x

echo "Hello! starting $(date)"

sudo rm -rf bowcuff.img
singularity create -s 2048 bowcuff.img
sudo singularity bootstrap bowcuff.img ubuntu.sh

echo "Goodbye! ending $(date)"
