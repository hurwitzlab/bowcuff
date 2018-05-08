#!/bin/bash

#SBATCH -A iPlant-Collabs
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 02:00:00
#SBATCH -p development
#SBATCH -J cntrfuge
#SBATCH --mail-type BEGIN,END,FAIL
#SBATCH --mail-user scottdaniel@email.arizona.edu

#for local testing#####
#if the singularity.conf is right, then /vagrant should be auto-shared
export WORK="/vagrant"
########################

export OUT_DIR="$WORK/cufflinks_test"

#export MY_PARAMRUN="$HOME/launcher/paramrun"

[[ -d "$OUT_DIR" ]] && rm -rf $OUT_DIR/*

#-i "$WORK/genomes"

bash run.sh \
    -o $OUT_DIR -t 4 \
    -g $WORK/genomes \
    $WORK/cancer_out/bowtie2-run.bam \
    $WORK/control_out/bowtie2-run.bam
