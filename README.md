# ChronoAdd

## Step 0: Directory setup

### inputs: 
* <trait_name> : trait name
* <score_list_file> : file containing list of PGS ids
### runline: ./0.directory_setup.sh <trait_name> <score_list_file>
### example: ./0.directory_setup.sh CAD CAD.score_list.txt



## Step 1: Download PGS ids, format, and harmonize to reference

### inputs: 
* <trait_name> : trait name
* <trait_dir> : location of directory created in step 0, should be named for_<trait_name>
* <script_dir> : location of directory containing these scripts
* <ref_file> : location of file with three columns for every SNP in genotype data: ID, ALT, and REF
  * see PRSmix github for more instructions
  * example head of valid ref file:
    >   ID      ALT     REF
    >   chr1:10001:T:A  A       T
    >   chr1:10001:T:C  C       T
    >   chr1:10108:C:CAA        CAA     C
* <tool_dir> : location of directory containg tools, i.e. GNU parallel binary
  
### runline: ./1.download_format_harmonize.sh <trait_name> <trait_dir> <script_dir> <ref_file> <tool_dir>
### example: ./1.download_format_harmonize.sh CAD for_CAD scripts aou_acaf/acaf_threshold.ALL_CHRS.snpinfo tools



## Step 2: Run PLINK2 scoring and sum all per-chromosome scores together

### inputs: 
* <trait_name> : trait name
* <trait_dir> : location of directory created in step 0, should be named for_<trait_name>
* <script_dir> : location of directory containing these scripts
* <plink_file_prefix> : prefix of all plink bed files
* <num_at_a_time> : how many chromosomes to run at a single time (choose based on environment specs)
* <num_threads> : how many threads to use to run a single score (PLINK2 parameter, choose based on environment specs)
* <mem_per_score> : how much memory to use to run a single score (PLINK2 parameter, choose based on environment specs)
* <tool_dir> : location of directory containg tools, i.e. GNU parallel binary

### runline: ./2.run_plink_scoring.sh <trait_name> <trait_dir> <script_dir> <plink_file_prefix> <num_at_a_time> <num_threads> <mem_per_score> <tool_dir>
### example: ./2.run_plink_scoring.sh CAD for_CAD scripts aou_acaf/acaf_threshold.chr 3 4 500 tools



## Step 3: Run PRSmix

### inputs: 
* <trait_name> : trait name
* <trait_dir> : location of directory created in step 0, should be named for_<trait_name>
* <script_dir> : location of directory containing these scripts
* <covariate_file> : location of covariate file containing person_id, age, sex, PC1:10
* <pheno_file> : location of phenotype file containing IID, phenotype
* <pheno_name> : name of column in pheno_file containing phenotype
* <\isbinary\> : TRUE if trait is binary else FALSE
* <\ncores\> : number of cores to run PRSmix (PRSmix parameter, refer to github for details)

### runline: ./3.run_prsmix.sh <trait_name> <trait_dir> <script_dir> <covariate_file> <pheno_file> <pheno_name> <isbinary> <ncores>
### example: ./3.run_prsmix.sh CAD for_CAD scripts pheno_files/covariate_basics_230912.txt pheno_files/CAD_pheno.tsv has_CAD True 48



## Step 4: Calculate individual's PRSmix scores based on generated weights

### inputs: 
* <trait_name> : trait name
* <trait_dir> : location of directory created in step 0, should be named for_<trait_name>
* <script_dir> : location of directory containing these scripts

### runline: ./4.cal_individual_prsmixes.sh <trait_name> <trait_dir> <script_dir> 
### example: ./4.cal_individual_prsmixes.sh CAD for_CAD scripts



