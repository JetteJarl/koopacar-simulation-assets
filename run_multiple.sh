#!/bin/bash
source ~/.bashrc

#TODO: get path to label func as input

# Define variables
ttl=20

num_poses=21
num_worlds=2

path_to_worlds="/home/ubuntu/koopacar-simulation-assets/src/koopacar_simulation/koopacar_simulation/worlds/"
world_files=("cone_cluster.world" "track01_circle.world")
launch_files=("cone_cluster.launch.py" "track01_circle.launch.py")

# Run every simulation with every position
for w_ind in $(seq 0 `expr $num_worlds - 1`)
do
  for i in $(seq 0 `expr $num_poses - 1`)
  do
    # Set bot pose
    python3 change_pose_gazebo.py -f /home/ubuntu/koopacar-simulation-assets/poses.txt -i $i -o KoopaCar -w "$path_to_worlds${world_files[$w_ind]}"

    if [ $? -ne 0 ];
    then
      echo "Error in change_pose_gazebo.py. Evaluate stack trace for more information."
      exit 1
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
    sleep $ttl

    # Kill simulation
    pkill ros2
    pkill gazebo
    pkill gzserver
    pkill gzclient

    # TODO: Call labeling
  done
done

$@