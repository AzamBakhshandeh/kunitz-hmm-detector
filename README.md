# Kunitz HMM Detector

This repository contains the final report, source code, and evaluation results of a bioinformatics project for detecting Kunitz protein domains using a profile Hidden Markov Model (HMM).

## Contents

- 📄 `kunitz-hmm-project-report.pdf` – Final project report
- 🧬 `create_hmm_build.sh` – Shell script used to build the HMM
- 📊 `final_HMM_table.xlsx` – Table showing model performance at different E-value thresholds
- 💻 `performance.py` – Script for evaluating model accuracy (Q2), MCC, TPR, and PPV


## Highlights

- Model trained on Kunitz-containing protein sequences
- Tested on two independent sets from Swiss-Prot
- Achieved:
  - Q2 ≈ 0.99998
  - MCC ≈ 0.99185
  - FN = 3, FP = 1 (Set1) – FN = 1, FP = 1 (Set2)

## Citation

If you use this repository, please cite:

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.15459212.svg)](https://doi.org/10.5281/zenodo.15459212)

---

## License

This project is licensed under the [MIT License](LICENSE).
