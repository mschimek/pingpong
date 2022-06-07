import argparse
import os
import subprocess
import tempfile
import sys

parser = argparse.ArgumentParser(description='Process some data.')
parser.add_argument("--names", help="names of the experiment to process [comma separated]")
parser.add_argument("--path", help="path to experiment directory")

args = parser.parse_args()

names = args.names.split(",")

def concat_file(concat_file_path, base_path, directorynames) :
    for i, name in enumerate(directorynames):
        directory = base_path + "/" + name + "/"
        directory = os.path.abspath(directory)
        directorynames[i] = directory
    with open(concat_file_path, 'a+') as concat_file:
        for directory in directorynames:
            print(directory)
            for filename in os.listdir(directory):
                if filename.startswith("err"):
                    continue
                print(filename)
                with open(os.path.join(directory, filename), 'r') as file:
                    for line in file.readlines():
                        concat_file.write(line)

#with tempfile.TemporaryDirectory() as tmp:
tmp = "./tmp"
try:
    os.makedirs(tmp)
except OSError:
    print ("Creation of the directory %s failed" % tmp)
else:
    print ("Successfully created the directory %s" % tmp)

working_dir = tmp
print(working_dir)
concat_file_name = "concat_file"
concat_file_path = os.path.join(working_dir, concat_file_name)
print(concat_file_path)
concat_file(concat_file_path, args.path, names)
os.chdir(tmp)
subprocess.check_output(["touch", "file.db"])
subprocess.run("/home/matthias/Promotion/code/sqlplot-tools/build/src/sqlplot-tools import-data -D sqlite:file.db ex1 {file}".format(file = concat_file_name), shell=True)
with open("sql_commands", "w+") as sql_commands:
    sql_commands.write(".headers on\n")
    sql_commands.write(".mode csv\n")
    sql_commands.write(".output out\n")
    sql_commands.write("SELECT * FROM ex1;\n")
    sql_commands.write(".exit\n")

with open('sql_commands', 'r') as infile:
    subprocess.run(['sqlite3', 'file.db'], 
        stdin=infile, stdout=sys.stdout, stderr=sys.stderr)


    
