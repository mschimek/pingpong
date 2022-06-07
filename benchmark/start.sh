#!/bin/bash

num_bytes_start=$1
num_bytes_stop=$2
stepsize=$3
iterations=$4
num_nodes=$5
id=$6
desc=$7
partition=$8
account=$9

tasks_per_node=$((2 / $num_nodes))

subdirectory="${desc}_$(date +"%Y_%m_%d")"
path="$HOME/pingpong_experiments/${subdirectory}"
path_to_exec="$HOME/pingpong/build"
mkdir -p ${path}
mkdir -p ${path}/output

cp ./job_template.sh "${path}/job_template.sh"
cp ./supermuc_load_config.sh "${path}/supermuc_load_config.sh"
cp "${path_to_exec}/pingpong" "${path}/"

sed -i "s/NUM_BYTES_START/$num_bytes_start/"                                      "${path}/job_template.sh"
sed -i "s/NUM_BYTES_STOP/$num_bytes_stop/"                                        "${path}/job_template.sh"
sed -i "s/STEPSIZE_TO_BE_REPLACED/$stepsize/"                                     "${path}/job_template.sh"
sed -i "s/ITERATIONS_TO_BE_REPLACED/$iterations/"                                 "${path}/job_template.sh"
sed -i "s/ID_TO_BE_REPLACED/$id/"                                                 "${path}/job_template.sh"
sed -i "s/NUM_NODES_TO_BE_REPLACED/$num_nodes/"                                   "${path}/job_template.sh"
sed -i "s/TASKS_PER_NODE_TO_BE_REPLACED/$tasks_per_node/"                         "${path}/job_template.sh"
sed -i "s|PATH_TO_BE_REPLACED|$path|"                                             "${path}/job_template.sh"

sbatch --partition=${partition} --time=00:30:00 "${path}/job_template.sh" --account ${account}


