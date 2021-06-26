###################
# Set up GCP host #
###################
gcloud beta compute --project=aryeelab instances create cas-designer --zone=us-central1-a --machine-type=n1-standard-8 --subnet=default --network-tier=PREMIUM --metadata=google-logging-enabled=true --maintenance-policy=TERMINATE --service-account=303574531351-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --accelerator=type=nvidia-tesla-k80,count=1 --image=ubuntu-2004-focal-v20210623 --image-project=ubuntu-os-cloud --boot-disk-size=20GB --boot-disk-type=pd-balanced --boot-disk-device-name=cas-designer --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --metadata-from-file=startup-script=/Users/maryee/Documents/cas-designer/gcp_host_setup.sh
# See gcp_host_setup.sh for startup script
gcloud beta compute ssh --zone "us-central1-a" "cas-designer" --project "aryeelab"


# Test docker GPU
sudo docker run --rm --gpus all nvidia/cuda:11.3.1-base nvidia-smi

##########################
# Docker Container setup #
##########################

sudo docker run --gpus all --rm -it gcr.io/aryeelab/cas-designer /bin/bash

# Genome FASTA
mkdir GRCh38
cd GRCh38
gsutil -m cp gs://genomics-public-data/references/GRCh38/* .
gunzip *


docker build -t gcr.io/aryeelab/cas-designer .



## WDL

java -Dconfig.file=cromwell-gcp.conf -jar /usr/local/Cellar/cromwell/65/libexec/cromwell.jar run -o cromwell-gcp-options.conf cas-designer.wdl

java -Dconfig.file=cromwell-gcp.conf -jar /usr/local/Cellar/cromwell/65/libexec/cromwell.jar run cas-designer.wdl

java -Dconfig.file=cromwell-gcp.conf -jar /usr/local/Cellar/cromwell/65/libexec/cromwell.jar run -i CD_EMX1_2_1_1.json cas-designer.wdl


#################
# ERIXdxl setup #
#################
ssh ma695@erisxdl.partners.org


# Conda

module load Anaconda3
conda create -n cas-designer python=3.8
conda activate cas-designer
conda install cuda

# Podman

podman pull nvidia/cuda:11.0-base
podman pull nvcr.io/nvidia/opencl:runtime-ubuntu18.04
podman pull gcr.io/aryeelab/cas-designer
podman images 

podman run --rm -it gcr.io/aryeelab/cas-designer /bin/bash

podman run --rm -it nvcr.io/nvidia/cuda:11.0-base nvidia-smi


podman run --rm -it nvidia/opencl:runtime-ubuntu18.04 /bin/bash




################################################

# Highest GCP NVIDIA for WDL? 460.73.01



# Cos

cos-extensions install gpu
sudo mkdir /mnt/disks/scratch
sudo mount -t tmpfs tmpfs /mnt/disks/scratch/


docker run --rm -it nvidia/cuda:11.3.1-base-ubuntu20.04 /bin/bash

docker run --rm -it \
 --volume /var/lib/nvidia/lib64:/usr/local/nvidia/lib64 \
 --volume /var/lib/nvidia/bin:/usr/local/nvidia/bin \
 --device /dev/nvidia0:/dev/nvidia0 \
 --device /dev/nvidia-uvm:/dev/nvidia-uvm \
 --device /dev/nvidiactl:/dev/nvidiactl \
 nvidia/cuda:11.3.1-base-ubuntu20.04 /bin/bash

docker run --rm -it \
 --volume /var/lib/nvidia/lib64:/usr/local/nvidia/lib64 \
 --volume /var/lib/nvidia/bin:/usr/local/nvidia/bin \
 --device /dev/nvidia0:/dev/nvidia0 \
 --device /dev/nvidia-uvm:/dev/nvidia-uvm \
 --device /dev/nvidiactl:/dev/nvidiactl \
 nvidia/opencl:runtime-ubuntu18.04 /bin/bash





gcloud compute scp --zone "us-central1-a" --project "aryeelab" EMX1_fasta.fa a100:/home/maryee/
gcloud compute scp --zone "us-central1-a" --project "aryeelab" CD_EMX1_4_2_2.txt a100:/home/maryee/



gcloud beta compute ssh --zone "us-central1-a" "instance-1" --project "aryeelab"


time cas-designer CD_EMX1_4_2_2.txt 


/data/molpath/genomes/GRCh38/Homo_sapiens/NCBI/GRCh38/Sequence/



cd bin &&\
wget https://versaweb.dl.sourceforge.net/project/cas-offinder/Binaries/2.4/Linux64/cas-offinder &&\
chmod +x cas-offinder



