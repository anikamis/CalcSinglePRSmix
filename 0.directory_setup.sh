#!/bin/bash

# trait is read from first command line argument, dir will be named for_${trait}
trait=$1

# tab-separated file of all single scores in chronological order by publication date
# first column contains PGS ID, second column contains publication PGP ID
pgs_list=$2

set_up_dirs () {
    trait=$1
    pgs_list=$2

    # make directory and copy directory structure
    mkdir for_${trait}  ; cd for_${trait} 
    # mkdir -p scores/summed_scores scores/raw_scores add_in_prsmix pgs_catalog_harmonized_weights weights all_harmonized_weights
    mkdir -p scores/summed_scores scores/raw_scores for_prsmix pgs_catalog_harmonized_weights weights all_harmonized_weights

    cp $cwd/$pgs_list for_prsmix/${trait}.score_list.txt
    cp $cwd/$pgs_list weights/${trait}.score_list.txt

    pgs_list=for_prsmix/${trait}.score_list.txt

    cd $cwd
}

cwd=$PWD

set_up_dirs $trait $pgs_to_pgp

echo -e "finished all step 0 tasks for ${trait} ! \n"
cd $cwd

