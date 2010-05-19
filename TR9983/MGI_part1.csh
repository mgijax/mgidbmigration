#!/bin/csh -fx

# Migration for "adding alleles to search tool" release
# (part 1 - adding new database structures and populating them)

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

date | tee -a ${LOG}
echo "--- Updating version numbers in db..." | tee -a ${LOG}

# number references in comments are to sections of schema doc GeneTrapLF.pdf

${UTILS}/bin/updatePublicVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "MGI 4.35" | tee -a ${LOG}
${UTILS}/bin/updateSchemaVersion.csh ${MGD_DBSERVER} ${MGD_DBNAME} "4-3-5-0" | tee -a ${LOG}

cd ${CWD}

###----------------------###
###--- add new tables ---###
###----------------------###

# add new tables

date | tee -a ${LOG}
echo "--- Creating new tables" | tee -a ${LOG}

${SCHEMA}/table/VOC_Allele_Cache_create.object | tee -a ${LOG}

# add permissions for new tables

date | tee -a ${LOG}
echo "--- Adding new perms" | tee -a ${LOG}

${PERMS}/public/table/VOC_Allele_Cache_grant.object | tee -a ${LOG}

###--------------------------###
###--- add new procedures ---###
###--------------------------###

# add new stored procedures

date | tee -a ${LOG}
echo "--- Creating new tables" | tee -a ${LOG}

${SCHEMA}/procedure/VOC_Cache_MP_Alleles_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_OMIM_Alleles_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_Alleles_create.object | tee -a ${LOG}

# no procedure permissions needed, since these will only be executed by dbo

###--------------------------###
###--- update procedures ---###
###--------------------------###

# add new stored procedures

date | tee -a ${LOG}
echo "--- Updating stored procedures" | tee -a ${LOG}

${SCHEMA}/procedure/VOC_Cache_MP_Markers_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_OMIM_Markers_drop.object | tee -a ${LOG}

${SCHEMA}/procedure/VOC_Cache_MP_Markers_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_OMIM_Markers_create.object | tee -a ${LOG}


# no procedure permissions needed, since these will only be executed by dbo

###-----------------------------------###
###--- populate & index new tables ---###
###-----------------------------------###

# add cached data by calling the new stored procedures

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

exec VOC_Cache_Alleles
go
exec VOC_Cache_Markers
go
EOSQL

# add indexes for new tables (do this after loading tables so the indexes
# and statistics are up-to-date after we load the data, plus we get better
# performance during the load)

date | tee -a ${LOG}
echo "--- Adding indexes" | tee -a ${LOG}

${SCHEMA}/index/VOC_Allele_Cache_create.object | tee -a ${LOG}

###------------###
###--- done ---###
###------------###

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
