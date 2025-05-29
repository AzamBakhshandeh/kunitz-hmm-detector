# Kunitz HMM Project – Full Workflow

This document explains all steps taken during the Kunitz domain detection project, from data collection to model evaluation.

---

## 🧠 Step 1: Data Collection

### 🔹 Step 1.1 – Retrieve Kunitz Domain Structures from PDB

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

### 🔹 Step 1.2 – Retrieve Kunitz Sequences from Pfam

To obtain representative sequences of the Kunitz domain, Pfam was queried for the domain **PF00014**.

We downloaded the following FASTA files:

- `human-kunitz.fasta` – Kunitz-containing human proteins  
- `nonhuman-kunitz.fasta` – Kunitz-containing non-human proteins  
- `human-notkunitz.fasta` – Human proteins that do **not** contain the Kunitz domain (used later for the negative dataset)

The first two files were merged to generate a combined dataset of **397 sequences** containing the domain.

✅ **Merged file:** `all_kunitz.fasta`  
This merged file was later used to prepare the **positive test set**, after removing overlaps with model training sequences using BLAST.

---

### 🔹 Step 1.3 – Remove Redundancy from PDB Sequences with CD-HIT

To remove redundancy from the 161 PDB-derived sequences, we used **CD-HIT**.

📌 **Command used:**
```bash
cd-hit -i pdb_kunitz.fasta -o pdb_kunitz.clst
```

✅This step reduced the 161 PDB-derived sequences to 25 non-redundant representatives, which were later used for structural alignment.

---

### 🔹 Step 1.4 – Multiple Structural Alignment with MUSCLE

