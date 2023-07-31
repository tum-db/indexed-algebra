#!/bin/env Rscript
library(ggplot2)
library(data.table)
library(cowplot)
library(sqldf)
library(plyr)
library(this.path)
library(tikzDevice)
library(RColorBrewer)
library(xtable)

setwd(paste0(this.dir(), "/.."))

# Prerequisites:
# scripts/tpch/dbgen.sh
# scripts/tpcds/dbgen.sh
# scripts/job/dbgen.sh
# bin/sql '' measure.sql

cat("Generating TikZ pictures. This may take a couple of seconds...\n")

repetitions <- 1000

# Read the log file
optlog <- fread('data/opt.csv')
# Classify the workload
optlog[, c("scripts", "Benchmark", "queries", "Q") := tstrsplit(query, "/", fixed = TRUE)]
# Prettyfiy the labels
optlog$Implementation <- factor(optlog$Implementation, levels = c('Indexed Algebra', 'Path Traversal', 'Column Sets', 'OrdPath'))
optlog$Benchmark <- revalue(optlog$Benchmark, c("hugejoin" = "Synthetic Joins", "tpch" = "TPC-H", "tpcds" = "TPC-DS", "job" = "JOB"))
optlog$Benchmark <- factor(optlog$Benchmark, levels = c('TPC-H', 'TPC-DS', 'JOB', 'Synthetic Joins'))

# We have two special queries tat we only measure for Indexed Algebra
IAHuge <- optlog[Q == '1000.sql' | Q == '10000.sql']
optlog <- optlog[Q != '1000.sql' & Q != '10000.sql']

defaultTheme <- theme(plot.margin = unit(c(0, 1.5, 0, 1), "mm"), strip.text = element_text(size = 6, vjust = -2),
                      legend.spacing.y = unit(c(-.5), "mm"),
                      axis.text.x = element_text(size = 6, margin = margin(1, 1, 1, 1)),
                      axis.text.y = element_text(size = 6, margin = margin(1, 1, 1, 1)),
                      axis.title.x = element_text(size = 8, margin = margin(1, 1, 1, 1)),
                      axis.title.y = element_text(size = 8, margin = margin(1, 1, 1, 1)),
                      legend.text = element_text(size = 6), legend.title = element_text(size = 8),
                      legend.margin = margin(-.5, 0, 0, 0, "cm"),
                      legend.background = element_rect(fill = "white", size = 0.5, linetype = "solid"))

tikz(file = "images/unnestingBenchmarks.tikz", width = 3.4, height = 1.6)
ggplot(data = optlog[optimization == 'Unnesting'], aes(x = Implementation, y = time / repetitions, fill = Implementation)) +
  geom_boxplot(outlier.size = .5) +
  facet_wrap(. ~ Benchmark, scales = 'free_y') +
  theme_minimal_hgrid() +
  panel_border() +
  scale_x_discrete(name = element_blank(), expand = expansion(mult = c(.2, .2))) +
  scale_y_continuous(name = "Unnesting Time [ms]", expand = expansion(mult = c(0, .1))) +
  defaultTheme +
  scale_fill_brewer(type = "qual", palette = 6) +
  theme(axis.text.x = element_text(angle = -13, vjust = .1, hjust = .35, margin = margin(0, 0, 0, 0))) +
  theme(legend.position = "none") +
  theme(panel.spacing = unit(2, "pt")) +
  theme(plot.margin = unit(c(-1, 1.5, -2.5, 1), "mm")) +
  expand_limits(y = 0)
dev.off()

