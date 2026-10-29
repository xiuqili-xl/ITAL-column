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


# Process arXiv data ----




# Process bioRxiv and medRxiv data -----
## data last pulled from OpenAlex on 2026-10-26
## for comparison with data from bioRxiv/medRxiv API, see XXX
biorxiv_medrxiv_data <- load_preprint_data(subdirectory = "biorxiv_medrxiv")
openrxiv_data <- load_preprint_data(subdirectory = "openrxiv")

## compare with OpenAlex web interface
biorxiv_medrxiv_data %>% count(publication_year)      # doi prefix: 10.1101
openrxiv_data %>% count(publication_year)             # doi prefix: 10.64898

## combine dataset
biorxiv_medrxiv_combined_data <- bind_rows(biorxiv_medrxiv_data, openrxiv_data)
rm(biorxiv_medrxiv_data, openrxiv_data)

## sanity check
nrow(biorxiv_medrxiv_combined_data)                        # 235,605
sort(table(biorxiv_medrxiv_combined_data$journal_title), decreasing = TRUE)[1:5]
# include more than bioRxiv and medRxiv -- some known publications by CSHL, which we'll remove
sort(table(biorxiv_medrxiv_combined_data$article_type), decreasing = TRUE)
# mostly tagged as preprints

## investigate CSH publications
## other CSH publications share the same DOI prefix
biorxiv_medrxiv_remove_1 <- biorxiv_medrxiv_combined_data %>% 
  filter(str_detect(journal_title, "Cold Spring Harbor"), 
         !str_detect(journal_title, "Institutional Repository"), 
         !str_detect(journal_title, "bioRxiv")) %>%
  arrange(journal_title)
view(biorxiv_medrxiv_remove_1)
## spot check revealed that these are other CSH publications - to remove

biorxiv_medrxiv_remove_2 <- biorxiv_medrxiv_combined_data %>% 
  filter(journal_title %in% c("Genes & Development", "Genome Research", 
                              "Learning & Memory", "Molecular Case Studies")) %>%
  arrange(journal_title)
view(biorxiv_medrxiv_remove_2)
## spot check revealed that these are other CSH publications - to remove

## observation: doi for these CSH publications starts with letters, let's investigate
biorxiv_medrxiv_remove_3 <- biorxiv_medrxiv_combined_data %>% 
  filter(!article_id %in% c(biorxiv_medrxiv_remove_1$article_id, 
                            biorxiv_medrxiv_remove_2$article_id)) %>%
  filter(str_detect(doi, "1101/[a-zA-Z]+")) %>%
  arrange(doi)
view(biorxiv_medrxiv_remove_3)
## majority (60/89)  have PubMed listed as journal_title...
## spot test revealed that a lot of doi fail to resolve...

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
  nrow(biorxiv_medrxiv_remove_1) - nrow(biorxiv_medrxiv_remove_2) - nrow(biorxiv_medrxiv_remove_3)

nrow(biorxiv_medrxiv_cleaned_data)                      # 223,003
sort(table(biorxiv_medrxiv_cleaned_data$journal_title), decreasing = TRUE)
# still include more than bioRxiv and medRxiv
sort(table(biorxiv_medrxiv_cleaned_data$article_type), decreasing = TRUE)    
# nearly all tagged preprints
biorxiv_medrxiv_cleaned_data %>% get_dupes(doi)         # 64 duplicates
biorxiv_medrxiv_cleaned_data %>% get_dupes(article_id)  # all unique OpenAlex ID

## summary statistics
biorxiv_medrxiv_stats <- biorxiv_medrxiv_cleaned_data %>% 
  count(publication_year, publication_month)

write_csv(biorxiv_medrxiv_stats, here("outputs_stats", "biorxiv_medrxiv_openalex_stats.csv"))



# Process ChemRxiv data ----
## data last pulled from OpenAlex on 2026-10-26
## on the same day, ChemRxiv claims 45,639 preprints listed
chemrxiv_data <- load_preprint_data(subdirectory = "chemrxiv")
chemrxiv_data %>% count(publication_year)           # doi prefix: 10.26434

## sanity check
nrow(chemrxiv_data)                                 # 28,387
count(chemrxiv_data, journal_title, sort = TRUE)    # mostly ChemRxiv (28,379)
count(chemrxiv_data, article_type, sort = TRUE)     # mostly tagged as preprints (28,377)

# summary statistics
chemrxiv_stats <- chemrxiv_data %>% 
  count(publication_year, publication_month)

write_csv(chemrxiv_stats, here("outputs_stats", "chemrxiv_openalex_stats.csv"))



# EarthArXiv ----
# data last pulled from OpenAlex on 2026-10-26 | numbers were ~7.9k 10/25
# on the same day, EarthArXiv claims 7927 preprints listed, including those published in Oct 2026
eartharxiv_data <- load_preprint_data(subdirectory = "eartharxiv")
eartharxiv_data %>% count(publication_year)          # doi prefix: 10.31223

