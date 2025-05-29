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
