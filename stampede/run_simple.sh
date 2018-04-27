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
#INPUT_DIR="./" #-i | --input-dir
#READS_DIR="./" #-r | --reads | --reads-dir
#INPUT_DB="genome.fna" #-d | --db | --input-db
#INPUT_FMT="fastq" #-f | --fmt | --input-format
#KEEP_SAM="FALSE" #-k | --keep-sam
#MERGE_OUTPUT="FALSE" #-m | --merge-args
#MERGE_NAME="bowtie2-run.sam" #-n | --merge-name
#REMOVE_TMP="FALSE" #-z | --remove-tmp
#LOG_FN="bowtie2-read-mapping.log" #-l | --log-file
#ALIGN_TYPE="end-to-end" #-a | --alignment-type
#GLOBAL_PRESETS="sensitive" #-e | --end-to-end-presets
#LOCAL_PRESETS="sensitive-local" #-c | --local-presets
#NON_DETERMINISTIC="FALSE" #-N | --non-deterministic
#MININS="0" #-I | --minins
#MAXINS="2000" #-X | --maxins
#THREADS="1" #-t | --threads
SING_IMG="bowtie_sam.img" #-S | --sing-img
#OUT_DIR="./out_dir" #-O | --out-dir

#check for centrifuge image
if [[ ! -e "$SING_IMG" ]]; then
    echo "Missing SING_IMG \"$SING_IMG\""
    exit 1
fi

#
# Some needed functions
#
function lc() { 
    wc -l "$1" | cut -d ' ' -f 1 
}

function HELP() {

    singularity exec $SING_IMG patric_bowtie2.py -h
    
    exit 0
}

#
# Show HELP if no arguments
#
[[ $# -eq 0 ]] && echo "Need some arguments" && HELP

set -u

# In case you wanted to check what variables were passed
#echo "ARG = $*"

#
# Verify existence of various directories, files
# Don't need this if python script is already checking
#

#Run bowtie_batch
singularity exec $SING_IMG patric_bowtie2.py $@

echo "Log messages will be in "$OUT_DIR"/bowtie2-read-mapping.log by default"
echo "Comments to Scott Daniel <scottdaniel@email.arizona.edu>"

