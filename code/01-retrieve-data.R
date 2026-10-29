# Goal ----
# Write a function that can be used to pull preprint info from OpenAlex
# Use the function to pull preprint data for specific servers based on doi prefix


# Load Libraries ----
library(tidyverse)
library(here)
library(purrr)
library(openalexR)


# Set up openalex API ----
# Since Feb 2026, the OpenAlex API requires an API key
# For more info see: https://docs.ropensci.org/openalexR/
library(usethis)
usethis::edit_r_environ()
## add openalexR.apikey = YOUR_API_KEY
## restart R for the changes to take effect
## remember to rotate API key regularly!


# Define function to pull preprint data from OpenAlex ----
# based on doi prefix and within some timeframe

## set output directory -- make sure this exist
output_dir <- "data_OpenAlex"

## define function
oa_preprint <- function(preprint_name, doi_prefix, time_seg = c("year", "quarter", "month", "week"),
                        start_date = "1991-06-01", end_date = "2026-06-01"){
  # start with generating time series
  if(time_seg == "year"){
    period <- seq(ymd(start_date), ymd(end_date), by = "year")
  }else if(time_seg == "quarter"){
    period <- seq(ymd(start_date), ymd(end_date), by = "quarter")
  } else if (time_seg == "month"){
    period <- seq(ymd(start_date), ymd(end_date), by = "month")
  } else if(time_seg == "week"){
    period <- seq(ymd(start_date), ymd(end_date), by = "week")
  } else{
    return("Issue with time_seg. Double check")
  }
  
  period_starts <- period[1:length(period)-1]
  period_ends <- (period-1)[2:length(period)]
  period_no <- length(period_starts)
  
  # check if folder exists; if not create folder
  if(dir.exists(here(output_dir, preprint_name))){
    print(paste("Folder for", preprint_name, "exists"))
  } else {
    print(paste("Created folder for", preprint_name))
    dir.create(here(output_dir, preprint_name))
  }
  
  # retrieve data through oa_fetch() -- iterate through the loop
  for(i in 1:period_no){
    preprint_list <- oa_fetch(
      entity = "works",
      doi_starts_with = doi_prefix,
      from_publication_date = period_starts[i],
      to_publication_date = period_ends[i],
      options = list(
        select = c("id", "title", "doi", "type", "publication_date", "primary_location")
      ),
      output = "list",
      timeout = 90,
#      verbose = TRUE
    )
    
    print(paste(preprint_name, "data retrieved for", time_seg, 
                period_starts[i], "to", period_ends[i]))
    
    # skip to next iteration is no record found
    if(length(preprint_list) == 0){
      next
    }
    
    # turn list into df
    preprint_df <- map_dfr(preprint_list, ~tibble(
      journal_title    = pluck(.x, "primary_location", "source", "display_name", .default = NA_character_),
      article_title    = pluck(.x, "title", .default = NA_character_),
      article_id       = pluck(.x, "id", .default = NA_character_),
      article_type     = pluck(.x, "type", .default = NA_character_),
      doi              = pluck(.x, "doi", .default = NA_character_),
      publication_date = pluck(.x, "publication_date", .default = NA_character_)
    )) %>%
      arrange(publication_date)
    
    # export df
    saveRDS(preprint_df, 
            file = here(output_dir, preprint_name,
                        paste0(preprint_name, "_raw_", period_starts[i], ".rds")))
  }
}


# Retrieve arXiv data ----




# Retrieve bioRxiv and medRxiv data ----
# bioRxiv was established in late 2013
# data last pulled from OpenAlex on 2026-10-26
oa_preprint(preprint_name = "biorxiv_medrxiv", doi_prefix = "10.1101", time_seg = "year",
            start_date = "2013-01-01", end_date = "2018-01-01")

oa_preprint(preprint_name = "biorxiv_medrxiv", doi_prefix = "10.1101", time_seg = "quarter",
            start_date = "2018-01-01", end_date = "2023-01-01")

oa_preprint(preprint_name = "biorxiv_medrxiv", doi_prefix = "10.1101", time_seg = "month",
            start_date = "2023-01-01", end_date = "2026-10-01")

