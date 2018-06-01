#!/usr/bin/env Rscript

#install SARTools from github
library(devtools)

if(getOption("unzip") == "") options(unzip = 'internal')
#install.packages("stringi", configure.args="--disable-pkg-config")
install_github("PF2-pasteur-fr/SARTools", quick = TRUE, dependencies = FALSE,
               upgrade_dependencies = FALSE)
