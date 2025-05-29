# Kunitz HMM Project – Full Workflow

This document explains all steps taken during the Kunitz domain detection project, from data collection to model evaluation.

---

## Step 1: Data Collection

### Step 1.1 – Retrieve Kunitz Domain Structures from PDB

To build a Hidden Markov Model (HMM) specific to the Kunitz domain, we first retrieved relevant protein structures from the Protein Data Bank (PDB).  
**Search method:** Manual advanced search on https://www.rcsb.org  
**Filters used:**
- Pfam Domain: PF00014 (Kunitz domain)
- Structure resolution ≤ 3.5 Å
- Sequence length: 40–80 amino acids

**Number of entries retrieved:** 159

✅ Files downloaded as `.pdb` and one `.csv` metadata file (PDB ID + chain).  
These were used for structural alignment in later steps.

---

### Step 1.2 – Retrieve Kunitz Sequences from Pfam

To obtain representative sequences of the Kunitz domain, Pfam was queried for the domain **PF00014**.

We downloaded the following FASTA files:

- `human-kunitz.fasta` – Kunitz-containing human proteins  
- `nonhuman-kunitz.fasta` – Kunitz-containing non-human proteins  
- `human-notkunitz.fasta` – Human proteins that do **not** contain the Kunitz domain (used later for the negative dataset)

The first two files were merged to generate a combined dataset of **397 sequences** containing the domain.

✅ **Merged file:** `all_kunitz.fasta`  
This merged file was later used to prepare the **positive test set**, after removing overlaps with model training sequences using BLAST.

---

### Step 1.3 – Remove Redundancy from PDB Sequences with CD-HIT

To remove redundancy from the 161 PDB-derived sequences, we used **CD-HIT**.

📌 **Command used:**
```bash
cd-hit -i pdb_kunitz.fasta -o pdb_kunitz.clst

✅This step reduced the 161 PDB-derived sequences to 25 non-redundant representatives, which were later used for structural alignment.

---

### Step 1.4 – Multiple Structural Alignment with MUSCLE

To align the non-redundant Kunitz domain structures, we used the [MUSCLE](https://www.ebi.ac.uk/Tools/msa/muscle/) server.

📌 Input: 25 non-redundant sequences (from Step 1.3), uploaded in FASTA format  
📎 Output file: `muscle-I20250515-xxxx.aln-fasta`

The aligned sequences were then formatted for HMM model building using the following command:

📌 **Command used:**
```bash
awk '{if (substr($1,1,1)==">") {print "\n"toupper($1)} else {printf "%s",toupper($1)}}' muscle-....fasta | sed s/PDB:// | tail -n +2 > pdb_kunitz_nr_clean.fasta

✅ Resulting file: pdb_kunitz_nr_clean.fasta
This was later converted to .ali format and used as input for hmmbuild.

---


## Step 2 – Build HMM Model

To construct the Hidden Markov Model (HMM) for the Kunitz domain, we first prepared a structural multiple sequence alignment of 25 non-redundant Kunitz domain sequences.

📎 The sequences were aligned using the MUSCLE web server in multiple structure alignment mode.
(https://www.ebi.ac.uk/Tools/msa/muscle/) web server (multiple structure mode).  

📎 The resulting .fasta file was cleaned using awk and sed to remove unnecessary formatting, convert headers to uppercase, and delete the PDB: prefix. The cleaned file was then converted to Stockholm format using esl-reformat:

📌 **Command used:**
```bash
awk '{if (substr($1,1,1)==">") {print "\n"toupper($1)} else {printf "%s",toupper($1)}}' input.aln-fasta | sed 's/PDB://' | tail -n +2 > pdb_kunitz_nr_clean.fasta

esl-reformat a2m pdb_kunitz_nr_clean.fasta > pdb_kunitz_nr_clean.ali

📎 Finally, the profile HMM was built using the hmmbuild tool from the HMMER suite:

📌 **Command used:**
```bash
hmmbuild pdb_kunitz_nr_clean.hmm pdb_kunitz_nr_clean.ali


✅ This model captures the conserved sequence and structural characteristics of the Kunitz domain and serves as the basis for downstream sequence classification and domain detection.





