#!/bin/bash

#########################
# Launch the tmux session
# 1. PX4
# 2. ROS Launch file
#########################


tmux new-session "/opt/launch.sh ros2 launch /opt/all.yml" \; rename-window 'ROS + PX4' \; \
    set mouse on \; \
    split-window -h "/opt/launch.sh ros2 launch /opt/control.yml; read" \; rename-window 'Control' \; \
    select-window -t 0 \;
