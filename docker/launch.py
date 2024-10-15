from launch import LaunchDescription
from launch_ros.actions import Node
from launch.actions import ExecuteProcess


def generate_launch_description():
    return LaunchDescription(
        [
            Node(name="rosboard", package="rosboard", executable="rosboard_node"),
            Node(name="rosbridge", package="rosbridge_server", executable="rosbridge_websocket"),
            Node(name="term_controller", package="px4_offboard", executable="control", prefix="xterm -e"),
            Node(name="velocity_controller", package="px4_offboard", executable="velocity_control"),
            # Node(package="px4_offboard", namespace="px4_offboard", executable="visualizer", name="visualizer"),
            # ros2 run ros_gz_bridge parameter_bridge /x500_0/command/motor_speed@actuator_msgs/msg/Actuators[gz.msgs.Actuators
            # ExecuteProcess(
            #     cmd=[
            #         "ros2",
            #         "run",
            #         "ros_gz_bridge",
            #         "parameter_bridge",
            #         "/x500_0/command/motor_speed@actuator_msgs/msg/Actuators[gz.msgs.Actuators",
            #     ]
            # ),
            ExecuteProcess(cmd=["rqt_graph"]),
            ExecuteProcess(name="PX4", cmd=["make", "-C", "/opt/PX4", "px4_sitl", "gz_x500"], shell=True),
            ExecuteProcess(name="MicroXRCEAgent", cmd=["MicroXRCEAgent", "udp4", "-p", "8888"], shell=True),
        ]
    )
