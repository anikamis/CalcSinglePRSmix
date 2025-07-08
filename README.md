# Run PRSmix for single trait
#### Given a list of PGS IDs from PGS Catalog, assuming GRCh38

### Requirements:
* Python3 (with Pandas, NumPy)
* R (with PRSmix installed, see https://github.com/buutrg/PRSmix for installation details)
* GNU parallel binary downloaded (https://www.gnu.org/software/parallel/)
* PLINK2 binary downloaded (https://www.cog-genomics.org/plink/2.0/)
* Per-chromosome hg38-build genotype files downloaded in PLINK2 .bed/.bim/.fam format

#### After cloning this repository, you might have to run the following (in terminal) to make the scripts executable:
```
# navigate to subdirectory containing all the scripts
cd CalcSinglePrsmix/scripts

# make each bash script executable
for f in *.sh ; do chmod u+x $f ; done
cd ..
```
#### I would also recommend running each of these steps in a `tmux` session and setting the timeout limit to 8 hours. If you want to save the output of each command to read through in case of failure, you can add a ` > out` to the end of each runline command to store the output of the command in a text file named `out`.


## Step 0: Directory setup

### inputs: 
* <trait_name> : trait name
* <score_list_file> : file containing list of PGS ids
### runline: ./scripts/0.directory_setup.sh <trait_name> <score_list_file>
### example: ./scripts/0.directory_setup.sh CAD CAD.score_list.txt



## Step 1: Download PGS ids, format, and harmonize to reference

### inputs: 
* <trait_name> : trait name
* <trait_dir> : location of directory created in step 0, should be named for_<trait_name>
* <script_dir> : location of directory containing these scripts
* <ref_file> : location of file with three columns for every SNP in genotype data: ID, ALT, and REF
  * see PRSmix github for more instructions
  * example head of valid ref file:
    >   ID      ALT     REF<br>
    >   chr1:10001:T:A  A       T<br>
    >   chr1:10001:T:C  C       T<br>
    >   chr1:10108:C:CAA        CAA     C<br>
* <tool_dir> : location of directory containg tools, i.e. GNU parallel binary
  
### runline: ./scripts/1.download_format_harmonize.sh <trait_name> <trait_dir> <script_dir> <ref_file> <tool_dir>
### example: ./scripts/1.download_format_harmonize.sh CAD for_CAD scripts ../aou_acaf/acaf_threshold.ALL_CHRS.snpinfo ../tools



## Step 2: Run PLINK2 scoring and sum all per-chromosome scores together

### inputs: 
* <trait_name> : trait name
* <trait_dir> : location of directory created in step 0, should be named for_<trait_name>
* <script_dir> : location of directory containing these scripts
* <plink_file_prefix> : prefix of all plink bed files
* <num_at_a_time> : how many chromosomes to run at a single time (choose based on environment specs)
* <num_threads> : how many threads to use to run a single score (PLINK2 parameter, choose based on environment specs)
* <mem_per_score> : how much memory (in MB) to use to run a single score (PLINK2 parameter, choose based on environment specs)
* <tool_dir> : location of directory containg tools, i.e. GNU parallel binary

### runline: ./scripts/2.run_plink_scoring.sh <trait_name> <trait_dir> <script_dir> <plink_file_prefix> <num_at_a_time> <num_threads> <mem_per_score> <tool_dir>
### example: ./scripts/2.run_plink_scoring.sh CAD for_CAD scripts ../aou_acaf/acaf_threshold.chr 3 8 30000 ../tools

#### NOTES:
* re <num_threads>: to see how many threads you have available, run `lscpu` in the terminal. the `Thread(s) per core)` * `Core(s) per socket` * `Socket(s)` is the number of threads you have available. If running in *All of Us*, this should be the same value as the number of CPUs you requested for your environment; you can increase this value by increasing the number of CPUs in your environment.
  * **make sure your chosen <num_at_a_time> * your chosen <num_threads> is LESS than the number of available threads.** I would recommend leaving at least one thread unused.
    
* re <mem_per_score>: to see how much memory (in MB) is available, run `free -m` in the terminal. you should consider the value under `free` to be the amount you have to use. If running in *All of Us*, this should be a bit less than the amount of RAM you requested for your environment (after converting from GB to MB); you can increase this value by increasing the amount of RAM in your environment.
  * **make sure your chosen <num_at_a_time> * your chosen <mem_per_score> is LESS than the amount of `free` memory available.** I would recommend leaving at least 1024 MB (or 1 GB) free.



## Step 3: Run PRSmix

### inputs: 
* <trait_name> : trait name
* <trait_dir> : location of directory created in step 0, should be named for_<trait_name>
* <script_dir> : location of directory containing these scripts
* <covariate_file> : location of covariate file containing person_id, age, sex, PC1:10
* <pheno_file> : location of phenotype file containing IID, phenotype
* <pheno_name> : name of column in pheno_file containing phenotype
* <isbinary\> : TRUE if trait is binary else FALSE
* <ncores\> : number of cores to run PRSmix (PRSmix parameter, refer to github for details)

### runline: ./scripts/3.run_prsmix.sh <trait_name> <trait_dir> <script_dir> <covariate_file> <pheno_file> <pheno_name> <isbinary\> <ncores\>
### example: ./scripts/3.run_prsmix.sh CAD for_CAD scripts ../pheno_files/covariate_basics_230912.txt ../pheno_files/CAD_pheno.tsv has_CAD True 12

#### NOTES:
* re <ncores>: to see how many cores you have available, run `lscpu` in the terminal. the `Core(s) per socket` * `Socket(s)` is the number of cores you have available. If running in *All of Us*, you can increase this value by increasing the number of CPUs in your environment.
  * **make sure your chosen <ncores> value is LESS than your amount of available cores.**
    

## Step 4: Calculate individual's PRSmix scores based on generated weights

### inputs: 
* <trait_name> : trait name
* <trait_dir> : location of directory created in step 0, should be named for_<trait_name>
* <script_dir> : location of directory containing these scripts

### runline: ./scripts/4.calc_individual_prsmixes.sh <trait_name> <trait_dir> <script_dir> 
### example: ./scripts/4.calc_individual_prsmixes.sh CAD for_CAD scripts



