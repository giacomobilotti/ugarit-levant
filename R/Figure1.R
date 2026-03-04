#### Code for Figure 1 ----

## Directories and libraries
sourcedir <- file.path('data', 'raw_data')
targetdir <- file.path('data', 'derived_data')

library(tmap)

## load variables
# remotes::install_github("wmgeolab/rgeoboundaries")
syria <- rgeoboundaries::geoboundaries(country = c("Syria"), "adm1") |>
  sf::st_transform(sf::st_crs(area))

levant <- geodata::world(resolution = 2, path = tempdir()) |>
  sf::st_as_sf() |>
  dplyr::filter(NAME_0 %in% c("Syria", "Lebanon", "Turkey", "Iraq", "Israel", "Palestine", "Egypt", "Jordan", "Saudi Arabia", "Cyprus", "Northern Cyprus")) |>
  sf::st_transform(sf::st_crs(area))

sites <- sf::st_read(dsn = file.path(targetdir, "sites.gpkg") ,
                     layer = 'sites')

ugarit <- sf::st_read(dsn = file.path(targetdir, "sites.gpkg") ,
                      layer = 'ugarit')

area <- sf::st_read(dsn = file.path(targetdir, "sites.gpkg") ,
                    layer = 'area')

boundary <- sf::st_bbox(area) |>
  sf::st_as_sfc()

buff <- sf::st_buffer(boundary, dist = 7e5)

dem <- terra::rast(file.path(sourcedir, "dem.tif"))
hill <- terra::shade(terra::terrain(dem, v = "slope", unit = "radians"),
                     terra::terrain(dem, v = "aspect", unit = "radians"))

# # tmap_mode("plot")
tm_main <- tm_shape(sf::st_union(levant[levant$NAME_0 == "Syria" | levant$NAME_0 == "Turkey",])) +
  tm_fill(col = "white") +
  tm_shape(stars::st_as_stars(dem), is.main = TRUE) +
  tm_raster(col.scale = tm_scale_continuous(values = "-brewer.br_bg", midpoint = 200) , 
            col.legend = tm_legend(bg.alpha = 0, title = "Elevation (m asl)")) +
  tm_shape(hill) +
  tm_raster(col_alpha = .25, col.legend = tm_legend(show = FALSE)) +
  tm_shape(ugarit) +
  tm_bubbles(size = 1.5, fill = "red", shape = 19) +
  tm_shape(sites) +
  tm_bubbles(shape = 4, col = "black", size = 1) +
  tm_layout(legend.position = c("LEFT", "BOTTOM"), bg.color = rgb(0,0.2,.8,alpha = .15),
            legend.text.size = 2, legend.title.size = 3, outer.margins = 0) +
  tm_scalebar(position = c("right", "BOTTOM"), text.size = 1.5) +
  tm_compass(position = c("LEFT", "top"), size = 4, text.size = 1.2)

tm_inset <- tm_shape(levant, bbox = sf::st_bbox(buff)) +
  tm_polygons(col = "white") +
  tm_shape(boundary) +
  tm_fill(col = "red", fill_alpha = .5) +
  tm_layout(bg.color = "grey95") +
  tm_scalebar(position = c("right", "BOTTOM"), text.size = 1.5, breaks = c(0,200,400)) +
  tm_compass(position = c("LEFT", "TOP"), size = 3, text.size = 1)

## Combine maps using a viewport
vp <- grid::viewport(width = .25, height = .25, x = .88, y = .908)
# pdf(file = "Figure_1.pdf", width = 7, height = 9.625)
# png(filename = "Figure_1.png", width = 1200, height = 1650)
tiff(filename = file.path('figures', "Figure1.tiff"), width = 1200, height = 1650)
tm_main
print(tm_inset, vp = vp)
dev.off()
