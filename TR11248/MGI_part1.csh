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

source ../Configuration

env | grep PG

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${PG_DBSERVER}..${PG_DBNAME}" | tee -a ${LOG}
    #${PGDBUTILS}/bin/loadDB.csh mgi-testdb4 export snp /export/dump/snp
    date | tee -a ${LOG}
else
    echo "--- Using existing database:  ${PG_DBSERVER}..${PG_DBNAME}" | tee -a ${LOG}
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

-- being renamed to SNP_Accession_idx_clustered
drop index snp.SNP_Accession_Object_key;

-- duplicate of primary key
drop index snp.dp_snp_marker_idx_snpmarker_key;
drop index snp.snp_accession_idx_accession_key;
drop index snp.snp_consensussnp_idx_consensussnp_key;
drop index snp.snp_consensussnp_marker_idx_marker_fxn_cs_key;
drop index snp.snp_consensussnp_marker_idx_consensussnp_marker_key;
drop index snp.snp_coord_cache_idx_cache_cs_key;
drop index snp.snp_subsnp_idx_subsnp_key;
drop index snp.snp_consensussnp_strainallele_idx_primary;
drop index snp.snp_consensussnp_strainallele_idx_strain_key;
drop index snp.snp_coord_cache_idx_chr_startcoord;
drop index snp.snp_flank_idx_consensussnp_key_seqnum;
drop index snp.snp_population_idx_population_key;
drop index snp.snp_strain_idx_snpstrain_key;
drop index snp.snp_strain_idx_mgdstrain_key;
drop index snp.snp_subsnp_idx_consensussnp_key;
drop index snp.snp_subsnp_strainallele_idx_subsnp_key;


-- as part of TR10788/postgres, this table is no longer needed
drop table snp.mrk_location_cache;

-- tables that are no longer needed?
-- remove from pgsnpdbschema as well
drop table snp.mgi_columns;
drop table snp.mgi_tables;
-- drop table snp.mgi_dbinfo

EOSQL

date | tee -a ${LOG}

# should not need to do this step
${PG_SNP_DBSCHEMADIR}/index/SNP_Accession_create.object | tee -a ${LOG}
${PG_SNP_DBSCHEMADIR}/index/SNP_ConsensusSnp_create.object | tee -a ${LOG}
${PG_SNP_DBSCHEMADIR}/index/SNP_ConsensusSnp_Marker_create.object | tee -a ${LOG}
${PG_SNP_DBSCHEMADIR}/index/SNP_ConsensusSnp_StrainAllele_create.object | tee -a ${LOG}
${PG_SNP_DBSCHEMADIR}/index/SNP_Coord_Cache_create.object | tee -a ${LOG}
${PG_SNP_DBSCHEMADIR}/index/SNP_Flank_create.object | tee -a ${LOG}
${PG_SNP_DBSCHEMADIR}/index/SNP_Population_create.object | tee -a ${LOG}
${PG_SNP_DBSCHEMADIR}/index/SNP_Strain_create.object | tee -a ${LOG}
${PG_SNP_DBSCHEMADIR}/index/SNP_SubSnp_create.object | tee -a ${LOG}
${PG_SNP_DBSCHEMADIR}/index/SNP_SubSnp_StrainAllele_create.object | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