To align the non-redundant Kunitz domain structures, we used the [MUSCLE](https://www.ebi.ac.uk/Tools/msa/muscle/) server.

📌 **Input:** 25 non-redundant sequences (from Step 1.3), uploaded in FASTA format  
📎 **Output file:** `muscle-I20250515-xxxx.aln-fasta`

The aligned sequences were then formatted for HMM model building using the following command:

📌 **Command used:**
```bash
awk '{if (substr($1,1,1)==">") {print "\n"toupper($1)} else {printf "%s",toupper($1)}}' muscle-....fasta | sed s/PDB:// | tail -n +2 > pdb_kunitz_nr_clean.fasta
```
---

## 🧠 Step 2 – Build HMM Model

To construct the Hidden Markov Model (HMM) for the Kunitz domain, we first prepared a structural multiple sequence alignment of 25 non-redundant Kunitz domain sequences.

📎 The sequences were aligned using the MUSCLE web server in multiple structure alignment mode.
(https://www.ebi.ac.uk/Tools/msa/muscle/) web server (multiple structure mode).  

📎 The resulting .fasta file was cleaned using awk and sed to remove unnecessary formatting, convert headers to uppercase, and delete the PDB: prefix. The cleaned file was then converted to Stockholm format using esl-reformat:

📌 **Command used:**
```bash
awk '{if (substr($1,1,1)==">") {print "\n"toupper($1)} else {printf "%s",toupper($1)}}' input.aln-fasta | sed 's/PDB://' | tail -n +2 > pdb_kunitz_nr_clean.fasta

esl-reformat a2m pdb_kunitz_nr_clean.fasta > pdb_kunitz_nr_clean.ali
```

📎 Finally, the profile HMM was built using the hmmbuild tool from the HMMER suite:

📌 **Command used:**
```bash
hmmbuild pdb_kunitz_nr_clean.hmm pdb_kunitz_nr_clean.ali
```

✅ This model captures the conserved sequence and structural characteristics of the Kunitz domain and serves as the basis for downstream sequence classification and domain detection.

---

## 🧠 Step 3 – Dataset Preparation

To evaluate the HMM model, we prepared both positive and negative datasets:

### 🔹 Step 3.1 – Build BLAST Database

The all_kunitz.fasta file (containing 397 Kunitz-related sequences) was used to create a local BLAST database:

📌 **Command used:**
```bash
makeblastdb -in all_kunitz.fasta -input_type fasta -dbtype prot -out all_kunitz.fasta
```
---

### 🔹 Step 3.2 – Identify Redundant Sequences

The aligned PDB sequences were searched against the BLAST database to identify redundant sequences (those already used in the model training):

📌 **Command used:**
```bash
blastp -query pdb_kunitz_nr.fasta -db all_kunitz.fasta -out pdb_kunitz_nr_23.blast -outfmt 7
```

From the output, highly similar sequences (≥95% identity, alignment ≥50 residues) were extracted and removed:

📌 **Command used:**
```bash
grep -v "^#" pdb_kunitz_nr_23.blast | awk '{if ($3>=95 && $4>=50) print $2}' | sort -u | cut -d "|" -f 2 > to_remove.ids
grep ">" all_kunitz.fasta | cut -d "|" -f 2 > all_kunitz.id
comm -23 <(sort all_kunitz.id) <(sort to_remove.ids) > ok_kunitz.ids
```

✅ The resulting ok_kunitz.ids contained 366 non-redundant Kunitz sequences used as the positive dataset.

---

### 🔹 Step 3.3 – Prepare Negative Dataset

To construct the negative set, we used the uniprot_sprot.fasta file (UniProtKB/Swiss-Prot full database). All entries that did not appear in all_kunitz.fasta were extracted using the following commands:

📌 **Command used:**
```bash
grep ">" uniprot_sprot.fasta | cut -d "|" -f 2 > sp.id
comm -23 <(sort sp.id) <(sort all_kunitz.id) > sp_negs.ids
```

✅ The sp_negs.ids file contains ~572,833 UniProt sequences without the Kunitz domain.

To ensure balanced evaluation, we randomly shuffled and split the files:

📌 **Command used:**
```bash
sort -R sp_negs.ids > random_sp_negs.id
head -n 286286 random_sp_negs.id > neg_1.id
tail -n +286287 random_sp_negs.id > neg_2.id
```

Finally, FASTA sequences were retrieved for each group:

📌 **Command used:**
```bash
python3 get_seq.py neg_1.id uniprot_sprot.fasta > neg_1.fasta
python3 get_seq.py neg_2.id uniprot_sprot.fasta > neg_2.fasta
```

---

## 🧠 Step 4 – Run HMM Search on Datasets

To evaluate the performance of the constructed HMM, we used hmmsearch from the HMMER suite. Each dataset (positive and negative) was scanned against the HMM profile (pdb_kunitz_nr_clean.hmm) using the --tblout option to capture tabular output and --max for more sensitive local alignments.

📌 **Command used:**
```bash
hmmsearch --max -Z 1000 --tblout pos_1.out pdb_kunitz_nr_clean.hmm pos_1.fasta
hmmsearch --max -Z 1000 --tblout pos_2.out pdb_kunitz_nr_clean.hmm pos_2.fasta
hmmsearch --max -Z 1000 --tblout neg_1.out pdb_kunitz_nr_clean.hmm neg_1.fasta
hmmsearch --max -Z 1000 --tblout neg_2.out pdb_kunitz_nr_clean.hmm neg_2.fasta
```

✅ This step generates alignment scores and e-values, which are later used to evaluate sensitivity, specificity, and overall performance.

---

## 🧠 Step 5 – Generate Classification Files for Evaluation

After running hmmsearch, we extracted results into .class files to be used for performance evaluation. Each line contains:

📌 **Command used:**
```bash
<sequence_id> <label> <full_seq_evalue> <domain_evalue>
```
▶Label: 1 for positive set, 0 for negative set

▶E-values: used to test different threshold cutoffs later

Extract .class files from hmmsearch output:

📌 **Command used:**
```bash
grep -v "^#" pos_1.out | awk '{split($1,a,"|"); print a[2]"\t1\t"$5"\t"$8}' > pos_1.class
grep -v "^#" pos_2.out | awk '{split($1,a,"|"); print a[2]"\t1\t"$5"\t"$8}' > pos_2.class
grep -v "^#" neg_1.out | awk '{split($1,a,"|"); print a[2]"\t0\t"$5"\t"$8}' > neg_1.class
grep -v "^#" neg_2.out | awk '{split($1,a,"|"); print a[2]"\t0\t"$5"\t"$8}' > neg_2.class
```

Handle unmatched sequences (not returned by hmmsearch):

📌 **Command used:**
```bash
comm -23 <(sort neg_1.id) <(cut -f 1 neg_1.class | sort) | awk '{print $1"\t0\t10.0\t10.0}' >> neg_1.class
comm -23 <(sort neg_2.id) <(cut -f 1 neg_2.class | sort) | awk '{print $1"\t0\t10.0\t10.0}' >> neg_2.class
```

✅ These files allow downstream statistical analysis of the model’s performance using different E-value thresholds.

---

## 🧠 Step 6 – Model Performance Evaluation and Threshold Selection

To evaluate the discriminative power of our HMM, we used the .class files generated from positive and negative sets.

### 🔹 Step 6.1 – Merge Sets

📌 **Command used:**
```bash
cat pos_1.class neg_1.class > set_1.class
cat pos_2.class neg_2.class > set_2.class
cat set_1.class set_2.class > temp_overall.class
```

---

### 🔹 Step 6.2 – Evaluate with fixed threshold

We evaluated model performance at a fixed E-value threshold (1e-5) using the provided Python script performance.py:

📌 **Command used:**
```bash
python3 performance.py set_1.class 1e-5
python3 performance.py set_2.class 1e-5
python3 performance.py temp_overall.class 1e-5
```
🛠Each run returns:

▶Q2 (Accuracy)

▶MCC (Matthews Correlation Coefficient)

▶TPR (Sensitivity / Recall)

▶PPV (Precision)

▶Confusion Matrix

---

### 🔹 Step 6.3 – Optimal Threshold Search (Optional but Recommended)

To identify the best threshold:

📌 **Command used:**
```bash
for i in `seq 1 9`; do python3 performance.py set_1.class 1e-"$i"; done | grep 'threshold' | grep 'True' | sort -nrk 6 | head -n 1
for i in `seq 1 9`; do python3 performance.py set_2.class 1e-"$i"; done | grep 'threshold' | grep 'True' | sort -nrk 6 | head -n 1
```

✅ The best threshold from each set can be averaged for final application.

---

## 🧠 Step 7 – Result Reporting and Visualization

### 🔹 Step 7.1 – Final Performance Summary

The evaluation at threshold 1e-5 yielded the following results:

| Set      | Accuracy (Q2) | MCC   | TPR   | PPV   | FP | FN |
| -------- | ------------- | ----- | ----- | ----- | -- | -- |
| Set 1    | 0.99998       | 0.989 | 0.994 | 0.983 | 1  | 3  |
| Set 2    | 0.99999       | 0.994 | 0.994 | 0.994 | 1  | 1  |
| Combined | 0.99998       | 0.991 | 0.994 | 0.988 | 2  | 4  |

✅ These values indicate excellent sensitivity and precision, confirming the model’s ability to correctly classify Kunitz and non-Kunitz proteins.

---

### 🔹 Step 7.2 – Visualizing Domain Conservation

To visualize conservation across the aligned sequences, we used the Skylign server.

▶Input: pdb_kunitz_nr_clean.hmm

▶Output: Sequence logo plot showing highly conserved residues, especially cysteines forming disulfide bridges.

📎 ![Kunitz Sequence Logo](figures/kunitz_logo_skylign.png)


ر`````````
