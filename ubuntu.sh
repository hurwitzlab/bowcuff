BootStrap: debootstrap
OSVersion: trusty
MirrorURL: http://us.archive.ubuntu.com/ubuntu/

%environment
    PATH="/media/miniconda/bin:$PATH"

%runscript
    echo "By default this runs solexaqa, use singularity exec to run fastqc\
        , trim_galore, or cutadapt"
    exec /usr/bin/solexaqa "$@"

%post
    echo "Hello from inside the container"
    sed -i 's/$/ universe/' /etc/apt/sources.list

    #essential stuff
    apt -y --force-yes install git sudo man vim build-essential wget unzip

    touch /etc/init.d/systemd-logind
    sudo apt -y --force-yes install default-jre
    
    #maybe dont need, add later if do:
    #curl autoconf libtool 
    cd /tmp
    wget https://sourceforge.net/projects/solexaqa/files/latest/download?source=files -O solexa.zip
    sudo unzip solexa.zip -d /media
    sudo ln -s /media/Linux_x64/SolexaQA++ /usr/bin/solexaqa

    wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip -O fastqc.zip
    sudo unzip fastqc.zip -d /media
    sudo chmod +x /media/FastQC/fastqc
    sudo ln -s /media/FastQC/fastqc /usr/bin/fastqc

    #Miniconda for cutadapt / trimgalore
    #and if trimgalore works better we might just get rid of solexaqa
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
    bash miniconda.sh -b -p /media/miniconda
    PATH="/media/miniconda/bin:$PATH"
    conda install -y -f -q -c bioconda xopen
    conda install -y -f -q -c bioconda cutadapt

    wget http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/trim_galore_v0.4.4.zip
    sudo unzip -o trim_galore_v0.4.4.zip
    sudo chmod +x trim_galore
    sudo mv trim_galore /usr/bin

    #cleanup    
    conda clean -y --all
    rm -rf /tmp/*
    cd /media
    rm -rf MacOs_10.7+/
    rm -rf source/
    rm -rf Windows_x64/

    #create a directory to work in
    mkdir /work
