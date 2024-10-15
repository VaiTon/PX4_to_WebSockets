#!/bin/bash

podman build -t ros-server . || exit 1

xhost + # allow access to X11

tmux new-session "./tmux/launch_sim.sh" \; \
     set mouse on \; \
     split-window -v "echo 'Waiting for PX4...'; sleep 5; podman exec ros supervisorctl tail -f px4" \; \
     split-window -h "echo 'Waiting for PX4...'; sleep 5; ./tmux/launch_control.sh" \;




