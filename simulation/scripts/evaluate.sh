#!/usr/bin/env bash
# Evaluate one policy with a single attempt and with the deployment protocol (usage: scripts/evaluate.sh <seed> [checkpoint]).
set -euo pipefail
cd "$(dirname "$0")/.."
# openarm_isaac_lab imports its own assets as `source.openarm...`, which resolves from its repository root.
export PYTHONPATH="$PWD/third_party/openarm_isaac_lab${PYTHONPATH:+:$PYTHONPATH}"
export OMNI_KIT_ACCEPT_EULA=YES PYTHONUNBUFFERED=1
PYTHON="${PYTHON:-python}"
SEED="${1:?usage: scripts/evaluate.sh <seed> [checkpoint]}"
CKPT="${2:-logs/rl_games/policyik_s$SEED/checkpoint_average.pth}"
OUT="outputs/eval/s$SEED"
mkdir -p "$OUT"
# Isaac Sim 6.2 occasionally segfaults while starting right after another GPU-heavy run, and its crash handler can
# then hang. Each run gets a time limit and up to three tries (an evaluation run has no side effects to undo).
launch() { for try in 1 2 3; do timeout -k 30 1200 "$@" && return; echo "[evaluate.sh] run failed (try $try)" >&2; done; return 1; }
EVAL=(launch "$PYTHON" -m policyik_sim.evaluate --checkpoint "$CKPT")

"${EVAL[@]}" --task_file data/eval_tasks.npz --output "$OUT/single.npz"
"$PYTHON" -m policyik_sim.corrected_goals --single "$OUT/single.npz" --task_file data/eval_tasks.npz \
    --output "$OUT/corrected_tasks.npz"
"${EVAL[@]}" --task_file "$OUT/corrected_tasks.npz" --output "$OUT/corrected.npz"
for k in 0 1 2 3 4 5 6 7; do
  "${EVAL[@]}" --task_file data/eval_tasks.npz --transient_seed "$k" --output "$OUT/transient$k.npz"
done
"$PYTHON" -m policyik_sim.metrics --seed_dir "$OUT"
