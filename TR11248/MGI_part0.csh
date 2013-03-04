#!/bin/csh -fx

#
# Migration for TR11248
# (part 0 - load new SNP vocabularies/translations into MGD/Sybase
#
# on Sybase: load new vocabularies
# dbsnpload/bin/loadTranslations.sh
# dbsnpload/bin/loadVoc.sh
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/scrum-dog/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

env | grep MGD

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

#
# load Sybase/MGD backup into scrum-dog
# may need to load Sybase/SNP backup into scrum-dog
#
date | tee -a ${LOG}
${MGI_DBUTILS}/bin/load_db.csh ${MGDEXP_DBSERVER} ${MGDEXP_DBNAME} /backups/rohan/scrum-dog/mgd.backup | tee -a ${LOG}
#${MGI_DBUTILS}/bin/load_db.csh ${SNPEXP_DBSERVER} ${SNPEXP_DBNAME} /backups/rohan/scrum-dog/snp.backup | tee -a ${LOG}
date | tee -a ${LOG}

# load new SNP Function Class
# load new SNP handler
date | tee -a ${LOG}
${DBSNPLOAD}/bin/loadVoc.sh | tee -a ${LOG}
date | tee -a ${LOG}

# load new Translations (fxnClass.goodbad)
date | tee -a ${LOG}
${DBSNPLOAD}/bin/loadTranslations.sh | tee -a ${LOG}
date | tee -a ${LOG}

# make backup of mgd with snp changes
date | tee -a ${LOG}
${MGI_DBUTILS}/bin/dump_db.csh ${MGDEXP_DBSERVER} ${MGDEXP_DBNAME} /backups/rohan/scrum-dog/mgd-TR11248.backup
date | tee -a ${LOG}

# update the MGI_dbinfo information
date | tee -a ${LOG}
cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

update MGI_dbinfo set 
	schema_version = '5-1-4', 
	public_version = 'MGI 5.14',
	snp_data_version = 'dbSNP Build 137'
go

EOSQL
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

