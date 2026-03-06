#### Fuzzy map creation ----

# Load libraries 
# if(!require('devtools')) install.packages('devtools')
# devtools::install_git('https://gitlab.com/CRC1266-A2/FuzzyLandscapes.git')
library(FuzzyLandscapes)

# set up directories
targetdir <- file.path('data', 'derived_data')
sourcedir <- file.path('data', 'raw_data')

# load rasters
dem <- terra::rast(file.path(sourcedir, 'dem.tif'))
terra::terrain(dem, v = 'slope', filename = file.path(targetdir, 'rasters', 'slope.tif'))
slope <- terra::terrain(file.path(targetdir, 'rasters', 'slope.tif'))
twi <- terra::rast(file.path(sourcedir, 'dem.tif'))

library(whitebox)
# If installing/using whitebox for the first time
# install_whitebox()
whitebox::wbt_init()


wbt_d_inf_flow_accumulation(input = file.path(sourcedir, 'dem.tif'),
                            output = file.path(sourcedir, 'flow.tif'),
                            out_type = 'Specific Contributing Area')

wbt_wetness_index(sca = file.path(sourcedir, 'flow.tif'),
                  slope = file.path(targetdir, 'rasters', 'slope.tif'),
                  output = file.path(sourcedir, 'twi.tif'))

twi <- terra::rast(file.path(sourcedir, 'twi.tif'))

### SLOPE L-shaped membership function: Fuzzy set 0-15% 
elev_cer <- fl_create_ras(
  method = 'trapezoid',
  rast   = dem, 
  p1 = 0,
  p2 = 0,
  p3 = 300,
  p4 = 350
)

slope_cer <- fl_create_ras(
  method = 'trapezoid',
  rast   = slope, 
  p1 = 0,
  p2 = 0,
  p3 = 15,
  p4 = 20
)

# this is the same for all
twi_fuz <- fl_create_ras(
  method = 'trapezoid',
  rast   = twi, 
  p1 = 3,
  p2 = 6,
  p3 = 11,
  p4 = 15
)

### Olives

elev_oli <- fl_create_ras(
  method = 'trapezoid',
  rast   = dem, 
  p1 = 250,
  p2 = 300,
  p3 = 600,
  p4 = 650
)

slope_oli <- fl_create_ras(
  method = 'trapezoid',
  rast   = slope, 
  p1 = 0,
  p2 = 0,
  p3 = 20,
  p4 = 25
)

### Viens

elev_vin <- fl_create_ras(
  method = 'trapezoid',
  rast   = dem, 
  p1 = 150,
  p2 = 200,
  p3 = 700,
  p4 = 750
)

slope_vin <- fl_create_ras(
  method = 'trapezoid',
  rast   = slope, 
  p1 = 0,
  p2 = 0,
  p3 = 25,
  p4 = 30
)

### Combine memberships into suitability maps ----

# use algebraic sum:
# ( 'Elevation' + 'TWI' + 'Slope' ) - ( 'Elevation' * 'Slope' * 'TWI' )

cer_fuzzy <- (elev_cer$FuzzyRaster + twi_fuz$FuzzyRaster + slope_cer$FuzzyRaster) -
  (elev_cer$FuzzyRaster * slope_cer$FuzzyRaster * twi_fuz$FuzzyRaster)

oli_fuzzy <- (elev_oli$FuzzyRaster + twi_fuz$FuzzyRaster + slope_oli$FuzzyRaster) -
  (elev_oli$FuzzyRaster * slope_oli$FuzzyRaster * twi_fuz$FuzzyRaster)

vin_fuzzy <- (elev_vin$FuzzyRaster + twi_fuz$FuzzyRaster + slope_vin$FuzzyRaster) -
  (elev_vin$FuzzyRaster * slope_vin$FuzzyRaster * twi_fuz$FuzzyRaster)

# normalise
cer_fuzzy <- cer_fuzzy / 2
oli_fuzzy <- oli_fuzzy / 2
vin_fuzzy <- vin_fuzzy / max(vin_fuzzy)
# save
terra::writeRaster(cer_fuzzy, filename = file.path(targetdir, 'rasters', 'Suitability_Cereals.tif'))
terra::writeRaster(oli_fuzzy, filename = file.path(targetdir, 'rasters', 'Suitability_Olives.tif'))
terra::writeRaster(vin_fuzzy, filename = file.path(targetdir, 'rasters', 'Suitability_Vines.tif'))

#### Cereal suitability with irrigation ----

# load rivers
rivers <- terra::rast(file.path(targetdir, 'rasters', 'rivers_distance.tif')) |>
  terra::project(dem, method = 'bilinear')

# if you# if you# if you want to create it yourself you need a raster with the rivers and run:
# terra::distance(riv_rast) 

# Fuzzify
riv_cer <- fl_create_ras(method = 'trapezoid',
                          rast = rivers, 
                          p1 = 0,
                          p2 = 0,
                          p3 = 250,
                          p4 = 300,
                          setname = 'Rivers')

cer_fuzzy <- (elev_cer$FuzzyRaster + twi_fuz$FuzzyRaster + slope_cer$FuzzyRaster + riv_cer$FuzzyRaster) -
  (elev_cer$FuzzyRaster * slope_cer$FuzzyRaster * twi_fuz$FuzzyRaster * riv_cer$FuzzyRaster)
cer_fuzzy <- cer_fuzzy / 3
# save
terra::writeRaster(cer_fuzzy, filename = file.path(targetdir, 'rasters', 'extra',  'suitability_cereals_rivers.tif'))