#!/bin/env Rscript
library(ggplot2)
library(data.table)
library(cowplot)
library(sqldf)
library(this.path)
library(tikzDevice)
library(RColorBrewer)

setwd(paste0(this.dir(), "/.."))

theme_tex <- theme(plot.margin = unit(c(0, 2, .5, .5), "mm"), strip.text = element_text(size = 6),
                      legend.spacing.y = unit(c(-.5), "mm"),
                      axis.text.x = element_text(size = 6, margin = margin(1, 1, 1, 1)),
                      axis.text.y = element_text(size = 6, margin = margin(1, 1, 1, 1)),
                      axis.title.x = element_text(size = 8, margin = margin(1, 1, 1, 1)),
                      axis.title.y = element_text(size = 8, margin = margin(1, 1, 1, 1)),
                      legend.text = element_text(size = 6), legend.title = element_text(size = 8),
                      legend.margin = margin(-.5, 0, 0, 0, "cm"),
                      legend.background = element_rect(fill = "white", size = 0.5, linetype = "solid"))

second_labels <- function(y) {
  lapply(y, function(x) {
    if (is.na(x)) return("")
    if (x < 1)
      return(paste(x * 1000, "ms", sep = ' '))
    else
      return(paste(x, "s", sep = ' '))
  })
}

dbms <- fread('data/dbs.csv')
dbms$DBMS <- factor(dbms$DBMS, levels = c('MariaDB', 'DuckDB', 'Hyper', 'PostgreSQL', 'Umbra', 'SQLite', 'Umbra Execution Only'))

max <- sqldf('
SELECT * FROM dbms
WHERE time IN (
  SELECT max(time)
  FROM dbms
  GROUP BY DBMS
)
ORDER BY DBMS
')
max$xshift = c(1.1, -.25, -0.05, 0.5, -0.25, 1.1, 1)
max$yshift = c(  0,  .75, -0.4, -0.4,     0,   0, 5)


tikz(file = "images/dbmsComparison.tikz", width = 3.2, height = 1.8)
ggplot(data = dbms, aes(x = Joins, y = Time / 1000, color = DBMS, shape = DBMS)) +
  geom_point() +
  geom_smooth(formula = y ~ x, method = 'loess', se = FALSE) +
  geom_label(data = max, label.size = NA, label.padding = unit(.2, "mm"), aes(x = Joins, y = Time / 1000, label = DBMS, hjust = xshift, vjust = yshift), size = 2) +
  annotate("segment", x = 800, xend = 950, y = 0.0015, yend = 0.0008,
           colour = "black", size = 1, arrow = arrow(angle = 40, length = unit(.2,"cm"))) +
  annotate("label", label.size = NA, label.padding = unit(.2, "mm"), x = 620, y = 0.001, size = 2, label = "better") +
  theme_minimal_grid() +
  theme_tex +
  panel_border() +
  labs(x = "Number of Joins [log]", y = "Total Time [log]") +
  scale_color_brewer(type = "qual", palette = 7) +
  scale_shape_manual(values = seq(0, 15)) +
  scale_x_log10(expand = expansion(mult = c(.01, .01)),
                breaks = c(10, 100, 1000), minor_breaks = c(2, 3, 4, 5, 6, 7, 8, 9,
                                                         20, 30, 40, 50, 60, 70, 80, 90,
                                                         200, 300, 400, 500, 600, 700, 800, 900)) + 
  scale_y_log10(expand = expansion(mult = c(.01, .01)), labels = second_labels,
                breaks = c(0.001, 0.01, 0.1, 1, 10, 100), minor_breaks = c(0.0002, 0.0003, 0.0004, 0.0005, 0.0006, 0.0007, 0.0008, 0.0009,
                                                                    0.002, 0.003, 0.004, 0.005, 0.006, 0.007, 0.008, 0.009,
                                                                    0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09,
                                                                    0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9,
                                                                    2, 3, 4, 5, 6, 7, 8, 9,
                                                                    20, 30, 40, 50, 60, 70, 80, 90,
                                                                    200, 300, 400, 500, 600, 700, 800, 900)) +
  theme(panel.grid.minor = element_line(size = .1)) +
  theme(legend.position="none")
dev.off()

# Calculate the mean time spent in execution
cat("\nUmbra average percentage of time in query optimization:\n")
sqldf("
select avg(exec.time / total.time)
from dbms total, dbms exec
where total.joins = exec.joins
  and total.DBMS = 'Umbra'
  and exec.DBMS = 'Umbra Execution Only'
")

