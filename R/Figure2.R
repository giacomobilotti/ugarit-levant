### Code for figure 2 ----

settl_dens <- data.frame(
  Group   = paste0('Group ', 1:8),
  Density = c(38, 8, 11, 7, 16, 7, 9, 5) # note that values are rounded to unit and sum to 101
)

tiff(filename = file.path('figures', 'Figure2.tiff'), width = 9, height = 5, res = 1200, units = 'in')
bp <- barplot(
  height     = settl_dens$Density,
  names.arg  = settl_dens$Group,
  col        = 'steelblue',
  border     = NA,
  main       = 'Settlement Density',
  xlab       = '',
  ylab       = 'Density',
  las        = 1,
  ylim       = c(0, max(settl_dens$Density) * 1.2)
)

# Add value and percentage labels on top of each bar
text(
  x      = bp,
  y      = settl_dens$Density + max(settl_dens$Density) * 0.05,
  labels = paste0(settl_dens$Density, '%'),
  cex    = 0.85,
  font   = 2,
  col    = 'black'
)
dev.off()