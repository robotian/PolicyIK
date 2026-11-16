# Copyright 2025 Enactic, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Modified by the PolicyIK authors: registers the PolicyIK tasks, then runs Isaac Lab 3's RL-Games trainer
# (Isaac Lab 3 replaced the per-library train.py scripts with one trainer per library).

"""Train an RL agent with RL-Games on the PolicyIK tasks."""

import sys

import policyik_sim.tasks  # noqa: F401  (registers the PolicyIK gym tasks)
from isaaclab_rl.entrypoints.backends.train_rl_games import run

if __name__ == "__main__":
    run(sys.argv[1:])