# since bioRiv & medRxiv transitioned to openArxiv in 2025, the doi prefix changed
oa_preprint(preprint_name = "openrxiv", doi_prefix = "10.64898", time_seg = "quarter",
            start_date = "2025-10-01", end_date = "2026-10-01")



# Retrieve ChemRxiv data ----
# ChemRxiv was established in 2017
# data last pulled from OpenAlex on 2026-10-26
oa_preprint(preprint_name = "chemrxiv", doi_prefix = "10.26434", time_seg = "quarter",
            start_date = "2017-01-01", end_date = "2026-10-01")


# Retrieve EarthArXiv data ----
# EarthArXiv was established in 2017
# data last pulled from OpenAlex on 2026-10-26
oa_preprint(preprint_name = "eartharxiv", doi_prefix = "10.31223", time_seg = "year",
            start_date = "2017-01-01", end_date = "2026-01-01")

oa_preprint(preprint_name = "eartharxiv", doi_prefix = "10.31223", time_seg = "quarter",
            start_date = "2026-01-01", end_date = "2026-10-01")


# Retrieve EcoEvoRxiv data | numbers were ~3.7k 10/25----
# EcoEvoRxiv was established in 2018
# data last pulled from OpenAlex on 2026-10-26
oa_preprint(preprint_name = "ecoevorxiv", doi_prefix = "10.32942", time_seg = "year",
            start_date = "2018-01-01", end_date = "2026-01-01")

oa_preprint(preprint_name = "ecoevorxiv", doi_prefix = "10.32942", time_seg = "quarter",
            start_date = "2026-01-01", end_date = "2026-10-01")



# Retrieve data for Research Square ----
# Research Square was established in 2013, and acquired by Nature in 2022
# prior to 2018, Research Square did not mint DOI
# data last pulled from OpenAlex on 2026-10-28
oa_preprint(preprint_name = "researchsquare", doi_prefix = "10.21203", time_seg = "quarter",
            start_date = "2013-01-01", end_date = "2020-01-01")

oa_preprint(preprint_name = "researchsquare", doi_prefix = "10.21203", time_seg = "month",
            start_date = "2020-01-01", end_date = "2026-10-01")



# Retrieve data for SSRN ----
# SSRN was established in 1994, and was acquired by Elsevier in 2016 
# data last pulled form OpenAlex on 2026-10-28
oa_preprint(preprint_name = "ssrn", doi_prefix = "10.2139", time_seg = "year",
            start_date = "1994-01-01", end_date = "2006-01-01")

oa_preprint(preprint_name = "ssrn", doi_prefix = "10.2139", time_seg = "quarter",
            start_date = "2006-01-01", end_date = "2020-01-01")

oa_preprint(preprint_name = "ssrn", doi_prefix = "10.2139", time_seg = "month",
            start_date = "2020-01-01", end_date = "2026-10-01")

# observation: most of SSRN preprints are posted at the beginning of the year 
# (first quarter or first month)



# Retrieve data for preprints.org ----
# preprint.org is owned by MDPI. It was launched in 2016
# data last pulled from OpenAlex on 2026-10-28
oa_preprint(preprint_name = "preprintsorg", doi_prefix = "10.20944", time_seg = "year",
            start_date = "2016-01-01", end_date = "2024-01-01")

oa_preprint(preprint_name = "preprintsorg", doi_prefix = "10.20944", time_seg = "quarter",
            start_date = "2024-01-01", end_date = "2026-10-01")



# Retrieve data for SciELO ----
# SciELO includes more than preprints; SciELO Preprints was launched in Apr 2020
# data last pulled from OpenAlex on 2026-10-26
oa_preprint(preprint_name = "scielo", doi_prefix = "10.1590", time_seg = "quarter",
            start_date = "2020-01-01", end_date = "2026-10-01")



# Notes about ChinaRxiv and AfricArXiv ----
# ChinaRxiv does not appear to mint DOI, instead they provide a ChinaRxiv unique ID (ChinaXiv:YYYYMM.NNNNN)
# Future note, directly investigate ChinaRxiv API https://chinarxiv.org/api/docs

# Certain preprints in AfricArxiv has the doi prefix 10.60763, 
# but it doesn't not appear to be applicable across the board...
# OpenAlex only contains ~150 items with this prefix, which is a lot lower than the 8k count reported by the platform