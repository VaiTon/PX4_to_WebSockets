FROM ros:humble as microxrce

ENV DEBIAN_FRONTEND noninteractive
ENV MICRO_XRCE_VERSION v3.0.0

# Install Micro XRCE-DDS Agent
WORKDIR /opt
RUN <<EOF
    git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git
    cd Micro-XRCE-DDS-Agent
    git checkout $MICRO_XRCE_VERSION
    cmake -B build
    cmake --build build -j$(nproc)
    cmake --install build
    ldconfig /usr/local/lib
    cd ..
    rm -rf Micro-XRCE-DDS-Agent
EOF

FROM microxrce as px4

ENV PX4_VERSION 1.15

# Install PX4
WORKDIR /opt
RUN <<EOF
    apt-get update
    apt-get install -y wget

    git clone https://github.com/PX4/PX4-Autopilot.git PX4 --recursive -b release/${PX4_VERSION}
    bash ./PX4/Tools/setup/ubuntu.sh
    pip3 install --user -U pyros-genmsg

    rm -rf /var/lib/apt/lists/*
    rm -rf /root/.cache/pip
EOF

RUN cd PX4 && make px4_sitl

FROM px4 as ros2-px4

# Install ROS packages
ENV WORKSPACE_DIR /opt/ros2_ws
RUN <<EOF
    apt-get update
    apt-get upgrade -y
    apt-get install -y \
        ros-$ROS_DISTRO-rosbridge-server \
        python3-setuptools \
        python3-packaging \
        python3-empy

    pip3 install --user -U simplejpeg tornado

    rm -rf /var/lib/apt/lists/*
    rm -rf /root/.cache/pip
EOF

WORKDIR $WORKSPACE_DIR/src

RUN <<EOF
    git clone --depth 1 https://github.com/dheera/rosboard.git
    git clone --depth 1 https://github.com/AleOrcia/ROS2_PX4_Quadcopter_Controller.git
    git clone --depth 1 https://github.com/PX4/px4_msgs.git -b release/1.14

    . /opt/ros/$ROS_DISTRO/setup.sh
    cd $WORKSPACE_DIR
    rosdep install -i --from-paths src --rosdistro $ROS_DISTRO -y
    colcon build
EOF

# Install utility packages
RUN <<EOF
    apt-get update
    apt-get install -y xterm ros-$ROS_DISTRO-rqt-graph ros-$ROS_DISTRO-rviz2
    rm -rf /var/lib/apt/lists/*
EOF

# Copy launch scripts
WORKDIR /opt
COPY docker /opt/
CMD ["/opt/launch.sh"]
