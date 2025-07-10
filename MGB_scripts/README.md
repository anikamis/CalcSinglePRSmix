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
* <score_list_file> : file containing list of all PGS inputs
* <prsmix_weight_list> : output weight file from PRSmix
* <which\> : "all" if you want to run all input scores, or "prsmix" if you only want to run scores needed to calculate prsmix
### runline: qsub scripts/step0.directory_setup.sh <trait_name> <score_list_file>  <prsmix_weight_list> <which\>
### example: qsub ../scripts/step0.directory_setup.sh CAD CAD.score_list.txt CAD_power.0.95_pthres.0.05_weight_PRSmix.txt all



## Step 1.0: Download PGS ids and format

### inputs: 
* **QSUB input**: <number_of_scores> : number of scores being run
* <trait_name> : trait name
* <trait_dir> : location of directory created in step 0, should be named for_<trait_name>
* <script_dir> : location of directory containing these scripts
  
### runline: qsub -t 1-<number_of_scores> scripts/step1.0.download_format.sh <trait_name> <trait_dir> <script_dir>
### example: qsub -t 1-$( wc -l < for_CAD/weights/CAD.score_list.txt ) ../scripts/step1.0.download_format.sh CAD for_CAD ../scripts


## Step 1.1: Harmonize all scores to reference

### inputs: 
* <trait_name> : trait name
* <trait_dir> : location of directory created in step 0, should be named for_<trait_name>
* <script_dir> : location of directory containing these scripts
* <ref_file> : prefix to location of .snpinfo file with three columns for every SNP in genotype data: ID, ALT, and REF
  * see PRSmix github for more instructions
  * example head of valid ref file:
    >   ID      ALT     REF<br>
    >   chr1:10001:T:A  A       T<br>
    >   chr1:10001:T:C  C       T<br>
    >   chr1:10108:C:CAA        CAA     C<br>
  
### runline: qsub scripts/step1.1.harmonize.sh <trait_name> <trait_dir> <script_dir> <ref_file>
### example: qsub ../scripts/step1.1.harmonize.sh CAD for_CAD ../scripts ../mgbb/mgbb.53k_gsa.chr


## Step 2.0: Run PLINK2 scoring

### inputs: 
* <trait_name> : trait name
* <trait_dir> : location of directory created in step 0, should be named for_<trait_name>
* <script_dir> : location of directory containing these scripts
* <plink_file_prefix> : prefix of all plink .bed (if aou) or .pgen (if mgbb) files
* <tool_dir> : location of directory containg tools, i.e. GNU parallel binary

### runline: qsub scripts/step2.0.run_scoring.sh <trait_name> <trait_dir> <script_dir> <plink_file_prefix> <tool_dir>
### example: qsub ../scripts/step2.0.run_scoring.sh CAD for_CAD ../scripts ../mgbb/mgbb.53k_gsa.chr ../../tools


## Step 2.1: Sum all per-chromosome scores together

### inputs: 
* <trait_name> : trait name
* <trait_dir> : location of directory created in step 0, should be named for_<trait_name>
* <script_dir> : location of directory containing these scripts

### runline: qsub scripts/step2.1.sum.sh <trait_name> <trait_dir> <script_dir>
### example: qsub ../scripts/step2.1.sum.sh CAD for_CAD ../scripts 


## Step 3: Calculate individual's PRSmix scores based on generated weights

### inputs: 
* <trait_name> : trait name
* <trait_dir> : location of directory created in step 0, should be named for_<trait_name>
* <script_dir> : location of directory containing these scripts

### runline: qsub step3.calc_individual_prsmixes.sh <trait_name> <trait_dir> <script_dir> 
### example: qsub ../scripts/step3.calc_individual_prsmixes.sh CAD for_CAD ../scripts



