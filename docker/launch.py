from launch import LaunchDescription
from launch_ros.actions import Node
from launch.actions import ExecuteProcess


def generate_launch_description():
    nodes = [
            # PX4 <-> ROS2 bridge
            ExecuteProcess(name="MicroXRCEAgent", cmd=["MicroXRCEAgent", "udp4", "-p", "8888"], shell=True),

            # PX4 simulator + Gazebo
            ExecuteProcess(name="PX4", cmd=["make", "-C", "/opt/PX4", "px4_sitl", "gz_x500"], prefix="xterm -e", shell=True),

            # Web Server on port <robot_ip>:8888
            Node(package="rosboard", executable="rosboard_node", name="rosboard"),

            # WebSocket server on <robot_ip>:9090
            Node(package="rosbridge_server", executable="rosbridge_websocket", name="rosbridge"),

            # Control Terminal
            Node(package="px4_offboard", executable="control", prefix="xterm -e", name="term_controller"),
            # Bridge between /fcu and the control terminal
            Node(package="px4_offboard", executable="velocity_control", name="velocity_controller"),

            # Bridge between /fcu and /px4_visualizer. Translates the messages from PX4 to ROS2
            Node(package="px4_offboard", executable="visualizer"),

            # RVIZ2 Visualizer
            Node(package="rviz2", executable="rviz2", arguments=[
                 '-d', ['/opt/ros2_ws/src/ROS2_PX4_Quadcopter_Controller/px4_offboard/resource/visualize.rviz']
            ]),

            # Node graphs
            ExecuteProcess(cmd=["rqt_graph"]),
    ]

    return LaunchDescription(nodes)
