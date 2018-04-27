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
# Some needed functions
#
function lc() { 
    wc -l "$1" | cut -d ' ' -f 1 
}

function HELP() {
    
    echo "INPUT_DIR="./" #-i | --input-dir"
    echo "READS_DIR="./" #-r | --reads | --reads-dir"
    echo "INPUT_DB="genome.fna" #-d | --db | --input-db"
    echo "INPUT_FMT="fastq" #-f | --fmt | --input-format"
    echo "KEEP_SAM="FALSE" #-k | --keep-sam"
    echo "MERGE_OUTPUT="FALSE" #-m | --merge-args"
    echo "MERGE_NAME="bowtie2-run.sam" #-n | --merge-name"
    echo "REMOVE_TMP="FALSE" #-z | --remove-tmp"
    echo "LOG_FN="bowtie2-read-mapping.log" #-l | --log-file"
    echo "ALIGN_TYPE="end-to-end" #-a | --alignment-type"
    echo "GLOBAL_PRESETS="sensitive" #-e | --end-to-end-presets"
    echo "LOCAL_PRESETS="sensitive-local" #-c | --local-presets"
    echo "NON_DETERMINISTIC="FALSE" #-N | --non-deterministic"
    echo "MININS="0" #-I | --minins"
    echo "MAXINS="2000" #-X | --maxins"
    echo "THREADS="1" #-t | --threads"
    echo "SING_IMG="bowtie_sam.img" #-S | --sing-img"
    echo "OUT_DIR="./out_dir" #-O | --out-dir"

    echo "See bowtie_batch.py for additional help"
    exit 0
}

#
# Show HELP if no arguments
#
[[ $# -eq 0 ]] && echo "Need some arguments" && HELP

set -u

#
# Set up defaults for inputs, constants
#

INPUT_DIR="./" #-i | --input-dir
READS_DIR="./" #-r | --reads | --reads-dir
INPUT_DB=""$INPUT_DIR"/genome.fna" #-d | --db | --input-db
INPUT_FMT="fastq" #-f | --fmt | --input-format
#INTERLEAVED="FALSE" #-i | --interleaved
#READ_TYPES="mixed" #-y | --read-types
#DISTANCE="1" #-D | --dist
#FILTER=".py" #-x | --exclude
#UNPAIR_TERM="unpair" #-u | --unpair-terms
#PAIR_TERM="pair" #-p | --pair-terms
KEEP_SAM="FALSE" #-k | --keep-sam
MERGE_OUTPUT="FALSE" #-m | --merge-args
MERGE_NAME="bowtie2-run.sam" #-n | --merge-name
REMOVE_TMP="FALSE" #-z | --remove-tmp
LOG_FN="bowtie2-read-mapping.log" #-l | --log-file
ALIGN_TYPE="end-to-end" #-a | --alignment-type
GLOBAL_PRESETS="sensitive" #-e | --end-to-end-presets
LOCAL_PRESETS="sensitive-local" #-c | --local-presets
NON_DETERMINISTIC="FALSE" #-N | --non-deterministic
#TRIM5="0" #-5 | --trim5
#TRIM3="0" #-3 |--trim3
MININS="0" #-I | --minins
MAXINS="2000" #-X | --maxins
THREADS="1" #-t | --threads
SING_IMG="bowtie_sam.img" #-S | --sing-img
OUT_DIR="./out_dir" #-O | --out-dir

#Read the arguments
# In case you wanted to check what variables were passed
echo "ARG = $*"

#commented out
#iy:D:x:u:p:5:3:

while getopts :i:r:d:f:k:mn:zl:a:e:c:NI:X:t:S:O:h ARG; do
    case $ARG in
        i)
            INPUT_DIR="$OPTARG"
            ;;
        r)
            READS_DIR="$OPTARG"
            ;;
        d)
            INPUT_DB="$OPTARG"
            ;;
        f)
            INPUT_FMT="$OPTARG"
            ;;
