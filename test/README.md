# ont-bedmaker — Test

## Test Usage

```bash
./ont-bedmaker.sh \
  -g Homo_sapiens.GRCh38.115.gtf.gz \
  -t actionable_PGx_genes.txt \
  -o actionable_PGx_targets_hg38.bed \
  -b 100000 \
  --genome hg38 \
  --add-chr \
  --stats-out actionable_PGx_stats_hg38.txt


# Output
┌────────────────────────────────────────────────────────────┐
│                    ont-bedmaker v1.0.0                     │
│     Target region BED generator for ONT adaptive sampling  │
└────────────────────────────────────────────────────────────┘
Date: 2025. 11. 11. (화) 15:36:15 KST

Gene list: actionable_PGx_genes.txt (39 unique)
Output BED: actionable_PGx_targets_hg38.bed
Chromosome prefix: chr
Total bp: 10,339,790 (10.340 Mb)
Genome coverage: 0.3348 %
Stats saved to: actionable_PGx_stats_hg38.txt

---

./ont-bedmaker.sh \
  -g Homo_sapiens.GRCh37.87.gtf.gz \
  -t actionable_PGx_genes.txt \
  -o actionable_PGx_targets_hg19.bed \
  -b 100000 \
  --genome hg19 \
  --add-chr \
  --stats-out actionable_PGx_stats_hg19.txt


# Output
┌────────────────────────────────────────────────────────────┐
│                    ont-bedmaker v1.0.0                     │
│     Target region BED generator for ONT adaptive sampling  │
└────────────────────────────────────────────────────────────┘
Date: 2025. 11. 11. (화) 15:36:28 KST

Gene list: actionable_PGx_genes.txt (39 unique)
Output BED: actionable_PGx_targets_hg19.bed
Chromosome prefix: chr
Total bp: 10,052,052 (10.052 Mb)
Genome coverage: 0.3247 %
Stats saved to: actionable_PGx_stats_hg19.txt
