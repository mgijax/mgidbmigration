#!/bin/csh -fx

#
# Migration for TR11248
# (part 1 - migration of existing data into new structures)
#
# branches:
# snpcacheload-postgres
#
# trunk:
# pgsnpdbschema
# lib_py_postgres (add sym-link of "pg_db_py/db.py" to Install)
#
# retire:
# snpdbschema
#
# on Sybase: load new vocabularies
# dbsnpload/bin/loadTranslations.sh
# dbsnpload/bin/loadVoc.sh
#
# MUST RUN lib_java_dbssnp INSTALL after this is completed!!!!
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/test/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

env | grep PG

# start a new log file for this migration, and add a datestamp

setenv PART1LOG $0.log.$$
rm -rf ${PART1LOG}
touch ${PART1LOG}

date | tee -a ${PART1LOG}

#
# Export Sybase MGD database to Postgres.
#
#date | tee -a ${PART1LOG}
#${EXPORTER}/bin/exportDB.sh mgd postgres | tee -a ${PART1LOG}
#${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a ${PART1LOG}
#date | tee -a ${PART1LOG}

#
# Re-fresh SNP database
#
${PG_DBUTILS}/bin/dropSchema.csh ${PG_DBSERVER} ${PG_DBNAME} snp | tee -a ${PART1LOG}
${PG_DBUTILS}/bin/createSchema.csh ${PG_DBSERVER} ${PG_DBNAME} snp | tee -a ${PART1LOG}
${PG_SNP_DBSCHEMADIR}/all_create.csh | tee -a ${PART1LOG}
${PG_DBUTILS}/bin/grantPublicPerms ${PG_DBSERVER} ${PG_DBNAME} snp | tee -a ${PART1LOG}
${PG_DBUTILS}/bin/loadtable.csh ${PG_DBSERVER} ${PG_DBNAME} snp /export/dump/snp.postgres.dump SNP_Strain | tee -a ${PART1LOG}
${PG_DBUTILS}/bin/loadtable.csh ${PG_DBSERVER} ${PG_DBNAME} snp /export/dump/snp.postgres.dump MGI_dbinfo | tee -a ${PART1LOG}
${PG_DBUTILS}/bin/loadtable.csh ${PG_DBSERVER} ${PG_DBNAME} snp /export/dump/snp.postgres.dump MGI_Tables | tee -a ${PART1LOG}

date | tee -a ${PART1LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${PART1LOG}
update mgd.mgi_dbinfo set schema_version = '5-1-4', public_version = 'MGI 5.14';
update snp.mgi_dbinfo set schema_version = 'pgsnpdbschema-5-1-4', public_version = 'MGI 5.14';
EOSQL
date | tee -a ${PART1LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${PART1LOG}
echo "--- Finished" | tee -a ${PART1LOG}

