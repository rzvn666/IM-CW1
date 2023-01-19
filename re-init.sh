#!/bin/bash

export PGHOST=localhost
export PGUSER=postgres
export PGPASSWORD=postgres

psql -c "DROP DATABASE banking";
psql -c "CREATE DATABASE banking";
psql -U postgres -d banking < banking.sql;

./add-details.sh