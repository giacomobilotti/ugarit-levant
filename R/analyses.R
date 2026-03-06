#### Script to carry out the analyses presented in the paper ----

## Directories and libraries
targetdir <- file.path("data", "derived_data")

library(spatstat)
library(splines) 

## Load sites and area 
sites <- sf::st_read(dsn = file.path(targetdir, "sites.gpkg") ,
                     layer = 'sites')
                     
ugarit <- sf::st_read(dsn = file.path(targetdir, "sites.gpkg") ,
                      layer = 'ugarit')

area <- sf::st_read(dsn = file.path(targetdir, "sites.gpkg") ,
                    layer = 'area')

## Load covariates (DEM, slope, distance from rivers and the three suitabilities)
covars <- sapply(
  strsplit(dir(here::here(targetdir, "rasters"), ".*tif$"), "\\."),
  function(x) x[1])[-2]

# Make sure you can parallelise on your machine
# On windows use: type = 'PSOK'
clus <- parallel::makeCluster(6, type = "FORK")
covs <- parallel::parLapply(
  cl = clus,
  X = covars,
  fun = function(covar) {
    terra::rast(here::here(targetdir, "rasters", paste0(covar, ".tif"))) |>
      terra::project(terra::crs(terra::vect(area))) |>
      stars::st_as_stars() |>
      as.im()
  })
parallel::stopCluster(clus)
names(covs) <- c("elevation", "rivers", "slope", "suitability_cereals", "suitability_olives", "suitability_vines")

#### ppm-prediction

## convert sites to ppp object (spatstat)
sites_ppp <- ppp(
  x = sf::st_coordinates(sites)[,1],
  y = sf::st_coordinates(sites)[,2],
  window = as.owin(area)
)

rr <- data.frame(r = seq(2000, 5900, by=100))
ps <- profilepl(rr, Strauss, sites_ppp)

# plot(ps, main = "Optimal r for Strauss PP")
# 5000 m

## Fit a non-linear ppm model (GAM model)
fit <- ppm(sites_ppp ~ bs(suitability_vines, 3) + bs(suitability_olives, 3) +
             bs(suitability_cereals, 3), Strauss(5000), data = covs, use.gam = TRUE) 
# as we are interested in site intensiy, use that parameter 

## Creat a predicted raster
fit_int <- predict(fit, type= "intensity", eps = 100)/max(predict(fit, type= "intensity", eps = 100))

## Simulate possible site location. Do it 99 times
# Parallelisation with parallel package optimised for Linux machines, change according to your needs or do not parallelise.
set.seed(123)
seeds <- sample(1:1e3, size = 99)
clus <- parallel::makeCluster(parallel::detectCores() / 2, type = "FORK")
sim_pts <- parallel::parLapply(
  cl = clus, 
  X = seeds,
  fun = function(seed){
    set.seed(seed = seed)
    tmp <- spatstat.geom::superimpose(spatstat.model::rmh.ppm(fit, nsim = 10), sites_ppp)
    return(tmp)
  }
)
parallel::stopCluster(clus)
names(sim_pts) <- paste0("sim_", 1:length(sim_pts))

## Use the simulated points to compute KDE
clus <- parallel::makeCluster(parallel::detectCores() / 3, type = "FORK")
dens <- parallel::parLapply(
  cl = clus,
  X = sim_pts,
  fun = function(sim){
    tmp_dens <- density.ppp(sim, sigma = 2000, eps = 100)
    tmp_scaled <- tmp_dens/max(tmp_dens)
    return(tmp_scaled)
  })
parallel::stopCluster(clus)

dens_fit <- Reduce(f = function(x,y) {x + y}, x = dens)
dens_fit <- dens_fit/max(dens_fit)

# convert the results to raster (terra) 
rast_pred <- stars::st_as_stars(dens_fit) |>
  sf::st_set_crs("EPSG:3857")
# save
stars::write_stars(obj = rast_pred, dsn = file.path(targetdir, "dens_prediction.tif"))

## The simulation might serve to compute site catchments for further analyses
## It does not serve to compute "site distribution" as the predict(fit) serves the same purpose

## Now predict sites solely based on land suitability
clus <- parallel::makeCluster(3, type = "FORK")
suit_pred <- parallel::parLapply(
  cl = clus,
  X = covs[4:6],
  fun = function(cov){
    tmp_pp <- rpoispp(cov, lmax = 1, win = as.owin(area), forcewin = TRUE)
    tmp_subpp <- sample(1:tmp_pp$n, 200)
    tmp_pp <- ppp(x = tmp_pp$x[tmp_subpp], y = tmp_pp$y[tmp_subpp], window = as.owin(area))
    tmp_dens <- density.ppp(tmp_pp, sigma = 2000, eps = 100)
    tmp_scaled <- tmp_dens/max(tmp_dens)
    return(tmp_scaled)
  })
parallel::stopCluster(clus)

