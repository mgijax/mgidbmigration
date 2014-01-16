#!/bin/csh -f

#
# Migration for TR11515/Allele Type
#
# Update/Run MGI_Statistic/Measurements
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

cd ${DBUTILS}/mgidbmigration/TR11515/alleletype

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select * from MGI_Measurement where isLatest = 1 order by _Statistic_key
go

EOSQL
date | tee -a ${LOG}

#
# run MGI_Statistics
#
${MGI_DBUTILS}/bin/addMeasurements.csh | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

