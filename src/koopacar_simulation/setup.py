import os
from glob import glob
from setuptools import setup

package_name = 'koopacar_simulation'

# Path to current directory
cur_directory_path = os.path.abspath(os.path.dirname(__file__))

setup(
    name=package_name,
    version='0.0.0',
    packages=[package_name],
    data_files=[
        ('share/ament_index/resource_index/packages',
            ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),

	# Path to launch file
	(os.path.join('share', package_name, 'launch'), glob('launch/*.launch.py')),

	# Path to world file
	(os.path.join('share', package_name,'worlds/'), glob('./koopacar_simulation/worlds/*')),
	(os.path.join('share', package_name,'models/'), glob('./worlds/*')),

	# Path to KoopaCar sdf file
    (os.path.join('share', package_name,'models/koopacar/meshes'), glob('./koopacar_simulation/models/koopacar/meshes/*')),
	(os.path.join('share', package_name,'models/koopacar/'), glob('./koopacar_simulation/models/koopacar/mo*')),

	# Path to cones sdf files
	(os.path.join('share', package_name,'models/orange_cone/'), glob('./koopacar_simulation/models/orange_cone/*')),
	(os.path.join('share', package_name,'models/blue_cone/'), glob('./koopacar_simulation/models/blue_cone/*')),
	(os.path.join('share', package_name,'models/yellow_cone/'), glob('./koopacar_simulation/models/yellow_cone/*')),
    (os.path.join('share', package_name,'models/cone_meshes/'), glob('./koopacar_simulation/models/cone_meshes/*')),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='ubuntu',
    maintainer_email='maintainer.maintains@foo.de',
    description='Package with custom simulation for an autonomous driving Turtlebot3 called KoopaCar',
    license=' ',
    tests_require=['pytest'],
    entry_points={
        'console_scripts': [
		# ros2 node to spawn koopacar with world
		'koopacar_simulation = koopacar_simulation.koopacar_simulation:main'
        ],
    },
)
