### Data editing and creation ---- 

## Directories and libraries
sourcedir <- file.path('data', 'raw_data')
targetdir <- file.path('data', 'derived_data')

## Load sites and covariates for the analyses of the paper

## Sites 
sites <- sf::st_read(dsn = file.path(sourcedir, 'vectors', 'Siti Uniti_No Ugarit.shp')) |>
  sf::st_zm() #|>
# sf::st_transform('EPSG:32636')
ugarit <- sf::st_read(file.path(sourcedir, 'vectors', 'Siti Uniti_con Ugarit.shp')) |>
  sf::st_zm() |>
  dplyr::filter(Name == 'Ugarit') |>
  sf::st_transform(sf::st_crs(sites))

area <- sf::st_read(dsn = file.path(sourcedir, 'ugarit.gpkg'), layer = 'area') |>
  sf::st_transform(sf::st_crs(sites))


## store them into a new GPKG file 

sites$fid <- NULL
ugarit$fid <- NULL

out <- file.path(targetdir, 'sites.gpkg')

sf::st_write(sites, out, layer = 'sites', append = FALSE)
sf::st_write(ugarit, out, layer = 'ugarit', append = FALSE)
sf::st_write(area, out, layer = 'area', append = FALSE)
