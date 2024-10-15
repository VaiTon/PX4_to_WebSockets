#!/bin/sh

# ##############################
# source /opt/setup.bash
# ros2 launch launch.yml
# ##############################

set -e

# setup ros2 environment
source "/opt/ros/$ROS_DISTRO/setup.bash" --

# workspace overlay
source "$WORKSPACE_DIR/install/setup.bash" --
