#!/bin/bash

# =========================================
# Kunitz Domain Detection - Full Pipeline
# Author: Azam Bakhshandeh
# Description: End-to-end script to build HMM model,
# generate datasets, run hmmsearch, and evaluate performance
# =========================================

set -e

echo "> Cleaning up previous outputs (if any)..."
rm -f *.hmm *.blast *.id *.fasta *.out *.class *.txt ending.txt to_remove.ids all_kunitz.id

echo "> Step 1: Convert aligned MSA file to clean FASTA"
awk '{if (substr($1,1,1)==">") {print "\n"toupper($1)} else {printf "%s",toupper($1)}}' pdb_kunitz_nr.ali | sed 's/PDB://' | tail -n +2 > pdb_kunitz_nr_clean.fasta

echo "> Step 2: Build the HMM model"
hmmbuild pdb_kunitz_nr_clean.hmm pdb_kunitz_nr_clean.fasta

echo "> Step 3: Create BLAST database"
makeblastdb -in all_kunitz.fasta -input_type fasta -dbtype prot -out all_kunitz.fasta

echo "> Step 4: Run BLAST"
blastp -query pdb_kunitz_nr.fasta -db all_kunitz.fasta -out pdb_kunitz_nr_23.blast -outfmt 7

echo "> Step 5: Extract high-identity sequences"
grep -v "^#" pdb_kunitz_nr_23.blast | awk '{if ($3>=95 && $4>=50) print $2}' | sort -u | cut -d "|" -f 2 > to_remove.ids
grep ">" all_kunitz.fasta | cut -d "|" -f 2 > all_kunitz.id

echo "> Step 6: Create positive test sets"
comm -23 <(sort all_kunitz.id) <(sort to_remove.ids) > ok_kunitz.ids
sort -r ok_kunitz.ids > random_ok_kunitz.id
head -n 184 random_ok_kunitz.id > pos_1.id
tail -n 184 random_ok_kunitz.id > pos_2.id
python3 get_seq.py pos_1.id uniprot_sprot.fasta > pos_1.fasta
python3 get_seq.py pos_2.id uniprot_sprot.fasta > pos_2.fasta

echo "> Step 7: Create negative test sets"
grep ">" uniprot_sprot.fasta | cut -d "|" -f 2 > sp.id
comm -23 <(sort sp.id) <(sort all_kunitz.id) > sp_negs.ids
sort -r sp_negs.ids > random_sp_negs.id
head -n 286286 random_sp_negs.id > neg_1.id
tail -n 286286 random_sp_negs.id > neg_2.id
python3 get_seq.py neg_1.id uniprot_sprot.fasta > neg_1.fasta
python3 get_seq.py neg_2.id uniprot_sprot.fasta > neg_2.fasta

echo "> Step 8: Run HMM search"
hmmsearch -Z 1000 --max --tblout pos_1.out pdb_kunitz_nr_clean.hmm pos_1.fasta
hmmsearch -Z 1000 --max --tblout pos_2.out pdb_kunitz_nr_clean.hmm pos_2.fasta
hmmsearch -Z 1000 --max --tblout neg_1.out pdb_kunitz_nr_clean.hmm neg_1.fasta
hmmsearch -Z 1000 --max --tblout neg_2.out pdb_kunitz_nr_clean.hmm neg_2.fasta

echo "> Step 9: Create class files with e-values"
grep -v "^#" pos_1.out | awk '{split($1,a,"|"); print a[2]"\t1\t"$5"\t"$8}' > pos_1.class
grep -v "^#" pos_2.out | awk '{split($1,a,"|"); print a[2]"\t1\t"$5"\t"$8}' > pos_2.class
grep -v "^#" neg_1.out | awk '{split($1,a,"|"); print a[2]"\t0\t"$5"\t"$8}' > neg_1.class
grep -v "^#" neg_2.out | awk '{split($1,a,"|"); print a[2]"\t0\t"$5"\t"$8}' > neg_2.class

echo "> Handling unmatched sequences (potential false negatives)"
comm -23 <(sort neg_1.id) <(cut -f 1 neg_1.class | sort) | awk '{print $1"\t0\t10.0\t10.0"}' >> neg_1.class
comm -23 <(sort neg_2.id) <(cut -f 1 neg_2.class | sort) | awk '{print $1"\t0\t10.0\t10.0"}' >> neg_2.class

echo "> Step 10: Merge sets"
cat pos_1.class neg_1.class > set_1.class
cat pos_2.class neg_2.class > set_2.class
cat set_1.class set_2.class > temp_overall.class

echo "> Step 11: Evaluate performance using threshold 1e-5"
rm -f ending.txt
python3 performance.py set_1.class 1e-5 1 >> ending.txt
python3 performance.py set_2.class 1e-5 1 >> ending.txt
python3 performance.py temp_overall.class 1e-5 1 >> ending.txt

echo "> Final Results:"
cat ending.txt
