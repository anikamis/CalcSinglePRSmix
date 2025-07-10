#!/bin/bash
#$ -cwd
#$ -N step2_1
#$ -l h_rt=168:00:00
#$ -l s_rt=168:00:00
#$ -l h_vmem=20G
#$ -o step21.log
#$ -e step21.log

source /broad/software/scripts/useuse
reuse -q Python-3.9

# get name of trait from first command-line argument
trait=$1

# location of trait directory created in step 0
trait_dir=$2

# location of all scripts, with subdirectory containing helper scripts
script_dir=$3


sum_per_chr_scores () {
    trait=$1

    cd $obj_trait_dir

    echo -e "starting to sum per-chrom scores for trait ${trait}! \n"

    python3 $obj_script_dir/helper/sum_per_chr_scores.py $trait    

    echo -e "finished summing per-chrom scores for trait ${trait}! \n"

    cd $cwd
}


cwd=$PWD
obj_trait_dir=${cwd}/${trait_dir}
obj_script_dir=${cwd}/${script_dir}


sum_per_chr_scores $trait

echo -e "finished all step 2 tasks for trait ${trait} ! \n"
cd $cwd

