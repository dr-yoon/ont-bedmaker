# ont-bedmaker — Test

## Test Input
**File:** `actionable_PGx_genes.txt (44 genes)`  
**Genome:** `hg38`
**Add "chr" prefix:** `Yes`  
**Output:** `actionable_PGx_targets_hg38.bed`  

---

## Test Usage

```bash
./ont-bedmaker.sh \
  -g Homo_sapiens.GRCh38.115.gtf.gz \
  -t actionable_PGx_genes.txt \
  -o actionable_PGx_targets_hg38.bed \
  -b 100000 \
  --genome hg38 \
  --add-chr \
  --stats-out actionable_PGx_stats.txt
