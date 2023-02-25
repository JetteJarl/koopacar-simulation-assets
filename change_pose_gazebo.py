import re
import sys
import argparse


def _models_from_sdf(xml_string):
    state_tag_reg = re.compile("<state.*?</state>", flags=re.DOTALL)
    model_reg = re.compile("<model.*?</model>", flags=re.DOTALL)

    state = state_tag_reg.findall(xml_string)  # find state tag
    models = model_reg.findall(state[0])  # find all models in state tag

    return models


def set_pose_in_sdf(pose, object_name, file_path):
    """
    Set the pose of an object in the given sdf file.

    pose        --> [x, y, z, roll, pitch, yaw]
    object_name --> [name in model tag]
    file_path   --> [path of sdf file]
    """
    if len(pose) != 6:
        raise Exception("Pose needs to be of form [x, y, z, roll, pitch, yaw]")

    with open(file_path, 'r') as file:
        xml_string = file.read()

    pose_reg = re.compile("<pose>.*?</pose>", flags=re.DOTALL)

    models = _models_from_sdf(xml_string)  # find all models in state tag

    for model in models:
        if f"<model name='{object_name}'>" in model:
            pose_tag_old = pose_reg.search(model).group()
            pose_string_old = pose_tag_old.replace("<pose>", "").replace("</pose>", "")
            pose_string_new = " ".join([str(x) for x in pose])
            pose_tag_new = pose_tag_old.replace(pose_string_old, pose_string_new)

            # replace old pose
            xml_string = xml_string.replace(pose_tag_old, pose_tag_new, 1)

            with open(file_path, 'w') as file:
                file.write(xml_string)

            return

    raise Exception(f"No model tag found with name {object_name}")


def main():
    parser = argparse.ArgumentParser(description="Script running a specified gazebo simulation with a specific "
                                                 "Turtlebot position")
    parser.add_argument('-p', '-pose', nargs='+', type=float, help="Set of 6 numbers specifying a models pose in the "
                                                                   "gazebo simulation.", required=False)
    parser.add_argument('-o', '-object_name', type=str, help="Name of the object, whose position is being set in the "
                                                             "script.", required=False)
    parser.add_argument('-w', '-world', type=str, help="File path specifying the location of the world file (sdf) "
                                                       "describing the simulation.", required=False)
    parser.add_argument('-f', '-file', type=str, help="File containing a set of possible bot poses.", required=False)
    parser.add_argument('-i', '-index', type=int, help="Index referencing a pose from the specified file.",
                        required=False)

    args = parser.parse_args()

    # TODO: Clean up
    # if not args.p and not (args.f and args.i):
    #    print("Either specify a pose directly using -p or reference a file and an index referencing a pose using -f "
    #          "and -i.")
    #    return -1

    if args.p and args.f and args.i:
        print("Please use only one of the options. Specify a pose (-p) OR a file and index (-f, -i).")
        return -1

    if not args.o:
        print("Specify the objects name with -o.")
        return -1

    if not args.w:
        print("Specify the world file matching the simulation with -w.")
        return -1

    if args.f is not None and args.i is not None:
        pose_file = open(args.f)
        all_poses = pose_file.readlines()

        pose = all_poses[args.i][0:-1]

        print(pose)

    # TODO: Change simulation
    # set_pose_in_sdf(args.p, args.o, args.w)


if __name__ == '__main__':
    main()
