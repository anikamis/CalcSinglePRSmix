#!/bin/bash

# file containing all pgs_ids
score_list=$1

# location of directory containing tool binaries (i.e. parallel)
tool_dir=$2

# example run:
# ./download_all_metadata.sh ../score_file_lists/CAD.score_list.txt ../tools

# download GRCh38-harmonized scores from PGS Catalog
download_from_pgs () {

    echo -e "starting pgs catalog downloads for trait ${trait}! \n"

    ${obj_tool_dir}/parallel -a $obj_score_list -j 10 'wget -O  "{}_metadata_cohorts.csv" https://ftp.ebi.ac.uk/pub/databases/spot/pgs/scores/{}/Metadata/{}_metadata_cohorts.csv && wget -O "{}_metadata_score_development_samples.csv" https://ftp.ebi.ac.uk/pub/databases/spot/pgs/scores/{}/Metadata/{}_metadata_score_development_samples.csv'
}



cwd=$PWD
obj_tool_dir=${cwd}/${tool_dir}
obj_score_list=${cwd}/${score_list}

download_from_pgs $trait

cd $cwd
