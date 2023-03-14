# koopacar-simulation-assets

This repository contains assets related to running simulations for the KoopaCar. The simulations are meant as a adequate testing environment and are created and run in Gazebo.

This simulation works with ROS 2 Foxy and Gazebo 11.

## How to run the simulation

Before building the package make sure the correct versions for Gazebo and ROS are installed.

Next if not already done install the ros-foxy-gazebo packages: \
$ sudo apt-get install ros-foxy-gazebo-* \
Some other ros packages might also need to be installed depending on the setup.

Set the GAZEBO_MODEL_PATH to contain all the path to the models directory from this repository. \
$ export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:<path to directory>/koopacar-simulation-assets/src/koopacar_simulation/koopacar_simulation/models \
You might consider adding this line to the '~/.bashrc' file. 

Lastly there are probably some missing Python packages: \
$ sudo pip3 install setuptools \
$ sudo pip3 install glob2

Now the package can be build using 'colcon build' and the simulation can be run by executing the corresponding node. \
$ . install/setup.bash \
$ ros2 launch koopacar_simulation cone_cluster.launch.py

## How to add additional worlds / simulated environments

1. Create new sdf file with gazebo and add models
2. Save file as *.world in the "worlds" directory
3. Create a new launch file *.launch.py and add the new world file (use existing file as example)
4. Build and run the simulation

## How to create replays

1. Run a simulation by following the steps above
2. Press Ctrl+D or click the icon in the top right to open the Data Logger
3. Save any log by clicking on the red button
4. Close Gazebo
5. Add the KoopaCar/cone models from `src/koopacar_simulation/koopacar_simulation/models` to `/home/<username>/.gazebo/models`
6. Replay the log with `gazebo -p <path_to_log_file>`

## Related

The package was build using the Tutorial "How to Simulate a Robot Using Gazebo and ROS 2" from automaticaddision.com. 
Some code passages were copied from this Tutorial.

The model for the KoopaCar ist build on the Turtlebot3 Burger model from ROBOTIS (https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git).
The meshes for the core model are taken from this repository.

An overview over Logging and playback in Gazebo can be found [here](https://classic.gazebosim.org/tutorials?cat=tools_utilities&tut=logging_playback)
