library(arrow)
library(purrr)
library(memoise)
library(stringr)
library(dplyr)
library(data.table)
library(tidyr)
library(fs)
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("GenomicDataCommons")
BiocManager::install("TCGAbiolinks")
library(GenomicDataCommons)
library(TCGAbiolinks)

quiet = pkgcond::suppress_conditions

data_dir = "data"
fs::dir_create(data_dir)

cache_dir = "cache"
fs::dir_create(cache_dir)
# set the cache

# Get the clinical supplement for cases in the TCGA program
# build patients info list
tcga.pid <- projects() |>
  select("project_id") |>
  results_all() |>
  pluck("project_id") |>
  keep(~ grepl("TCGA", .))

print("Downloading clinical supplement patient information")
tcga.clin.BCRtab.list <- purrr::reduce(tcga.pid,function(agg,project_id){

  query <- TCGAbiolinks::GDCquery(project = project_id,
                     data.category = "Clinical",
                     data.type = "Clinical Supplement",
                     data.format = "BCR Biotab") |> quiet()
  TCGAbiolinks::GDCdownload(query,directory = cache_dir) |> quiet()
  TCGAbiolinks::GDCprepare(query,directory  = cache_dir) |> quiet() |>
    lapply(\(l){slice(l,-2:-1)}) |> append(agg)
},.init = list())

clinical_dataframe_names <- names(tcga.clin.BCRtab.list)

print("Creating clinical patient parquet files")
# clinical_patient data
clinical_patient_names <- clinical_dataframe_names[grepl("^clinical_patient_[a-z]*$",clinical_dataframe_names,perl=TRUE)]
purrr::map(clinical_patient_names,function(name) {
  project_name = str_match(name,"^clinical_patient_([a-z]*)$")[[2]] |>
    str_to_upper()
  # make the project dir
  project_dir = file.path(data_dir,paste0("TCGA-",project_name))
  mkdir(project_dir)
  parquet_filename = file.path(project_dir,paste0(name,".parquet"))
  arrow::write_parquet(tcga.clin.BCRtab.list[[name]],parquet_filename)
}) |> quiet()

print("Creating clinical drug names parquet files")
# clinical_drug
clinical_drug_names <- clinical_dataframe_names[grepl("^clinical_drug_[a-z]*$",clinical_dataframe_names,perl=TRUE)]
purrr::map(clinical_drug_names,function(name) {
  project_name = str_match(name,"^clinical_drug_([a-z]*)$")[[2]] |>
    str_to_upper()
  # make the project dir
  project_dir = file.path(data_dir,paste0("TCGA-",project_name))
  mkdir(project_dir)
  parquet_filename = file.path(project_dir,paste0(name,".parquet"))
  arrow::write_parquet(tcga.clin.BCRtab.list[[name]],parquet_filename)
}) |> quiet()


# mutect files
# since we last did this and upload the information to Thrive, there has been
# an update to the MAF files and the way they are named and downloaded
# Genome of reference: hg38
# The query is for TCGA-PRAD a URL of the format:
# https://portal.gdc.cancer.gov/repository?facetTab=files&filters=%7B%22op%22%3A%22and%22%2C%22content%22%3A%5B%7B%22content%22%3A%7B%22field%22%3A%22cases.project.project_id%22%2C%22value%22%3A%5B%22TCGA-PRAD%22%5D%7D%2C%22op%22%3A%22in%22%7D%2C%7B%22op%22%3A%22in%22%2C%22content%22%3A%7B%22field%22%3A%22files.access%22%2C%22value%22%3A%5B%22open%22%5D%7D%7D%2C%7B%22op%22%3A%22in%22%2C%22content%22%3A%7B%22field%22%3A%22files.data_type%22%2C%22value%22%3A%5B%22Masked%20Somatic%20Mutation%22%5D%7D%7D%5D%7D&searchTableTab=files
# If this doesn't match query below, then something is broken.
# Warning: This takes a long time

# Downloads the files
print("Downloading MAF files")
purrr::map(tcga.pid,function(project_id){
  print(paste0("Downloading MAF files for ",project_id))
  query <- GDCquery(project_id,
                    data.category = "Simple Nucleotide Variation",
                    data.type = "Masked Somatic Mutation",
                    data.format = "MAF") |> quiet()
  TCGAbiolinks::GDCdownload(query,directory = cache_dir) |> quiet()
}) |> quiet()

print("Processing MAF files into Parquet")
# create the files
# PAAD and SKCM are not processing
maf_pids <- tcga.pid |> discard(~ .x %in% c("TCGA-PAAD","TCGA-SKCM"))
purrr::map(maf_pids,function(project_id){
  print(paste0("Processing MAF files for ",project_id))
  query <- GDCquery(project_id,
                    data.category = "Simple Nucleotide Variation",
                    data.type = "Masked Somatic Mutation",
                    data.format = "MAF") |> quiet()
  df <- TCGAbiolinks::GDCprepare(query,directory  = cache_dir)
  filename <- "wxs.aliquot_ensemble_masked.maf"
  # most of this should already be done of course
  project_dir = file.path(data_dir,paste0(project_id))
  mkdir(project_dir)
  parquet_filename = file.path(project_dir,paste0(filename,".parquet"))
  arrow::write_parquet(df,parquet_filename)
}) |> quiet()

print("Combine clinical_patient parquet files into one")
list.files(path="data",recursive=TRUE,include.dirs=TRUE,pattern="*.parquet") |>
  map(partial(file.path,"data")) |>
  keep(~ grepl("*.clinical_patient.*",.x)) |>
  reduce(function(agg,filename)
  {
    rbindlist(list(agg,arrow::read_parquet(filename)),fill=TRUE)
  },.init = tibble()) |>
  arrow::write_parquet("data/combined_clinical_patient.parquet")

print("Combine clinical drug information files into one")
list.files(path="data",recursive=TRUE,include.dirs=TRUE,pattern="*.parquet") |>
  map(partial(file.path,"data")) |>
  keep(~ grepl("*.clinical_drug.*",.x)) |>
  reduce(function(agg,filename)
  {
    rbindlist(list(agg,arrow::read_parquet(filename)),fill=TRUE)
  },.init = tibble()) |>
  arrow::write_parquet("data/combined_clinical_drug.parquet")

print("Combine maf files into one")
list.files(path="data",recursive=TRUE,include.dirs=TRUE,pattern="*.parquet") |>
  map(partial(file.path,"data")) |>
  keep(~ grepl("*.wxs.aliquot_ensemble_masked.maf.*",.x)) |>
  reduce(function(agg,filename)
  {
    rbindlist(list(agg,arrow::read_parquet(filename)))
  },.init = tibble()) |>
  arrow::write_parquet("data/combined.wxs.aliquot_ensemble_masked.maf.parquet")