speedup <- sqldf("
WITH total AS (
  SELECT * FROM optlog WHERE optimization = 'Total'
), columnsets AS (
  SELECT * FROM total WHERE Implementation = 'Column Sets'
), indexedalgebra as (
  SELECT * FROM total WHERE Implementation = 'Indexed Algebra'
)
SELECT c.Q as Query, c.Benchmark,
       c.time as CSetTime, i.time IndexedTime, c.time / i.time as speedup
FROM columnsets c, indexedalgebra i
WHERE c.Q = i.Q
  AND c.Benchmark = i.Benchmark
")

# This is total optimization time. Column Sets is with Path Traversal + unnesting via IUSets
tikz(file = "images/optimizationSpeedup.tikz", width = 3.4, height = 1.35)
ggplot(data = speedup, aes(x = Benchmark, y = speedup, fill = Benchmark)) +
  geom_boxplot(outlier.size = .5) +
  theme_minimal_hgrid() +
  panel_border() +
  theme(legend.position = "none") +
  scale_x_discrete(name = element_blank(), expand = expansion(mult = c(.2, .2))) +
  scale_y_continuous(name = "Speedup", breaks = scales::pretty_breaks(), expand = expansion(mult = c(0.01, 0.01))) +
  defaultTheme +
  scale_fill_brewer(type = "qual")
dev.off()


# Analyze Syntetic Join workload for the number of relations
hugejoins <- optlog[Benchmark == 'Synthetic Joins' & Implementation != 'OrdPath']
hugejoins[, c("relations", "sql") := tstrsplit(Q, ".", fixed = TRUE)]
hugejoins$relations <- as.numeric(as.character(hugejoins$relations))
tikz(file = "images/unnestingHugejoins.tikz", width = 3.2, height = 1.35)
ggplot(data = hugejoins[optimization == 'Unnesting'], aes(x = relations, y = time / repetitions, color = Implementation, shape = Implementation)) +
  geom_point() +
  geom_smooth(method = 'loess', formula = y ~ x, se = FALSE) +
  theme_minimal_hgrid() +
  panel_border() +
  scale_y_continuous(name = "Unnesting Time [ms]", breaks = scales::pretty_breaks(), expand = expansion(mult = c(0, 0.03))) +
  scale_x_continuous(name = "Number of Joins", expand = expansion(mult = c(0, 0.01))) +
  defaultTheme +
  scale_color_brewer(type = "qual", palette = 6) +
  theme(legend.position = c(0.1, 0.5)) +
  expand_limits(x = 0, y = 0)
dev.off()

cat("Finished generating TikZ pictures!\n")

# Compare total optimization time of Indexed Algebra and OrdPath
optimizationcomparison <- sqldf("
select *
from optlog
where optimization = 'Total'
  and Benchmark in ('TPC-H', 'Synthetic Joins')
")
tikz(file = "images/optimizationcomparison.tikz", width = 3.2, height = 1.35)
ggplot(optimizationcomparison, aes(x = Implementation, y = time / 1000, fill = Implementation)) +
  geom_boxplot(outlier.size = .5) +
  facet_wrap(. ~ Benchmark, scales = 'free') +
  theme_minimal_hgrid() +
  panel_border() +
  scale_x_discrete(name = element_blank(), expand = expansion(mult = c(.2, .2))) +
  scale_y_continuous(name = "Optimization Time [ms]", expand = expansion(mult = c(0, .04))) +
  defaultTheme +
  scale_fill_brewer(type = "qual", palette = 6) +
  theme(axis.text.x = element_text(angle = -13, vjust = .1, hjust = .35, margin = margin(0, 0, 0, 0))) +
  theme(plot.margin = unit(c(0, 1, -2.5, 1), "mm")) +
  theme(panel.spacing = unit(2, "pt")) +
  theme(legend.position = "none") +
  expand_limits(y = 0)
dev.off()

ablation <- sqldf("
with opt as (
select * from optlog
where Benchmark = 'TPC-DS'
and optimization not in ('Common Subtree Elimination', 'Side-way Information Passing')
), indexedalgebra as (
select * from opt
where Implementation = 'Indexed Algebra'
), columnsets as (
select * from opt
where Implementation = 'Column Sets'
)
select ia.optimization as 'Optimization Pass', round(avg(cs.time), 1) as cstime, round(avg(ia.time), 1) as iatime, avg(cs.time / ia.time) as Speedup
from indexedalgebra ia, columnsets cs
where ia.query = cs.query
  and ia.optimization = cs.optimization
group by ia.optimization
order by (
  case when ia.optimization = 'Simplify Expressions'   then 0
       when ia.optimization = 'Unnesting'              then 1
       when ia.optimization = 'Predicate Pushdown'     then 2
       when ia.optimization = 'Cardinality Estimation' then 3
       when ia.optimization = 'Join Ordering'          then 4
       when ia.optimization = 'Physical Planning'      then 5
       when ia.optimization = 'Total'                  then 6
       else 9
  end
)
")

# print(xtable(newobject2, type = "latex"), file = "filename2.tex")
print(xtable(ablation), type = "latex", booktabs = TRUE,
      only.contents = TRUE, include.rownames = FALSE, include.colnames = FALSE,
      add.to.row = list(pos = list(5), command = c("\\vspace{1mm}\n")),
      file = "data/ablation.tex"
      )

sqldf("
WITH stddev AS (
  SELECT stddev, time, stddev / time as stddev_percent, Benchmark, Q
  FROM optlog o
  WHERE optimization IN ('Unnesting', 'Total')
)
SELECT MIN(stddev_percent), MAX(stddev_percent)
FROM stddev
")

cat("\nAverage unnesting speedup of Indexed Algebra:\n")
sqldf("
WITH total AS (
  SELECT * FROM optlog WHERE optimization = 'Unnesting'
), columnsets AS (
  SELECT * FROM total WHERE Implementation = 'Column Sets'
), indexedalgebra as (
  SELECT * FROM total WHERE Implementation = 'Indexed Algebra'
), speedup AS (
SELECT c.Q as Query, c.Benchmark, c.time as CSetTime, i.time IndexedTime, c.time / i.time as speedup
FROM columnsets c, indexedalgebra i
WHERE c.Q = i.Q
  AND c.Benchmark = i.Benchmark
)
SELECT Benchmark, avg(speedup), max(CSetTime), max(IndexedTime)
FROM speedup
GROUP BY Benchmark
")

cat("\nAverage total speedup of Indexed Algebra:\n")
sqldf("
SELECT Benchmark, avg(speedup), max(CSetTime), max(IndexedTime)
FROM speedup
GROUP BY Benchmark
")

cat("\nTotal speedup over the slowest Column Sets queries:\n")
sqldf("
WITH complexqueries as (
  SELECT Benchmark, max(CSetTime) as time
  FROM speedup
  GROUP BY Benchmark
)
SELECT c.Benchmark, Query, CSetTime, IndexedTime, speedup
FROM complexqueries c, speedup s
WHERE c.Benchmark = s.Benchmark
  AND c.time = s.CSetTime
")

cat("\nIndexed Algebra optimization times for 1k and 10k queries:\n")
sqldf("
SELECT optimization, CAST(time AS INT) as time, Q
FROM IAHuge
WHERE optimization in ('Unnesting', 'Join Ordering', 'Total')
")
