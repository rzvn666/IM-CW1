#!/bin/bash

export PGHOST=localhost
export PGUSER=postgres
export PGPASSWORD=postgres

psql -c "CREATE DATABASE banking";
psql -U postgres -d banking < banking.sql;