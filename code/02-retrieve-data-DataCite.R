# Goal ----
# Use Datacite API to obtain preprint data from arXiv


# Load libraries ----
library(tidyverse)
library(here)
library(rdatacite)



# Define a function to pull count data from DataCite ----
output_dir <- "data_DataCite"

datacite_count <- function(preprint_name, doi_prefix, start_date, end_date){
  # check if directory exist
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
  
  # set up for loop to extract data from DataCite on a monthly basis
  for(i in 1:length(start_dates)){
    # pause for 1 second before each API request
    Sys.sleep(1)
    
    # set up queries
    dc_query = paste0("prefix:", doi_prefix, " AND registered:[", start_dates[i], " TO ", end_dates[i], "]") 
    dc_query_preprint = paste0(dc_query, " AND types.resourceTypeGeneral:Preprint")
    # resourceTypeGeneral is a required metadata field. For more information see:
    # https://support.datacite.org/docs/what-are-the-resource-types-for-datacite-dois
    
    # create new df
    preprint_count_new <- data.frame(
      period_start = start_dates[i],
      period_end = end_dates[i],
      # limit = 0 means not returning individual record, saving bandwidth
      total_count = dc_dois(query = dc_query, limit = 0)$meta$total,
      preprint_count = dc_dois(query = dc_query_preprint, limit = 0)$meta$total
    )
    
    # add monthly count to df
    preprint_count <- bind_rows(preprint_count, preprint_count_new)
    
    # print message to keep track of progress
    message(paste("Extracted data for", start_dates[i], "to", end_dates[i]))
  }
  
  # outputs
  write_csv(preprint_count, here(output_dir, paste0("dc_stats_", preprint_name, ".csv")))
  return(preprint_count)
}



# Retrieve data for arXiv ----
# arXiv was established in 1991
# data pulled from DataCite on 2026-11-02
# on the same day, arxiv reports 3,236,641 submissions
arxiv_stats <- datacite_count(preprint_name = "arxiv", doi_prefix = "10.48550", 
                              start_date = "1991-01-01", end_date = "2026-10-01")

sum(arxiv_stats$total_count)               # 3190668
sum(arxiv_stats$preprint_count)            # 1861074


# note, arXiv only started assigning DOI upon submission in 2022
# https://blog.arxiv.org/2022/02/17/new-arxiv-articles-are-now-automatically-assigned-dois/
# in the current arxiv_stats, there is spike in early 2022 likely caused by retrospective DOI registration
# we'll need to dig a little deeper for these...


# write a function to download arxiv metadata from DataCite on a monthly basis within a certain period
datacite_arxiv <- function(start_date, end_date){
  # set up monthly sequence within the period
  period <- seq(ymd(start_date), ymd(end_date), by = "month")
  start_dates <- period[1: length(period) - 1]
  end_dates <- (period - 1)[2: length(period)]
  
  for(i in 1:length(start_dates)){
    # message to keep track
    message("Start retrieving records registered ", start_dates[i], " to ", end_dates[i])
    
    # set up query, limit this to just the objects labeled Preprint
    arxiv_query <- paste0("prefix:10.48550 AND registered:[", start_dates[i], " TO ", end_dates[i], "] AND types.resourceTypeGeneral:Preprint")
    cursor <- "1"
    dc_pages <- list()
    
    # extract DataCite data within a certain registration period
    repeat {
      response <- dc_dois(query = arxiv_query, limit = 1000, cursor = cursor)
      dc_pages[[length(dc_pages) + 1L]] <- response$data$attributes %>%
        select(doi, publisher, types, publicationYear, registered, dates)
      
      message("Retrieved page ", length(dc_pages))
      
      next_url <- response$links$`next`
      if (is.null(next_url) || !nzchar(next_url)) break
      
      # extract the next cursor from DataCite's pagination url
      query_string <- sub("^[^?]*\\?", "", next_url)
      parameters <- strsplit(query_string, "&", fixed = TRUE)[[1]]
      cursor_parameter <- parameters[startsWith(URLdecode(parameters), "page[cursor]=")]
      
      stopifnot(length(cursor_parameter) == 1L)
      cursor <- URLdecode(sub("^[^=]*=", "", cursor_parameter))
      Sys.sleep(1)
    }
    
    # combine arxiv data extracted from DataCite and save a copy to repo
    arxiv_records <- bind_rows(dc_pages)
    saveRDS(arxiv_records, here("data_DataCite", "arxiv", paste0("arxiv_preprint_records_", start_dates[i], ".rds")))
  }
}


# download dataset for early 2022 - data that need refining
# also downloading data from some additional period, mostly for sanity check
datacite_arxiv(start_date = "2022-01-01", end_date = "2022-04-01")
datacite_arxiv(start_date = "2022-04-01", end_date = "2022-07-01")
datacite_arxiv(start_date = "2026-04-01", end_date = "2026-07-01")

# all fill path within `data_DataCite/arxiv`
file_paths <- list.files(path = here("data_DataCite", "arxiv"), pattern = "\\.rds$", full.names = TRUE)

# examine records from 2022 Jan, Feb, Mar -- update arxiv_stats


# examine records from 2022 Apr, May, Jun
arxiv_2022Q2 <- bind_rows(lapply(file_paths[1:3], readRDS)) %>%
  select(doi, registered, dates) 

arxiv_2022Q2_cleaned <- arxiv_2022Q2 %>%
  mutate(registered = str_sub(registered, start = 1, end = 10)) %>%
  unnest(dates) %>%
  filter(dateType == "Available", dateInformation == "v1") %>% 
  distinct(doi, registered, date)
nrow(arxiv_2022Q2_cleaned) == nrow(arxiv_2022Q2)

arxiv_2022Q2_cleaned %>% 
  filter(str_sub(registered, start = 1, end = 7) != date) %>%
  view()
# these are all has registration date at the beginning of the month
# likely just due to the subtle delay with assigning DOI


# examine records from 2026 Apr, May, Jun
arxiv_2026Q2 <- bind_rows(lapply(file_paths[4:6], readRDS)) %>%
  select(doi, registered, dates) 

arxiv_2026Q2_cleaned <- arxiv_2026Q2 %>%
  mutate(registered = str_sub(registered, start = 1, end = 10)) %>%
  unnest(dates) %>%
  filter(dateType == "Available", dateInformation == "v1") %>% 
  distinct(doi, registered, date)
nrow(arxiv_2026Q2_cleaned) == nrow(arxiv_2026Q2)

arxiv_2026Q2_cleaned %>% 
  filter(str_sub(registered, start = 1, end = 7) != date) %>%
  view()
# these are all has registration date at the beginning of the month
# likely just due to the subtle delay with assigning DOI





# Explore Zenodo (out of curiosity) ----
zenodo_test <- rdatacite:::dc_GET(route = "dois",
                                  args = list(query = "prefix:10.5281 AND registered:[2026-01-01 TO 2026-01-31]",
                                              `page[size]` = 0, `disable-facets` = "false"))
zenodo_test$meta$resourceTypes
# various resource types, including Preprints







