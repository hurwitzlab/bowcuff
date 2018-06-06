### [centrifuge-patric - Radcot Part One - 1st step](https://github.com/hurwitzlab/centrifuge-patric)
- Identified bacterial species from a metagenomic sample
- Downloaded genomes of said species

### [bowtie-samtools - Radcot Part Two - 2nd step](https://github.com/hurwitzlab/bowtie-samtools)
- Quantified transcripts of genes within these species

## [cound-deseq - Radcot Part Three - YOU ARE HERE](https://github.com/hurwitzlab/count-deseq)
- Count RNA alignments using htseq-count
- Do differenital expression analysis using deseq2, generating graphs, tables, and a summary report
- *TODO* Generate tables and/or graphs of pathway and species information with the genes that have counts

## How to use:
1. Use https://www.imicrobe.us/#/apps to access the app with your [cyverse login](http://www.cyverse.org/create-account)
OR
1. git clone https://github.com/scottdaniel/count-deseq
2. Get the singularity image like so: `wget [address we setup]`
3. Run the pipeline on an HPC with a slurm scheduler<sup>1</sup>

---
<sup>1</sup>I assume this can be adapted to run on other 
batch-scheduled high-performance computer systems 
but this has not been tested.

