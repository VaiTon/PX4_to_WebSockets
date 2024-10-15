#!/bin/sh
podman run -it --rm --name ros -e DISPLAY -e XDG_RUNTIME_DIR -p 8888:8888 -p 9090:9090  --volume='/tmp/.X11-unix:/tmp/.X11-unix:rw' --security-opt label=type:container_runtime_t ros-server
bash
