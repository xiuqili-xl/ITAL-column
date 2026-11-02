# Goal ----
# Compare Crossref data to bioRxiv/medRxiv API


# Load libraries ----
library(tidyverse)
library(here)


# Import data ----
cr_openarxiv_count <- read_csv(here("data_Crossref", "cr_stats_biorxiv_medrxiv.csv"))

biorxiv_api_count <- read_csv(here("data_saved", "biorxiv_api_count.csv"))
medrxiv_api_count <- read_csv(here("data_saved", "medrxiv_api_count.csv"))


# Wrangle data ----
data_source_levels <- c("Crossref", "Server API")
data_source_colors <- c("#F7B6D2", "salmon")
names(data_source_colors) <- data_source_levels

platform_stats <- biorxiv_api_count %>%
  left_join(medrxiv_api_count, by = "month_label") %>%
  mutate(platform_count = coalesce(biorxiv_count, 0) + coalesce(medrxiv_count, 0),
         grouping = "combined") %>%
  mutate(year_label = str_sub(month_label, start = 1, end = 4), .before = month_label) %>%
  mutate(data_source = data_source_levels[2],
         data_source = factor(data_source, levels = data_source_levels))

crossref_stats <- cr_openarxiv_count %>%
  mutate(month_label = str_sub(period_start, start = 1, end = 7),
         year_label = str_sub(period_start, start = 1, end = 4),
         data_source = data_source_levels[1],
         data_source = factor(data_source, levels = data_source_levels))


# Graph data ----
ggplot() +
  geom_col(data = crossref_stats, 
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
  labs(x = "", y = "New preprints",
       title = "bioRxiv and medRxiv data source comparison",
       subtitle = "Crossref vs bioRxiv/medRxiv APIs")


ggsave(filename = "bioRxiv_medRxiv_Crossref_vs_Platform.png", path = here("outputs_graphs"),
       height = 4, width = 8.5, dpi = 300, units = "in")



## temp (need to clean up) ----

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




