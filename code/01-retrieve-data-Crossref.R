# Goal ----
# Use Crossref API to obtain preprint data


# Load libraries ----
library(tidyverse)
library(here)
library(rcrossref)


# Register for the Crossref polite pool ----
library(usethis)
usethis::edit_r_environ()
# add email address to be shared with Crossref `crossref_email = "name@example.com"`
# save the file and restart your R session
# to stop sharing your email simply delete it from your .Renviron file.


# Define a function to pull count data from Crossref ----
output_dir <- "data_Crossref"

crossref_count <- function(preprint_name, doi_prefix, start_date, end_date){
  # check if output directory has been assigned
  if (dir.exists(output_dir)) {
    message("Directory '", output_dir, "' exist. Moving forward.")
  } else {
    message("Check directory! Ending function")
    return(NULL)     # exit the function early
  }
  
  # set up monthly sequence within the period
  period <- seq(ymd(start_date), ymd(end_date), by = "month")
  
  start_dates <- period[1: length(period) - 1]
  end_dates <- (period - 1)[2: length(period)]
  
  # define empty df
  preprint_count <- data.frame(period_start = as.Date(character()),
                               period_end = as.Date(character()),
                               total_count = numeric(),
                               preprint_count = numeric())
  
  # set up for loop to extract data from CrossRef on a monthly basis
  for(i in 1:length(start_dates)){
    # pause for 1 second before each API request
    Sys.sleep(1)                       
    
    preprint_count_new <- data.frame(
      period_start = start_dates[i],
      period_end = end_dates[i],
      # limit = 0 means not returning individual record, saving bandwidth
      total_count = rcrossref::cr_works(filter = c(prefix = doi_prefix,
                                                   from_pub_date = as.character(start_dates[i]),
                                                   until_pub_date = as.character(end_dates[i])),
                                        limit = 0)$meta$total_results,
      # see all possible values for https://api.crossref.org/types 
      preprint_count = rcrossref::cr_works(filter = c(prefix = doi_prefix, type = "posted-content", 
                                                      from_pub_date = as.character(start_dates[i]),
                                                      until_pub_date = as.character(end_dates[i])),
                                           limit = 0)$meta$total_results
    )                           
    
    # add monthly count to df
    preprint_count <- bind_rows(preprint_count, preprint_count_new)
    
    # print message to keep track of progress
    message(paste("Extracted data for", start_dates[i], "to", end_dates[i]))
  }
  
  # outputs
  write_csv(preprint_count, here(output_dir, paste0("cr_stats_", preprint_name, ".csv")))
  return(preprint_count)
}

## Of note, this function will also only work with DOIs that are registered with Crossref.
## For example, arXiv (doi prefix 10.48550) is registered with DataCite and so crossref_count()
## won't work. For a list of DOI registration agencies, see https://www.doi.org/the-community/existing-registration-agencies/

## Since this function relies of doi prefix to identify preprints associated with specific servers and 
## returns a total count for each month. It's only useful for when doi prefixes uniquely map to preprints. 
## It shouldn't be used for when the same doi prefix is used for one organization with multiple publications.



# Note about arXiv ----
# arXiv (doi prefix 10.48550) is registered with DataCite, so crossref_count() won't work
# see XXX for code used to pull arXiv data from DataCite



# Retrieve data for bioRxiv and medRxiv ----
# Crossref DOI prefix is fundamentally associated with a specific member organization 
# (the registrant). DOI prefix for openRxiv is 10.64898. This applies to preprints 
# published before the move to openRxiv. See test below.
biorxiv_medrxiv_test <- cr_works(filter = c(prefix = "10.64898", from_pub_date = "2019-12-01", 
                                            until_pub_date = "2019-12-14"),
                                 limit = 20)

glimpse(biorxiv_medrxiv_test$data)
unique(biorxiv_medrxiv_test$data$prefix)      # 10.64898  
unique(biorxiv_medrxiv_test$data$type)        # posted-content

# data last pulled from Crossref 2026-11-02
biorxiv_medrxiv_stats <- crossref_count(preprint_name = "biorxiv_medrxiv", doi_prefix = "10.64898", 
                                        start_date = "2013-01-01", end_date = "2026-10-01")

biorxiv_medrxiv_stats %>% filter(preprint_count != total_count)   
# 0 rows, meaning all items are labeled as "posted-content"
# for comparison to bioRxiv/medRxiv API data, see XXXX



# Retrieve ChemRxiv data ----
# ChemRxiv was established in 2017
# data last pulled from Crossref on 2026-11-02
# on the same day, ChemRxiv reports 45,992 preprints, including those from in Oct/Nov 2026
chemrxiv_stats <- crossref_count(preprint_name = "chemrxiv", doi_prefix = "10.26434", 
                                 start_date = "2017-01-01", end_date = "2026-10-01")

chemrxiv_stats %>% filter(preprint_count != total_count)    # 0 rows
sum(chemrxiv_stats$preprint_count)                          # 56657



