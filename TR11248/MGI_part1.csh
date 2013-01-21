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
#
# retire:
# snpdbschema
#

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

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    #load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /lindon/sybase/mgd.backup | tee -a ${LOG}
    #load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/scrum-dog/mgd.postdailybackup | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

#cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}
#
#use ${MGD_DBNAME}
#go
#
#update MGI_dbinfo set schema_version = "5-1-2", public_version = "MGI 5.12"
#go
#
#EOSQL

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${LOG}

-- remove extra unique index; schema product has already been fixed

drop index snp.SNP_ConsensusSnp_Marker_idx_ConsensusSnp_Marker_key;

drop index snp.SNP_Accession_Object_key;

drop index snp.SNP_Accession_Accession_key;

EOSQL

${PG_SNP_DBSCHEMADIR}/index/?_create.object | tee -a ${LOG}

date | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

