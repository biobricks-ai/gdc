---
title: GDC
namespace: GDC
description: The GDC contains molecular & clinical human cancer data
dependencies: 
  - name: GDC
    url: https://portal.gdc.cancer.gov/
---
<a href="https://github.com/biobricks-ai/gdc/actions"><img src="https://github.com/biobricks-ai/gdc/actions/workflows/bricktools-check.yaml/badge.svg?branch=master"/></a>

This directory contains data that was obtained from the Genetic Data Commons

It contains projects from the The Cancer Genome Atlas (TCGA) program

The data is stored in parquet files and has clinical_patient, clinical_drug and MuTect2 aliquot sample MAF files describing genetic mutations
Each individual project has all patient data in its respective subdir eg. 

```
data/TCGA-PRAD/clinical_drug_prad.parquet
data/TCGA-PRAD/clinical_patient_prad.parquet
data/TCGA-PRAD/wxs.aliquot_ensemble_masked.maf.parquet
```

In addition, all of the projects data are collated into the files (sans TCGA-PAAD and TCGA-SKCM MAF files due to processing errors).

```
data/combined_clinical_drug.parquet
data/combined_clinical_patient.parquet
data/combined.wxs.aliquot_ensemble_masked.maf.parquet
```


It should be noted that each project produced data that can have different formats, so column names will vary between projects

# Data Retrieval

You will need dvc installed in order to retrieve the data.

To download an individual file, use the command
```
dvc get git@github.com:insilica/oncindex-bricks.git bricks/gdc/data/TCGA-PRAD/clinical_drug_prad.parquet -o data/TCGA-PRAD/clinical_drug_prad.parquet
```
to download the TCGA-PRAD project files
```
dvc get git@github.com:insilica/oncindex-bricks.git bricks/gdc/data/TCGA-PRAD -o data/TCGA-PRAD
```

download the collated patient data
```
dvc get git@github.com:insilica/oncindex-bricks.git bricks/gdc/data/combined_clinical_drug.parquet -o data/
```

### It is advised to import the files into a project so that you will able to track changes in the dataset
```
dvc import git@github.com:insilica/oncindex-bricks.git bricks/gdc/data/TCGA-PRAD -o data/TCGA-PRAD
```

Then follow the instructions to save the data into your local dvc repo




