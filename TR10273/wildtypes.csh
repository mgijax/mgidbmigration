#!/bin/csh -fx

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use $MGD_DBNAME
go

select m._Marker_Type_key, m._Marker_key, m.symbol, m.creation_date
from MRK_Marker m
where m._Organism_key = 1
and m._Marker_Status_key in (1,3)
and m._Marker_Type_key not in (2,8)
and not exists (select 1 from ALL_Allele a where m._Marker_key = a._Marker_key)
order by m._Marker_Type_key, m.creation_date, m.symbol
go

checkpoint
go

end

EOSQL

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

