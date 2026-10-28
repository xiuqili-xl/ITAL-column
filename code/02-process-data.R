# Goal ----
# Examine preprint data retrieved from OpenAlex
# Calculate summary statistics for each preprint server


# Load libraries ----
library(tidyverse)
library(here)

library(janitor)       # get_dupes()


# Define function for loading data ----
input_dir <- "data_OpenAlex"

load_preprint_data <- function(directory = input_dir, subdirectory){
  file_paths <- list.files(path = here(directory, subdirectory), 
                           pattern = "\\.rds$", full.names = TRUE)
  
  data_combined <- data.table::rbindlist(lapply(file_paths, readRDS), 
                                         idcol = "source_file") %>%
    mutate(publication_date = ymd(publication_date),
           publication_year = year(publication_date),
           publication_month = month(publication_date))
}


# arXiv ----




# bioRxiv and medRxiv -----
## data pulled from OpenAlex on 2026-10-26
## for comparison with data from bioRxiv/medRxiv API, see XXX
biorxiv_medrxiv_data <- load_preprint_data(subdirectory = "biorxiv_medrxiv")
openrxiv_data <- load_preprint_data(subdirectory = "openrxiv")

biorxiv_medrxiv_combined_data <- bind_rows(biorxiv_medrxiv_data, openrxiv_data)
rm(biorxiv_medrxiv_data, openrxiv_data)

## sanity check
nrow(biorxiv_medrxiv_combined_data)                     # 235,605
table(biorxiv_medrxiv_combined_data$journal_title)      # Include more than bioRxiv and medRxiv
biorxiv_medrxiv_combined_data %>% count(article_type)   # mostly tagged as preprints

## investigate CSH publications
## other CSH publications share the same DOI prefix
biorxiv_medrxiv_remove_1 <- biorxiv_medrxiv_combined_data %>% 
  filter(str_detect(journal_title, "Cold Spring Harbor"), 
         !str_detect(journal_title, "Institutional Repository"), 
         !str_detect(journal_title, "bioRxiv")) %>%
  arrange(journal_title)
view(biorxiv_medrxiv_remove_1)
## spot check revealed that these are other CSH publications - remove

biorxiv_medrxiv_remove_2 <- biorxiv_medrxiv_combined_data %>% 
  filter(journal_title %in% c("Genes & Development", "Genome Research", 
                              "Learning & Memory", "Molecular Case Studies")) %>%
  arrange(journal_title)
view(biorxiv_medrxiv_remove_2)
## spot check revealed that these are other CSH publications - remove

## observation: doi for these CSH publications starts with letters, let's investigate
biorxiv_medrxiv_remove_3 <- biorxiv_medrxiv_combined_data %>% 
  filter(!article_id %in% c(biorxiv_medrxiv_remove_1$article_id, 
                            biorxiv_medrxiv_remove_2$article_id)) %>%
  filter(str_detect(doi, "1101/[a-zA-Z]+")) %>%
  arrange(doi)
view(biorxiv_medrxiv_remove_3)
## majority (60/89)  have PubMed listed as journal_title...
## spot test revealed that a lot of doi fail to resolve


## remove CSH publications
biorxiv_medrxiv_cleaned_data <- biorxiv_medrxiv_combined_data %>%
  filter(!article_id %in% c(biorxiv_medrxiv_remove_1$article_id, 
                            biorxiv_medrxiv_remove_2$article_id,
                            biorxiv_medrxiv_remove_3$article_id)) 

## export intermediate data file to `data_temp`. Note, this directory is not tracked by Git
saveRDS(biorxiv_medrxiv_cleaned_data, 
        file = here("data_temp", "biorxiv_medrxiv_openalex_cleaned.rds"))


## sanity check with row numbers
nrow(biorxiv_medrxiv_cleaned_data) == nrow(biorxiv_medrxiv_combined_data) - 
  nrow(biorxiv_medrxiv_remove_1) -
  nrow(biorxiv_medrxiv_remove_2) -
  nrow(biorxiv_medrxiv_remove_3)

nrow(biorxiv_medrxiv_cleaned_data)                      # 223003
table(biorxiv_medrxiv_cleaned_data$journal_title)       # still include more than bioRxiv and medRxiv
table(biorxiv_medrxiv_cleaned_data$article_type)        # nearly all tagged preprints
biorxiv_medrxiv_cleaned_data %>% get_dupes(doi)         # 64 duplicates
biorxiv_medrxiv_cleaned_data %>% get_dupes(article_id)  # all unique OpenAlex ID


