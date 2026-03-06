# Supplementary Information

This repository contains the necessary instructions to carry out the analyses described in the paper titled:

**Reconstructing the Organisation and Agricultural Capacity of Late Bronze Age kingdom  of Ugarit: A Statistical and Spatial Modelling Approach**

## Paper Authors

Cristiana Liberati(a), Giacomo Bilotti(b)

a University of Rome “La Sapienza”, Rome, Italy

b Social Resilience Lab, Center for Humanities Computing, Aarhus University, Aarhus, Denmark

## Repository maintainer

Giacomo Bilotti (bilottigiacomo@gmail.com)

## Paper abstract

The site of Ras Shamra, ancient Ugarit, located on the northern coast of Syria (Lattakia Governorate), was the capital of a flourishing kingdom during the 2nd millennium BC, documented both by archaeological excavations and numerous inscribed tablets that provide insight into its size and organisation. Previous studies based on historical data estimate that around 200 hamlets economically supported the city-state, with toponymic research identifying 17 of them, mostly located near Ugarit or along the coast. In this paper, we calculate the kingdom’s agricultural capacity and examine it in relation to its network of villages and subordinate settlements to better understand its organisation. Agricultural potential was quantified using suitability maps for the kingdom’s three primary crops: cereals, olives, and vines. Additionally, we employed point pattern analysis (PPA) to integrate the agricultural suitability proposed here with existing archaeological knowledge, identifying areas most likely to have hosted these villages. The results provide a renewed perspective on the kingdom’s hinterland during the Late Bronze Age, identifying areas most suitable for village locations based on economic factors and productivity. They also suggest a differentiation in the economic life of these hamlets.

## Structure of the repository

The repository folder is structured as follows:

