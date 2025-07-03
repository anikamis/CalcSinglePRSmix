#!/bin/bash

# get name of trait from first command-line argument
trait=$1

# location of trait directory created in step 0
trait_dir=$2

# location of all scripts, with subdirectory containing helper scripts
script_dir=$3


cal_indiv_prsmix () {
    trait=$1

    cd $obj_trait_dir

    in_score_prefix=scores/summed_scores/${trait}.ACAF.ALL
    out_score_prefix=scores/summed_scores/${trait}.ACAF.with_PRSmix.ALL

    num_scores=$( ls add_in_prsmix/with_*/${trait}.score_list.txt | wc -w )

    prsmix_dir=for_prsmix

    colname=PRSmix.AOU_SUM

    python3 ${obj_script_dir}/helper/apply_individual_prsmix.py $trait $in_score_prefix $out_score_prefix $prsmix_dir $colname
    
    echo -e "finished running all add in PRSmix!"
    
    cd $cwd
}

cwd=$PWD
obj_trait_dir=${cwd}/${trait_dir}
obj_script_dir=${cwd}/${script_dir}

cal_indiv_prsmix $trait 

echo -e "finished all step 4 tasks for trait ${trait} ! \n"
cd $cwd
