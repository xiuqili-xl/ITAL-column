# Goal ----
# Investigate Crossref as an alternative source of data


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
crossref_count <- function(doi_prefix, start_date, end_date){
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
    
    preprint_count <- bind_rows(preprint_count, preprint_count_new)
    
    message(paste("Extracted data for", start_dates[i], "to", end_dates[i]))
  }
  
  return(preprint_count)
}



# Extract data for crossref ----

## BioRxiv and medRxiv ----
biorxiv_medrxiv_stats <- crossref_count(doi_prefix = "10.64898", 
                                        start_date = "2013-01-01",
                                        end_date = "2026-10-01")

write_csv(openarxiv_stats, here("data_Crossref", "biorxiv_medrxiv_stats.csv"))



# Compare Crossref data to bioRxiv/medRxiv API ---
data_source_levels <- c("OpenAlex", "Server API")
data_source_colors <- c("#F7B6D2", "salmon")
names(data_source_colors) <- data_source_levels

biorxiv_api_count <- read_csv(here("data_saved", "biorxiv_api_count.csv"))
medrxiv_api_count <- read_csv(here("data_saved", "medrxiv_api_count.csv"))

platform_stats <- biorxiv_api_count %>%
  left_join(medrxiv_api_count, by = "month_label") %>%
  mutate(platform_count = coalesce(biorxiv_count, 0) + coalesce(medrxiv_count, 0),
         grouping = "combined") %>%
  mutate(year_label = str_sub(month_label, start = 1, end = 4), .before = month_label) %>%
  mutate(data_source = data_source_levels[2],
         data_source = factor(data_source, levels = data_source_levels))

openarxiv_stats_graph <- openarxiv_stats %>%
  mutate(month_label = str_sub(period_start, start = 1, end = 7),
         year_label = str_sub(period_start, start = 1, end = 4),
         data_source = data_source_levels[1],
         data_source = factor(data_source, levels = data_source_levels))

ggplot() +
  geom_col(data = openarxiv_stats_graph, 
           mapping = aes(x = month_label, y = preprint_count, fill = data_source), 
           width = 0.85, alpha = 0.5) +
  geom_line(data = platform_stats, mapping = aes(x = month_label, y = platform_count, 
                                                 group = grouping, color = data_source)) + 
  geom_point(data = platform_stats, mapping = aes(x = month_label, y = platform_count,
                                                  color = data_source), size = 1) +
  scale_y_continuous(limits = c(0, 6800), expand = c(0.01, 0)) +
  scale_color_manual(values = data_source_colors, drop = FALSE, name = "Data Source") +
  scale_fill_manual(values = data_source_colors, drop = FALSE, name = "Data Source") +
  facet_grid(~ year_label, scales="free", space="free_x", switch="both") +
  theme_bw() +
  theme(panel.grid.major.y = element_line(color = "grey90", linewidth = 0.15),
        panel.grid.minor.y = element_line(color = "grey90", linewidth = 0.15),
        panel.spacing.x = unit(0, "cm"),                   # plot facet panels together
        panel.grid.major.x = element_blank(),
        #        plot.caption = element_text(face = "italic", color = "grey35"),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        strip.background = element_blank(),
        panel.border = element_rect(colour = "grey70", linewidth = 0.25)) +
  labs(x = "", y = "New preprints")



## temp ----

cr_prefix <- function(doi_prefix, start_date, end_date) {
  # Count matching records
  total <- rcrossref::cr_works(
    filter = c(prefix = doi_prefix, 
               from_pub_date = start_date, 
               until_pub_date = end_date),
    limit = 0
  )$meta$total_results
  
  if (total == 0) return(tibble::tibble())
  
  # Retrieve all records using cursor pagination
  result <- rcrossref::cr_works(
    filter = filters,
    cursor = "*",
    cursor_max = total,
    limit = 1000
  )
  
  result$data
}




