#!/usr/bin/env bash
set -eu

SCRIPTDIR="$PWD"
if [ ! -f "$SCRIPTDIR"/umbra/bin/sql ]; then
  echo "$SCRIPTDIR/umbra/bin/sql does not exist. Please extract first";
  exit 1;
fi
rm -rf tableaupublic
git clone https://gitlab.db.in.tum.de/fent/tableaupublic.git

(
  cd -- 'tableaupublic/-2_17' || exit
  "$SCRIPTDIR"/umbra/bin/sql -createdb temp.db <<EOF 2> /dev/null
    \i 'table_187329930 _copy_.sql'
    \i load.sql
EOF
  TMPFILE=$(mktemp measurement.XXXXXX)
  "$SCRIPTDIR"/umbra/bin/sql temp.db <<EOF 2> "$TMPFILE"
    \o -
    \set repeatmode all
    \set repeat 100
    \i queries.sql

    \set useLinkCutTree false
    \set useColumnSets true
    \i queries.sql
EOF
)
(
  cd tableaupublic/ahlyAfrica || exit
  "$SCRIPTDIR"/umbra/bin/sql -createdb temp.db <<EOF 2> /dev/null
    \i 'excel_direct_42328_717700902800.sql'
    \i load.sql
EOF
  TMPFILE=$(mktemp measurement.XXXXXX)
  "$SCRIPTDIR"/umbra/bin/sql temp.db <<EOF 2> "$TMPFILE"
    \o -
    \set repeatmode all
    \set repeat 100
    \i queries.sql

    \set useLinkCutTree false
    \set useColumnSets true
    \i queries.sql
EOF
)
(
  cd tableaupublic/ControledeConstitucionalidadeviaADIDivulgao || exit
  "$SCRIPTDIR"/umbra/bin/sql -createdb temp.db <<EOF 2> /dev/null
    \i 'excel_41160_877450925924.sql'
    \i load.sql
EOF
  TMPFILE=$(mktemp measurement.XXXXXX)
  "$SCRIPTDIR"/umbra/bin/sql temp.db <<EOF 2> "$TMPFILE"
    \o -
    \set repeatmode all
    \set repeat 100
    \i queries.sql

    \set useLinkCutTree false
    \set useColumnSets true
    \i queries.sql
EOF
)
(
  cd tableaupublic/DCIncomeDistributionTool || exit
  "$SCRIPTDIR"/umbra/bin/sql -createdb temp.db <<EOF 2> /dev/null
    \i 'excel_direct_13aku550iejlpf1gtux.sql'
    \i load.sql
EOF
  TMPFILE=$(mktemp measurement.XXXXXX)
  "$SCRIPTDIR"/umbra/bin/sql temp.db <<EOF 2> "$TMPFILE"
    \o -
    \set repeatmode all
    \set repeat 100
    \i queries.sql

    \set useLinkCutTree false
    \set useColumnSets true
    \i queries.sql
EOF
)
(
  cd tableaupublic/GraficosPGRKelton || exit
  "$SCRIPTDIR"/umbra/bin/sql -createdb temp.db <<EOF 2> /dev/null
    \i 'ADI Completa (Tabela completa a ser revisada.xlsx).sql'
    \i load.sql
EOF
  TMPFILE=$(mktemp measurement.XXXXXX)
  "$SCRIPTDIR"/umbra/bin/sql temp.db <<EOF 2> "$TMPFILE"
    \o -
    \set repeatmode all
    \set repeat 100
    \i queries.sql

    \set useLinkCutTree false
    \set useColumnSets true
    \i queries.sql
EOF
)
(
  cd tableaupublic/ParkingPlateSearch || exit
  "$SCRIPTDIR"/umbra/bin/sql -createdb temp.db <<EOF 2> /dev/null
    \i '#TableauTemp_0vlg5zj0o8i1n71ain8l21oo5tqz.sql'
    \i load.sql
EOF
  TMPFILE=$(mktemp measurement.XXXXXX)
  "$SCRIPTDIR"/umbra/bin/sql temp.db <<EOF 2> "$TMPFILE"
    \o -
    \set repeatmode all
    \set repeat 100
    \i queries.sql

    \set useLinkCutTree false
    \set useColumnSets true
    \i queries.sql
EOF
)
(
  cd tableaupublic/SearchICD-10-CMPCS || exit
  "$SCRIPTDIR"/umbra/bin/sql -createdb temp.db <<EOF 2> /dev/null
    \i 'excel_direct_42318_374151643518.sql'
    \i load.sql
EOF
  TMPFILE=$(mktemp measurement.XXXXXX)
  "$SCRIPTDIR"/umbra/bin/sql temp.db <<EOF 2> "$TMPFILE"
    \o -
    \set repeatmode all
    \set repeat 100
    \i queries.sql

    \set useLinkCutTree false
    \set useColumnSets true
    \i queries.sql
EOF
)
(
  cd tableaupublic/Site11CoolingExcursions || exit
  "$SCRIPTDIR"/umbra/bin/sql -createdb temp.db <<EOF 2> /dev/null
    \i 'csv_41803_434627476854.sql'
    \i load.sql
EOF
  TMPFILE=$(mktemp measurement.XXXXXX)
  "$SCRIPTDIR"/umbra/bin/sql temp.db <<EOF 2> "$TMPFILE"
    \o -
    \set repeatmode all
    \set repeat 100
    \i queries.sql

    \set useLinkCutTree false
    \set useColumnSets true
    \i queries.sql
EOF
)
(
  cd tableaupublic/Venn_0 || exit
  "$SCRIPTDIR"/umbra/bin/sql -createdb temp.db <<EOF 2> /dev/null
    \i 'excel_direct_41830_783438587961.sql'
    \i load.sql
EOF
  TMPFILE=$(mktemp measurement.XXXXXX)
  "$SCRIPTDIR"/umbra/bin/sql temp.db <<EOF 2> "$TMPFILE"
    \o -
    \set repeatmode all
    \set repeat 100
    \i queries.sql

    \set useLinkCutTree false
    \set useColumnSets true
    \i queries.sql
EOF
)

# Merge all optimization measurements
cat tableaupublic/-2_17/opt.csv \
  <(tail -n +2 tableaupublic/ahlyAfrica/opt.csv) \
  <(tail -n +2 tableaupublic/ControledeConstitucionalidadeviaADIDivulgao/opt.csv) \
  <(tail -n +2 tableaupublic/DCIncomeDistributionTool/opt.csv) \
  <(tail -n +2 tableaupublic/GraficosPGRKelton/opt.csv) \
  <(tail -n +2 tableaupublic/ParkingPlateSearch/opt.csv) \
  <(tail -n +2 tableaupublic/SearchICD-10-CMPCS/opt.csv) \
  <(tail -n +2 tableaupublic/Site11CoolingExcursions/opt.csv) \
  <(tail -n +2 tableaupublic/Venn_0/opt.csv) \
  > opt.csv

# Merge the execution times
echo "execution" > execution.csv
cat tableaupublic/*/measurement.* | grep execution: | awk '{print $8}' \
  >> execution.csv
