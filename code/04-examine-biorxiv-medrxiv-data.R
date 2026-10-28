# Goal ----
# Compare bioRxiv/medRxiv preprint data from OpenAlex vs the source


# Load libraries
library(tidyverse)
library(here)



# Import data ---
## OpenAlex data ----
biorxiv_medrxiv_oa_df <- readRDS(here("data_temp", "biorxiv_medrxiv_openalex_cleaned.rds"))
## biorxiv_medrxiv_oa_df is generated in 02-process-data.R
## `data_temp` stores intermediate data files, not tracked by Git


## bioRxiv API ----
## for more info about bioRxiv API, see documentation https://api.biorxiv.org/
biorxiv_api_count <- read_csv("https://api.biorxiv.org/sum/m/csv", show_col_types = FALSE) %>%
  select(month_label = month, biorxiv_count = new_papers)

## save a copy to file (data retrieved on 2026-10-27)
write_csv(biorxiv_api_count, here("data_saved", "biorxiv_api_count.csv"))


## medRxiv API ----
## the same function works for medRxiv, see documentation https://api.medrxiv.org/
medrxiv_api_count <- read_csv("https://api.medrxiv.org/sum/m/csv", show_col_types = FALSE) %>%
  select(month_label = month, medrxiv_count = new_papers)

## save a copy to file (data retrieved on 2026-10-27)
write_csv(medrxiv_api_count, here("data_saved", "medrxiv_api_count.csv"))



# Wrangle data ----
## OpenAlex tally ----
glimpse(biorxiv_medrxiv_oa_df)
unique(biorxiv_medrxiv_oa_df$publication_month)

oa_stats <- biorxiv_medrxiv_oa_df %>%
  mutate(month_label = paste(publication_year, sprintf("%02d", publication_month), sep = "-")) %>%
  count(month_label, name = "oa_count")
  

## bioRxiv and medRxiv API data ----
platform_stats <- biorxiv_api_count %>%
  left_join(medrxiv_api_count, by = "month_label") %>%
  mutate(platform_count = coalesce(biorxiv_count, 0) + coalesce(medrxiv_count, 0),
         grouping = "combined")


# Graph data ----
ggplot() +
  geom_col(data = oa_stats, mapping = aes(x = month_label, y = oa_count), 
           width = 0.85, fill = "#F7B6D2", alpha = 0.5) +
  geom_line(data = platform_stats, mapping = aes(x = month_label, y = platform_count, group = grouping),
            color = "salmon") + 
  geom_point(data = platform_stats, mapping = aes(x = month_label, y = platform_count),
             color = "salmon", size = 1) +
  theme_bw()


platform_stats %>%
  mutate(year_label = str_sub(month_label, start = 1, end = 4)) %>%
  count(year_label, wt = platform_count)


  scale_y_continuous(limits = c(0, 6500), expand = c(0.01, 0)) +
  facet_grid(~ year, scales="free", space="free_x", switch="both") +
  theme_bw() +
  theme(panel.grid.major.y = element_line(color = "grey90", linewidth = 0.15),
        panel.grid.minor.y = element_line(color = "grey90", linewidth = 0.15),
        panel.spacing.x = unit(0, "cm"),                   # plot facet panels together
        panel.grid.major.x = element_blank(),
        plot.caption = element_text(face = "italic", color = "grey35"),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        strip.background = element_blank(),
        panel.border = element_rect(colour = "grey70", linewidth = 0.25)) +
  labs(x = "", y = "New preprint deposited",
       caption = paste("Last updated", today()))


ggsave(filename = "20260305-bioRxiv_medRxiv_count.png", path = here("graphs"),
       height = 3.5, width = 10, dpi = 300, units = "in")



