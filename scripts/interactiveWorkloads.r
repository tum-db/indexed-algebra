#!/bin/env Rscript
library(ggplot2)
library(data.table)
library(cowplot)
library(this.path)
library(sqldf)
library(tikzDevice)

setwd(paste0(this.dir(), "/.."))
defaultTheme <- theme(plot.margin = unit(c(0, 1.5, 0, 1), "mm"), strip.text = element_text(size = 6, vjust = -2),
                      legend.spacing.y = unit(c(-.5), "mm"),
                      axis.text.x = element_text(size = 6, margin = margin(1, 1, 1, 1)),
                      axis.text.y = element_text(size = 6, margin = margin(1, 1, 1, 1)),
                      axis.title = element_text(size = 8),
                      legend.text = element_text(size = 6), legend.title = element_text(size = 8),
                      legend.margin = margin(-.5, 0, 0, 0, "cm"),
                      legend.background = element_rect(fill = "white", size = 0.5, linetype = "solid"))

# Tableau public queries
tableaupublic <- fread('data/tableaupublicopt.csv')[optimization == 'Total']
tableaupublic$Implementation <- factor(tableaupublic$Implementation, levels = c('Indexed Algebra', 'Path Traversal', 'Column Sets', 'OrdPath'))
tableaupublic$time <- tableaupublic$time / 1000
# Remove outliers, since they make the plot unreadable
tpwithoutOutliers <- tableaupublic[time <= 0.5]
tikz(file = "images/interactiveworkloads1.tikz", width = 1.6, height = 1.3)
ggplot(tpwithoutOutliers, aes(x = Implementation, y = time, fill = Implementation)) +
  geom_boxplot(outlier.size = .5) +
  theme_minimal_hgrid() +
  panel_border() +
  scale_x_discrete(name = element_blank(), expand = expansion(mult = c(.5, .5))) +
  scale_y_continuous(name = "Optimization Time [ms]", expand = expansion(mult = c(0, .05))) +
  scale_fill_brewer(type = "qual", palette = 6, drop = FALSE) +
  expand_limits(y = 0) +
  defaultTheme +
  theme(legend.position = "none") +
  theme(plot.margin = unit(c(1, 0, -1.5, 1), "mm"))
dev.off()

# Small TPC-H workloads
smalltpch <- fread('data/smallTPCH.csv')
smalltpch$Method <- factor(smalltpch$Method, levels = c('Indexed Algebra', 'Path Traversal', 'Column Sets', 'OrdPath'))
smalltpch$execution <- smalltpch$execution * 1000
smalltpch$compilation <- smalltpch$compilation * 1000
smalltpch$total <- smalltpch$total * 1000
tikz(file = "images/interactiveworkloads2.tikz", width = 1.6, height = 1.3)
ggplot(smalltpch, aes(x = Method, y = total, fill = Method)) +
  geom_boxplot(outlier.size = .5) +
  theme_minimal_hgrid() +
  panel_border() +
  scale_x_discrete(name = element_blank(), expand = expansion(mult = c(.5, .5))) +
  scale_y_continuous(name = "Total Time [ms]", expand = expansion(mult = c(0.04, .04))) +
  scale_fill_brewer(type = "qual", palette = 6, drop = FALSE) +
  defaultTheme +
  theme(legend.position = "none") +
  theme(plot.margin = unit(c(1, 0, -1.5, 1), "mm"))
dev.off()

cat("\nMedian optimization time for Tableau Public queries:\n")
sqldf("
select Implementation, median(time)
from tableaupublic
group by Implementation
")

cat("\nMedian execution time for Tableau Public queries:\n")
execution <- fread('data/tableaupublicexecution.csv')
execution$execution <- execution$execution * 1000 * 1000
sqldf("
select median(execution)
from execution
")

cat("\nMedian total time for small TPC-H queries:\n")
sqldf("
select Method, median(total)
from smalltpch
group by Method
")

cat("\nMedian execution time for small TPC-H queries:\n")
sqldf("
select median(execution)
from smalltpch
")
