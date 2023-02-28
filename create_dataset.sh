#!/bin/bash
source ~/.bashrc

# catch sigint
control_c() {
  # Kill simulation
  pkill ros2
  pkill gazebo
  pkill gzserver
  pkill gzclient

  return 1
}

trap control_c SIGINT


# Define variables
label_path=$1
if ! [[ -f "$label_path" ]]; then
  echo "$label_path is not a file. Need "
  return 1
fi

gazebo_start_time=30

num_worlds=2

path_to_worlds="/home/ubuntu/koopacar-simulation-assets/src/koopacar_simulation/koopacar_simulation/worlds/"
world_files=("cone_circles.world" "cones_cubes.world")
launch_files=("cone_circles.launch.py" "cones_cubes.launch.py")

# Install missing dependencies
rosdep install -i --from-path src --rosdistro foxy -y

# source package and nodes
. install/setup.bash

# build
colcon build

source install/local_setup.bash

# Run every simulation with every position
for w_ind in $(seq 0 `expr $num_worlds - 1`)
do
  # Launch simulation
  ros2 launch koopacar_simulation "${launch_files[w_ind]}" &

  # Wait
  sleep $gazebo_start_time

  while read line; do
    IFS=', ' read -r -a pose_array <<< "$line"

    ros2 service call /gazebo/set_entity_state "gazebo_msgs/SetEntityState" "{state: {name: "KoopaCar", \
    pose: {position: {x: "${pose_array[0]}", y: "${pose_array[1]}", z: "${pose_array[2]}"}, \
    orientation: {x: "${pose_array[3]}", y: "${pose_array[4]}", z: "${pose_array[5]}", w: "${pose_array[6]}"}}}}"

    sleep 3

    # make snapshot
    ros2 param set /lidar_collection store_once True

    # label new data
    python3 $label_path -p $line -w "$path_to_worlds${world_files[$w_ind]}" -d /home/ubuntu/koopacar-system/data/lidar_perception/new_data_set

    sleep 3

  done < "/home/ubuntu/koopacar-simulation-assets/poses_quaternions.txt"

  sleep 30

  # Kill simulation
  pkill ros2
  pkill gazebo
  pkill gzserver
  pkill gzclient
done

$@