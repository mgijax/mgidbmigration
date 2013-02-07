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

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/test/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

env | grep PG

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

#
# Export Sybase MGD database to Postgres.
#
date | tee -a ${LOG}
${EXPORTER}/bin/exportDB.sh mgd postgres | tee -a ${LOG}
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a ${LOG}
date | tee -a ${LOG}

#
# Re-fresh SNP database
#
${PG_DBUTILS}/bin/dropSchema.csh ${PG_DBSERVER} ${PG_DBNAME} snp | tee -a ${LOG}
${PG_DBUTILS}/bin/createSchema.csh ${PG_DBSERVER} ${PG_DBNAME} snp | tee -a ${LOG}
${PG_SNP_DBSCHEMADIR}/all_create.csh | tee -a ${LOG}
${PG_DBUTILS}/bin/grantPublicPerms ${PG_DBSERVER} ${PG_DBNAME} snp | tee -a ${LOG}
${PG_DBUTILS}/bin/loadtable.csh ${PG_DBSERVER} ${PG_DBNAME} snp /export/dump/snp.postgres.dump SNP_Strain | tee -a ${LOG}
${PG_DBUTILS}/bin/loadtable.csh ${PG_DBSERVER} ${PG_DBNAME} snp /export/dump/snp.postgres.dump MGI_dbinfo | tee -a ${LOG}
${PG_DBUTILS}/bin/loadtable.csh ${PG_DBSERVER} ${PG_DBNAME} snp /export/dump/snp.postgres.dump MGI_Tables | tee -a ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${LOG}
update mgd.mgi_dbinfo set schema_version = '5-1-4', public_version = 'MGI 5.14';
delete from MGI_Tables where table_name in ('MGI_Columns', 'MRK_Location_Cache');
EOSQL
date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

