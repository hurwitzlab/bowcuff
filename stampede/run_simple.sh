#!/bin/bash

#SBATCH -J bowtie2
#SBATCH -A iPlant-Collabs 
#SBATCH -N 4
#SBATCH -n 1
#SBATCH -t 24:00:00
#SBATCH -p normal

# Author: Scott G. Daniel <scottdaniel@email.arizona.edu>

###Uncomment when back on tacc#
#module load tacc-singularity 
#module load launcher

#
# Set up defaults for inputs, constants
#
SING_IMG="bowtie_sam.img" #-S | --sing-img
# can do rest in python because its better

#check for centrifuge image
if [[ ! -e "$SING_IMG" ]]; then
    echo "Missing SING_IMG \"$SING_IMG\""
    exit 1
fi

#
# Some needed functions
#
#function lc() { 
#    wc -l "$1" | cut -d ' ' -f 1 
#}

function HELP() {

    singularity exec $SING_IMG cufflinks.py -h
    
    exit 0
}

#
# Show HELP if no arguments
#
[[ $# -eq 0 ]] && echo "Need some arguments" && HELP

set -u

# In case you wanted to check what variables were passed
#echo "ARG = $*"

#Run bowtie_batch
singularity exec $SING_IMG cufflinks.py $@

echo "Log messages will be in "$OUT_DIR"/cufflinks.log by default"
echo "Comments to Scott Daniel <scottdaniel@email.arizona.edu>"

