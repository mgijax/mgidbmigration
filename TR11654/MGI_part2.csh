#!/bin/csh -fx

#
# Migration for TR11654
#
# explinkload
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

#
# run explinkload
#
date | tee -a ${LOG}
echo "TR11721/GXD Expression : chicken : GEISHA load" | tee -a ${LOG}
${EXPLINKLOAD}/bin/chicken-geisha.sh | tee -a ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

-- approx 1539
select count(*) from MGI_Note where _NoteType_key = 1043
go

EOSQL
date | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

