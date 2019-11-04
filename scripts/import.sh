#!/usr/bin/env zsh

mkfifo sqlite_pipe

gzcat $1 > sqlite_pipe &
sqlite3 $2 < scripts/create.sql

rm sqlite_pipe
