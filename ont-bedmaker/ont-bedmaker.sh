#!/usr/bin/env bash
# ont-bedmaker: Target region BED generator for Oxford Nanopore adaptive sampling
# Copyright (c) 2025 Jihoon G. Yoon
# MIT License
#
#┌────────────────────────────────────────────────────────────┐
#│                    ont-bedmaker v1.0.0                     │
#│     Target region BED generator for ONT adaptive sampling  │
#└────────────────────────────────────────────────────────────┘
# Description:
#   Reads a target gene list and an Ensembl GTF (gzipped), extracts gene loci,
#   applies a user-defined buffer, merges overlaps (concatenating gene names),
#   optionally appends the full mitochondrial chromosome, and writes:
#     - a merged BED (final targets, non-overlapping)
#   Also prints and saves run statistics.

set -euo pipefail
IFS=$'\n\t'

VERSION="1.0.0"

usage() {
  cat <<'EOF'
Usage:
  ./ont-bedmaker.sh \
    -g Homo_sapiens.GRCh38.gtf.gz \
    -t target_gene_list.txt \
    -o targets_buffered_merged.bed \
    [-b 100000] \
    [--genome {hg38|hg19}] \
    [--include-mt] \
    [--mt-name MT] \
    [--add-chr] \
    [--stats-out target_bed_stats.txt]

Options:
  -g                Path to gzipped Ensembl/Gencode GTF
  -t                Text file with one gene name per line (HGNC symbols)
  -o                Output BED (merged, non-overlapping)
  -b                Buffer size (bp) around genes [default: 100000]
  --genome          Genome build: hg38 (default) or hg19
  --include-mt      Append full mitochondrial chromosome
  --mt-name         mtDNA chromosome name [default: MT]
  --add-chr         Add "chr" prefix to all chromosome names (e.g. 1→chr1, MT→chrMT)
  --stats-out       Save summary stats here [default: target_bed_stats.txt]
  -h, --help        Show help and exit
  --version         Print version and exit
EOF
}

# defaults
BUFFER=100000
GENOME="hg38"
STATS_OUT="target_bed_stats.txt"
INCLUDE_MT=0
MT_NAME="MT"
ADD_CHR=0

# parse arguments
if [ "$#" -eq 0 ]; then usage; exit 2; fi
while (( "$#" )); do
  case "$1" in
    -g) GTF="$2"; shift 2 ;;
    -t) TARGET="$2"; shift 2 ;;
    -o) OUTBUF="$2"; shift 2 ;;
    -b) BUFFER="$2"; shift 2 ;;
    --genome) GENOME="$2"; shift 2 ;;
    --include-mt) INCLUDE_MT=1; shift 1 ;;
    --mt-name) MT_NAME="$2"; shift 2 ;;
    --add-chr) ADD_CHR=1; shift 1 ;;
    --stats-out) STATS_OUT="$2"; shift 2 ;;
    --version) echo "ont-bedmaker ${VERSION}"; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 2 ;;
  esac
done

: "${GTF:?Missing -g <Ensembl.gtf.gz>}"
: "${TARGET:?Missing -t <target_gene_list.txt>}"
: "${OUTBUF:?Missing -o <output.bed>}"

command -v awk >/dev/null || { echo "Error: awk not found"; exit 1; }

tmp_raw="$(mktemp)"
trap 'rm -f "$tmp_raw"' EXIT

# Header display
printf "\n┌────────────────────────────────────────────────────────────┐\n"
printf "│                    ont-bedmaker v%s                     │\n" "$VERSION"
printf "│     Target region BED generator for ONT adaptive sampling  │\n"
printf "└────────────────────────────────────────────────────────────┘\n"
printf "Date: %s\n\n" "$(date)"

GENE_COUNT=$(awk 'NF>0{g[$1]=1} END{print length(g)}' "$TARGET")

# --- extract gene intervals ---
awk -v OFS='\t' -v BUF="$BUFFER" -v addchr="$ADD_CHR" '
  FNR==NR {
    g=$1; sub(/\r$/,"",g); gsub(/^[ \t]+|[ \t]+$/, "", g)
    if (g!="") targets[g]=1
    next
  }
  $3=="gene" {
    if (match($0, /gene_name "([^"]+)"/, m)) name=m[1]
    else if (match($0, /gene_id "([^"]+)"/, m2)) name=m2[1]
    else next
    if (name in targets) {
      chrom=$1
      if (addchr && chrom !~ /^chr/) chrom="chr"chrom
      start=$4; end=$5
      bedstart=start-1
      bstart=bedstart-BUF; if (bstart<0) bstart=0
      bend=end+BUF
      print chrom,bstart,bend,name
    }
  }
' "$TARGET" <(gzip -dc "$GTF") > "$tmp_raw"

if [ ! -s "$tmp_raw" ]; then
  echo "Warning: No matching genes found. Check gene list and GTF naming."
fi

# --- merge overlapping intervals and combine names ---
awk -v OFS='\t' '
  function flush() {
    if (c=="") return
    joined=""; sep=""
    for (n in uniq) { joined=joined sep n; sep="; " }
    print c,s,e,joined
  }
  {
    ch=$1; st=$2+0; en=$3+0; nm=$4
    if (ch==c && st<=e) {
      if (en>e) e=en
      uniq[nm]=1
    } else {
      flush()
      c=ch; s=st; e=en; delete uniq; uniq[nm]=1
    }
  }
  END { flush() }
' <(sort -k1,1V -k2,2n -k3,3n "$tmp_raw") > "$OUTBUF"

# --- add MT if requested ---
if [ "$INCLUDE_MT" -eq 1 ]; then
  MTCHR="$MT_NAME"
  if [ "$ADD_CHR" -eq 1 ]; then
    [[ "$MTCHR" =~ ^chr ]] || MTCHR="chr${MTCHR}"
  fi
  echo -e "${MTCHR}\t0\t16569\tMT_full" >> "$OUTBUF"
fi

# --- genome size and stats ---
TOTAL_BP=$(awk '{s+=($3-$2)}END{print s+0}' "$OUTBUF")
if [ "$GENOME" = "hg19" ]; then
  GENOME_BP=3095677412
else
  GENOME_BP=3088269832
fi
PCT=$(awk -v t="$TOTAL_BP" -v g="$GENOME_BP" 'BEGIN{printf("%.4f",100*t/g)}')

printf "Gene list: %s (%d unique)\n" "$TARGET" "$GENE_COUNT"
printf "Output BED: %s\n" "$OUTBUF"
[ "$ADD_CHR" -eq 1 ] && echo "Chromosome prefix: chr"
[ "$INCLUDE_MT" -eq 1 ] && echo "Included full MT: $MTCHR"
printf "Total bp: %'d (%.3f Mb)\n" "$TOTAL_BP" "$(awk -v t="$TOTAL_BP" 'BEGIN{print t/1e6}')"
printf "Genome coverage: %s %%\n" "$PCT"

cat > "$STATS_OUT" <<EOF
┌────────────────────────────────────────────────────────────┐
│                    ont-bedmaker v${VERSION}                     │
│     Target region BED generator for ONT adaptive sampling  │
└────────────────────────────────────────────────────────────┘
Date: $(date)
----------------------------------
GTF: $GTF
Gene list: $TARGET
Unique genes: $GENE_COUNT
Buffer size: $BUFFER

Output BED: $OUTBUF
Total region size (bp): $TOTAL_BP
Genome coverage: $PCT %
----------------------------------
EOF
echo "Stats saved to: $STATS_OUT"