- **README.md**: This file (repository overview).  
- **R/**: Contains all R scripts for data preparation, analysis, and visualisation.  
  - *data_editing.R*: Prepares the data.
  - *Fuzzyfication.R*: Script to generate the suitability maps.
   *analyses.R*: Performs the analyses presented in the paper.  
  - *FigureX.R*: Six scripts. Each one generates one of the six figures presented in the paper.
  - *SI_figures.R*: Computes the 3 supplementary figures.
  - *Table1.R*: Generates Table 1.
- **data/**: Raw and derived data necessary for the paper.  
  - *raw_data*: Where raw input files are stored (only DEM and TWI are provided).  
  - *derived_data*: Contains processed or derived datasets, including sites.  
- **Figures/**: Contains the 6 figures generated with the scripts provided. 
- **Supplement/**: Contains the 3 supplementary figures generated in the SI_figure.R script.  

### Scripts

Each script in this repository has a brief caption explaining its function. However, only the *analyses.R* script needs to be run to perform the analyses for the paper. Intermediate and final results are provided (suitability and predictive maps). 

#### analyses.R

This is the main script that performs all analyses described in the paper. It is self-contained and structured to run end-to-end. Specifically, it performs two complementary spatial analyses:

1. **PPM-based prediction** — fits a Gibbs point process model (with Strauss interaction) to observed site locations using agricultural suitability covariates, simulates plausible site distributions, and derives a kernel density estimate (KDE) of predicted site intensity.
2. **Suitability-based prediction** — independently generates synthetic point patterns from raw land suitability rasters (cereals, olives, vines) and combines them into a composite suitability surface.

The two predictions are then merged into a final combined output raster.

A **supplementary analysis** replicates the workflow with a modified cereal suitability covariate that incorporates distance from rivers, using a simpler linear PPM due to convergence constraints.

<div style="border: 1px solid #f0ad4e; background-color: #fcf8e3; padding: 1em; border-radius: 5px;">

<strong>⚠️ WARNING</strong>  

Part of the analyses presented here are <strong>computationally demanding</strong>. 

Running them on a machine with insufficient memory or processing power may result in slow performance or crashes. In the script it is indicated when this might happen.

The original analyses were carried out on a system with <strong>128 GB RAM</strong>, and parallel processing was used extensively.
</div>


## Data

### Raw data

The `data/raw_data/` folder originally contained the source files used to prepare the analysis inputs: a Digital Elevation Model (DEM) raster, and shapefiles (.shp) defining the archaeological sites and study area boundary. These were stored into a single GeoPackage for convenience and interoperability (sites.gpkg). Currently, the folder only contains the DEM.

### Input 

All input data should be placed under `data/derived_data/`. The script expects:

| Path | Description |
|---|---|
| `data/derived_data/sites.gpkg` (layer: `sites`) | Point locations of known archaeological sites |
| `data/derived_data/sites.gpkg` (layer: `ugarit`) | Ugarit reference geometry |
| `data/derived_data/sites.gpkg` (layer: `area`) | Study area boundary polygon |
| `data/derived_data/rasters/*.tif` | Covariate rasters: DEM, slope, river distance, and suitability for cereals, olives, and vines |
| `data/derived_data/rasters/extra/suitability_cereals_rivers.tif` | Modified cereal suitability raster for the supplementary analysis |

---

### Output

All output rasters are written to `data/derived_data/`:

| File | Description |
|---|---|
| `dens_prediction.tif` | KDE of simulated site locations (PPM-based) |
| `prediction.tif` | Predicted intensity surface from the fitted PPM |
| `suitability.tif` | Combined land suitability surface |
| `result.tif` | Combined result (KDE + suitability) |
| `result2.tif` | Combined result (PPM intensity + suitability, resampled) |
| `*_SM.tif` | Equivalents for the supplementary analysis |

The raw_data contains the original data used to generate the sites.gpkg:

## Computational Environment

All analyses and code development were conducted on:

- Linux (Ubuntu 22.04.4 LTS, 64-bit): Lenovo ThinkPad P16 Gen 1, 12th Gen Intel Core i7 (24 threads), 128 GB RAM

Code was additionally tested for compatibility on:

- macOS 15.x: MacBook Pro (Apple M4 Pro, 24 GB unified memory)

> **Note:** The parallelisation uses `type = "FORK"`, which is not supported on Windows. Windows users should replace `"FORK"` with `"PSOCK"` throughout the script.

However, see the next section for the full details about the R session and the necessary packages to run all the scripts in this repository.

### Information about the R Session

R version 4.4.3 (2025-02-28)

attached base packages:
[1] splines   stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] spatstat_3.3-2         spatstat.linnet_3.2-5  spatstat.model_3.3-5   rpart_4.1.24           spatstat.explore_3.4-2
 [6] nlme_3.1-167           spatstat.random_3.3-3  spatstat.geom_3.3-6    spatstat.univar_3.1-2  spatstat.data_3.1-6   
[11] whitebox_2.4.0         FuzzyLandscapes_1.0    tmap_4.0              

loaded via a namespace (and not attached):
 [1] DBI_1.3.0               deldir_2.0-4            geodata_0.6-2           tmaptools_3.2           s2_1.1.9               
 [6] logger_0.4.0            rlang_1.1.7             magrittr_2.0.4          envirem_3.1             e1071_1.7-17           
[11] compiler_4.4.3          mgcv_1.9-1              png_0.1-8               vctrs_0.6.5             pkgconfig_2.0.3        
[16] wk_0.9.5                fastmap_1.2.0           lwgeom_0.2-14           leafem_0.2.3            rmarkdown_2.29         
[21] spacesXYZ_1.5-1         xfun_0.52               goftest_1.2-3           palinsol_1.0            spatstat.utils_3.1-3   
[26] terra_1.8-42            parallel_4.4.3          R6_2.6.1                RColorBrewer_1.1-3      pkgload_1.4.0          
[31] stars_0.6-8             Rcpp_1.1.1              knitr_1.50              tensor_1.5              zoo_1.8-14             
[36] base64enc_0.1-3         leaflet.providers_2.0.0 FNN_1.1.4.1             Matrix_1.7-2            tidyselect_1.2.1       
[41] yaml_2.3.10             rstudioapi_0.17.1       dichromat_2.0-0.1       abind_1.4-8             codetools_0.2-20       
[46] lattice_0.22-6          tibble_3.3.0            intervals_0.15.5        leafsync_0.1.0          plyr_1.8.9             
[51] S7_0.2.0                evaluate_1.0.3          RSAGA_1.4.2             foreign_0.8-88          sf_1.1-0               
[56] units_1.0-0             proxy_0.4-29            polyclip_1.10-7         xts_0.14.1              pillar_1.11.1          
[61] KernSmooth_2.23-26      renv_1.1.5              generics_0.1.4          rprojroot_2.0.4         sp_2.2-0               
[66] spacetime_1.3-3         ggplot2_4.0.1           scales_1.4.0            shapefiles_0.7.2        class_7.3-23           
[71] glue_1.8.0              tools_4.4.3             leaflegend_1.2.1        data.table_1.17.0       XML_3.99-0.18          
[76] grid_4.4.3              crosstalk_1.2.1         colorspace_2.1-1        cols4all_0.8            raster_3.6-32          
[81] cli_3.6.5               spatstat.sparse_3.1-0   gstat_2.1-3             viridisLite_0.4.2       dplyr_1.1.4            
[86] gtable_0.3.6            digest_0.6.39           classInt_0.4-11         htmlwidgets_1.6.4       farver_2.1.2           
[91] htmltools_0.5.8.1       lifecycle_1.0.5         leaflet_2.2.2           here_1.0.1              microbenchmark_1.5.0   