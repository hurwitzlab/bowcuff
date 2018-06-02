#!/usr/bin/env python3

###############################################################################
#                                                                             #
#  count-deseq.py                                                             #
#                                                                             #
#  A wrapper script for filtering gffs, counting alignments per protein       #
#  coding sequence, and performing differential expression with deseq2        #
#                                                                             #
#    Copyright (C) Scott G Daniel                                             #
#                                                                             #
###############################################################################
#                                                                             #
#    This library is free software; you can redistribute it and/or            #
#    modify it under the terms of the GNU Lesser General Public               #
#    License as published by the Free Software Foundation; either             #
#    version 3.0 of the License, or (at your option) any later version.       #
#                                                                             #
#    This library is distributed in the hope that it will be useful,          #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of           #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU        #
#    Lesser General Public License for more details.                          #
#                                                                             #
#    You should have received a copy of the GNU Lesser General Public         #
#    License along with this library.                                         #
#                                                                             #
###############################################################################

__author__ = "Scott G Daniel"
__copyright__ = "Copyright 2018"
__credits__ = "Scott G Daniel"
__license__ = "LGPLv3"
__maintainer__ = "Scott G Daniel"
__email__ = "scottdaniel@email.arizona.edu"
__status__ = "Development"

import glob
import os
import sys
import subprocess
import argparse
from pprint import pprint
import pandas as pd

#WORK env var will be present on TACC
#But may not be set when testing locally
if os.getenv('WORK') is None:
    os.environ['WORK'] = './'

####################
# ARGUMENTS ########
####################

parser = argparse.ArgumentParser(description=
        "A wrapper script for filtering gffs, counting alignments per protein\n"
        "coding sequence, and performing differential expression with deseq2.",
        formatter_class=argparse.RawTextHelpFormatter)

inputs = parser.add_argument_group('Required Inputs and Parameters')

inputs.add_argument('-G', '--gff-dir', 
        dest='gff_dir', metavar='DIRECTORY', 
        default=os.path.join(os.getenv('WORK'),'genomes'),
        help="The Directory containing individual gffs\n"
        "that will be pasted together.\n"
        "if pasted gff file already exists, this input\n"
        "will be ignored, [ Default = $WORK/gffs ]")

inputs.add_argument('-g', '--gff-file', 
        dest='gff_file', metavar='FILENAME', 
        default=os.path.join(os.getenv('WORK'),'all.RefSeq.gff'),
        help="The gff file with annotations for the genome.\n"
        "This will be filtered for use with htseq-count.\n"
        " [ Default = $WORK/all.RefSeq.gff ] ")

inputs.add_argument('-b', '--bams-dir', 
        dest='bams_dir', metavar='DIRECTORY',
        default=os.path.join(os.getenv('WORK'),'bams'),
        help="Directory containing bams to process.\n"
        " [ Default = $WORK/bams ]")

inputs.add_argument('-m', '--metadata', 
        dest='metadata', metavar='FILENAME',
        default='metadata.txt',
        help="File containing file / sample information.\n"
        "Use the metadata_template to start and DO NOT change\n"
        "headings. [ Default = metadata.txt ]")

inputs.add_argument('-o', '--out-dir', 
        dest='out_dir', metavar='DIRECTORY',
        default=os.getcwd(),
        help="Output directory to put all the\n"
        "results in. [ Default = Current working dir ]")

gen_opts = parser.add_argument_group('General Options')  

gen_opts.add_argument('-s', '--skip-counting', action='store_true',
        help="Skip htseq-count step and go directly to deseq2.\n"
        "In this case, you do not need to specify the bams_dir\n"
        "or gff_dir/file, BUT the out_dir must be created and contain\n"
        "the counts as specified in the metadata.txt.")

gen_opts.add_argument('-d', '--debug', action='store_true',
        help="Extra logging messages.") 

gen_opts.add_argument('-t', '--threads', 
        dest='threads', metavar='INT', 
        type=int, default=1,
        help="number of alignment threads to launch.\n"
        " [ Default = 1 ] ")

program_opts = parser.add_argument_group('Specific program options')

program_opts.add_argument('-v', '--varInt',
        dest='varInt', default='condition',
        help="Factor of interest [ Default = condition ]\n"
        "This should not have to be changed if you are using the\n"
        "metadata_template.txt.")

program_opts.add_argument('-c', '--condRef',
        dest='condRef', default='control',
        help="Reference biological condition [ Default = control ]\n"
        "Needed or deseq2 will not know what to compare against.")

program_opts.add_argument('-C', '--htseq-count-options', 
        dest='htseq_count_opt_txt', metavar='FILENAME',
        default=os.path.join(os.getenv('WORK'),'htseq_options.txt'),
        help="File with additional options for htseq-count\n"
        "Options must be one per line like so:\n"
        "-o1 option1\n"
        "-o2 option2")

program_opts.add_argument('-D', '--deseq2-options', 
        dest='deseq2_opt_txt', metavar='FILENAME',
        default=os.path.join(os.getenv('WORK'),'deseq2_options.txt'),
        help="File with additional options for deseq2\n"
        "Options must be one per line like so:\n"
        "-o1 option1\n"
        "-o2 option2")

args = parser.parse_args()

