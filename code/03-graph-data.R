# Goal ----
# Graph rise in monthly preprint posting across servers over the last 20 years
# aka, 2006 to 2026 (incomplete)


# Load libraries ----
library(tidyverse)
library(here)


# Import data ----
arxiv_stats <- read_csv(here("data_DataCite", "dc_stats_arxiv_revised.csv")) %>%
  mutate(preprint_server = "arXiv", .before = period_start) 

biorxiv_medrxiv_stats <- read_csv(here("data_Crossref", "cr_stats_biorxiv_medrxiv.csv")) %>%
  mutate(preprint_server = "bioRxiv & medRxiv", .before = period_start) 

chemrxiv_stats <- read_csv(here("data_Crossref", "cr_stats_chemrxiv.csv")) %>%
  mutate(preprint_server = "ChemRxiv", .before = period_start) 

eartharxiv_ecoevorxiv_stats <- rbind(read_csv(here("data_Crossref", "cr_stats_eartharxiv.csv")),
                                     read_csv(here("data_Crossref", "cr_stats_ecoevorxiv.csv"))) %>%
  group_by(period_start, period_end) %>%
  summarise(total_count = sum(total_count),
            preprint_count = sum(preprint_count)) %>%
  ungroup() %>%
  mutate(preprint_server = "EarthArXiv & EcoEvoRxiv", .before = period_start) 

preprintsorg_stats <- read_csv(here("data_Crossref", "cr_stats_preprintsorg.csv")) %>%
  mutate(preprint_server = "Preprints.org", .before = period_start) 

researchsquare_stats <- read_csv(here("data_Crossref", "cr_stats_researchsquare.csv")) %>%
  mutate(preprint_server = "Research Square", .before = period_start) 

ssrn_stats <- read_csv(here("data_Crossref", "cr_stats_ssrn.csv")) %>%
  mutate(preprint_server = "SSRN", .before = period_start)

scielo_stats <- read_csv(here("data_Crossref", "cr_stats_scielo.csv")) %>%
  mutate(preprint_server = "SciELO", .before = period_start)

osf_stats <- read_csv(here("data_Crossref", "cr_stats_osf.csv")) %>%
  mutate(preprint_server = "OSF", .before = period_start)


# Wrangle data ----
preprint_servers <- c("arXiv", "bioRxiv & medRxiv", "ChemRxiv", "EarthArXiv & EcoEvoRxiv", 
                      "SSRN", "Research Square", "Preprints.org",  "OSF", "SciELO" )
preprint_colors <- c("#1F77B4", "#AEC7E8", "#17BECF", "#9EDAE5", 
                     "#FFBB78", "#FF9896", "#D62728", "#9467BD", "#C5B0D5")
names(preprint_colors) <- preprint_servers


# looks like SSRN DOI are almost always assigned in Jan of each year
# we'll use an average to approximate monthly preprint posting
ssrn_stats_revised <- ssrn_stats %>%
  mutate(year_label = str_sub(period_start, start = 1, end = 4)) %>%
  group_by(year_label) %>%
  mutate(total_count = round(mean(total_count), 0),
         preprint_count = round(mean(preprint_count), 0)) %>% 
  ungroup() %>%
  select(-year_label)

preprint_stats_combined <- bind_rows(arxiv_stats, biorxiv_medrxiv_stats, chemrxiv_stats,
                                     eartharxiv_ecoevorxiv_stats, preprintsorg_stats, 
                                     researchsquare_stats, ssrn_stats_revised, 
                                     osf_stats, scielo_stats) %>%
  filter(total_count != 0 | preprint_count != 0) %>%
  mutate(preprint_server = factor(preprint_server, levels = preprint_servers)) %>%
  mutate(period_label = str_sub(period_start, start = 1, end = 7), .after = period_end) %>%
  mutate(publication_year = str_sub(period_start, start = 1, end = 4),
         publication_year = as.numeric(publication_year))



# Graph data ----
ggplot(data = preprint_stats_combined %>% filter(publication_year > 2005),
       mapping = aes(x = period_label, y = preprint_count, fill = preprint_server)) +
  geom_col() +
  facet_grid(~ publication_year, scales="free", space="free_x", switch="both") +
  scale_x_discrete(name = NULL) +
  scale_y_continuous(expand = 0.01, limits = c(0, 95000),
                     breaks = seq(from = 0, to = 100000, by = 20000)) +
  scale_fill_manual(values = preprint_colors) +
  theme_bw() +
  theme(panel.grid.major.y = element_line(color = "grey90", linewidth = 0.45),
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
  labs(y = "Number of preprints", fill = "Preprint server")

ggsave(filename = "preprint_growth_monthly_Crossref_DataCite.png", path = here("outputs_graphs"),
       height = 4, width = 8, dpi = 300, units = "in")





library(pals)
pal.bands(alphabet, alphabet2, cols25, glasbey, kelly, okabe, polychrome, 
          stepped, stepped2, stepped3, tableau20, tol, tol.groundcover,
          watlington, show.names=FALSE)
tol()
tableau20()
"#1F77B4" "#AEC7E8" "#FF7F0E" "#FFBB78" "#2CA02C" "#98DF8A" "#D62728" "#FF9896" "#9467BD" "#C5B0D5"
[11] "#8C564B" "#C49C94" "#E377C2" "#F7B6D2" "#7F7F7F" "#C7C7C7" "#BCBD22" "#DBDB8D" "#17BECF" "#9EDAE5"


"#1F77B4", "#AEC7E8", "#17BECF", "#9EDAE5", 
"#FFBB78", "#D62728", "#FF9896", "#9467BD", "#C5B0D5"

"#332288", "#6699CC", "#88CCEE", "#44AA99",
"#117733", "#999933", "#DDCC77", "#661100", "#CC6677