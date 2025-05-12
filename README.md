# gdc

## 🔍 Overview
TODO: one‑sentence plain‑language description.

## 📦 Data Source

- **TODO: data source name**  
  URL: [TODO: https://example.com](TODO: https://example.com)
  <br>Citation: TODO: Author et al. (YEAR)
  <br>License: TODO: license


## 🔄 Transformations
TODO: describe any processing, or say 'none — preserved as‑is'

## 📁 Assets

- `TODO.parquet` (Parquet): TODO: what this file contains


## 🧪 Usage
```bash
biobricks install gdc

import biobricks as bb
import pandas as pd

paths = bb.assets("gdc")

# Available assets:

df_1 = pd.read_parquet(paths.TODO_parquet)


print(df_1.head())      # Preview the first asset

## Additional Information
# gdc

<a href="https://github.com/biobricks-ai/gdc/actions"><img src="https://github.com/biobricks-ai/gdc/actions/workflows/bricktools-check.yaml/badge.svg?branch=master"/></a>

## Description
> The NCI's Genomic Data Commons (GDC)

## Usage
```{R}
biobricks::install_brick("gdc")
biobricks::brick_pull("gdc")
biobricks::brick_load("gdc")
```
