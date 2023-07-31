#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8
TMPFILE=$(mktemp /tmp/postgres-measurement.XXXXXX)

# Postgres: 6..100
psql -U postgres <<EOF > "$TMPFILE"
\o /dev/null
\i dbmsComparison/temptable.sql
\timing
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
EOF

# Avg of three
AVGS=$(awk '{sum+=$2} (NR%3)==0{print sum/3; sum=0;}' "$TMPFILE")

DBMS="PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL
PostgreSQL"
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
300"

paste -d , <(echo "$DBMS") <(echo "$JOIN_SIZES") <(echo "$AVGS")

rm "$TMPFILE"
