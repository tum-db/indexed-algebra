#!/usr/bin/env bash

# These are for the DBMS comparison and assume a the temptable.sql is loaded

usage() {
  cat <<EOM
Generate queries with 1,000 (or even more) Tables Under the From
Usage: $(basename "$0") <#tables>
EOM
}

if [ "$#" -ne 1 ] || [ "$1" == "-h" ] ||  [ "$1" == "--help" ]; then
  usage
  exit 1
fi

cat <<EOF
select 1 from
EOF

# Tables
for i in $(seq 1 "$1"); do
  if [ "$i" -gt 1 ]; then
    echo -n ", "
  fi
  echo -n "test tbl$i"
done
echo ""
echo -n "where"

# Join predicates
for i in $(seq 1 "$1" | tail --lines=+2); do
  if [ "$i" -gt 2 ]; then
      echo -n " and"
  fi
  echo -n " tbl$((i-1)).x=tbl$i.y"
done
echo ";"
