# Goal ----
# Graph preprint data retrieved from OpenAlex


# Load libraries ----
library(tidyverse)
library(here)


# Import and wrangle data ----
arxiv_stats <- read_csv(here("outputs_stats", "arxiv_openalex_stats.csv")) %>%
  mutate(preprint_server = "arXiv")

biorxiv_medrxiv_stats <- read_csv(here("outputs_stats", "biorxiv_medrxiv_openalex_stats.csv")) %>%
  mutate(preprint_server = "bioRxiv & medRxiv")

chemrxiv_stats <- read_csv(here("outputs_stats", "chemrxiv_openalex_stats.csv")) %>%
  mutate(preprint_server = "chemRxiv")

eartharxiv_ecoevorxiv_stats <- bind_rows(
  read_csv(here("outputs_stats", "eartharxiv_openalex_stats.csv")),
  read_csv(here("outputs_stats", "ecoevorxiv_openalex_stats.csv"))
) %>%
  count(publication_year, publication_month, wt = n) %>%
  mutate(preprint_server = "EarthArXiv & EcoEvoRxiv")

reseachsquare_stats <- read_csv(here("outputs_stats", "researchsquare_openalex_stats.csv")) %>%
  mutate(preprint_server = "Research Square")

preprintsorg_stats <- read_csv(here("outputs_stats", "preprintsorg_openalex_stats.csv")) %>%
  mutate(preprint_server = "Preprints.org")

scielo_stats <- read_csv(here("outputs_stats", "scielo_openalex_stats.csv")) %>%
  mutate(preprint_server = "SciELO Preprints")


# Bind data ----
preprint_data <- bind_rows(arxiv_stats, biorxiv_medrxiv_stats, chemrxiv_stats, 
                           eartharxiv_ecoevorxiv_stats, reseachsquare_stats, 
                           preprintsorg_stats, scielo_stats) %>%
  mutate(publication_month_label = paste(publication_year, sprintf("%02d", publication_month), sep = "-"), .after = publication_month) %>%
  rename(preprint_no = n)

glimpse(preprint_data)


# Graph data ----
ggplot(data = preprint_data %>% filter(publication_year >= 2010),
       mapping = aes(x = publication_month_label, y = preprint_no, fill = preprint_server)) +
  geom_col() +
  facet_grid(~ publication_year, scales="free", space="free_x", switch="both") +
  scale_x_discrete(name = NULL) +
  scale_y_continuous(expand = 0.01, limits = c(0, 41000)) +
  theme_bw() +
  theme(panel.grid.major.y = element_line(color = "grey90", linewidth = 0.15),
        panel.grid.minor.y = element_line(color = "grey90", linewidth = 0.15),
        panel.spacing.x = unit(0, "cm"),                   # plot facet panels together
        panel.grid.major.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        strip.background = element_blank(),
        panel.border = element_rect(colour = "grey70", linewidth = 0.25),
        legend.position = "top",
        legend.justification.top = "left") +
  guides(fill = guide_legend(nrow = 2)) +        # use byrow = TRUE to order top to bottom
  labs(y = "Number of preprints", fill = "Preprint server",
       caption = "Note to self: still missing ArXiv data")

ggsave(filename = "preprint_growth_over_the_years.png", path = here("outputs_graphs"),
       height = 4, width = 8, dpi = 300, units = "in")


# Next steps: 
# Add arXiv data to plot
# Change color scheme