#######################
# GENERAL FUNCTIONS ###
#######################

#really basic checker, check that options file exists and then check that each line begins with a '-', then parse
def parse_options_text(options_txt_path):
    if not (os.path.isfile(options_txt_path)):
        print("Options text {} does not exist or is not a file\n".format(options_txt_path))
        return None
    else:
        options_string = ''
        with open(options_txt_path) as options_txt:
            for line in options_txt:
                if not line.startswith('-'):
                    print("Skipping line that doesnt have hyphen\n")
                else:
                    options_string += line.replace('\n', ' ')

    if args.debug:
        print("These are the options for {}:\n".format(options_txt_path))
        print("{}\n".format(options_string))

    return options_string

def error(msg):
    sys.stderr.write("ERROR: {}\n".format(msg))
    sys.stderr.flush()
    sys.exit(1)


def execute(command):

    print('Executing {}'.format(command) + os.linesep)
    process = subprocess.Popen(command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                               shell=True)
    (stdout, stderr) = process.communicate()
    print(stdout.decode() + os.linesep)
    print(stderr.decode() + os.linesep)

#############################
# Script-specific Functions #
#############################

def cat_gff(gff_dir,gff):
    file_list = glob.glob(gff_dir + "/*.gff")
    with open(gff,'w') as outfile:
        for filen in file_list:
            with open(filen, 'r') as infile:
                for line in infile:
                    outfile.write(line)

        return outfile.name

def filter_gff(gff_in,gff_out):

    processCall = ''

    processCall = 'bash filtering-gffs.sh {} > {}'.format(gff_in,gff_out)

    execute(processCall)

    return gff_out

def read_targets(metadata):

    bams_and_counts = []
    #read targets file with pandas read_table method
    #then return list of tuples of (bam_file, count_file)
    #targets file will also be used in the SARTools deseq wrapper
    if os.path.isfile(metadata):
        targets = pd.read_table(metadata,delimiter='\t',header=0,comment='#')

    for row in targets.itertuples(index=True, name='Pandas'):
        bams_and_counts.append([getattr(row,'bam_files'),getattr(row,'count_files')])

    return bams_and_counts

def htseq_count(gff, bams_and_counts):
    
    htseq_count_options = parse_options_text(args.htseq_count_opt_txt)

    processCall = ''

    for bam_file, count_file in bams_and_counts:
        
        bam_path = os.path.join(args.bams_dir, bam_file)
        count_path = os.path.join(args.out_dir, count_file)
        processCall = 'samtools view -@ {} -h {} | htseq-count {} - {} > {}'.format(args.threads, bam_path, htseq_count_options, gff, count_path)

        execute(processCall)

def run_deseq():

    deseq2_options = parse_options_text(args.deseq2_opt_txt)

    processCall = ''

    #call deseq2.r 
    #SARTools deseq wrapper
    #https://github.com/PF2-pasteur-fr/SARTools/blob/master/template_script_DESeq2_CL.r

#local testing
#    processCall = './deseq2.r --targetFile {} --rawDir {}\
#            --varInt {} --condRef {} {}'.format(args.metadata, args.out_dir,
#                    args.varInt, args.condRef, deseq2_options)

    processCall = 'deseq2.r {} --targetFile {} --rawDir {}\
            --varInt {} --condRef {}'.format(deseq2_options,
                    args.metadata, args.out_dir,
                    args.varInt, args.condRef)

    execute(processCall)

def make_species_graphs():

    #TODO: call counts_per_species.r
    #My own script based on work in 
    #https://github.com/hurwitzlab/bacteria-bowtie/tree/master/scripts/R-interactive
    return None

####################
# SETS AND CHECKS ##
####################

#check for args that need to be set (the app.json / agave api should do this too)

##################
# THE MAIN LOOP ##
##################

if __name__ == '__main__':
   
    #make the out dir if does not exist
    if not os.path.isdir(args.out_dir):
        os.mkdir(args.out_dir)

    #DEBUG#
    if args.debug:
        print('all the arguments:' + os.linesep)
        pprint(args); print()

        print('.gff files in {}:'.format(args.gff_dir) + os.linesep)
        pprint(glob.glob(args.gff_dir + "/*.gff")); print()
    #END DEBUG#
    
    #GFF munging
    if not os.path.isfile(args.gff_file):
        print("Did not find a big gff file created so")
        print("Catting together a gff file at the path: {}\n".format(args.gff_file))
        gff_name = cat_gff(args.gff_dir,args.gff_file)
        print("Created {}\n".format(gff_name))
    else:
        gff_name = os.path.basename(args.gff_file)
        print("Using {}\n".format(gff_name))

    #these three lines could be in the filter gff function
    if not args.skip_counting:
        
        gff_old_name, ext = os.path.splitext(args.gff_file)
        gff_new_name = gff_old_name + '-CDS'
        gff_out = gff_new_name + ext
        filter_gff(args.gff_file,gff_out)
        print("Filtered {} into {} for you\n".format(os.path.basename(args.gff_file),os.path.basename(gff_out)))

        htseq_count(gff_out, read_targets(args.metadata))

        run_deseq()

    else:

        run_deseq()

    print('Program Complete, Hopefully it Worked!')
