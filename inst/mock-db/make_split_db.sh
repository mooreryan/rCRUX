#!/bin/bash
set -euo pipefail

# This script splits the mock database of sequences into three parts and creates
# BLAST databases for each part.
#
# Usage: ./make_split_db.sh <workdir>
#
# Arguments:
#
#   <workdir> - The working directory containing the mock database sequences and
#   taxid map files.
#
if [ "$#" -ne 1 ]; then
  printf "Usage: %s <workdir>\n" "$(basename "$0")" >&2
  exit 1
fi

workdir="$1"

split_dir="${workdir}/mock-db-sequences-split"
mock_db_seqs_fasta="${workdir}/mock-db-sequences.fasta"
mock_db_taxid_map="${workdir}/mock-db-sequences-taxid.map"

# Check if commands are installed and executable
if ! command -v seqkit &>/dev/null; then
  printf "seqkit is not installed or not in the PATH" >&2
  exit 1
fi
if ! command -v makeblastdb &>/dev/null; then
  printf "makeblastdb is not installed or not in the PATH" >&2
  exit 1
fi

# Remove the outdir if it already exists.
[[ -d "${split_dir}" ]] && rm -r "${split_dir}"

# Check for required files
[[ -f "${mock_db_seqs_fasta}" ]] || {
  printf "%s does not exist\n" "${mock_db_seqs_fasta}" >&2
  exit 1
}
[[ -f "${mock_db_taxid_map}" ]] || {
  printf "%s does not exist\n" "${mock_db_taxid_map}" >&2
  exit 1
}

# Split the original fasta in 3 parts.
seqkit split2 \
  --by-part 3 \
  --out-dir "${split_dir}" \
  "${mock_db_seqs_fasta}"

for split in {1,2,3}; do
  basename="${split_dir}/mock-db-sequences.part_00${split}"

  fasta="${basename}.fasta"
  tax_id_map_name="${basename}.taxid_map.txt"
  blast_db="${basename}"

  # Create the taxid map for each fasta split.
  join \
    --check-order \
    <(sort -k1,1 "${mock_db_taxid_map}") \
    <(grep '^>' "${fasta}" | sed 's/^>//' | cut -f1 -d' ' | sort) \
    >"${tax_id_map_name}"

  # Make the blast db.
  makeblastdb \
    -in "${fasta}" \
    -dbtype nucl \
    -parse_seqids \
    -title "Mock rCRUX source database ${split}" \
    -taxid_map "${tax_id_map_name}" \
    -out "${blast_db}"
done
