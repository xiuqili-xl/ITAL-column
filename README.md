# ITAL Column

This GitHub repo contains data, code, analysis and figures supporting a [ITAL & Feature Column](https://ital.corejournals.org/index.php/ital/ital-and-column).

> Li X, Chim M. From Preprint Awareness to Engagement: Expanding Library Roles. Information Technology and Libraries (ITAL). Forthcoming. [DOI to be added]

The analysis focuses on examining growth across selected preprint servers over the past 25 years. As a side analysis, we also compare preprint data across different data sources.

<br>


# Analysis Overview

## Preprint Growth Analysis

* Retrieve records for selected preprint servers from OpenAlex
* Save dated snapshots of the retrieved record
* Clean and aggregate the records by server, year, and month
* Visualize changes in preprint volume over time


## Data source comparison

Comparing OpenAlex counts for bioRxiv and medRxiv with counts reported directly by the bioRxiv and medRxiv APIs. [Add a section elaboratign on the discrepency we found and why we are suddenly looking into this? Comment on potentially exploring other sources e.g., Crossref]


# Repository Structure

```text
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

## Analysis Scripts

* `01-retrieve-data.R`: Retrieves OpenAlex records using DOI prefixes associated with selected preprint servers and saves the results as dated RDS files
* `02-process-data.R`: Combines the saved records, performs server-specific cleaning and validation, and calculates monthly counts
* `03-graph-data.R`: Combines the monthly counts and creates the preprint growth figure
* `04-compare-data-source.R`: Retrieves monthly counts from the bioRxiv and medRxiv APIs and compares them with OpenAlex counts.

OpenAlex records are retrieved in yearly, quarterly, or monthly segments. Breaking requests into smaller periods makes large API queries more manageable and creates identifiable snapshots of the source data.

<br>


# Methodological Decisions and Limitations

## Why use OpenAlex? 

Preprint servers differ in their APIs, available metadata, and methods of identifying records. OpenAlex offers a common metadata source that allows a broadly consisten retrieval and aggregation workflow to be applied across mulitple preprint servers. Using a common data source improves comparability, but it does **not** ensure complete or equally current coverage of different platforms.


## Why these preprint servers?

The current OpenAlex workflow examines records from [TBA]. The script also document a few platforms (e.g., ChinaRxiv and AfriArXiv) that could not be included using the same DOI-based method. These preprint servers were selected [because TBA]. This project should not be interpreted as a comprehensive inventory of all preprint servers. [Link to preprint server inventories]


## Identifying records by DOI prefix

Our preliminary exploration showed that filtering OpenAlex records by work type alone could omit relevant records because not every preprint is classified as such. Records were therefore retrieved using DOI prefixes associated with selected preprint servers, followed by server specific cleaning when necessary.

We recognize that this methods has several limitations: (1) a DOI prefix may cover publications other than preprints, (2) a preprint server may use more than one DOI prefix, (3) a platform may change DOI prefix over time, (4) some platforms does not assign DOI to preprints.

DOI-prefix retrieval should therefore be viewed as a reproducible approximation, rather than a complete census of preprints.


## Why preserve data snapshots?

OpenAlex records, classifications, and coverage can change over time. Saving the retrieved records makes it possible to inspect the data underlying the published analysis even if later API queries return different results. 

The OpenAlex data used in the current analysis were retrieved in late Oct 2026. More specific retrieval dates are recorded in the analysis script. 

Monthly counts obtained from the bioRxiv and medRxiv APIs are also saved in `data_saved/` so the comparison does not depend entirely on live API responses.


## Preprint versions and duplicate records

Preprint platforms handle versioning differently. Some retain one DOI across multiple versions, while others may create a separate record or identifiers.

This analysis counts the OpenAlex records returned by the specified DOI-prefix queries. It does **not** reconstruct version histories or attempt to determine if records represent different versions of the same manuscript. Counts should therefore be interpreted as records captured by the retrieval strategy, rather than definitive coutns of unique manuscript.


## Difference between OpenAlex and platform counts

During our analysis we discovered that OpenAlex counts differs quite significantly from totals reported by individual preprint servers. 

[ADD MORE AFTER INVESTIGATION]


## Publication dates

Some OpenAlex record contains dates that may be approximate or assigned at a broader level than the actual posting date. This is particularly important when interpreting monthly trend. For example, a large proportion of the retrieved SSRN records use Jan 1 as the publication date, which may indicate year-level or default date metadata rather than the actual posting date.

<br>


# Reproducing the analysis

ADD info about packages, OpenAlex API, 

OpenAlex is continuously updated, so newly retrieved records may not produce exactly the same counts as the archived data. The saved snapshots document the records used for this analysis.

<br>


# License

The code in this repository is available under the [BSD 3 License](LICENSE.md).

Data retrieved from OpenAlex, bioRxiv, medRxiv, and other sources may be subject to the terms and licenses of their respective providers.
