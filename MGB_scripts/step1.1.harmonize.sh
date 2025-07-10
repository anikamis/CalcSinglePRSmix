#!/bin/bash
#$ -cwd
#$ -N step1_1
#$ -l h_rt=168:00:00
#$ -l s_rt=168:00:00
#$ -l h_vmem=40G
#$ -o step11.log
#$ -e step11.log
#$ -t 1-23

source /broad/software/scripts/useuse
source activate /home/unix/misraani/.conda/envs/r_env

i=$SGE_TASK_ID

# trait is read from first command line argument
trait=$1

# location of trait directory created in step 0
trait_dir=$2

# location of all scripts, with subdirectory containing helper scripts
script_dir=$3

# location of ref file 
ref_file=$4



# use PRSmix to harmonize weights together
harmonize_pgs_weights () {
    trait=$1
    obj_ref_file=$2
    chr=$3

    cd $obj_trait_dir

    echo -e "starting harmonization for trait ${trait}! \n"
    
    pattern="chr${chr}:"
    cd weights
    
    mkdir weights_chr${chr}
    list=weights_chr${chr}/${trait}.score_list.chr${chr}.txt

    for f in PGS*.txt ;
    do
        pid="${f::-4}"
        fprefix="${pid}.chr${chr}"

        echo -e $fprefix >> $list
        
        ofile=weights_chr${chr}/${fprefix}.txt
        head -1 $f > $ofile
        grep $pattern $f >> $ofile 
    done
    cd ..

    pgs_folder=weights/weights_chr${chr}/
    pgs_list=weights/weights_chr${chr}/${trait}.score_list.chr${chr}.txt
    out=all_harmonized_weights/${trait}.all_harmonized_weights.ALL_SNPS.chr${chr}.txt
    chr_ref_file=${obj_ref_file}${chr}.snpinfo

    # run prsmix script to harmonize all pgs weight files together
    Rscript --vanilla $obj_script_dir/helper/harmonize_snpeffect_toALT_prsmix.R ${trait} $chr_ref_file $pgs_folder $pgs_list $out

    echo -e "finished harmonizing weight files together for trait ${trait} for chr${chr}! \n"
}


cwd=$PWD
obj_trait_dir=${cwd}/${trait_dir}
obj_script_dir=${cwd}/${script_dir}
obj_ref_file=${cwd}/${ref_file}

echo {22..1} X | tr " " "\n" | head -n $i | tail -n 1 | while read x ; do
    chr="${x}"
    harmonize_pgs_weights $trait $obj_ref_file $chr
done


echo -e "finished all step 1.1 tasks for trait ${trait} for chr${x} ! \n"
cd $cwd

