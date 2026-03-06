#### Code for Figure 6 ----

## Directories and libraries
targetdir <- file.path('data', 'derived_data')
sourcedir <- file.path('data', 'raw_data')

library(tmap)

## Load rasters 

dem <- terra::rast(file.path(sourcedir, "dem.tif"))
hill <- terra::shade(terra::terrain(dem, v = "slope", unit = "radians"),
                     terra::terrain(dem, v = "aspect", unit = "radians"))

suit_com <- terra::rast(file.path(targetdir, "suitability.tif"))
suit_com2 <- terra::rast(file.path(targetdir, "suitability_SM.tif"))
res <- terra::rast(file.path(targetdir, "result.tif"))
res2 <- terra::rast(file.path(targetdir, "result2.tif"))

# load ugarit location
ugarit <- sf::st_read(dsn = file.path(targetdir, "sites.gpkg") ,
                      layer = 'ugarit')

# plot
pal <- viridisLite::inferno(7)
pal_def <- c('white', pal[2:7])


terra::values(suit_com) <- ifelse(
  terra::values(suit_com) < 0.05, NA, terra::values(suit_com)
)
terra::values(suit_com2) <- ifelse(
  terra::values(suit_com2) < 0.05, NA, terra::values(suit_com2)
)
terra::values(res) <- ifelse(
  terra::values(res) < 0.05, NA, terra::values(res)
)
terra::values(res2) <- ifelse(
  terra::values(res2) < 0.05, NA, terra::values(res2)
)

tm_a <- tm_shape(suit_com) +
  tm_raster(col.scale = tm_scale_intervals(values = pal_def, breaks = c(0,0.05,.1,.25,.5,0.6, 0.75, 1)),
            col.legend = tm_legend(title = "Intensity", frame = FALSE)) +
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

tm_b <- tm_shape(suit_com2) +
  tm_raster(col.scale = tm_scale_intervals(values = pal_def, breaks = c(0,0.05,.1,.25,.5,0.6, 0.75, 1)),
            col.legend = tm_legend(title = "Intensity", frame = FALSE)) +
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

tm_c <- tm_shape(res2) +
  tm_raster(col.scale = tm_scale_intervals(values = pal_def, breaks = c(0,0.05,.1,.25,.5,0.6, 0.75, 1)),
            col.legend = tm_legend(title = "Intensity", frame = FALSE)) +
  tm_shape(hill) +
  tm_raster(col_alpha = .35, col.scale = tm_scale_continuous(values = 'greys'),
            col.legend = tm_legend(show = FALSE)) +
  tm_shape(ugarit) +
  tm_bubbles(size = .5, fill = "black", shape = 19) +
  tm_layout(legend.position = c("LEFT", "BOTTOM"), title.position = c("LEFT", "TOP"),
            title.size = 3, legend.title.size = 1.5, outer.margins = 0) +
  tm_title("C)") +
  tm_scalebar(position = c('RIGHT', 'BOTTOM'), text.size = 1, breaks = c(0,10,20)) +
  tm_compass(position = c("RIGHT", "top"))

tm_d <- tm_shape(res) +
  tm_raster(col.scale = tm_scale_intervals(values = pal_def, breaks = c(0,0.05,.1,.25,.5,0.6, 0.75, 1)),
            col.legend = tm_legend(title = "Intensity", frame = FALSE)) +
  tm_shape(hill) +
  tm_raster(col_alpha = .35, col.scale = tm_scale_continuous(values = 'greys'),
            col.legend = tm_legend(show = FALSE)) +
  tm_shape(ugarit) +
  tm_bubbles(size = .5, fill = "black", shape = 19) +
  tm_layout(legend.position = c("LEFT", "BOTTOM"), title.position = c("LEFT", "TOP"),
            title.size = 3, legend.title.size = 1.5, outer.margins = 0) +
  tm_title("D)") +
  tm_scalebar(position = c('RIGHT', 'BOTTOM'), text.size = 1, breaks = c(0,10,20)) +
  tm_compass(position = c("RIGHT", "top"))

tmap_save(tmap_arrange(tm_a, tm_b, tm_c, tm_d), filename = file.path('figures', "Figure6.tiff"), device = tiff,
          height = 12, width = 11, dpi = 300)
