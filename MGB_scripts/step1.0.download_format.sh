#!/bin/bash
#$ -cwd
#$ -N step1_0
#$ -l h_rt=168:00:00
#$ -l s_rt=168:00:00
#$ -l h_vmem=24G
#$ -o step10.log
#$ -e step10.log

source /broad/software/scripts/useuse
reuse -q Python-3.9

i=$SGE_TASK_ID

# trait is read from first command line argument
trait=$1

# location of trait directory created in step 0
trait_dir=$2

# location of all scripts, with subdirectory containing helper scripts
script_dir=$3


# download GRCh38-harmonized scores from PGS Catalog
download_from_pgs () {
    trait=$1
    pgs_id=$2

    cd $obj_trait_dir

    echo -e "starting pgs catalog downloads for ${pgs_id}! \n"
    ofile="pgs_catalog_harmonized_weights/${pgs_id}_hmPOS_GRCh38.txt.gz"
    link="https://ftp.ebi.ac.uk/pub/databases/spot/pgs/scores/${pgs_id}/ScoringFiles/Harmonized/${pgs_id}_hmPOS_GRCh38.txt.gz"

    wget -O $ofile $link
    gzip -d $ofile

    echo -e "finished pgs catalog downloads for ${pgs_id}! \n"
}

# reformat weights from PGS Catalog to be PRSmix-input compatible 
format_pgs_weights () {
    trait=$1
    pgs_id=$2

    cd $obj_trait_dir

    echo -e "starting formatting for trait ${trait}! \n"
    
    # reformat weights from pgs catalog to be prsmix-input compatible
    python3 $obj_script_dir/helper/reformat_pgs_weights.py ${trait} ${pgs_id}
    
    echo -e "finished formatting weights for ${pgs_id}! \n"
}


cwd=$PWD
obj_trait_dir=${cwd}/${trait_dir}
obj_script_dir=${cwd}/${script_dir}


pgs_id=$( head -n $i ${obj_trait_dir}/weights/${trait}.score_list.txt | tail -1 )

download_from_pgs $trait $pgs_id
format_pgs_weights $trait $pgs_id

echo -e "finished all step 1.0 tasks for score ${pgs_id} ! \n"
cd $cwd

