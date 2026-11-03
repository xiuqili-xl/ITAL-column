# From Preprint Awareness to Engagement: Expanding Library Roles

This GitHub repo contains data, code, analyses, and figures supporting a [ITAL & Feature Column](https://ital.corejournals.org/index.php/ital/ital-and-column). Specifically, 

> Li X, Chim M. From Preprint Awareness to Engagement: Expanding Library Roles. Information Technology and Libraries (ITAL). **Forthcoming**. [DOI to be added]

The main analysis examines the growth of selected preprint servers over time. A secondary analysis compares preprint counts across different data sources.

<br>


# Analysis Overview

## 📈 Preprint growth analysis

- Retrieve monthly counts for selected preprint servers from [Crossref](https://www.crossref.org/) and [DataCite](https://datacite.org/)
- Save the retrieved counts and selected metadata for inspection and reuse
- Clean and aggregate the records as needed to generate monthly counts
- Visualize changes in preprint volume from 2006 through Sep 2026


## 📊 Data source comparison

During data validation, we noticed that counts from different sources tend to vary. We therefore made the following comparisons to assess how coverage, classification, and date metadata affect the interpretation of preprint growth

- **bioRxiv and medRxiv:** Compare combined counts from the platform APIs, Crossref, and an earlier OpenAlex retrieval (more on the OpenAlex analysis later)
- **arXiv**: Compare platform-reported monthly submissions with DataCite counts, including differences between all retrieved DOI records and records classified as preprints

<br>


# Repository Structure

```text
ITAL-column/
├── README.md
├── LICENSE
├── ITAL-column.Rproj
├── code/                 # current Crossref/DataCite analysis and source comparisons
├── code_previous/        # earlier OpenAlex retrieval, processing, and analysis
├── data_Crossref/        # saved monthly counts from Crossref
├── data_DataCite/        # saved DataCite counts and selected arXiv metadata
├── data_OpenAlex/        # earlier OpenAlex snapshots organized by preprint server
├── data_Platform/        # saved counts from bioRxiv, medRxiv, and arXiv
├── data_temp/            # intermediate data files; excluded from version control
├── outputs_stats/        # processed counts from the earlier OpenAlex workflow
└── outputs_graphs/       # figures generated from the analyses
```

## 💻 Analysis Scripts

- `01-retrieve-data-Crossref.R`: Retrieves monthly counts by DOI prefixes, both with and without the `type = "posted-content"` filter
- `02-retrieve-data-DataCite.R`: Retrieves monthly arXiv counts and selected metadata;  reconstructs earlier posting months for records with retrospective DOI registration in early 2022 
- `03-graph-data.R`: Combines Crossref and DataCite counts, applies the SSRN date adjustment, and creates the preprint growth figure
* `04-compare-data-source.R`: Creates source comparison figures for bioRxiv/medRxiv and arXiv

Scripts in `code_previous/` preserve the earlier OpenAlex workflow, including data retrieval, server-specific cleaning, monthly aggregation, and platform API comparisons.

<br>


# Methodological Decisions and Limitations

## 🌐 Why use Crossref and DataCite?

Crossref and DataCite provide DOI registration metadata that can be queried using a common approach across selected preprint servers. The main analysis uses Crossref for the included platforms other than arXiv, whose DOI records are retrieved from DataCite. The scripts retrieve both total DOI counts and counts filtered by metadata type: `posted-content` in Crossref and `Preprint` in DataCite. The preprint monthly growth figure uses the type-filtered counts.

Using DOI registration metadata enables a broadly consistent retrieval and aggregation workflow across multiple preprint servers. It also allows future expansion to other preprint servers. Using two main data sources improves comparability, but it does **not** ensure complete coverage or consistent classification across platforms. The two sources also use different date fields, which affects comparison of monthly trends.


## 🗂️ Why these preprint servers?

The analysis includes arXiv, bioRxiv & medRxiv, ChemRxiv, EarthArXiv, EcoEvoRxiv, Research Square, SSRN, Preprints.org, OSF, and SciELO preprints. These platforms were selected to represent preprint servers spanning different disciplines, geographic contexts, and governance models. They can be queried using the selected DOI-prefix approach.

The growth figure combines bioRxiv with medRxiv and EarthArxiv with EcoEvoRxiv. The OSF series represents records returned by the Crossref DOI prefix query rather than separate counts for each OSF-hosted community.

The scripts also document exploration of ChinaRxiv, AfricArXiv, and Zenodo, which don't use the current retrieval process. Thus, this project should _**not**_ be interpreted as a comprehensive inventory of all preprint servers. For additional platforms, please see [ASAPbio Preprint Server Directory](https://asapbio.org/resources/preprint-server-directory/) and the [Directory of Open Access Preprint Repositories](https://doapr.coar-repositories.org/).


## 🔎 Why use DOI prefix?

DOI prefixes provide a practical way to identify records associated with selected preprint servers or their registering organization. The scripts combine DOI prefix queries with metadata-type filters to distinguish the selected content from other records where possible.

We recognize that this method has several limitations: (1) a DOI prefix may cover publications other than preprints, (2) a preprint server may use more than one DOI prefix, (3) a platform may change DOI prefix over time, and (4) some platforms do not assign DOI to preprints. Metadata-type filters can also omit relevant records or include content that does not correspond precisely to the intended definition of a preprint.

DOI-prefix retrieval should therefore be viewed as a reproducible approximation, rather than a complete census of preprints.


## 🧭 What did our earlier exploration with OpenAlex show?

This project initially used OpenAlex as a common metadata source across preprint servers - the workflow retrieved records by DOI prefix and applied server-specific cleaning. Validation identified substantial differences between the retrieved OpenAlex counts and counts reported by individual preprint platforms. 

Communication with the OpenAlex Support Team revealed that OpenAlex merges preprint records into published records once the manuscript is published in a journal. The work's main DOI becomes the journal article's. Thus, filtering on DOI prefixes of only preprint servers finds only preprints that haven't been published yet (or whose published version hasn't been linked yet). While it's possible to filter on `locations.source.id`, a merged work's publication year is the journal article's, not the preprint's.

These findings motivated the shift to Crossref and Datacite for the main preprint growth analysis. The earlier scripts and saved OpenAlex data are retained to document that exploration, and OpenAlex remains part of the bioRxiv/medRxiv data source comparison. The comparison describes the particular retrieval strategy and snapshots used; it should _**not**_ be interpreted as a general assessment of OpenAlex coverage.


## 📸 Why save data snapshots?

Source metadata and API results can change over time. Saving the retrieved counts and selected records makes it possible to inspect the data underlying the figures even if later API queries return different results. 

The repository retains monthly Crossref and Datacite counts, selected arXiv metadata used for date adjustments, earlier OpenAlex snapshots, and platform-reported counts. Retrieval dates are documented in the script where available. Most data retrieval occurred in late Oct and early Nov, 2026.


## 🧬 What about preprint versions and duplicate records?

Preprint platforms handle versioning differently. Some retain one DOI across multiple versions, while others may create separate records or identifiers.

The main analysis counts DOI records returned by the specified DOI-prefix and type queries. It does **not** reconstruct version histories or attempt to determine if records represent different versions of the same manuscript. Counts should therefore be interpreted as records captured by the retrieval strategy, rather than definitive counts of unique manuscripts.


## ⚖️ Any difference between data sources?

Yes. It's important to note that counts can differ simply because different sources measure different things: platform submissions, registered DOI records, or records assigned to a particular metadata type. Differences in coverage, versioning, classification, and timestamp can also affect comparisons

Date fields require particular care:

- **Crossref**: Monthly queries use publication-date filters
- **DataCite/arXiv**: Initial queries use DOI registration dates. For records registered in Jan-Mar 2022 (when retrospective DOI registration happened), the workflow uses the `Available` date labeled `v1` to reconstruct posting month. Later counts retain registration months, which may be a day or two delayed, placing it in a different month
- **SSRN**: Retrieved counts are concentrated in Jan. For plotting purposes, monthly counts are replaced with the rounded mean for that year. These values approximate monthly volume and should not be interpreted as observed monthly posting patterns.

The data source comparison figures provide checks on these differences for bioRxiv/medRxiv and arXiv. They do _**not**_ establish equivalent coverage or date accuracy.

<br>


# Reproducing the Analysis

The current analysis uses R and the `tidyverse`, `here`, `rcrossref`, and `rdatacite` packages. The Crossref setup also uses `usethis`. Open the `ITAL-column.Rproj` project before running the scripts.

For fresh retrievals, run the Crossref and DataCite scripts before the plotting and comparison scripts. The Crossref script includes instructions for configuring an email address in `.Renviron` for polite-pool requests.

The scripts currently contain interactive setup, exploratory code, and intermediate processing steps, so they should be reviewed and run section by section. The bioRxiv/medRxiv comparison also requires the cleaned OpenAlex intermediate file generated by `code_previous/oa2-process-data.R`. Because this file is stored in the untracked `data_temp/` directory, regenerate it if it's missing.

Re-running the earlier OpenAlex retrieval requires `openalexR` and an API key configured as `openalexR.apikey` in `.Renviron`. An OpenAlex API key is not needed for the main Crossref/DataCite retrieval or for inspecting saved outputs.

New API queries may _**not**_ reproduce the archived counts exactly because source metadata and coverage change over time.

<br>


# License

The code in this repository is available under the [BSD 3 License](LICENSE).

Data retrieved from Crossref, DataCite, OpenAlex, bioRxiv, medRxiv, arXiv, and other sources may be subject to the terms and licenses of their respective providers.

<br>

