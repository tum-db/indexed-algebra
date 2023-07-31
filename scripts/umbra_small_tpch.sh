#!/usr/bin/env bash

TMPFILE=$(mktemp /tmp/umbra-measurement.XXXXXX)
cd umbra || { echo "umbra directory does not exist. Please extract first"; exit 1; }

# Create tpc-h scale factor 0.01
./scripts/tpch/dbgen.sh 0.01 >&2

# Measure with Indexed Algebra
./bin/sql db/tpchSf0.01.db <<EOF 2> "$TMPFILE"
\o -
\set commonsubtreeelimination false
\set joinorder 'g'
\set repeatmode all
\set repeat 100

\set useLinkCutTree true
\set useColumnSets false
\set useordpath false

\i scripts/tpch/tpch_all

EOF

EXECUTION=$(tail --lines=+1 "$TMPFILE" | grep 'execution'  | awk '{ print $8 }')
COMPILATION=$(tail --lines=+1 "$TMPFILE" | grep 'execution'  | awk '{ print $43 }')
TOTAL=$(tail --lines=+1 "$TMPFILE" | grep 'execution'  | awk '{ print $8+$43 }')
METHOD=$(yes "Indexed Algebra" | head -n 22)

echo "Method, execution, compilation, total"
paste -d , <(echo "$METHOD") <(echo "$EXECUTION") <(echo "$COMPILATION") <(echo "$TOTAL")

rm "$TMPFILE"

# And measure without
./bin/sql db/tpchSf0.01.db <<EOF 2> "$TMPFILE"
\o -
\set commonsubtreeelimination false
\set joinorder 'g'
\set repeatmode all
\set repeat 100

\set useLinkCutTree false
\set useColumnSets true
\set useordpath false

\i scripts/tpch/tpch_all
EOF

# Avg of ten
EXECUTION=$(tail --lines=+1 "$TMPFILE" | grep 'execution'  | awk '{ print $8 }')
COMPILATION=$(tail --lines=+1 "$TMPFILE" | grep 'execution'  | awk '{ print $43 }')
TOTAL=$(tail --lines=+1 "$TMPFILE" | grep 'execution'  | awk '{ print $8+$43 }')
METHOD=$(yes "Column Sets" | head -n 22)

paste -d , <(echo "$METHOD") <(echo "$EXECUTION") <(echo "$COMPILATION") <(echo "$TOTAL")

rm "$TMPFILE"
