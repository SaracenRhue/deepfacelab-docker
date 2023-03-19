FROM nvidia/cuda:12.1.0-base-rockylinux9

# Update package repositories and install dependencies
RUN dnf install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm
RUN dnf update -y
RUN dnf install -y git wget ffmpeg python3 python3-pip librubberband 

# Add a new user
RUN useradd -ms /bin/bash user && \
    echo "user:password" | chpasswd

# Install Anaconda
RUN wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh && \
    bash Anaconda3-2021.05-Linux-x86_64.sh -b -p /opt/anaconda && \
    rm Anaconda3-2021.05-Linux-x86_64.sh

# Set up Anaconda environment
ENV PATH /opt/anaconda/bin:$PATH

# Create the Conda environment for DeepFaceLab
RUN conda create -n deepfacelab -c main python=3.7 cudnn=7.6.5 cudatoolkit=10.1.243

# Activate the Conda environment
RUN echo "source activate deepfacelab" > ~/.bashrc
ENV PATH /opt/anaconda/envs/deepfacelab/bin:$PATH

WORKDIR /home/user
RUN git clone --depth 1 https://github.com/nagadit/DeepFaceLab_Linux.git
WORKDIR /home/user/DeepFaceLab_Linux
RUN git clone --depth 1 https://github.com/iperov/DeepFaceLab.git && \
    python -m pip install -r ./DeepFaceLab/requirements-cuda.txt
