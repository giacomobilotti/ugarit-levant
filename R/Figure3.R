#### Code for Figure 3 ----

# create fuzzy sets
source('R/Fuzzyfication.R')

## custom function to plot fuzzy set 
plot_fuzzy <- function(p, xlim, main = '', xlab = '') {
  
  p1 <- p[1]; p2 <- p[2]; p3 <- p[3]; p4 <- p[4]
  
  x <- seq(xlim[1], xlim[2], length = 1000)
  
  y <- ifelse(x <= p1, 0,
              ifelse(x < p2, (x - p1)/(p2 - p1),
                     ifelse(x <= p3, 1,
                            ifelse(x < p4, (p4 - x)/(p4 - p3), 0))))
  
  plot(x, y,
       type = 'l',
       lwd = 3,
       ylim = c(0,1),
       xlim = xlim,
       xlab = xlab,
       ylab = '',
       main = main)
  
  abline(v = p, lty = 2, col = 'grey60')
  abline(h = seq(0,1,.2), lwd = .25)
  
}


tiff(filename = file.path('figures', 'Figure3.tiff'), width = 11, height = 7, res = 300, units = 'in')
par(mfrow = c(3,3), mar = c(3,3,2,1), oma = c(3,4,1,1), mgp = c(1.7,0.5,0))
## Cereals
plot_fuzzy(elev_cer$FuzzificationRules, c(0.1,1000), 'Elevation', '')
plot_fuzzy(slope_cer$FuzzificationRules, c(0.1,35), 'Slope', '')
plot_fuzzy(twi_fuz$FuzzificationRules, c(0,20), 'TWI', '')
## Olives
plot_fuzzy(elev_oli$FuzzificationRules, c(0,1000), '', '')
plot_fuzzy(slope_oli$FuzzificationRules, c(0.1,35), '', '')
plot_fuzzy(twi_fuz$FuzzificationRules, c(0,20), '', '')
## Vines
plot_fuzzy(elev_vin$FuzzificationRules, c(0,1000), '', 'Elevation')
plot_fuzzy(slope_vin$FuzzificationRules, c(0.1,35), '', 'Slope')
plot_fuzzy(twi_fuz$FuzzificationRules, c(0,20), '', 'TWI')

mtext('Cereals', side = 2, line = 0.5, at = 0.83, outer = TRUE)
mtext('Olives', side = 2, line = 0.5, at = 0.50, outer = TRUE)
mtext('Vines', side = 2, line = 0.5, at = 0.17, outer = TRUE)

mtext('Fuzzy Membership', side = 2, line = 2.2, outer = TRUE)
mtext('Environmental variable', side = 1, line = 1.2, outer = TRUE)
dev.off()