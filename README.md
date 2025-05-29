# Kunitz HMM Detector

This repository contains the final report, source code, datasets, and evaluation results of a bioinformatics project for detecting Kunitz protein domains using a profile Hidden Markov Model (HMM).

---

## 📂 Contents

- 📄 `kunitz-hmm-project-report.pdf` – Final project report
- 🧬 `scripts/create_hmm_build.sh` – Shell script for pipeline execution and model building
- 📊 `results/final_HMM_table.xlsx` – Table of model performance at different E-value thresholds
- 💻 `scripts/performance.py` – Script for computing Q2, MCC, TPR, PPV
- 📘 `docs-workflow.md` – Full step-by-step pipeline documentation (data prep to evaluation)

---

## 🚀 Highlights

- HMM model trained on Kunitz-containing protein sequences
- Evaluated on two independent Swiss-Prot datasets
- High accuracy and low false positive/negative rates

**Performance at optimal threshold (1e-5):**

| Set | Q2        | MCC     | FN | FP |
|-----|-----------|---------|----|----|
| 1   | 0.999986  | 0.9890  | 1  | 1  |
| 2   | 0.999993  | 0.9945  | 1  | 1  |
| ✅ | Combined: Q2 ≈ 0.99998, MCC ≈ 0.999185, FN = 2, FP = 2 |

---

## 📌 Full Pipeline Documentation

For a complete breakdown of each step in the pipeline (data retrieval, MSA, HMM construction, testing, performance analysis):

👉 See [`docs-workflow.md`](docs-workflow.md)

---

## 🧪 Citation

If you use this repository, please cite:

> Azam Bakhshandeh. (2025). *Kunitz HMM Detector: Final report, datasets, and evaluation scripts (v1.0.0+).* [Zenodo](https://doi.org/10.5281/zenodo.15459211)

---

## ⚖️ License

This project is licensed under the MIT License.