## sanity check
nrow(eartharxiv_data)                                # 4,969
count(eartharxiv_data, journal_title, sort = TRUE)   # the most are actually NA...
count(eartharxiv_data, article_type, sort = TRUE)    # nearly all are tagged preprint (4,967)
eartharxiv_data %>% get_dupes(doi)                   # 92 duplicates
eartharxiv_data %>% get_dupes(article_id)            # all unique OpenAlex ID

## summary statistics
eartharxiv_stats <- eartharxiv_data %>% 
  count(publication_year, publication_month)

write_csv(eartharxiv_stats, here("outputs_stats", "eartharxiv_openalex_stats.csv"))



# Processed EcoEvoRxiv data -----
## data last pulled from OpenAlex on 2026-10-26
## on the same day, EcoEvoRxiv claims 3840 preprints listed
ecoevorxiv_data <- load_preprint_data(subdirectory = "ecoevorxiv")
ecoevorxiv_data %>% count(publication_year)     # doi prefix 10.32942

## sanity check
nrow(ecoevorxiv_data)                           # 2,825
count(ecoevorxiv_data, journal_title)           # mostly NA...
count(ecoevorxiv_data, article_type)            # mostly preprints (2,823)

# summary statistics
ecoevorxiv_stats <- ecoevorxiv_data %>% 
  count(publication_year, publication_month)

write_csv(ecoevorxiv_stats, here("outputs_stats", "ecoevorxiv_openalex_stats.csv"))



# Process Research Square data -----
## data last pulled from OpenAlex on 2026-10-28
## on the same day, Research Square reports 478,378 preprints posted before Oct 2026
reseachsquare_data <- load_preprint_data(subdirectory = "researchsquare")
reseachsquare_data %>% count(publication_year)          # doi prefix 10.21203

## sanity check
nrow(reseachsquare_data)                                # 299,509
count(reseachsquare_data, journal_title, sort = TRUE)   # mostly Research Square (279,277) and NA (20,195)
count(reseachsquare_data, article_type, sort = TRUE)    # 299508 preprints, 1 article

## summary statistics
reseachsquare_stats <- reseachsquare_data %>% 
  count(publication_year, publication_month)

write_csv(reseachsquare_stats, here("outputs_stats", "researchsquare_openalex_stats.csv"))



# Process SSRN data ----
## data last pulled from OpenAlex on 2026-10-28
## on the same day, SSRN reports X preprints, including those from Oct 2026
ssrn_data <- load_preprint_data(subdirectory = "ssrn")
ssrn_data %>% count(publication_year)                          # doi prefix: 10.2139

## sanity check
nrow(ssrn_data)                                                # 1,190,151
unique(ssrn_data$journal_title)                                # includes more than Research Square
sort(table(ssrn_data$journal_title), decreasing = TRUE)[1:5]   # mostly attributed to SSRN (1,183,009) 
sort(table(ssrn_data$article_type), decreasing = TRUE)         # mostly tagged as preprints (1,183,265)

## some additional investigation...
## how many items have an assigned publication date of Jan 1
ssrn_data %>%
  mutate(published_jan1 = str_detect(publication_date, "01-01")) %>%
  count(published_jan1) %>%
  mutate(percent = n/sum(n) * 100)
## nearly all (99.78%) of items have a publication date of Jan 1...

## summary statistics, which we probably won't graph
ssrn_stats <- ssrn_data %>% 
  count(publication_year, publication_month)

write_csv(ssrn_stats, here("outputs_stats", "ssrn_openalex_stats.csv"))



# Process preprints.org data ----
# data last pulled from OpenAlex on 2026-10-28
# on the same data, preprints.org reports 143K+ total preprints
preprintsorg_data <- load_preprint_data(subdirectory = "preprintsorg")
preprintsorg_data %>% count(publication_year)        # doi prefix: 10.20944

## sanity check
nrow(preprintsorg_data)                                 # 54,663
count(preprintsorg_data, journal_title, sort = TRUE)    # nearly all attributed to Preprints.org (54,640)
count(preprintsorg_data, article_type, sort = TRUE)     # nearly all tagged as preprints (54,662)

## summary statistics
preprintsorg_stats <- preprintsorg_data %>%
  count(publication_year, publication_month)

write_csv(preprintsorg_stats, here("outputs_stats", "preprintsorg_openalex_stats.csv"))



# Process SciELO data -----
# data pulled from OpenAlex on 2026-10-26 
scielo_data <- load_preprint_data(subdirectory = "scielo")
scielo_data %>% count(publication_year)          # doi prefix: 10.1590

## SciELO includes more than preprints, thus we need to do an additional level of filtering
## in our analysis, we'll include articles either marked as preprint or has "scieloprepints" in doi
scielo_cleaned_data <- scielo_data %>%
  filter(article_type == "preprint" | str_detect(doi, "scielopreprints"))

## summary statistics
scielo_stats <- scielo_cleaned_data %>%
  count(publication_year, publication_month)

write_csv(scielo_stats, here("outputs_stats", "scielo_openalex_stats.csv"))





