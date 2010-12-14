#!/bin/csh -fx

#
# Migration for TR10273 -- Europhenome/Sanger MP annotations
# (part 1 - migration of existing data into new structures)

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

setenv SCHEMA ${MGD_DBSCHEMADIR}
setenv PERMS ${MGD_DBPERMSDIR}
setenv UTILS ${MGI_DBUTILS}

setenv DB_PARMS "${MGD_DBUSER} ${MGI_DBPASSWORDFILE} ${MGD_DBSERVER} ${MGD_DBNAME}"

cd ${CWD}

###-------------------------------------------------###
###--- revisions to existing database components ---###
###-------------------------------------------------###

date | tee -a ${LOG}
echo "--- Table revisions" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go


/* for tables with columns added or removed (GXD_AllelePair), we must:
 * 	1. rename the existing versions
 * 	2. create new versions
 * 	3. load data into new versions
 * 	4. drop renamed versions (from 1)
 * 	5. add indexes & keys to new versions
 */

/* rename tables which will have columns added or removed */

sp_rename GXD_AllelePair, GXD_AllelePair_Old
go
EOSQL

# create new versions of old tables

date | tee -a ${LOG}
echo "--- Adding new versions of old tables" | tee -a ${LOG}

${SCHEMA}/table/GXD_AllelePair_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Adding permissions on re-created tables" | tee -a ${LOG}

${PERMS}/public/table/GXD_AllelePair_grant.object | tee -a ${LOG}
${PERMS}/curatorial/table/GXD_AllelePair_grant.object | tee -a ${LOG}

# add defaults related to new versions of old tables

date | tee -a ${LOG}
echo "--- Adding defaults to new versions of old tables" | tee -a ${LOG}

${SCHEMA}/default/GXD_AllelePair_bind.object | tee -a ${LOG}

# drop and re-create triggers on tables which we altered 

date | tee -a ${LOG}
echo "--- Re-creating triggers on existing tables" | tee -a ${LOG}

${SCHEMA}/trigger/GXD_AllelePair_drop.object | tee -a ${LOG}
${SCHEMA}/trigger/GXD_AllelePair_create.object | tee -a ${LOG}

# add keys for new tables (done after existing tables have been modified)

date | tee -a ${LOG}
echo "--- Creating new keys" | tee -a ${LOG}


cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/* populate new GXD_Allele_Pair set new mutant cell line keys null */

insert into GXD_AllelePair
select _AllelePair_key, _Genotype_key, _Allele_key_1, _Allele_key_2, null, null, _Marker_key, _PairState_key, _Compound_key, sequenceNum, _CreatedBy_key, _ModifiedBy_key, creation_date, modification_date
from GXD_AllelePair_Old 
go
/* 55968 */

/* Query for records in ALL_Allele_CellLine where there is only */
/* one cell line  then update GXD_AllelePair.._MutantCellLine_key_1 */
select _Allele_key, _MutantCellLine_key
into #oneCL
from ALL_Allele_CellLine
group by _Allele_key
having count(*) = 1
/* 552247 */

/* update GXD_AllelePair._MutantCellLine_key_1 */
update GXD_AllelePair
set _MutantCellLine_key_1 = c._MutantCellLine_key
from GXD_AllelePair a, #oneCL c
where a._Allele_key_1 = c._Allele_key
/* 35575 rows affected */
go

update statistics GXD_AllelePair
go

/* drop old versions of tables */

drop table GXD_AllelePair_Old
go

EOSQL

# create indexes and keys on re-created tables

date | tee -a ${LOG}
echo "--- Adding indexes and keys on re-created tables" | tee -a ${LOG}

${SCHEMA}/key/GXD_AllelePair_create.object | tee -a ${LOG}
${SCHEMA}/index/GXD_AllelePair_create.object | tee -a ${LOG}

# create triggers on re-created tables
${SCHEMA}/trigger/GXD_AllelePair_create.object | tee -a ${LOG}

###------------------------------------------------------------------------###
###--- give up and re-do everything, since Sybase randomly loses pieces ---###
###------------------------------------------------------------------------###

date | tee -a ${LOG}
echo "--- Remove mgddbschema logs" | tee -a ${LOG}
${SCHEMA}/removelogs.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Run reconfig.csh" | tee -a ${LOG}
${SCHEMA}/reconfig.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Revoke perms" | tee -a ${LOG}
${PERMS}/all_revoke.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Grant perms" | tee -a ${LOG}
${PERMS}/all_grant.csh | tee -a ${LOG}

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}

dump_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/sc/mgd.tr10273.backup | tee -a ${LOG}
date | tee -a ${LOG}
echo "--- Finished database dump" | tee -a ${LOG}
