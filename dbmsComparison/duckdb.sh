#!/usr/bin/env bash

TMPFILE=$(mktemp /tmp/duckdb-measurement.XXXXXX)

# DuckDB: 6..18
duckdb <<EOF > "$TMPFILE"
SET max_expression_depth TO 10000;
.output /dev/null
.read dbmsComparison/temptable.sql
.timer on
.read dbmsComparison/queries/6.sql
.read dbmsComparison/queries/6.sql
.read dbmsComparison/queries/6.sql
.read dbmsComparison/queries/7.sql
.read dbmsComparison/queries/7.sql
.read dbmsComparison/queries/7.sql
.read dbmsComparison/queries/8.sql
.read dbmsComparison/queries/8.sql
.read dbmsComparison/queries/8.sql
.read dbmsComparison/queries/9.sql
.read dbmsComparison/queries/9.sql
.read dbmsComparison/queries/9.sql
.read dbmsComparison/queries/10.sql
.read dbmsComparison/queries/10.sql
.read dbmsComparison/queries/10.sql
.read dbmsComparison/queries/11.sql
.read dbmsComparison/queries/11.sql
.read dbmsComparison/queries/11.sql
.read dbmsComparison/queries/12.sql
.read dbmsComparison/queries/12.sql
.read dbmsComparison/queries/12.sql
.read dbmsComparison/queries/13.sql
.read dbmsComparison/queries/13.sql
.read dbmsComparison/queries/13.sql
.read dbmsComparison/queries/14.sql
.read dbmsComparison/queries/14.sql
.read dbmsComparison/queries/14.sql
.read dbmsComparison/queries/15.sql
.read dbmsComparison/queries/15.sql
.read dbmsComparison/queries/15.sql
.read dbmsComparison/queries/16.sql
.read dbmsComparison/queries/16.sql
.read dbmsComparison/queries/16.sql
.read dbmsComparison/queries/17.sql
.read dbmsComparison/queries/17.sql
.read dbmsComparison/queries/17.sql
.read dbmsComparison/queries/18.sql
.read dbmsComparison/queries/18.sql
.read dbmsComparison/queries/18.sql
.read dbmsComparison/queries/19.sql
.read dbmsComparison/queries/19.sql
.read dbmsComparison/queries/19.sql
.read dbmsComparison/queries/20.sql
.read dbmsComparison/queries/20.sql
.read dbmsComparison/queries/20.sql
.read dbmsComparison/queries/33.sql
.read dbmsComparison/queries/33.sql
.read dbmsComparison/queries/33.sql
.read dbmsComparison/queries/40.sql
.read dbmsComparison/queries/40.sql
.read dbmsComparison/queries/40.sql
.read dbmsComparison/queries/50.sql
.read dbmsComparison/queries/50.sql
.read dbmsComparison/queries/50.sql
.read dbmsComparison/queries/60.sql
.read dbmsComparison/queries/60.sql
.read dbmsComparison/queries/60.sql
.read dbmsComparison/queries/64.sql
.read dbmsComparison/queries/64.sql
.read dbmsComparison/queries/64.sql
.read dbmsComparison/queries/100.sql
.read dbmsComparison/queries/100.sql
.read dbmsComparison/queries/100.sql
.read dbmsComparison/queries/200.sql
.read dbmsComparison/queries/200.sql
.read dbmsComparison/queries/200.sql
.read dbmsComparison/queries/300.sql
.read dbmsComparison/queries/300.sql
.read dbmsComparison/queries/300.sql
.read dbmsComparison/queries/1000.sql
.read dbmsComparison/queries/1000.sql
.read dbmsComparison/queries/1000.sql
EOF

# Avg of three
AVGS=$(awk '{sum+=$5} (NR%3)==0{print sum*1000/3; sum=0;}' "$TMPFILE")

DBMS="DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB
DuckDB"
JOIN_SIZES="6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
33
40
50
60
64
100
200
300
1000"

paste -d , <(echo "$DBMS") <(echo "$JOIN_SIZES") <(echo "$AVGS")

rm "$TMPFILE"
