# Simulation environment (Isaac Sim 6.2 + Isaac Lab v3.0.0), built with simulation/install.sh.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    OMNI_KIT_ACCEPT_EULA=YES ACCEPT_EULA=Y PYTHONUNBUFFERED=1 \
    NVIDIA_VISIBLE_DEVICES=all NVIDIA_DRIVER_CAPABILITIES=all

# libusb-1.0-0: open3d (an Isaac Lab 3 dependency that TensorBoard loads as a plugin) links it
RUN apt-get update && apt-get install -y --no-install-recommends \
      python3 python3-venv python3-dev build-essential cmake git ca-certificates wget \
      libglib2.0-0 libgl1 libglu1-mesa libegl1 libvulkan1 libsm6 libice6 libxext6 libxrender1 libxt6 \
      libxrandr2 libxi6 libxinerama1 libxcursor1 libxkbcommon0 ncurses-term libusb-1.0-0 \
 && rm -rf /var/lib/apt/lists/*

# isaaclab.sh picks the interpreter from VIRTUAL_ENV.
ENV VIRTUAL_ENV=/opt/venv PATH=/opt/venv/bin:$PATH
RUN python3 -m venv $VIRTUAL_ENV && pip install --no-cache-dir --upgrade pip

# Dependencies first so code edits don't redo the ~20 GB install.
WORKDIR /workspace/PolicyIK
COPY requirements/simulation.txt requirements/
COPY simulation/install.sh simulation/
COPY simulation/patches simulation/patches
RUN PIP_NO_CACHE_DIR=1 bash simulation/install.sh

COPY . .
WORKDIR /workspace/PolicyIK/simulation
CMD ["bash"]
