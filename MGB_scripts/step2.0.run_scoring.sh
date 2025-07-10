#!/bin/bash
#$ -cwd
#$ -N step2_0
#$ -l h_rt=168:00:00
#$ -l s_rt=168:00:00
#$ -l h_vmem=40G
#$ -o step20.log
#$ -e step20.log
#$ -t 1-23

source /broad/software/scripts/useuse
reuse -q GCC-5.2

i=$SGE_TASK_ID

# get name of trait from first command-line argument
trait=$1

# location of trait directory created in step 0
trait_dir=$2

# location of all scripts, with subdirectory containing helper scripts
script_dir=$3

# prefix of plink bed files up til chromosome number, e.g. aou_acaf/acaf_threshold.chr
plink_file_prefix=$4

# location of directory containing tool binaries (e.g. parallel, plink2)
tool_dir=$5

run_plink_scoring () {
    trait=$1
    obj_plink_file_prefix=$2

    chr=$3

    cd $obj_trait_dir

    echo -e "starting plink2 scoring for chr${chr} for trait ${trait}! \n"

    score_file="all_harmonized_weights/${trait}.all_harmonized_weights.ALL_SNPS.chr${chr}.txt"
    pfile="${obj_plink_file_prefix}${chr}"
    out="scores/raw_scores/${trait}.ACAF.chr${chr}"

    num_cols=$( head -1 $score_file | wc -w )

    # ${obj_tool_dir}/plink2 --threads $num_threads --memory $mem_per_score --bfile $obj_plink_file_prefix{} --score all_harmonized_weights/${trait}.all_harmonized_weights.ALL_SNPS.chr{}.txt cols=fid,scoresums no-mean-imputation header-read --score-col-nums 4-$num_cols --out scores/raw_scores/${trait}.ACAF.chr{} ::: {22..1} X
    ${obj_tool_dir}/plink2 --pfile $pfile --score $score_file cols=fid,scoresums no-mean-imputation header-read --score-col-nums 4-$num_cols --out $out

    echo -e "finished plink2 scoring for all chromosomes for trait ${trait}! \n"

    cd $cwd

}



cwd=$PWD
obj_trait_dir=${cwd}/${trait_dir}
obj_script_dir=${cwd}/${script_dir}
obj_plink_file_prefix=${cwd}/$plink_file_prefix
obj_tool_dir=${cwd}/${tool_dir}

echo {22..1} X | tr " " "\n" | head -n $i | tail -n 1 | while read x ; do
    chr="${x}"
    run_plink_scoring $trait $obj_plink_file_prefix $chr
done


echo -e "finished all step 2 tasks for trait ${trait} ! \n"
cd $cwd

