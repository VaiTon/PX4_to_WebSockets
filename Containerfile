FROM ros:humble as microxrce

# Install Micro XRCE-DDS Agent
WORKDIR /opt
RUN <<EOF
    git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git
    cd Micro-XRCE-DDS-Agent
    cmake -B build
    cmake --build build -j8
    cmake --install build
    ldconfig /usr/local/lib
    rm -rf Micro-XRCE-DDS-Agent
EOF

FROM microxrce as px4

RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

ENV PX4_VERSION 1.14

RUN git clone https://github.com/PX4/PX4-Autopilot.git PX4 --recursive -b release/${PX4_VERSION}
RUN bash ./PX4/Tools/setup/ubuntu.sh
RUN pip3 install --user -U pyros-genmsg
RUN cd PX4 && make px4_sitl

FROM px4 as ros2-px4
RUN <<EOF
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get upgrade -y
    apt-get install -y ros-$ROS_DISTRO-rosbridge-server python3-pip supervisor wget python3-setuptools \
        python3-packaging python3-empy
    rm -rf /var/lib/apt/lists/*
EOF

RUN pip3 install --user -U simplejpeg tornado

ENV WORKSPACE_DIR /opt/ros2_ws

# Create workspace
WORKDIR $WORKSPACE_DIR/src

# Install ROS packages
RUN <<EOF
    . /opt/ros/$ROS_DISTRO/setup.sh
    git clone --depth 1 https://github.com/dheera/rosboard.git
    git clone --depth 1 https://github.com/AleOrcia/ROS2_PX4_Quadcopter_Controller.git
    git clone --depth 1 https://github.com/PX4/px4_msgs.git -b release/1.14

    cd $WORKSPACE_DIR
    rosdep install -i --from-paths src --rosdistro $ROS_DISTRO -y
    colcon build
EOF



RUN echo ". /opt/ros/$ROS_DISTRO/setup.sh\n. $WORKSPACE_DIR/install/setup.sh" >/opt/setup.sh

# Supervisor
COPY docker/supervisord.conf /etc/supervisord.conf
RUN mkdir -p /opt/supervisord
COPY docker/*.sh /opt/supervisord/
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
