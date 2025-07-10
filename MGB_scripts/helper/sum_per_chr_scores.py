import sys
import glob
import pandas as pd

trait = sys.argv[1]

glob_path = f"scores/raw_scores/*.sscore"
raw_scores = glob.glob(glob_path)

out_fn = f"scores/summed_scores/{trait}.ACAF.ALL.sscore"

sums = pd.DataFrame()
prev_len = 0

for score in raw_scores:
    print(f"starting reading {score}!")
    
    temp = pd.read_csv(score, sep='\t')

    cols_to_keep = [x for x in list(temp.columns) if (x != "NAMED_ALLELE_DOSAGE_SUM" and x[-4:] == "_SUM")]
    new_colnames = [f"{x.split('.chr')[0]}_SUM" for x in cols_to_keep]

    temp = temp[["IID"] + cols_to_keep]
    temp.columns = ["IID"] + new_colnames

    if sums.empty:
        sums = temp
        prev_len = len(sums)

    else:
        temp = sums[["IID"]].merge(temp, how="inner")  

        sums = sums.merge(temp, on=["IID"], how='left', suffixes=["", "_temp"])

        if prev_len != len(sums):
            print(f"Error: mismatched n individuals between chromosomes for {score}!\n")
            break

        for c in sums.columns:
            if f"{c}_temp" not in sums:
                continue

            sums[c] = sums[c] + sums[c + "_temp"]

        sums = sums.loc[:,~sums.columns.str.endswith("_temp")]
        prev_len = len(sums)

    print(f"finished reading {score}!")

sums.to_csv(out_fn, sep='\t', index=False)