## summary statistics
biorxiv_medrxiv_stats <- biorxiv_medrxiv_cleaned_data %>% 
  count(publication_year, publication_month)

write_csv(biorxiv_medrxiv_stats, here("outputs_stats", "biorxiv_medrxiv_openalex_stats.csv"))



# ChemRxiv ----
## data pulled from OpenAlex on 2026-10-26
## on the same day, ChemRxiv claims 45,639 preprints listed
chemrxiv_data <- load_preprint_data(subdirectory = "chemrxiv")

## sanity check
nrow(chemrxiv_data)                         # 28,387
unique(chemrxiv_data$journal_title)         # Include more than ChemRxiv
chemrxiv_data %>% count(article_type)       # 28378 preprints, 1 article, 8 erratum, 1 other

# summary statistics
chemrxiv_stats <- chemrxiv_data %>% 
  count(publication_year, publication_month)

write_csv(chemrxiv_stats, here("outputs_stats", "chemrxiv_openalex_stats.csv"))



# EarthArXiv ----
# data pulled from OpenAlex on 2026-10-26 | numbers were ~7.9k 10/25
# on the same day, EarthArXiv claims 7927 preprints listed, including those published in Oct 2026
eartharxiv_data <- load_preprint_data(subdirectory = "eartharxiv")
glimpse(eartharxiv_data)

## sanity check
nrow(eartharxiv_data)                         # 4,969
unique(eartharxiv_data$journal_title)         # include more than EarthArxiv and NA
eartharxiv_data %>% count(article_type)       # 4967 preprint, 1 article, and 1 letter
eartharxiv_data %>% get_dupes(doi)            # 92 duplicates
eartharxiv_data %>% get_dupes(article_id)     # all unique OpenAlex ID

## summary statistics
eartharxiv_stats <- eartharxiv_data %>% 
  count(publication_year, publication_month)

write_csv(eartharxiv_stats, here("outputs_stats", "eartharxiv_openalex_stats.csv"))



# EcoEvoRxiv -----
## data pulled from OpenAlex on 2026-10-26
## on the same day, EarthArXiv claims XXX preprints listed
ecoevorxiv_data <- load_preprint_data(subdirectory = "ecoevorxiv")

## sanity check
nrow(ecoevorxiv_data)                       # 3,730
unique(ecoevorxiv_data$journal_title)       # Include just EcoEvoRxiv and NA
ecoevorxiv_data %>% count(article_type)     # 3728 preprints, 2 erratum

# summary statistics
ecoevorxiv_stats <- ecoevorxiv_data %>% 
  count(publication_year, publication_month)

write_csv(ecoevorxiv_stats, here("outputs_stats", "ecoevorxiv_openalex_stats.csv"))



# Research Square -----
## data pulled from OpenAlex on 2026-01-01
## on the same day, EarthArXiv reports 485,330 preprints, including those from Oct 2026
reseachsquare_data <- load_preprint_data(subdirectory = "researchsquare")

## sanity check
nrow(reseachsquare_data)                      # 299,916
unique(reseachsquare_data$journal_title)      # Include more than Research Square
reseachsquare_data %>% count(article_type)    # 299915 preprints, 1 article

## summary statistics
reseachsquare_stats <- reseachsquare_data %>% 
  count(publication_year, publication_month)

write_csv(reseachsquare_stats, here("outputs_stats", "researchsquare_openalex_stats.csv"))



# SciELO -----
# SciELO includes more than preprints, thus we need to do an additional level of filtering
# data pulled from OpenAlex on 2026-10-26 
scielo_data <- load_preprint_data(subdirectory = "scielo")

## in our analysis, we'll include articles either marked as preprint or has "scieloprepints" in doi
scielo_cleaned_data <- scielo_data %>%
  filter(article_type == "preprint" | str_detect(doi, "scielopreprints"))

## summary statistics
scielo_stats <- scielo_cleaned_data %>%
  count(publication_year, publication_month)

write_csv(scielo_stats, here("outputs_stats", "scielo_openalex_stats.csv"))



# 

