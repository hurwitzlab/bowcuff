#!/usr/bin/env Rscript

#script to install the most-up-to-date R-packages
myPaths <- .libPaths()

myPaths <- c(‘/media/miniconda/lib/R/library’, myPaths)

.libPaths(myPaths)  # add new path

library(devtools)

if(getOption("unzip") == "") options(unzip = 'internal')
#install.packages("stringi", configure.args="--disable-pkg-config")
install_github("PF2-pasteur-fr/SARTools", quick = TRUE, dependencies = FALSE,
               upgrade_dependencies = FALSE)
