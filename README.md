# Radcot Part Three
An app that can:
- Annotate RNA counts of genes with KEGG pathway information
- Generate graphs of RNA count differences per KEGG module

## Meant to follow Part Two<sup>1</sup> [here](https://github.com/hurwitzlab/bowtie-samtools)
- Quantify transcripts of genes within these species

## How to use:
1. Use https://www.imicrobe.us/#/apps to access the app with your [cyverse login](http://www.cyverse.org/create-account)
OR
1. git clone https://github.com/hurwitzlab/bowcuff
2. Get the singularity image like so: `wget [address we setup]`
3. Run the pipeline on an HPC with a slurm scheduler<sup>2</sup>

---
<sup>1</sup>Unless you already have SAM files
for each of your samples (and annotation files)

<sup>2</sup>I assume this can be adapted to run on other 
batch-scheduled high-performance computer systems 
but this has not been tested.
