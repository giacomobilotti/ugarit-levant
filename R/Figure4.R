#### Code for Figure 4 ----

## Directories and libraries
targetdir <- file.path('data', 'derived_data')

library(tmap)

## Load covariates 
covars <- sapply(
  strsplit(dir(here::here(targetdir, 'rasters'), '.*tif$'), '\\.'),
  function(x) x[1])[-c(1:4)]

covs <- lapply(
  X = covars,
  FUN = function(covar) {
    terra::rast(here::here(targetdir, 'rasters', paste0(covar, '.tif'))) |>
      terra::project(terra::crs(terra::vect(area))) |>
      stars::st_as_stars() 
  })
names(covs) <- c('suitability_cereals', 'suitability_olives', 'suitability_vines')

## normalize vines
covs$suitability_vines$Suitability_Vines <- covs$suitability_vines$Suitability_Vines/max(covs$suitability_vines$Suitability_Vines, na.rm = TRUE)

tm_c <- tm_shape(covs$suitability_cereals) +
  tm_raster(col.scale = tm_scale_continuous(values = 'brewer.yl_gn'),
            col.legend = tm_legend(title = 'Suitability cereals') ) +
  tm_layout(legend.position = c('LEFT', 'BOTTOM'), 
            legend.text.size = 1, legend.title.size = 2, outer.margins = 0) +
  tm_scalebar(position = c('right', 'BOTTOM'), text.size = 1.5, breaks = c(0,10,20)) +
  tm_compass(position = c('LEFT', 'top'), size = 4, text.size = 1.2)

tm_v <- tm_shape(covs$suitability_vines) +
  tm_raster(col.scale = tm_scale_continuous(values = 'brewer.yl_gn'),
            col.legend = tm_legend(title = 'Suitability vines') ) +
  tm_layout(legend.position = c('LEFT', 'BOTTOM'), 
            legend.text.size = 1, legend.title.size = 2, outer.margins = 0) +
  tm_scalebar(position = c('right', 'BOTTOM'), text.size = 1.5, breaks = c(0,10,20)) +
  tm_compass(position = c('LEFT', 'top'), size = 4, text.size = 1.2)

tm_o <- tm_shape(covs$suitability_olives) +
  tm_raster(col.scale = tm_scale_continuous(values = 'brewer.yl_gn'),
            col.legend = tm_legend(title = 'Suitability olives') ) +
  tm_layout(legend.position = c('LEFT', 'BOTTOM'), 
            legend.text.size = 1, legend.title.size = 2, outer.margins = 0) +
  tm_scalebar(position = c('right', 'BOTTOM'), text.size = 1.5, breaks = c(0,10,20)) +
  tm_compass(position = c('LEFT', 'top'), size = 4, text.size = 1.2)

tiff(filename = file.path('figures', 'Figure4.tiff'), width = 2400, height = 1200)
tmap_arrange(tm_c, tm_o, tm_v, ncol = 3)
dev.off()