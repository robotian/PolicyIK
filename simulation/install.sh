#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
PYTHON="${PYTHON:-python}"
ISAACLAB_TAG=v3.0.0
OPENARM_COMMIT=bad82e23716e6941c2de78ccb978f57c78b37734

"$PYTHON" -m pip install torch==2.11.0 torchvision==0.26.0 --index-url https://download.pytorch.org/whl/cu130
"$PYTHON" -m pip install "isaacsim[all,extscache]==6.2.0.0" --extra-index-url https://pypi.nvidia.com

[ -d third_party/IsaacLab ] || git clone --depth 1 --branch "$ISAACLAB_TAG" https://github.com/isaac-sim/IsaacLab.git third_party/IsaacLab
(cd third_party/IsaacLab && ./isaaclab.sh --install 'rl[rl-games]')

[ -d third_party/openarm_isaac_lab ] || git clone https://github.com/enactic/openarm_isaac_lab.git third_party/openarm_isaac_lab
git -C third_party/openarm_isaac_lab checkout "$OPENARM_COMMIT"
# openarm_isaac_lab targets Isaac Lab 2; the patch moves its reach task to Isaac Lab 3 (xyzw quaternions, .torch data, renamed noise config)
PATCH="$PWD/patches/openarm_isaac_lab_isaaclab3.patch"
git -C third_party/openarm_isaac_lab apply --reverse --check "$PATCH" 2>/dev/null \
    || git -C third_party/openarm_isaac_lab apply "$PATCH"
"$PYTHON" -m pip install -e third_party/openarm_isaac_lab/source/openarm
"$PYTHON" -m pip install -r ../requirements/simulation.txt
