library(purrr)

gdc.cases  <- {
    tbl <- arrow::read_parquet("data/combined.wxs.aliquot_ensemble_masked.maf.parquet")
    unique(tbl$case_id)
}

gdc2tcga <- (function(gdc_id,i){
    print(sprintf("%s out of %s",i,length(gdc.cases)))
    url  <- paste("https://api.gdc.cancer.gov/cases/",gdc_id,sep="")
    httr2::request(url) |>
        httr2::req_perform() |>
        httr2::resp_body_json() |>
        pluck("data","submitter_id",.default=NA)
}) |> slowly(rate_delay(pause=0.3))


tbl                     <- data.frame(case_id=gdc.cases)
tbl$bcr_patient_barcode <- imap_chr(tbl$case_id,gdc2tcga)

arrow::write_parquet(tbl,"data/gdc2tcga.parquet")
