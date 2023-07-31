#!/usr/bin/env bash

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." || exit 1

cat <<EOF
Please first start the server processes of the DBMS:

Hyper, e.g.,
~/.local/lib/python3.10/site-packages/tableauhyperapi/bin/hyper/hyperd run --no-password --skip-license

MariaDB with database "test", e.g.,
systemctl start mariadb
echo "create database test; " | mariadb

PostgreSQL, e.g.,
systemctl start postgresql.service
EOF

read -p "Press enter to continue"

echo "DBMS, Joins, Time" > dbs.csv

#echo "Measuring DuckDB"
./dbmsComparison/duckdb.sh >> dbs.csv
echo "Measuring Hyper"
./dbmsComparison/hyper.sh >> dbs.csv
echo "Measuring MariaDB"
./dbmsComparison/mariadb.sh >> dbs.csv
echo "Measuring PostgreSQL"
./dbmsComparison/postgres.sh >> dbs.csv
echo "Measuring SQLite"
./dbmsComparison/sqlite.sh >> dbs.csv
echo "Measuring Umbra"
./dbmsComparison/umbra.sh >> dbs.csv


