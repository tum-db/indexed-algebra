#!/usr/bin/env bash

TMPFILE=$(mktemp /tmp/umbra-measurement.XXXXXX)

# Umbra: 6..1000
./umbra/bin/sql <<EOF 2> "$TMPFILE"
\o -
\set joinorder 'g'
\i dbmsComparison/temptable.sql
\i dbmsComparison/queries/6.sql
\i dbmsComparison/queries/6.sql
\i dbmsComparison/queries/6.sql
\i dbmsComparison/queries/7.sql
\i dbmsComparison/queries/7.sql
\i dbmsComparison/queries/7.sql
\i dbmsComparison/queries/8.sql
\i dbmsComparison/queries/8.sql
\i dbmsComparison/queries/8.sql
\i dbmsComparison/queries/9.sql
\i dbmsComparison/queries/9.sql
\i dbmsComparison/queries/9.sql
\i dbmsComparison/queries/10.sql
\i dbmsComparison/queries/10.sql
\i dbmsComparison/queries/10.sql
\i dbmsComparison/queries/11.sql
\i dbmsComparison/queries/11.sql
\i dbmsComparison/queries/11.sql
\i dbmsComparison/queries/12.sql
\i dbmsComparison/queries/12.sql
\i dbmsComparison/queries/12.sql
\i dbmsComparison/queries/13.sql
\i dbmsComparison/queries/13.sql
\i dbmsComparison/queries/13.sql
\i dbmsComparison/queries/14.sql
\i dbmsComparison/queries/14.sql
\i dbmsComparison/queries/14.sql
\i dbmsComparison/queries/15.sql
\i dbmsComparison/queries/15.sql
\i dbmsComparison/queries/15.sql
\i dbmsComparison/queries/16.sql
\i dbmsComparison/queries/16.sql
\i dbmsComparison/queries/16.sql
\i dbmsComparison/queries/17.sql
\i dbmsComparison/queries/17.sql
\i dbmsComparison/queries/17.sql
\i dbmsComparison/queries/18.sql
\i dbmsComparison/queries/18.sql
\i dbmsComparison/queries/18.sql
\i dbmsComparison/queries/19.sql
\i dbmsComparison/queries/19.sql
\i dbmsComparison/queries/19.sql
\i dbmsComparison/queries/20.sql
\i dbmsComparison/queries/20.sql
\i dbmsComparison/queries/20.sql
\i dbmsComparison/queries/33.sql
\i dbmsComparison/queries/33.sql
\i dbmsComparison/queries/33.sql
\i dbmsComparison/queries/40.sql
\i dbmsComparison/queries/40.sql
\i dbmsComparison/queries/40.sql
\i dbmsComparison/queries/50.sql
\i dbmsComparison/queries/50.sql
\i dbmsComparison/queries/50.sql
\i dbmsComparison/queries/60.sql
\i dbmsComparison/queries/60.sql
\i dbmsComparison/queries/60.sql
\i dbmsComparison/queries/64.sql
\i dbmsComparison/queries/64.sql
\i dbmsComparison/queries/64.sql
\i dbmsComparison/queries/100.sql
\i dbmsComparison/queries/100.sql
\i dbmsComparison/queries/100.sql
\i dbmsComparison/queries/200.sql
\i dbmsComparison/queries/200.sql
\i dbmsComparison/queries/200.sql
\i dbmsComparison/queries/300.sql
\i dbmsComparison/queries/300.sql
\i dbmsComparison/queries/300.sql
\i dbmsComparison/queries/1000.sql
\i dbmsComparison/queries/1000.sql
\i dbmsComparison/queries/1000.sql
EOF

# Avg of three
AVGS_TOTAL=$(tail --lines=+1 "$TMPFILE" | grep 'execution'  | awk '{sum+=$6+$41} (NR%3)==0{print sum*1000/3; sum=0;}')
AVGS_EXECUTION=$(tail --lines=+1 "$TMPFILE" | grep 'execution'  | awk '{sum+=$6} (NR%3)==0{print sum*1000/3; sum=0;}')

DBMS_TOTAL=$(yes "Umbra" | head -n 24)
DBMS_EXECUTION=$(yes "Umbra Execution Only" | head -n 24)

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

paste -d , <(echo "$DBMS_TOTAL") <(echo "$JOIN_SIZES") <(echo "$AVGS_TOTAL")
paste -d , <(echo "$DBMS_EXECUTION") <(echo "$JOIN_SIZES") <(echo "$AVGS_EXECUTION")

rm "$TMPFILE"