suit_com <- Reduce(f = function(x, y) {x+y}, x = suit_pred)
suit_com <- suit_com/max(suit_com)

suit_com <- stars::st_as_stars(suit_com) |>
  sf::st_set_crs("EPSG:3857")

res <- (rast_pred + suit_com)/max((rast_pred + suit_com)$v, na.rm = T)

fit_pred <- stars::st_as_stars(fit_int) |>
  sf::st_set_crs("EPSG:3857")

res2 <- (terra::resample(terra::rast(fit_pred), terra::rast(suit_com)) + terra::rast(suit_com))/max(terra::values((terra::resample(terra::rast(fit_pred), terra::rast(suit_com)) + terra::rast(suit_com))), na.rm = T)

## save results
stars::write_stars(obj = fit_pred, dsn = file.path(targetdir, "prediction.tif"))
stars::write_stars(obj = suit_com, dsn = file.path(targetdir, "suitability.tif"))
stars::write_stars(obj = res, dsn = file.path(targetdir, "result.tif"))
terra::writeRaster(res2, file.path(targetdir, "result2.tif"), overwrite = TRUE)

## Supplementary analysis ----
## Rerun the same but considering distance from rivers as an additional covariate

covs$suitability_cereals <- terra::rast(file.path(targetdir, "rasters", "extra", "suitability_cereals_rivers.tif")) |>
  terra::project(terra::crs(terra::vect(area))) |>
  stars::st_as_stars() |>
  as.im()

## The GLM does not converge with this set up. Therefore we apply a simple PPM, without accounting for clustering

fit <- ppm(sites_ppp ~ suitability_vines + suitability_olives +
             suitability_cereals, data = covs)
# as we are interested in site intensiy, use that parameter

fit_int <- predict(fit, type= "intensity", eps = 100)/max(predict(fit, type= "intensity", eps = 100))

set.seed(123)
seeds <- sample(1:1e3, size = 99)
clus <- parallel::makeCluster(parallel::detectCores() / 2, type = "FORK")
sim_pts <- parallel::parLapply(
  cl = clus,
  X = seeds,
  fun = function(seed){
    set.seed(seed = seed)
    tmp <- spatstat.geom::superimpose(spatstat.model::rmh.ppm(fit, nsim = 10), sites_ppp)
    return(tmp)
  }
)
parallel::stopCluster(clus)
names(sim_pts) <- paste0("sim_", 1:length(sim_pts))

clus <- parallel::makeCluster(parallel::detectCores() / 3, type = "FORK")
dens <- parallel::parLapply(
  cl = clus,
  X = sim_pts,
  fun = function(sim){
    tmp_dens <- density.ppp(sim, sigma = 2000, eps = 100)
    tmp_scaled <- tmp_dens/max(tmp_dens)
    return(tmp_scaled)
  })
parallel::stopCluster(clus)

dens_fit <- Reduce(f = function(x,y) {x + y}, x = dens)
dens_fit <- dens_fit/max(dens_fit)

rast_pred <- stars::st_as_stars(dens_fit) |>
  sf::st_set_crs("EPSG:3857")

stars::write_stars(obj = rast_pred, dsn = file.path(targetdir, "dens_prediction_SM.tif"))

## Now predict sites solely based on land suitability

suit_pred <- lapply(
  X = covs[4:6],
  FUN = function(cov){
    tmp_pp <- rpoispp(cov, lmax = 1, win = as.owin(area), forcewin = TRUE)
    tmp_subpp <- sample(1:tmp_pp$n, 200)
    tmp_pp <- ppp(x = tmp_pp$x[tmp_subpp], y = tmp_pp$y[tmp_subpp], window = as.owin(area))
    tmp_dens <- density.ppp(tmp_pp, sigma = 2000, eps = 100)
    tmp_scaled <- tmp_dens/max(tmp_dens)
    return(tmp_scaled)
  })

suit_com <- Reduce(f = function(x, y) {x+y}, x = suit_pred)
suit_com <- suit_com/max(suit_com)

suit_com <- stars::st_as_stars(suit_com) |>
  sf::st_set_crs("EPSG:3857")

res <- (rast_pred + suit_com)/max((rast_pred + suit_com)$v, na.rm = T)

fit_pred <- stars::st_as_stars(fit_int) |>
  sf::st_set_crs("EPSG:3857")

res2 <- (terra::resample(terra::rast(fit_pred), terra::rast(suit_com)) + terra::rast(suit_com))/max(terra::values((terra::resample(terra::rast(fit_pred), terra::rast(suit_com)) + terra::rast(suit_com))), na.rm = T)

## save results
stars::write_stars(obj = fit_pred, dsn = file.path(targetdir, "prediction_SM.tif"))
stars::write_stars(obj = suit_com, dsn = file.path(targetdir, "suitability_SM.tif"))
stars::write_stars(obj = res, dsn = file.path(targetdir, "result_SM.tif"))
terra::writeRaster(res2, file.path(targetdir, "result2_SM.tif"), overwrite = TRUE)