# Retrieve EarthArXiv data ----
# EarthArXiv was established in 2017
# data last pulled from Crossref on 2026-11-02
# on the same day, EarthArxiv reports 7981 preprints, including those from Oct/Nov 2026
eartharxiv_stats <- crossref_count(preprint_name = "eartharxiv", doi_prefix = "10.31223", 
                                   start_date = "2017-01-01", end_date = "2026-10-01")

eartharxiv_stats %>% filter(preprint_count != total_count)    # 0 rows
sum(eartharxiv_stats$preprint_count)                          # 8391



# Retrieve EcoEvoRxiv data ----
# EcoEvoRxiv was established in 2018
# data last pulled from Crossref on 2026-11-02
# on the same day, EcoEvoRxiv reports 3885 preprints, including those from Oct/Nov 2026
ecoevorxiv_stats <- crossref_count(preprint_name = "ecoevorxiv", doi_prefix = "10.32942", 
                                   start_date = "2018-01-01", end_date = "2026-10-01")

ecoevorxiv_stats %>% filter(preprint_count != total_count)    # 0 rows
sum(ecoevorxiv_stats$preprint_count)                          # 3809



# Retrieve data for Research Square ----
# Research Square was established in 2013, and acquired by Nature in 2022
# prior to 2018, Research Square did not mint DOI, confirmed by Crossref data below
# data last pulled from Crossref on 2026-11-02
# on the same day, ResearchSquare reports 478,082 Preprints, posted before 2026-09-30
researchsquare_stats <- crossref_count(preprint_name = "researchsquare", doi_prefix = "10.21203", 
                                       start_date = "2013-01-01", end_date = "2026-10-01")

researchsquare_stats %>% filter(preprint_count != total_count)    # 0 rows
sum(researchsquare_stats$preprint_count)                          # 522290



# Retrieve data for SSRN ----
# SSRN was established in 1994, and was acquired by Elsevier in 2016 
# data last pulled form Crossref on 2026-11-28
# on the same day, SSRN reports 2,864,872 total citations and 1,992,503 full-text papers,
# including those from Oct/Nov 2026
ssrn_stats <- crossref_count(preprint_name = "ssrn", doi_prefix = "10.2139", 
                             start_date = "1994-01-01", end_date = "2026-10-01")

ssrn_stats %>% filter(preprint_count != total_count)    # 42 rows, seeing discrepancies
sum(ssrn_stats$total_count)                             # 1513413
sum(ssrn_stats$preprint_count)                          # 1271369

# observation: most of SSRN preprints are labeled during Jan of different years



# Retrieve data for preprints.org ----
# preprint.org is owned by MDPI. It was launched in 2016
# data last pulled from Crossref on 2026-11-02
# on the same day, Preprints.org reports 143k+ preprints, including those from Oct/Nov 2026 
preprintsorg_stats <- crossref_count(preprint_name = "preprintsorg", doi_prefix = "10.20944",
                                     start_date = "2016-01-01", end_date = "2026-10-01")

preprintsorg_stats %>% filter(preprint_count != total_count)     # 0 rows
sum(preprintsorg_stats$preprint_count)                           # 138995



# Retrieve data for SciELO ----
# SciELO includes more than preprints
# SciELO Preprints was launched in Apr 2020; see Crossref types https://api.crossref.org/types
# data last pulled from Crossref on 2026-11-02
scielo_stats <- crossref_count(preprint_name = "scielo", doi_prefix = "10.1590",
                               start_date = "2020-01-01", end_date = "2026-10-01")

scielo_stats %>% filter(preprint_count != total_count)     # 79 rows
sum(scielo_stats$total_count)                              # 135963
sum(scielo_stats$preprint_count)                           # 5116



# Explore OSF preprint data ----
# OSF Preprints was established in 2017, while community-based preprint servers started in 2016
# while these preprint servers have distinct doi prefix, in Crossref they are all listed with prefix 10.31219 for COS
# other OSF objects (e.g., projects, registrations, components) are registered in DataCite 
# data last pulled from OSF on 2026-11-02
osf_stats <- crossref_count(preprint_name = "osf", doi_prefix = "10.31219",
                            start_date = "2016-01-01", end_date = "2026-10-01")



# Note about ChinaXiv ----
# ChinaXiv is operated by the Chinese Academy of Sciences (CAS), 
# while CAS is registered with Crossref, preprints on ChinaXiv do not receive a doi
chinaxiv_test <- cr_works(filter = c(prefix = "10.11922", from_pub_date = "2026-01-01", 
                                     until_pub_date = "2026-10-31"),
                          limit = 200)

unique(chinaxiv_test$data$publisher)
unique(chinaxiv_test$data$type)



# Note about AfricArXiv ----
# Our investigating suggest that AfricArXiv receive Crossref DOIs through its 
# partner publishing  and hosting platforms (e.g., OSF, PubPub). 
# Hence, our workflow won't work...



