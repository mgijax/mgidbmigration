#!/bin/csh -fx

#
# Migration for TR9368 - bug fix to searchtool-related stored procedures
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration
setenv CWD `pwd`	# current working directory

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
    echo "--- Finished loading database" | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

setenv SCHEMA ${MGD_DBSCHEMADIR}
setenv PERMS ${MGD_DBPERMSDIR}
setenv UTILS ${MGI_DBUTILS}

setenv DBCLUSTIDXSEG seg0
setenv DBNONCLUSTIDXSEG seg1

###-------------------------------------------------------###
###--- recreate the nine problematic stored procedures ---###
###-------------------------------------------------------###

date | tee -a ${LOG}
echo "--- Recreating procedures" | tee -a ${LOG}

${SCHEMA}/procedure/VOC_Cache_PIRSF_Counts_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_OMIM_Counts_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_InterPro_Counts_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_GO_Counts_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_MP_Counts_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_OMIM_Markers_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_Other_Markers_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_MP_Markers_drop.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_Anatomy_Markers_drop.object | tee -a ${LOG}

${SCHEMA}/procedure/VOC_Cache_PIRSF_Counts_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_OMIM_Counts_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_InterPro_Counts_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_GO_Counts_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_MP_Counts_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_OMIM_Markers_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_Other_Markers_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_MP_Markers_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_Anatomy_Markers_create.object | tee -a ${LOG}

# These procedures are for use by mgd_dbo, so there are no permissions scripts

###-------------------------------------###
###--- recreate cache table contents ---###
###-------------------------------------###

date | tee -a ${LOG}
echo "--- Upating counts" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

exec VOC_Cache_Counts
go
EOSQL

date | tee -a ${LOG}
echo "--- Upating associated markers" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

exec VOC_Cache_Markers
go
EOSQL

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished migration" | tee -a ${LOG}
