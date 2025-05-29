## Kunitz HMM Detector

This repository contains the final report, source code, datasets, and evaluation results of a bioinformatics project for detecting Kunitz protein domains using a profile Hidden Markov Model (HMM).

## Contents

- 📄 `kunitz-hmm-project-report.pdf` – Final project report
- 🧬 `scripts/create_hmm_build.sh` – Shell script for pipeline execution and used to build the HMM
- 📊 `results/final_HMM_table.xlsx` – Table showing model performance at different E-value thresholds
- 💻 `scripts/performance.py` – Script for evaluating model accuracy (Q2), MCC, TPR, and PPV

## Pipeline Overview

1. Data Retrieval

  - Downloaded 151 PDB entries and 190 Pfam sequences (human + non-human)

2. Redundancy Removal

- Merged PDB & Pfam data, removed redundant sequences using CD-HIT (90% threshold)
- Final count: 25 representative sequences for model building

3. Multiple Sequence Alignment

- Used MUSCLE for structural alignment
- Cleaned FASTA using awk/sed, removed PDB: and reformatted for HMMER

4. Model Construction

- Built HMM using hmmbuild on cleaned aligned file

5. Dataset Construction

- Positive set: UniProt Swiss-Prot entries with Kunitz domains minus training data (366 sequences)
- Negative set: All other Swiss-Prot entries (572,833 sequences)
- Split each into pos_1, pos_2, neg_1, neg_2

6. HMM Search

- Performed using hmmsearch against all four datasets
- Saved outputs as .out files

7. Classification Data

- Converted .out to .class files with labels (1 for pos, 0 for neg)
- Missing IDs marked as false negatives with E-value = 10.0

8. Performance Evaluation

- Used performance.py to evaluate Q2, MCC at multiple thresholds (1e-1 to 1e-12)
- Final selected threshold: 1e-5

9. Results Summary

- Best performance observed at threshold 1e-5
- Set1: Q2 = 0.999986, MCC = 0.9890
- Set2: Q2 = 0.999993, MCC = 0.9945
- False negatives: 1 (each set), False positives: 1 (each set)

10. Sequence Logo

- Conserved residues, including cysteines, confirmed via sequence logo (Skulign output, see Figure 3 in report)

## Highlights

- Model trained on Kunitz-containing protein sequences
- Tested on two independent sets from Swiss-Prot
- High accuracy and low false positive/negative rates
- Achieved:
  - ○ Q2 ≈ 0.99998
  - ○ MCC ≈ 0.999185
  - ○ FN = 3, FP = 1 (Set1) – FN = 1, FP = 1 (Set2)

## Citation

If you use this repository, please cite it as:

Azam Bakhshandeh. (2025). Kunitz HMM Detector: Final report, datasets, and evaluation scripts (v1.0.0+). Zenodo. https://doi.org/10.5281/zenodo.15459211




## License

This project is licensed under the MIT License.
