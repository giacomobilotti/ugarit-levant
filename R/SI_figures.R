#### Code for SM figures ----

## Directories and libraries
sourcedir <- file.path('data', 'raw_data')
targetdir <- file.path('data', 'derived_data')

library(tmap)

## load variables
ugarit <- sf::st_read(dsn = file.path(targetdir, 'sites.gpkg') ,
                      layer = 'ugarit')

area <- sf::st_read(dsn = file.path(targetdir, 'sites.gpkg') ,
                    layer = 'area')

dem <- terra::rast(file.path(sourcedir, 'dem.tif'))
hill <- terra::shade(terra::terrain(dem, v = 'slope', unit = 'radians'),
                     terra::terrain(dem, v = 'aspect', unit = 'radians'))

fit_pred <- terra::rast(file.path(targetdir, 'prediction_SM.tif'))
suit_com <- terra::rast(file.path(targetdir, 'suitability_SM.tif'))
res <- terra::rast(file.path(targetdir, 'result_SM.tif'))
rast_pred <- terra::rast(file.path(targetdir, 'dens_prediction_SM.tif'))
res2 <- terra::rast(file.path(targetdir, 'result2.tif'))
cereals <- terra::rast(file.path(targetdir, 'rasters', 'extra', 'suitability_cereals_rivers.tif'))

## Edit variables
terra::values(fit_pred) <- ifelse(
  terra::values(fit_pred) < 0.05, NA, terra::values(fit_pred)
)
terra::values(rast_pred) <- ifelse(
  terra::values(rast_pred) < 0.05, NA, terra::values(rast_pred)
)
terra::values(suit_com) <- ifelse(
  terra::values(suit_com) < 0.05, NA, terra::values(suit_com)
)
terra::values(res) <- ifelse(
  terra::values(res) < 0.05, NA, terra::values(res)
)
terra::values(res2) <- ifelse(
  terra::values(res2) < 0.05, NA, terra::values(res2)
)


## Cereal suitability SM ----
# Compare it to Fig. 4A
tm_cer_sm <- tm_shape(area) +
  tm_fill(col = 'white') +
  tm_shape(cereals) +
  tm_raster(col.legend = tm_legend(title = 'Suitability Cereals'), col.scale = tm_scale_continuous(values = 'brewer.yl_gn')) +
  tm_layout(legend.position = tm_pos_auto_out(), outer.margins = 0) +
  tm_scalebar(position = c('RIGHT', 'BOTTOM'), text.size = .85, breaks = c(0,10,20)) +
  tm_compass(position = c('LEFT', 'TOP'))

# save
tmap_save(tm_cer_sm, filename = file.path('Supplement', 'SM_1.png'), device = png, dpi = 300)
# tmap_save(tm_cer_sm, filename = file.path('Supplement', 'SM_1.tif'), device = tiff, dpi = 300)

## Predicted surfaces SM ----
# Site location likelihood based on known site location and agricultural suitability.
# Compared to Fig. 5, the new suitability for cereals is used here

pal <- viridisLite::inferno(7)
pal_def <- c(adjustcolor(pal[2], alpha.f = .25), pal[2:7])

# Conditional intensity of the fitted point process model (PPM)
pred_plot <- fit_pred
tm_a_sm <- tm_shape(pred_plot) +
  tm_raster(col.legend = tm_legend(title = 'Intensity'), 
            col.scale = tm_scale_intervals(breaks = c(0,0.05,.1,.25,.5,0.6, 0.75, 1),
                                           values = pal_def)) +
  tm_shape(hill) +
  tm_raster(col_alpha = .35, col.scale = tm_scale_continuous(values = 'greys'),
            col.legend = tm_legend(show = FALSE)) +
  tm_shape(ugarit) +
  tm_bubbles(size = .5, fill = 'black', shape = 19) +
  tm_layout(legend.position = c('LEFT', 'BOTTOM'), legend.title.size = 1.5, outer.margins = 0) +
  tm_title('A)',position = tm_pos_in('LEFT', 'TOP'), size = 2.5) +
  tm_scalebar(position = c('RIGHT', 'BOTTOM'), text.size = .85, breaks = c(0,10,20)) +
  tm_compass(position = c('RIGHT', 'TOP'))

