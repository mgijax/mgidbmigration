#!/bin/csh -fx

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration

echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use $MGD_DBNAME
go

print "Female"
select a1.accID, c._Note_key, c.note
from MGI_NoteChunk c, MGI_Note n, ACC_Accession a1
where n._NoteType_key in (1008)
and n._Note_key = c._Note_key
and c.note like '% female %'
and n._Object_key = a1._Object_key
and a1._MGIType_key = 11
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

