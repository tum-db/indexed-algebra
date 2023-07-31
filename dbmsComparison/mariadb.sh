#!/usr/bin/env bash

TMPFILE=$(mktemp /tmp/mariadb-measurement.XXXXXX)

# MariaDB: 6..60
mariadb -U test <<EOF > "$TMPFILE"
\. dbmsComparison/temptable.sql
set SQL_BIG_SELECTS = 1;
set profiling = 1;
set profiling_history_size = 100;
\. dbmsComparison/queries/6.sql
\. dbmsComparison/queries/6.sql
\. dbmsComparison/queries/6.sql
\. dbmsComparison/queries/7.sql
\. dbmsComparison/queries/7.sql
\. dbmsComparison/queries/7.sql
\. dbmsComparison/queries/8.sql
\. dbmsComparison/queries/8.sql
\. dbmsComparison/queries/8.sql
\. dbmsComparison/queries/9.sql
\. dbmsComparison/queries/9.sql
\. dbmsComparison/queries/9.sql
\. dbmsComparison/queries/10.sql
\. dbmsComparison/queries/10.sql
\. dbmsComparison/queries/10.sql
\. dbmsComparison/queries/11.sql
\. dbmsComparison/queries/11.sql
\. dbmsComparison/queries/11.sql
\. dbmsComparison/queries/12.sql
\. dbmsComparison/queries/12.sql
\. dbmsComparison/queries/12.sql
\. dbmsComparison/queries/13.sql
\. dbmsComparison/queries/13.sql
\. dbmsComparison/queries/13.sql
\. dbmsComparison/queries/14.sql
\. dbmsComparison/queries/14.sql
\. dbmsComparison/queries/14.sql
\. dbmsComparison/queries/15.sql
\. dbmsComparison/queries/15.sql
\. dbmsComparison/queries/15.sql
\. dbmsComparison/queries/16.sql
\. dbmsComparison/queries/16.sql
\. dbmsComparison/queries/16.sql
\. dbmsComparison/queries/17.sql
\. dbmsComparison/queries/17.sql
\. dbmsComparison/queries/17.sql
\. dbmsComparison/queries/18.sql
\. dbmsComparison/queries/18.sql
\. dbmsComparison/queries/18.sql
\. dbmsComparison/queries/19.sql
\. dbmsComparison/queries/19.sql
\. dbmsComparison/queries/19.sql
\. dbmsComparison/queries/20.sql
\. dbmsComparison/queries/20.sql
\. dbmsComparison/queries/20.sql
\. dbmsComparison/queries/33.sql
\. dbmsComparison/queries/33.sql
\. dbmsComparison/queries/33.sql
\. dbmsComparison/queries/40.sql
\. dbmsComparison/queries/40.sql
\. dbmsComparison/queries/40.sql
\. dbmsComparison/queries/50.sql
\. dbmsComparison/queries/50.sql
\. dbmsComparison/queries/50.sql
\. dbmsComparison/queries/60.sql
\. dbmsComparison/queries/60.sql
\. dbmsComparison/queries/60.sql
show profiles;
EOF

# Avg of three
AVGS=$(grep 'select 1 from' "$TMPFILE" | awk '{sum+=$2} (NR%3)==0{print sum*1000/3; sum=0;}')

DBMS="MariaDB
MariaDB
MariaDB
MariaDB
MariaDB
MariaDB
MariaDB
MariaDB
MariaDB
MariaDB
MariaDB
MariaDB
MariaDB
MariaDB
MariaDB
MariaDB
MariaDB
MariaDB
MariaDB"
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
60"

paste -d , <(echo "$DBMS") <(echo "$JOIN_SIZES") <(echo "$AVGS")

rm "$TMPFILE"
