# From Preprint Awareness to Engagement: Expanding Library Roles

This GitHub repo contains data, code, analysis and figures supporting a [ITAL & Feature Column](https://ital.corejournals.org/index.php/ital/ital-and-column).

> Li X, Chim M. From Preprint Awareness to Engagement: Expanding Library Roles. Information Technology and Libraries (ITAL). Forthcoming. [DOI to be added]

The analysis focuses on examining the growth of selected preprint servers over time. A secondary analysis compares preprint counts across different data sources.

<br>


# Analysis Overview

## 📈 Preprint growth analysis

* Retrieve records for selected preprint servers from OpenAlex
* Save dated snapshots of the retrieved record
* Clean and aggregate the records by server, year, and month
* Visualize changes in preprint volume over time


## 📊 Data source comparison

During data validation, we noticed that the OpenAlex counts for bioRxiv and medRxiv are a lot lower than expected. We therefore compared OpenAlex counts with counts reported directly by the bioRxiv and medRxiv APIs. [Comment on other sources when ready, e.g., Crossref]

<br>


# Repository Structure

```text
ITAL-column/
├── README.md
├── LICENSE
├── ITAL-column.Rproj
├── code/                 # code used for analysis     
├── data_OpenAlex/        # OpenAlex snapshots organized by preprint server
├── data_saved/           # monthly counts saved from the bioRxiv and medRxiv APIs
├── data_temp/            # intermediate data files; excluded from version control
├── outputs_stats/        # processed monthly counts used for plotting
└── outputs_graphs/       # figures generated from the analysis
```

## 💻 Analysis Scripts

* `01-retrieve-data.R`: Retrieves OpenAlex records using DOI prefixes associated with selected preprint servers and saves the results as dated RDS files
* `02-process-data.R`: Combines the saved records, performs server-specific cleaning and validation, and calculates monthly counts
* `03-graph-data.R`: Combines the monthly counts and creates the preprint growth figure
* `04-compare-data-source.R`: Retrieves monthly counts from the bioRxiv and medRxiv APIs and compares them with OpenAlex counts.

OpenAlex records are retrieved in yearly, quarterly, or monthly segments. Breaking requests into smaller periods makes large API queries more manageable and creates identifiable snapshots of the source data.

<br>


# Methodological Decisions and Limitations

## 🌐 Why use OpenAlex? 

Preprint servers differ in their APIs, available metadata, and methods of identifying records. OpenAlex offers a common metadata source that allows a broadly consisten retrieval and aggregation workflow to be applied across mulitple preprint servers. Using a common data source improves comparability, but it does **not** ensure complete or equally current coverage of different platforms.


## 🗂️ Why these preprint servers?

The analysis includes arXiv, bioRxiv & medRxiv, ChemRxiv, EarthArXiv, EcoEvoRxiv, Research Squre, SSRN, Preprints.org, and SciELO preprints. These platforms were selected to represent preprint servers spanning different disciplines, genographic context, and governance models while remaining identifiable through OpenAlex data. The scripts also document platforms, including ChinaRxiv and AfricArXiv, that could not be included consistently using the same DOI-based method. Thus, this project should _**not**_ be interpreted as a comprehensive inventory of all preprint servers. For additional preprint servers, please see [ASAPbio Preprint Server Directory](https://asapbio.org/resources/preprint-server-directory/) and the [Directory of Open Access Preprint Repositories](https://doapr.coar-repositories.org/).


## 🔎 Why use DOI prefix?

Our preliminary exploration showed that filtering OpenAlex records by work type alone could omit relevant records because not every preprint is classified as such. Records were therefore retrieved using DOI prefixes associated with selected preprint servers, followed by server specific cleaning when necessary.

We recognize that this methods has several limitations: (1) a DOI prefix may cover publications other than preprints, (2) a preprint server may use more than one DOI prefix, (3) a platform may change DOI prefix over time, (4) some platforms does not assign DOI to preprints.

DOI-prefix retrieval should therefore be viewed as a reproducible approximation, rather than a complete census of preprints.


## 📸 Why preserve data snapshots?

OpenAlex records, classifications, and coverage can change over time. Saving the retrieved records makes it possible to inspect the data underlying the published analysis even if later API queries return different results. 

The OpenAlex data used in the current analysis were retrieved in late Oct 2026. More specific retrieval dates are recorded in the analysis script. 

Monthly counts obtained from the bioRxiv and medRxiv APIs are also saved in `data_saved/` so the comparison does not depend entirely on live API responses.


## 🧬 What about preprint versions and duplicate records?

Preprint platforms handle versioning differently. Some retain one DOI across multiple versions, while others may create a separate record or identifiers.

This analysis counts the OpenAlex records returned by the specified DOI-prefix queries. It does **not** reconstruct version histories or attempt to determine if records represent different versions of the same manuscript. Counts should therefore be interpreted as records captured by the retrieval strategy, rather than definitive coutns of unique manuscript.


## ⚖️ Any difference between OpenAlex and platform data?

During our analysis we found substantial differences between OpenAlex and totals reported by individual preprint servers. 

[ADD MORE AFTER INVESTIGATION, potentially a table?]

Some OpenAlex records also appear to contain dates that are approximate or assigned at a broader level than the actual posting date. This is particularly important when interpreting monthly trend. For example, approximately 99.8% of the retrieved SSRN record use Jan 1 as the publication date, which may reflect year-level or default date metadata rather than the actual posting date.

<br>


# Reproducing the Analysis

The analysis requires R and the `tidyverse`, `here`, `purrr`, `openalexR`, `usethis`, `janitor`, and `data.table` packages. Open the `ITAL-column.Rproj` project before running the scripts.

Retrieving fresh OpenAlex records requires an API key configured as `openalexR.apikey` in `.Renviron`. Readers who only want to inspect the archived data and outputs do not need an OpenAlex API key.

OpenAlex is continuously updated, so newly retrieved records may _**not**_ produce exactly the same counts as the archived data. The saved snapshots document the records used for this analysis.

<br>


# License

The code in this repository is available under the [BSD 3 License](LICENSE).

Data retrieved from OpenAlex, bioRxiv, medRxiv, and other sources may be subject to the terms and licenses of their respective providers.

<br>

