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





