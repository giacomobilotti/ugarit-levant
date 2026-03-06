#### Code for table 1 ----

targetdir <- file.path('data', 'derived_data')

# load sites
sites <- sf::st_read(dsn = file.path(targetdir, "sites.gpkg") ,
                     layer = 'sites') |>
  sf::st_transform(4326)

df <- data.frame(
  Site       = sites$Name,
  Easting    = sf::st_coordinates(sites)[,1],
  Northing   = sf::st_coordinates(sites)[,2]
)

# order them (N to S)
df <- df[order(df$Northing, decreasing = TRUE),]
# save
write.csv(df, file.path(targetdir, 'table1.csv'), row.names = FALSE)
