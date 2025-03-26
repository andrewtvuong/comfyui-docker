#!/bin/bash
set -e

echo "🔧 Setting up ComfyUI in Docker with GPU, cuDNN, and secure volume mapping..."

# Step 1: Install Docker & NVIDIA container toolkit (assumes Ubuntu)
echo "📦 Installing Docker and NVIDIA Container Toolkit..."

sudo apt update
sudo apt install -y docker.io curl wget gnupg lsb-release

# Add Docker group and enable service
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# Install NVIDIA Docker support
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list |   sed 's|^deb |deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit.gpg] |' |   sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt update
sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

# Step 2: Create comfyui-docker folder structure
echo "📁 Creating ComfyUI Docker folder structure..."

mkdir -p ~/comfyui-docker/volumes/{models/checkpoints,output,custom_nodes,user,temp}
cd ~/comfyui-docker

# Step 3: Write Dockerfile
echo "📝 Writing Dockerfile..."

cat > Dockerfile <<EOF
FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

RUN groupadd -g 1000 comfy && useradd -u 1000 -g comfy -m comfy

RUN apt update && apt install -y \
    git python3 python3-pip python-is-python3 \
    libgl1 libglib2.0-0 wget gnupg curl ca-certificates && \
    apt clean

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb && \
    dpkg -i cuda-keyring_1.0-1_all.deb && \
    rm cuda-keyring_1.0-1_all.deb && \
    apt-get update && \
    apt-get install -y libcudnn8=8.9.7.* libcudnn8-dev=8.9.7.* && \
    apt-mark hold libcudnn8 libcudnn8-dev

WORKDIR /workspace
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /workspace/ComfyUI

RUN pip install --upgrade pip && pip install -r requirements.txt

USER comfy
EXPOSE 8188
CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8188"]
EOF

# Step 4: Write docker-compose.yml
echo "📝 Writing docker-compose.yml..."

cat > docker-compose.yml <<EOF
services:
  comfyui:
    build: .
    container_name: comfyui
    ports:
      - "8188:8188"
    runtime: nvidia
    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu]
    environment:
      - NVIDIA_VISIBLE_DEVICES=all

    read_only: true
    tmpfs:
      - /tmp
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    user: 1000:1000

    volumes:
      - ./volumes/models:/workspace/ComfyUI/models:ro
      - ./volumes/output:/workspace/ComfyUI/output:rw
      - ./volumes/custom_nodes:/workspace/ComfyUI/custom_nodes:ro
      - ./volumes/user:/workspace/ComfyUI/user:rw
      - ./volumes/temp:/workspace/ComfyUI/temp:rw
EOF

echo "✅ ComfyUI Docker environment setup complete!"
echo "👉 Run the following to build and launch:"
echo ""
echo "   cd ~/comfyui-docker"
echo "   docker compose build"
echo "   docker compose up"
echo ""
echo "Then open ComfyUI in your browser at: http://<ubuntu-ip>:8188"