#        i)
#            INTERLEAVED=1
#            ;;
#        y)
#            READ_TYPES="$OPTARG"
#            ;;
#        D)
#            DISTANCE="$OPTARG"
#            ;;
#        x)
#            FILTER="$OPTARG"
#            ;;
#        u)
#            UNPAIR_TERM="$OPTARG"
#            ;;
#        p)
#            PAIR_TERM="$OPTARG"
#            ;;
        k)
            KEEP_SAM=1
            ;;
        m)
            MERGE_OUTPUT=1
            ;;
        n)
            MERGE_NAME="$OPTARG"
            ;;
        z)
            REMOVE_TMP=1
            ;;
        l)
            LOG_FN="$OPTARG"
            ;;
        a)
            ALIGN_TYPE="$OPTARG"
            ;;
        e)
            GLOBAL_PRESETS="$OPTARG"
            ;;
        c)
            LOCAL_PRESETS="$OPTARG"
            ;;
        N)
            NON_DETERMINISTIC=1
            ;;
#        5)
#            TRIM5="$OPTARG"
#            ;;
#        3)
#            TRIM3="$OPTARG"
#            ;;
        I)
            MININS="$OPTARG"
            ;;
        X)
            MAXINS="$OPTARG"
            ;;
        t)
            THREADS="$OPTARG"
            ;;
        S)
            SING_IMG="$OPTARG"
            ;;
        O)
            OUT_DIR="$OPTARG"
            ;;
        h)
            HELP
            ;;
        :)
            echo ""$OPTARG" requires an argument"
            ;;
        \?) #unrecognized option - show help
            echo "Invalid option "$OPTARG""
            HELP
            ;;
    esac
done
  
#It is common practice to call the shift command 
#at the end of your processing loop to remove 
#options that have already been handled from $@.
shift $((OPTIND -1))

#echo "Outdir is $OUT_DIR"
#echo "INTERLEAVED is $INTERLEAVED"

#If you have your own launcher setup on stampede2 just point MY_PARAMRUN at it
#this will override the TACC_LAUNCHER...
#PARAMRUN="${MY_PARAMRUN:-$TACC_LAUNCHER_DIR/paramrun}"
#check for centrifuge image
if [[ ! -e "$SING_IMG" ]]; then
    echo "Missing SING_IMG \"$SING_IMG\""
    exit 1
fi
#
# Verify existence of various directories, files
#
[[ ! -d "$OUT_DIR" ]] && mkdir -p "$OUT_DIR"

###Uncomment when back on TACC
#if [[ ! -d "$TACC_LAUNCHER_DIR" ]]; then
#    echo "Cannot find TACC_LAUNCHER_DIR \"$TACC_LAUNCHER_DIR\""
#    exit 1
#fi
#
#if [[ ! -f "$PARAMRUN" ]]; then
#    echo "Cannot find PARAMRUN \"$PARAM_RUN\""
#    exit 1
#fi

export GENOME_LIST="$(pwd)/genome_list"
cat /dev/null > $GENOME_LIST

#Need to concatenate all the fastas into one
if [[ ! -e "$INPUT_DB" ]]; then
    echo "Searching $INPUT_DIR for genome fastas"
    find $INPUT_DIR -iname "*.fna" > $GENOME_LIST
    echo "Found $(lc $GENOME_LIST) in $INPUT_DIR"
    if [[ $(lc $GENOME_LIST) -lt 1 ]]; then
        echo "No genome fastas found!"
        exit 1
    else
        sed 's/\n/ /' $GENOME_LIST | xargs -I file cat file > $INPUT_DB
    fi
fi

#Run bowtie_batch
#TODO: gotta figure out this path stuff
#TODO: make a "auto-map" in the singularity config file
#TODO: so that /vagrant is automagically available
INPUT_DB=$GUEST/$(basename $INPUT_DIR)/$(basename $INPUT_DB)
singularity run -B "$HOST":"$GUEST" $SING_IMG -d $INPUT_DB \
    -r $GUEST/rna/control \
    -f fastq -t 4

echo "Done, look in OUT_DIR \"$OUT_DIR\""
echo "Comments to Scott Daniel <scottdaniel@email.arizona.edu>"

