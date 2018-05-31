#!/usr/bin/env Rscript

#script to install the most-up-to-date R-packages

library(devtools)
if(getOption("unzip") == "") options(unzip = 'internal')
install_github("PF2-pasteur-fr/SARTools")
