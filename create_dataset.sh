#!/bin/bash
source ~/.bashrc

# Define variables
label_path=$1
if ! [[ -f "$label_path" ]]; then
  echo "$label_path is not a file."
  return 1
fi

gazebo_start_time=20

num_poses=21
num_worlds=2

# TODO: Add more files
path_to_worlds="/home/ubuntu/koopacar-simulation-assets/src/koopacar_simulation/koopacar_simulation/worlds/"
world_files=("cone_cluster.world" "track01_circle.world")
launch_files=("cone_cluster.launch.py" "track01_circle.launch.py")

# Run every simulation with every position
for w_ind in $(seq 0 `expr $num_worlds - 1`)
do
  for i in $(seq 0 `expr $num_poses - 1`)
  do
    # Set bot pose TODO: Change pose using ros2 service 'ros2 service call /gazebo/set_entity_state 'gazebo_msgs/SetEntityState' '{state: {name: "KoopaCar", pose: {position: {y: 2}}}}''
    python3 change_pose_gazebo.py -f /home/ubuntu/koopacar-simulation-assets/poses.txt -i $i -o KoopaCar -w "$path_to_worlds${world_files[$w_ind]}"

    if [ $? -ne 0 ];
    then
      echo "Error in change_pose_gazebo.py. Evaluate stack trace for more information."
      return 1
    fi

    # Install missing dependencies
    rosdep install -i --from-path src --rosdistro foxy -y

    # source package and nodes
    . install/setup.bash

    # build
    colcon build

    source install/local_setup.bash

    # Launch simulation
    ros2 launch koopacar_simulation cone_cluster.launch.py &

    # Wait
    sleep $gazebo_start_time

    # make snapshot
    ros2 param set /lidar_collection store_once True

    # label new data
    python3 $label_path -pf /home/ubuntu/koopacar-simulation-assets/poses.txt -i $i -w "$path_to_worlds${world_files[$w_ind]}" -d /home/ubuntu/koopacar-system/data/lidar_perception/new_data_set
  done

  # Kill simulation
  pkill ros2
  pkill gazebo
  pkill gzserver
  pkill gzclient
done

$@