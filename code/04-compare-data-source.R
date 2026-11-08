# Goal ----
# Compare data sources for bioRxiv/medRxiv and arXiv


# Load libraries ----
library(tidyverse)
library(here)


# bioRxiv and medRxiv ----
## Import data ----
cr_openarxiv_count <- read_csv(here("data_Crossref", "cr_stats_biorxiv_medrxiv.csv"))
openalex_count <- read_csv(here("outputs_stats", "biorxiv_medrxiv_openalex_stats.csv"))

biorxiv_api_count <- read_csv(here("data_Platform", "biorxiv_api_count.csv"))
medrxiv_api_count <- read_csv(here("data_Platform", "medrxiv_api_count.csv"))
## saved as part of `oa4-compare-data-source.R` 


## Wrangle data ----
data_source_levels <- c("Platform API", "Crossref", "OpenAlex (doi prefix)")
data_source_colors <- c("lightskyblue1", "royalblue4", "steelblue1")
names(data_source_colors) <- data_source_levels

platform_stats <- biorxiv_api_count %>%
  left_join(medrxiv_api_count, by = "month_label") %>%
  mutate(platform_count = coalesce(biorxiv_count, 0) + coalesce(medrxiv_count, 0)) %>%
  mutate(year_label = str_sub(month_label, start = 1, end = 4), .before = month_label) %>%
  mutate(data_source = "Platform API",
         data_source = factor(data_source, levels = data_source_levels))

openalex_stats <- openalex_count %>%
  mutate(month_label = paste(publication_year, sprintf("%02d", publication_month), sep = "-"), .before = n) %>%
  rename(year_label = publication_year, oa_count = n) %>%
  mutate(data_source = "OpenAlex (doi prefix)",
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
       subtitle = "bioRxiv/medRxiv APIs vs Crossref vs OpenAlex")

ggsave(filename = "bioRxiv_medRxiv_data_source_comparison.png", path = here("outputs_graphs"),
       height = 4, width = 10, dpi = 300, units = "in")



# arxiv ----
## Import data ----
arxiv_datacite_stats <- read_csv(here("data_DataCite", "dc_stats_arxiv_revised.csv"))
## note, NA in total_count means that number wasn't extracted

arxiv_monthly_sub <- read_csv("https://arxiv.org/stats/get_monthly_submissions")

## save a copy to file (data retrieved on 2026-11-03)
write_csv(arxiv_monthly_sub, here("data_Platform", "arxiv_api_count.csv"))


## Wrangle data ----
arxiv_data_source_levels <- c("Platform API", "DataCite (preprint)", "DataCite (total)")
arxiv_data_source_colors <- c("#F7B6D2", "salmon",  "firebrick")
names(arxiv_data_source_colors) <- arxiv_data_source_levels

arxiv_monthly_sub_graph <- arxiv_monthly_sub %>%
  mutate(year_label = str_sub(month, start = 1, end = 4), .before = month) %>%
  mutate(data_source = "Platform API",
         data_source = factor(data_source, levels = arxiv_data_source_levels))
## for more info, see https://arxiv.org/stats/monthly_submissions

arxiv_datacite_stats_graph <- arxiv_datacite_stats %>%
  pivot_longer(cols = -starts_with("period_"), names_to = "data_source", values_to = "count") %>%
  mutate(data_source = if_else(data_source == "total_count", "DataCite (total)", "DataCite (preprint)"),
         data_source = factor(data_source, levels = arxiv_data_source_levels)) %>% 
  mutate(month_label = str_sub(period_start, start = 1, end = 7), .before = period_start) %>%
  mutate(year_label = str_sub(period_start, start = 1, end = 4), .before = month_label)


## Graph data ----
ggplot() +
  geom_col(data = arxiv_monthly_sub_graph %>% filter(ym(month) < ymd("2026-10-01")),
           mapping = aes(x = month, y = submissions, fill = data_source),
           alpha = 0.75) +
  geom_line(data = arxiv_datacite_stats_graph,
            mapping = aes(x = month_label, y = count, group = data_source, color = data_source)) +
  geom_point(data = arxiv_datacite_stats_graph,
             mapping = aes(x = month_label, y = count, color = data_source), size = 1) +
  scale_y_continuous(limits = c(0, 42000), expand = c(0.01, 0)) +
  scale_color_manual(values = arxiv_data_source_colors, drop = FALSE, name = "Data Source") +
  scale_fill_manual(values = arxiv_data_source_colors, drop = FALSE, name = "Data Source") +
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
       title = "arXiv data source comparison",
       subtitle = "arXiv API vs DataCite")

ggsave(filename = "arxiv_data_source_comparison.png", path = here("outputs_graphs"),
       height = 4, width = 16, dpi = 300, units = "in")

