#!/bin/csh -fx

#
# Migration for TR11248
# (part 1 - migration of existing data into new structures)
#
# a) exports Sybase/mgd database to Postgres
# b) builds new SNP schema on Postgres
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/test/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv PART1LOG $0.log.$$
rm -rf ${PART1LOG}
touch ${PART1LOG}

env | grep PG | tee -a ${PART1LOG}

date | tee -a ${PART1LOG}

#
# Export Sybase MGD database to Postgres.
#
date | tee -a ${PART1LOG}
${EXPORTER}/bin/exportDB.sh mgd postgres | tee -a ${PART1LOG}
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} mgd | tee -a ${PART1LOG}
date | tee -a ${PART1LOG}

#
# Re-fresh SNP database
#
${PG_DBUTILS}/bin/dropSchema.csh ${PG_DBSERVER} ${PG_DBNAME} snp | tee -a ${PART1LOG}
${PG_DBUTILS}/bin/createSchema.csh ${PG_DBSERVER} ${PG_DBNAME} snp | tee -a ${PART1LOG}
${PG_SNP_DBSCHEMADIR}/all_create.csh | tee -a ${PART1LOG}
${PG_DBUTILS}/bin/grantPublicPerms.csh ${PG_DBSERVER} ${PG_DBNAME} snp | tee -a ${PART1LOG}
${PG_DBUTILS}/bin/loadtable.csh ${PG_DBSERVER} ${PG_DBNAME} snp /export/dump/snp.postgres.dump SNP_Strain | tee -a ${PART1LOG}
${PG_DBUTILS}/bin/loadtable.csh ${PG_DBSERVER} ${PG_DBNAME} snp /export/dump/snp.postgres.dump MGI_dbinfo | tee -a ${PART1LOG}
${PG_DBUTILS}/bin/loadtable.csh ${PG_DBSERVER} ${PG_DBNAME} snp /export/dump/snp.postgres.dump MGI_Tables | tee -a ${PART1LOG}

date | tee -a ${PART1LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${PART1LOG}
update snp.mgi_dbinfo set 
	schema_version = 'pgsnpdbschema-5-1-4', 
	public_version = 'MGI 5.14',
	snp_data_version = 'dbSNP Build 137';
EOSQL
date | tee -a ${PART1LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${PART1LOG}
echo "--- Finished" | tee -a ${PART1LOG}

