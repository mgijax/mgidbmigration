#!/bin/csh -x -f

#
# Dump development database to binary dump
#
# Parameters:
#	DBNAME - the name of the database to load
#	BACKUP - the name of the dump file to use
#

# doisql.csh expects DBSERVER, DBNAME, DBUSER and DBPASSWORDFILE to be set

cd `dirname $0` && source ./Configuration

setenv BACKUP $1

cat - <<EOSQL | doisql.csh $0

dump transaction ${DBNAME} with truncate_only
go

dump database ${DBNAME} to "${WORKDIR}/${BACKUP}1" stripe on "${WORKDIR}/${BACKUP}2"
go

quit

EOSQL
