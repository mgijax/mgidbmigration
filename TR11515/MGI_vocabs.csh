#!/bin/csh -fx

#
# Migration for TR11515/vocabularies only
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
# PLEASE READ!
# FOR TESTING ONLY 
# MAKE SURE BOTH ARE TURNED OFF FOR REAL MIGRATION
#
#${MGI_DBUTILS}/bin/load_db.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} /backups/rohan/scrum-dog/radar.backup
#${MGI_DBUTILS}/bin/load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /lindon/sybase/mgd.backup

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

delete from VOC_Term where _Vocab_key = 92
go

delete from VOC_Term where _Vocab_key = 93
go

EOSQL
date | tee -a ${LOG}

#
# 92 - allele collection
#
${VOCLOAD}/runSimpleFullLoadNoArchive.sh ${DBUTILS}/mgidbmigration/TR11515/allelecollection/alleleCollection.config | tee -a ${LOG}

#
# 93 - allele subtypes
#
${VOCLOAD}/runSimpleFullLoadNoArchive.sh ${DBUTILS}/mgidbmigration/TR11515/alleletype/alleleAttribute.config | tee -a ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

exec VOC_reorderTerms 92
go

exec VOC_reorderTerms 93
go

-- all collections
select _Term_key, substring(term,1,50) from VOC_Term where _Vocab_key = 92 order by term
go

-- allele subtype/attribute vocabulary
select _Term_key, substring(term,1,50) from VOC_Term where _Vocab_key = 93 order by term
go

EOSQL
date | tee -a ${LOG}

echo "--- Finished" | tee -a ${LOG}

