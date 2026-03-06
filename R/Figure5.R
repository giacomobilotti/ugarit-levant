#### Code for Figure 5 ----

## Directories and libraries
targetdir <- file.path('data', 'derived_data')

library(tmap)

## Load rasters 

dem <- terra::rast(file.path(sourcedir, "dem.tif"))
hill <- terra::shade(terra::terrain(dem, v = "slope", unit = "radians"),
                     terra::terrain(dem, v = "aspect", unit = "radians"))

fit_pred <- terra::rast(file.path(targetdir, "prediction.tif"))
rast_pred <- terra::rast(file.path(targetdir, "dens_prediction.tif"))
suit_com <- terra::rast(file.path(targetdir, "suitability.tif"))

pal <- viridisLite::inferno(7)
pal_def <- c('white', pal[2:7])

terra::values(fit_pred) <- ifelse(
  terra::values(fit_pred) < 0.05, NA, terra::values(fit_pred)
)

terra::values(rast_pred) <- ifelse(
  terra::values(rast_pred) < 0.05, NA, terra::values(rast_pred)
)
  
tm_a <- tm_shape(fit_pred) +
  tm_raster(col.scale = tm_scale_intervals(values = pal_def, breaks = c(0,0.05,.1,.25,.5,0.6, 0.75, 1)),
            col.legend = tm_legend(title = "Intensity")) +
  tm_shape(hill) +
  tm_raster(col_alpha = .35, col.scale = tm_scale_continuous(values = 'greys'),
            col.legend = tm_legend(show = FALSE)) +
  tm_shape(ugarit) +
  tm_bubbles(size = .5, fill = "black", shape = 19) +
  tm_layout(legend.position = c("LEFT", "BOTTOM"), title.position = c("LEFT", "TOP"),
            title.size = 3, legend.title.size = 1.5, outer.margins = 0) +
  tm_title("A)") +
  tm_scalebar(position = c('RIGHT', 'BOTTOM'), text.size = 1, breaks = c(0,10,20)) +
  tm_compass(position = c("RIGHT", "top"))

tm_b <- tm_shape(rast_pred) +
  tm_raster(col.scale = tm_scale_intervals(values = pal_def, breaks = c(0,0.05,.1,.25,.5,0.6, 0.75, 1)),
            col.legend = tm_legend(title = "Intensity")) +
  tm_shape(hill) +
  tm_raster(col_alpha = .35, col.scale = tm_scale_continuous(values = 'greys'),
            col.legend = tm_legend(show = FALSE)) +
  tm_shape(ugarit) +
  tm_bubbles(size = .5, fill = "black", shape = 19) +
  tm_layout(legend.position = c("LEFT", "BOTTOM"), title.position = c("LEFT", "TOP"),
            title.size = 3, legend.title.size = 1.5, outer.margins = 0) +
  tm_title("B)") +
  tm_scalebar(position = c('RIGHT', 'BOTTOM'), text.size = 1, breaks = c(0,10,20)) +
  tm_compass(position = c("RIGHT", "top"))


tmap_save(tmap_arrange(tm_a, tm_b), filename = file.path('figures', "Figure5.tiff"), device = tiff,
          height = 7, width = 11, dpi = 300)
