###################
# Set up GCP host #
###################
gcloud beta compute --project=aryeelab instances create-with-container cas-designer --zone=us-central1-a --machine-type=n1-standard-8 --subnet=default --network-tier=PREMIUM --metadata=google-logging-enabled=true --maintenance-policy=TERMINATE --service-account=303574531351-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --accelerator=type=nvidia-tesla-k80,count=1 --image=cos-stable-89-16108-470-1 --image-project=cos-cloud --boot-disk-size=20GB --boot-disk-type=pd-balanced --boot-disk-device-name=cas-designer --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --container-image=nvidia/opencl:runtime-ubuntu18.04 --container-restart-policy=always --labels=container-vm=cos-stable-89-16108-470-1 


gcloud beta compute ssh --zone "us-central1-a" "ubuntu2004" --project "aryeelab"


# Ubuntu with Docker and NVidia drivers
# NVIDIA driver install
# sudo apt install linux-headers-$(uname -r)
curl -O https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
sudo apt update
sudo apt -y install cuda

# Docker
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
 "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
 $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io

# Nvidia container toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi

#################
# ERIXdxl setup #
#################
ssh ma695@erisxdl.partners.org

podman pull nvcr.io/nvidia/cuda:11.0-base
podman pull nvcr.io/nvidia/opencl:runtime-ubuntu18.04
podman images 

podman run --rm -it nvcr.io/nvidia/cuda:11.0-base nvidia-smi


podman run --rm -it nvidia/opencl:runtime-ubuntu18.04 /bin/bash


##########################
# Docker Container setup #
##########################
sudo docker run --gpus all --rm -it nvidia/opencl:runtime-ubuntu18.04 /bin/bash

apt-get update &&\
apt-get install -y wget curl libgomp1 python &&\
rm -rf /var/lib/apt/lists/*


# Google Cloud SDK
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
apt-get -y install apt-transport-https ca-certificates gnupg
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
apt-get update 
apt-get -y install google-cloud-sdk

# Cas-Designer
cd tmp
wget https://versaweb.dl.sourceforge.net/project/cas-offinder/Binaries/2.4/Linux64/cas-offinder &&\
wget http://www.rgenome.net/static/files/cas-offinder-bulge
wget http://www.rgenome.net/static/files/cas-designer
chmod +x cas-offinder
chmod +x cas-offinder-bulge
chmod +x cas-designer
cp cas-* /bin

# Genome FASTA
mkdir GRCh38
cd GRCh38
gsutil -m cp gs://genomics-public-data/references/GRCh38/* .
gunzip *




################################################



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



