# Goal ----
# Use Crossref API to obtain preprint data ----


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
  # set up monthly sequence within the period
  period <- seq(ymd(start_date), ymd(end_date), by = "month")
  
  start_dates <- period[1: length(period) - 1]
  end_dates <- (period - 1)[2: length(period)]
  
  # define empty df
  preprint_count <- data.frame(period_start = as.Date(character()),
                               period_end = as.Date(character()),
                               preprint_count = numeric())
  
  # set up for loop to extract data from crossref on a monthly basis
  for(i in 1:length(start_dates)){
    Sys.sleep(1)                        # pause for 1 second before each API request
    
    preprint_count_new <- data.frame(
      period_start = start_dates[i],
      period_end = end_dates[i],
      preprint_count = rcrossref::cr_works(filter = c(prefix = doi_prefix, 
                                                      from_pub_date = as.character(start_dates[i]),
                                                      until_pub_date = as.character(end_dates[i])),
                                           limit = 0)$meta$total_results
    )                           # limit = 1 means return not returning individual record
    
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
















