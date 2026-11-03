# Goal ----
# Compare data sources for bioRxiv/medRxiv and arXiv


# Load libraries ----
library(tidyverse)
library(here)


# bioRxiv and medRxiv ----
## Import data ----
cr_openarxiv_count <- read_csv(here("data_Crossref", "cr_stats_biorxiv_medrxiv.csv"))
biorxiv_medrxiv_oa_df <- readRDS(here("data_temp", "biorxiv_medrxiv_openalex_cleaned.rds"))
## biorxiv_medrxiv_oa_df was generated in oa02-process-data.R, after removing other CSH publications
## `data_temp` stores intermediate data files, not tracked by Git

biorxiv_api_count <- read_csv(here("data_saved", "biorxiv_api_count.csv"))
medrxiv_api_count <- read_csv(here("data_saved", "medrxiv_api_count.csv"))


## Wrangle data ----
data_source_levels <- c("Server API", "Crossref", "OpenAlex")
data_source_colors <- c("#F7B6D2", "firebrick", "salmon")
names(data_source_colors) <- data_source_levels

platform_stats <- biorxiv_api_count %>%
  left_join(medrxiv_api_count, by = "month_label") %>%
  mutate(platform_count = coalesce(biorxiv_count, 0) + coalesce(medrxiv_count, 0)) %>%
  mutate(year_label = str_sub(month_label, start = 1, end = 4), .before = month_label) %>%
  mutate(data_source = "Server API",
         data_source = factor(data_source, levels = data_source_levels))

openalex_stats <- biorxiv_medrxiv_oa_df %>%
  mutate(month_label = paste(publication_year, sprintf("%02d", publication_month), sep = "-")) %>%
  count(month_label, name = "oa_count") %>%
  mutate(year_label = str_sub(month_label, start = 1, end = 4), .before = month_label) %>%
  mutate(data_source = "OpenAlex",
         data_source = factor(data_source, levels = data_source_levels))

crossref_stats <- cr_openarxiv_count %>%
  mutate(month_label = str_sub(period_start, start = 1, end = 7),
         year_label = str_sub(period_start, start = 1, end = 4),
         data_source = "Crossref",
         data_source = factor(data_source, levels = data_source_levels))


## Graph data ----
ggplot() +
  geom_col(data = platform_stats, 
           mapping = aes(x = month_label, y = platform_count, fill = data_source), 
           width = 0.85, alpha = 0.5) +
  geom_line(data = openalex_stats, mapping = aes(x = month_label, y = oa_count, 
                                                 group = data_source, color = data_source)) + 
  geom_point(data = openalex_stats, mapping = aes(x = month_label, y = oa_count,
                                                  color = data_source), size = 1) +
  geom_line(data = crossref_stats, mapping = aes(x = month_label, y = preprint_count, 
                                                 group = data_source, color = data_source)) +  
  geom_point(data = crossref_stats, mapping = aes(x = month_label, y = preprint_count,
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


ggsave(filename = "bioRxiv_medRxiv_data_source_comparison.png", path = here("outputs_graphs"),
       height = 4, width = 8.5, dpi = 300, units = "in")

