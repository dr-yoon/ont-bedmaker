# ont-bedmaker

**Target region BED generator for Oxford Nanopore adaptive sampling**

---

## Overview

**ont-bedmaker** is a Bash tool that automatically generates a **BED** file for **Oxford Nanopore adaptive sampling** workflows.

It reads **Ensembl GTF annotations**, extracts **target gene loci**, applies **user-defined flanking buffers**, and **merges overlapping regions** (joining gene names).  
The result is a clean, non-overlapping **BED file** that can be directly used for adaptive sampling experiments or other targeted long-read applications.
The tool also outputs key statistics — total target region size, genome coverage, and gene count — in a formatted report.



## Key Features

- Pre-download required: **Ensembl** GTFs:
  [[hg38 (GRCh38 release-115)](https://ftp.ensembl.org/pub/release-115/gtf/homo_sapiens/Homo_sapiens.GRCh38.115.gtf.gz)] or 
  [[hg19 (GRCh37 release-87)](https://ftp.ensembl.org/pub/grch37/release-115/gtf/homo_sapiens/Homo_sapiens.GRCh37.87.gtf.gz)]
- Generates **non-overlapping merged BED** regions suitable for ONT adaptive sampling
- Reports **target size**, **coverage**, and **unique gene count**
- Optionally includes the **mitochondrial genome**
- Produces a readable **summary file with all parameters and statistics**
- Simple, dependency-light (Bash + awk + gzip)



## Requirements

- Linux or macOS
- Bash v4 or higher  
- `awk`  
- `gzip`



## Usage

```bash
./ont-bedmaker.sh \
  -g Homo_sapiens.GRCh38.115.gtf.gz \
  -t target_gene_list.txt \
  -o target_regions_merged.bed \
  -b 100000 \
  --genome hg38 \
  --include-mt \
  --mt-name MT \
  --add-chr \
  --stats-out target_bed_stats.txt
```

## Command options
| Option         | Description                                         |
| -------------- | --------------------------------------------------- |
| `-g`           | Path to gzipped Ensembl/Gencode GTF file            |
| `-t`           | Text file with one gene symbol per line             |
| `-o`           | Output BED file (merged, non-overlapping)           |
| `-b`           | Buffer size (bp) around genes *(default: 100000)*   |
| `--genome`     | Genome build: `hg38` *(default)* or `hg19`          |
| `--include-mt` | Add full mitochondrial genome (0–16569 bp)          |
| `--mt-name`    | Name of mtDNA chromosome *(default: MT)*            |
| `--add-chr`    | Add `chr` prefix to chromosomes (e.g. `1 → chr1`)   |
| `--stats-out`  | Output stats file *(default: target_bed_stats.txt)* |
| `--version`    | Print version and exit                              |
| `-h, --help`   | Show usage and exit                                 |



## Output files
| File                        | Description                                                  |
| --------------------------- | ------------------------------------------------------------ |
| `target_regions_merged.bed` | Final merged BED regions for ONT adaptive sampling           |
| `target_bed_stats.txt`      | Text summary with counts, total bp, coverage, and parameters |

