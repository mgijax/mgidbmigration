#!/bin/csh -fx

#
# extract from the database the latest measurements for the statistics using
# Homology cluster data
#


cd `dirname $0` && source ../Configuration
setenv CWD `pwd`        # current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0
use ${MGD_DBNAME}
go
select s.abbreviation, m.intValue, m.timeRecorded
from mgi_statistic s, mgi_measurement m
where s.abbreviation in ('homologyPCG', 'homologyHuman', 'homologyHumanOneToOne', 'homologyRat', 'homologyChimp', 'homologyMonkey', 'homologyDog', 'homologyCattle', 'homologyChicken', 'homologyZebrafish')
  and s._Statistic_key = m._Statistic_key
  and m.isLatest = 1
order by abbreviation
go

EOSQL
