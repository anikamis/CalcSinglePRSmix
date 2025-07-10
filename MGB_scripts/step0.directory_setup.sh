#!/bin/bash
#$ -cwd
#$ -N step0
#$ -l h_rt=168:00:00
#$ -l s_rt=168:00:00
#$ -l h_vmem=8G
#$ -o step0.log
#$ -e step0.log

source /broad/software/scripts/useuse

# trait is read from first command line argument, dir will be named for_${trait}
trait=$1

# list of all input scores
score_list_file=$2

# output weight file from aou
prsmix_weight_list=$3

# if "all", run all input scores
# if "prsmix", run only scores needed for calculating prsmix
which=$4

set_up_dirs () {
    trait=$1
    score_list_file=$2
    prsmix_weight_list=$3
    which=$4

    # make directory and copy directory structure
    mkdir -p for_${trait}  ; cd for_${trait} 
    # mkdir -p scores/summed_scores scores/raw_scores add_in_prsmix pgs_catalog_harmonized_weights weights all_harmonized_weights
    mkdir -p scores/summed_scores scores/raw_scores for_prsmix pgs_catalog_harmonized_weights weights all_harmonized_weights

    cp $cwd/$prsmix_weight_list for_prsmix/${trait}_power.0.95_pthres.0.05_weight_PRSmix.txt

    pgs_list=weights/${trait}.score_list.txt

    # if running all input scores
    if [[ "$which" == "all" ]] ;
    then
        cp ${cwd}/${score_list_file} $pgs_list
    
    # only want to score the scores needed/weighted by prsmix
    elif [[ "$which" == "prsmix" ]] ;
    then
        infile="for_prsmix/${trait}_power.0.95_pthres.0.05_weight_PRSmix.txt"

        # filter out unweighted scores, only keep ones required in weights directory
        while IFS=$' ' read -r pgs_id weight ; 
        do
            if [[ "$weight" == "ww" || "$weight" == "0" ]] ;
            then
                continue
            else
                echo "${pgs_id}" >> $pgs_list
            fi

        done < $infile

    else
        echo "ERROR: INVALID <WHICH> ARGUMENT"
    fi




    infile="${cwd}/${prsmix_weight_list}"



    cd $cwd
}

cwd=$PWD

set_up_dirs $trait $score_list_file $prsmix_weight_list $which

echo -e "finished all step 0 tasks for ${trait} ! \n"
cd $cwd

