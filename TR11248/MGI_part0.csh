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

source ../Configuration

env | grep MGD

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    #${MGI_DBUTILS}/bin/loadDB.csh ${MGD_DBSERVER} ${MGD_DBNAME} ...
    date | tee -a ${LOG}
else
    echo "--- Using existing database:  ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

cat - <<EOSQL | ${MGD_DBUTILS}/bin/doisql.csh $0 | tee -a ${LOG}

EOSQL

#
# run on rohan (Sybase)
#

#
# make any necessary changes to the MGD/SNP Sybase databases on production
# make copies to /backups/rohan/scrum-dog
#
# only fxnClass will need to be re-loaded
# needs to run on Sybase only
#date | tee -a ${LOG}
#${DBSNPLOAD}/bin/loadVoc.sh | tee -a ${LOG}
#date | tee -a ${LOG}

#
# may need to load Sybase/MGD backup into scrum-dog
# may need to load Sybase/SNP backup into scrum-dog
#
#date | tee -a ${LOG}
#${MGI_DBUTILS}/bin/load_db.csh ${MGDEXP_DBSERVER} ${MGDEXP_DBNAME} /backups/rohan/scrum-dog/mgd.backup
#${MGI_DBUTILS}/bin/load_db.csh ${SNPEXP_DBSERVER} ${SNPEXP_DBNAME} /backups/rohan/scrum-dog/snp.backup
#date | tee -a ${LOG}

#
# run on mgi-testdb4 (Postgres)
#

#
# Export Sybase SNP database to Postgres.
# uses SNPEXP variables
#
date | tee -a ${LOG}
${EXPORTER}/bin/exportDB.sh snp postgres | tee -a ${LOG}
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} snp | tee -a ${LOG}
date | tee -a ${LOG}

# can do this manually using ei/translation module
${DBSNPLOAD}/bin/loadTranslations.sh | tee -a ${LOG}

# this runs on postgres; snp_population, snp_subsnp_strainallele
${DBSNPLOAD}/bin/snpPopulation.sh | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

