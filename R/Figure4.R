#### Code for Figure 4 ----

## Directories and libraries
targetdir <- file.path('data', 'derived_data')

library(tmap)

area <- sf::st_read(dsn = file.path(targetdir, "sites.gpkg") ,
                    layer = 'area')
## Load covariates 
covars <- sapply(
  strsplit(dir(here::here(targetdir, 'rasters'), '.*tif$'), '\\.'),
  function(x) x[1])[-c(1:4)]

covs <- lapply(
  X = covars,
  FUN = function(covar) {
    terra::rast(here::here(targetdir, "rasters", paste0(covar, ".tif"))) |>
      terra::project(terra::crs(terra::vect(area))) |>
      stars::st_as_stars() 
  })
names(covs) <- c('suitability_cereals', 'suitability_olives', 'suitability_vines')

tm_c <- tm_shape(covs$suitability_cereals) +
  tm_raster(col.scale = tm_scale_continuous(values = 'brewer.yl_gn'),
            col.legend = tm_legend(title = 'Suitability cereals', frame = FALSE) ) +
  tm_layout(legend.position = c('LEFT', 'BOTTOM'), 
            legend.text.size = .6, legend.title.size = .75, outer.margins = 0) +
  tm_scalebar(position = c('right', 'BOTTOM'), text.size = 1, breaks = c(0,10,20)) +
  tm_compass(position = c('LEFT', 'top'), size = 2, text.size = 1)

tm_v <- tm_shape(covs$suitability_vines) +
  tm_raster(col.scale = tm_scale_continuous(values = 'brewer.yl_gn'),
            col.legend = tm_legend(title = 'Suitability vines', frame = FALSE) ) +
  tm_layout(legend.position = c('LEFT', 'BOTTOM'), 
            legend.text.size = .6, legend.title.size = .75, outer.margins = 0) +
  tm_scalebar(position = c('right', 'BOTTOM'), text.size = 1, breaks = c(0,10,20)) +
  tm_compass(position = c('LEFT', 'top'), size = 2, text.size = 1)

tm_o <- tm_shape(covs$suitability_olives) +
  tm_raster(col.scale = tm_scale_continuous(values = 'brewer.yl_gn'),
            col.legend = tm_legend(title = 'Suitability olives', frame = FALSE) ) +
  tm_layout(legend.position = c('LEFT', 'BOTTOM'), 
            legend.text.size = .6, legend.title.size = .75, outer.margins = 0) +
  tm_scalebar(position = c('right', 'BOTTOM'), text.size = 1, breaks = c(0,10,20)) +
  tm_compass(position = c('LEFT', 'top'), size = 2, text.size = 1)


tmap_save(tmap_arrange(tm_c, tm_o, tm_v, ncol = 3), filename = file.path('figures', 'Figure4.tiff'), width = 15, height = 8, units = 'in', dpi = 300)
