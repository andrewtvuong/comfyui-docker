# 📦 ComfyUI Secure Docker Setup

This repository contains everything you need to securely run [ComfyUI](https://github.com/comfyanonymous/ComfyUI) inside a **GPU-accelerated Docker container** with **cuDNN 8.9.7** and **CUDA 12.2**, supporting:

- ✅ Safe, non-root execution
- ✅ Writable output, user config, and temp dirs
- ✅ Read-only model and custom node volumes
- ✅ Full GPU acceleration via NVIDIA Docker runtime
- ✅ Local access from browser (`http://<ubuntu-ip>:8188`)

---

## ⚙️ Prerequisites

- Ubuntu 22.04 system with NVIDIA GPU + drivers
- Docker installed (`docker`, `docker compose`)
- NVIDIA Container Toolkit installed (`nvidia-ctk`)

> Already included in `setup_comfyui_docker.sh` if you're starting fresh.

---

## 🛠️ Folder Structure

```
comfyui-docker/
├── Dockerfile
├── docker-compose.yml
├── volumes/
│   ├── models/
│   │   └── checkpoints/         # Put .safetensors/.ckpt files here
│   ├── output/                  # All image/video outputs go here
│   ├── custom_nodes/            # Place custom node folders/scripts here
│   ├── user/                    # ComfyUI user state (writable)
│   └── temp/                    # ComfyUI temp directory (writable)
```

---

## 🚀 Getting Started

1. **Run the setup script**  
   *(optional if you’re setting up from scratch)*

   ```bash
   chmod +x setup_comfyui_docker.sh
   ./setup_comfyui_docker.sh
   ```

2. **Build the Docker container**

   ```bash
   cd ~/comfyui-docker
   docker compose build
   ```

3. **Start ComfyUI**

   ```bash
   docker compose up
   ```

4. **Open in your browser**

   ```
   http://<ubuntu-ip>:8188
   ```

---

## 🖼️ Add Models / Nodes

- ✅ Place models in: `volumes/models/checkpoints/`
- ✅ Add custom nodes in: `volumes/custom_nodes/`
- ✅ All generated images/videos will appear in: `volumes/output/`

> Restart ComfyUI (`docker compose restart`) to load new models or nodes.

---

## 🛑 Stop the Container

```bash
docker compose down
```

To keep it running in the background via `tmux`:

```bash
tmux new -s comfy
docker compose up
# press Ctrl+B then D to detach
```

---

## 🔐 Security Notes

- Container runs as **non-root** user
- Core filesystem is **read-only**
- Only essential folders (`models`, `output`, `temp`, `user`, `custom_nodes`) are mounted with controlled access
- Custom nodes and checkpoints are sandboxed and not allowed to write

---

## ✅ Recommended Additions

- `start.sh` / `stop.sh` helper scripts
- Option to auto-tag outputs
- Reverse proxy or UFW firewall rules to restrict LAN access


ChatGPT generated, vetted, and works well.