# KDE of 99 simulated realisations of the PPM fitted to the data
pred_plot2 <- rast_pred
tm_b_sm <- tm_shape(pred_plot2) +
  tm_raster(col.legend = tm_legend(title = 'Intensity'), 
            col.scale = tm_scale_intervals(breaks = c(0,0.05,.1,.25,.5,0.6, 0.75, 1),
                                           values = pal_def)) +
  tm_shape(hill) +
  tm_raster(col_alpha = .35, col.scale = tm_scale_continuous(values = 'greys'),
            col.legend = tm_legend(show = FALSE)) +
  tm_shape(ugarit) +
  tm_bubbles(size = .5, fill = 'black', shape = 19) +
  tm_layout(legend.show = FALSE, outer.margins = 0) +
  tm_title('B)',position = tm_pos_in('LEFT', 'TOP'), size = 2.5) +
  tm_scalebar(position = c('RIGHT', 'BOTTOM'), text.size = .85, breaks = c(0,10,20)) +
  tm_compass(position = c('RIGHT', 'TOP'))

# save
tmap_save(tmap_arrange(tm_a_sm, tm_b_sm), filename = file.path('Supplement', 'SM_2.png'),
          device = png, height = 7, width = 11, dpi = 300)
# tmap_save(tmap_arrange(tm_a_sm, tm_b_sm), filename = file.path('Supplement', 'SM_2.tif'),
#            device = tiff, height = 7, width = 11, dpi = 300)

## Combine agricultural productivity with known site location ----
# This image is similar to Fig. 6 C-D but uses the new suitability for cereals
# suitability (shown in Fig. 6B) + SM2 A
res_plot2 <- res2
tm_a2_sm <- tm_shape(res_plot2) +
  tm_raster(col.legend = tm_legend(title = 'Intensity'), 
            col.scale = tm_scale_intervals(breaks = c(0,0.05,.1,.25,.5,0.6, 0.75, 1),
                                           values = pal_def)) +
  tm_shape(hill) +
  tm_raster(col_alpha = .35, col.scale = tm_scale_continuous(values = 'greys'),
            col.legend = tm_legend(show = FALSE)) +
  tm_shape(ugarit) +
  tm_bubbles(size = .5, fill = 'black', shape = 19) +
  tm_layout(legend.position = c('LEFT', 'BOTTOM'), legend.title.size = 1.5, outer.margins = 0) +
  tm_title('A)',position = tm_pos_in('LEFT', 'TOP'), size = 2.5) +
  tm_scalebar(position = c('RIGHT', 'BOTTOM'), text.size = .85, breaks = c(0,10,20)) +
  tm_compass(position = c('RIGHT', 'TOP'))

# suitability (shown in Fig. 6B) + SM2 B
res_plot <- res
tm_b2_sm <- tm_shape(res_plot) +
  tm_raster(col.legend = tm_legend(title = 'Intensity'), 
            col.scale = tm_scale_intervals(breaks = c(0,0.05,.1,.25,.5,0.6, 0.75, 1),
                                           values = pal_def)) +
  tm_shape(hill) +
  tm_raster(col_alpha = .35, col.scale = tm_scale_continuous(values = 'greys'),
            col.legend = tm_legend(show = FALSE)) +
  tm_shape(ugarit) +
  tm_bubbles(size = .5, fill = 'black', shape = 19) +
  tm_layout(legend.show = FALSE, outer.margins = 0) +
  tm_title('B)',position = tm_pos_in('LEFT', 'TOP'), size = 2.5) +
  tm_scalebar(position = c('RIGHT', 'BOTTOM'), text.size = .85, breaks = c(0,10,20)) +
  tm_compass(position = c('RIGHT', 'TOP'))

tmap_save(tmap_arrange(tm_a2_sm, tm_b2_sm), filename = file.path('Supplement', 'SM_combined.png'), device = png,
          height = 7, width = 11, dpi = 300)
# tmap_save(tmap_arrange(tm_a2_sm, tm_b2_sm), filename = file.path('Supplement', 'SM_combined.tif'), device = tiff,
#           height = 7, width = 11, dpi = 300)
