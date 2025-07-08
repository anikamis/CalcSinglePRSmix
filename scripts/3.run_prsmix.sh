#!/bin/bash

# get name of trait from first command-line argument
trait=$1

# location of trait directory created in step 0
trait_dir=$2

# location of all scripts, with subdirectory containing helper scripts
script_dir=$3

# location of covariate file
covariate_file=$4

# location of phenotype file
pheno_file=$5

# name of phenotype column
pheno_name=$6

# TRUE if trait is binary else FALSE
isbinary=$7

# number of cores to run a single iteration of PRSmix
ncores=$8

# name of column containing age in covar file
age=$9

# name of column containing sex in covar file
sex=${10}

# column containing person IDs in covar and pheno file
IID_pheno=${11}

# for each type of classification
run_prsmix () {
    trait=$1
    covariate_file=$2
    pheno_file=$3
    pheno_name=$4
    isbinary=$5
    ncores=$6
    age=$7
    sex=$8
    IID_pheno=$9
    
    cd $obj_trait_dir


    echo -e "starting prsmix for trait ${trait}! \n"

    out=for_prsmix/${trait}
    score_files_list=scores/summed_scores/${trait}.ACAF.ALL.sscore
    trait_specific_score_file=for_prsmix/${trait}.score_list.txt

    Rscript --vanilla ${obj_script_dir}/helper/run_PRSmix.R $trait $covariate_file $score_files_list $trait_specific_score_file $pheno_file $pheno_name $isbinary $out $ncores $age $sex $IID_pheno

    
    echo -e "finished running all add in PRSmix!"
    
    cd $cwd
}

cwd=$PWD
obj_trait_dir=${cwd}/${trait_dir}
obj_script_dir=${cwd}/${script_dir}

run_prsmix $trait ${cwd}/$covariate_file ${cwd}/$pheno_file $pheno_name $isbinary $ncores $age $sex $IID_pheno

echo -e "finished all step 3 tasks for trait ${trait} ! \n"
cd $cwd
