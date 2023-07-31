# PVLDB Artifact Availability for *Asymptotically Better Query Optimization Using Indexed Algebra*

Public link to this material: https://github.com/tum-db/indexed-algebra

This repository contains the required scripts to recreate all benchmarks for our VLDB 2023 paper
*Asymptotically Better Query Optimization Using Indexed Algebra*.

## Reproducing Umbra measurements

The following steps explain how to reproduce the figures in the Evaluation, i.e., Table 2, and Figures 12, 13, 14, 
and 16.

```shell
# Extract umbra binaries
tar -xf umbra.tar.xz
cd umbra
# Load benchmark databases. The following scripts download and generate the
# datasets, before they load them into Umbra. These should take a couple of
# minutes each.
scripts/tpch/dbgen.sh
scripts/tpcds/dbgen.sh
scripts/job/dbgen.sh
# Execute the measurements in Umbra
# This will take about 30 minutes
bin/sql '' measure.sql
cd ..
```

The measurements should now be in a `opt.csv` file.
The numbers used in the paper are located in `data/opt.csv`, which can be used in
the following example to generate the figures.
The included R scripts generate the Latex figures.

```shell
# (optional) copy results to data directory
cp umbra/opt.csv data/opt.csv
# Install R dependencies
R --vanilla --interactive < <(echo "install.packages(c('data.table', 'cowplot', 'plyr', 'ggplot2', 'this.path', 'RColorBrewer', 'sqldf', 'tikzDevice', 'xtable'))")

# Generate the figures
./scripts/unnestingComparison.r
```

The `images` subdirectory should now contain four `.tikz` files containing the
Figures.

## Reproducing interactive workloads

The following steps show how to reproduce the measurements of Figures 15a and 15b.
The scripts assume that you ran the previous scripts to extract umbra and install the R dependencies. 

```shell
# Measure the tableau public workload
# This takes about 10 minutes
scripts/TableauPublic/measure.sh
# Then measure the small TPC-H end-to-end evaluation
# This takes about 1 minute
scripts/umbra_small_tpch.sh > smallTPCH.csv
```

The scripts/TableauPublic directory should now contain an opt.csv and an execution.csv file, and there should be a 
smallTPCH.csv file.
The following R script generate the Latex figures:
```shell
# (optional) copy results to data directory
cp TableauPublic/opt.csv data/tableaupublicopt.csv
cp TableauPublic/execution.csv data/tableaupublicexecution.csv
cp smallTPCH.csv data/smallTPCH.csv

# Generate the figures
./scripts/interactiveWorkloads.r
```

## Reproducing measurements of the systems comparison

The following steps explain how to reproduce Figures 17.

```shell
# This assumes an installation of the measured systems on your machine.
# Please refer to their documentation on how to install them.

# Measure all systems
./dbmsComparison/measure.sh
```

The measurements should now be in a `dbs.csv` file.
The numbers used in the paper are located in `data/dbs.csv`, which we use in
the following example to generate the figure.

```shell
# (optional) copy results to data directory
cp dbs.csv data/dbs.csv
# For R dependencies see above

# Generate the figure
./scripts/dbmsComparison.r
```

The `images` subdirectory should now contain a `.tikz` file containing the
Figure.

## Generating a PDF of the figures

To conveniently render the generated figures, we provide a small latex wrapper
around the generated tikz files.

```shell
cd images
latexmk -pdf figures.tex
# figures.pdf contains a rendered PDF
```
