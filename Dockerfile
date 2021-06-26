FROM nvidia/cuda:11.3.1-base 

# Misc dependencies
RUN   apt-get update &&\
      apt-get install -y wget curl python3.8 libgomp1 &&\
      rm -rf /var/lib/apt/lists/*

# Install OpenCL 
# See https://gitlab.com/nvidia/container-images/opencl/-/blob/ubuntu16.04/runtime/Dockerfile

RUN   apt-get update &&\
      apt-get install -y --no-install-recommends ocl-icd-libopencl1 clinfo && \
      rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility


# Install Cas-Designer & Cas-Offinder
RUN   cd tmp &&\
      wget https://versaweb.dl.sourceforge.net/project/cas-offinder/Binaries/2.4/Linux64/cas-offinder &&\
      wget http://www.rgenome.net/static/files/cas-offinder-bulge &&\
      wget http://www.rgenome.net/static/files/cas-designer &&\
      chmod +x cas-offinder &&\
      chmod +x cas-offinder-bulge &&\
      chmod +x cas-designer &&\
      mv cas-* /bin

# Install Google Cloud SDK
RUN   echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list &&\
      apt-get -y install apt-transport-https ca-certificates gnupg &&\
      curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - &&\
      apt-get update &&\
      apt-get -y install google-cloud-sdk &&\
      rm -rf /var/lib/apt/lists/*