# 🧬 ont-bedmaker

**Target region BED generator for Oxford Nanopore adaptive sampling**

---

## Overview

**ont-bedmaker** is a Bash tool that automatically generates a **BED** file for **Oxford Nanopore adaptive sampling** workflows.

It reads **Ensembl GTF annotations**, extracts **target gene loci**, applies **user-defined flanking buffers**, and **merges overlapping regions** (joining gene names).  
The result is a clean, non-overlapping **BED file** that can be directly used for adaptive sampling experiments or other targeted long-read applications.
The tool also outputs key statistics — total target region size, genome coverage, and gene count — in a formatted report.

---

## Key Features

- Pre-download required: **Ensembl** GTFs
  *(e.g. `Homo_sapiens.GRCh38.gtf.gz`, `Homo_sapiens.GRCh37.gtf.gz`)*
- Generates **non-overlapping merged BED** regions suitable for ONT adaptive sampling
- Reports **target size**, **coverage**, and **unique gene count**
- Optionally includes the **mitochondrial genome**
- Produces a readable **summary file with all parameters and statistics**
- Simple, dependency-light (Bash + awk + gzip)

---

## Requirements

- Linux or macOS
- Bash v4 or higher  
- `awk`  
- `gzip`

---

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
