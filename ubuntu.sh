BootStrap: debootstrap
OSVersion: trusty
MirrorURL: http://us.archive.ubuntu.com/ubuntu/

%environment
    PATH="/media/miniconda/bin:$PATH"

%runscript
    echo "By default this runs bowtie2 (the mapper)\n/
    Use exec bowtie2-build, etc. for other Tuxedo programs"
    exec bowtie2 "$@"

%post
    echo "Hello from inside the container"
    sed -i 's/$/ universe/' /etc/apt/sources.list
    #essential stuff
    apt update
    apt -y --force-yes install git sudo man vim build-essential wget unzip
    #needed for bowtie2
    apt -y --force-yes install libtbb-dev

#    touch /etc/init.d/systemd-logind
#    sudo apt -y --force-yes install default-jre
    
    #maybe dont need, add later if do:
    #curl autoconf libtool 
    cd /tmp
#    wget 
#    sudo unzip solexa.zip -d /media
#    sudo ln -s /media/Linux_x64/SolexaQA++ /usr/bin/solexaqa
#
#    wget 
#    sudo unzip fastqc.zip -d /media
#    sudo chmod +x /media/FastQC/fastqc
#    sudo ln -s /media/FastQC/fastqc /usr/bin/fastqc
#
    #Miniconda for cutadapt / trimgalore
    #and if trimgalore works better we might just get rid of solexaqa
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
    bash miniconda.sh -b -p /media/miniconda
    PATH="/media/miniconda/bin:$PATH"
    conda install -y -c bioconda bowtie2
#use to split fasta
#    conda install -y -q -c bioconda mkl
#    conda install -y -q -c bioconda numpy
    conda install -y -c bioconda pyfasta

    wget http://cole-trapnell-lab.github.io/cufflinks/assets/downloads/cufflinks-2.2.1.Linux_x86_64.tar.gz
    sudo tar -xzf cufflinks-2.2.1.Linux_x86_64.tar.gz
    sudo mv cufflinks-2.2.1.Linux_x86_64/* /usr/bin 

    #cleanup    
    conda clean -y --all
    rm -rf /tmp/*
    cd /media
#    rm -rf MacOs_10.7+/
#    rm -rf source/
#    rm -rf Windows_x64/

    #create a directory to work in
    mkdir /work
