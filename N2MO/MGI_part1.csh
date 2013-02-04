#!/bin/csh -fx

#
# Migration for N2MO -- 
# (part 1 - optionally load dev database. Create new structures)

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${MGD_DBSERVER}"
echo "Database: ${MGD_DBNAME}"

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

#
# load a production backup into mgd and radar
#

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /lindon/sybase/mgd.backup | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

if ("${1}" == "dev") then
    echo "--- Loading new database into ${RADAR_DBSERVER}..${RADAR_DBNAME}" | tee -a ${LOG}
    load_db.csh ${RADAR_DBSERVER} ${RADAR_DBNAME} /lindon/sybase/radar.backup | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${RADAR_DBSERVER}..${RADAR_DBNAME}" | tee -a ${LOG}
endif

echo "--- Finished loading databases " | tee -a ${LOG}

#
# Update EUCOMM references
#

date | tee -a ${LOG}
echo "--- Update EUCOMM Reference titles ---" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}
update BIB_Refs
set title = "Alleles produced for the EUCOMM and EUCOMMTools projects by the Wellcome Trust Sanger Institute"
where _Refs_key = 156938
go

update BIB_Refs
set title = "Alleles produced for the EUCOMM and EUCOMMTools projects by the Helmholtz Zentrum Muenchen GmbH (Hmgu)"
where _Refs_key = 158158
go

EOSQL

#
# Migrate database structures
#
date | tee -a ${LOG}
echo "--- Create MRK_Cluster* tables" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/table/MRK_Cluster_create.object
${MGD_DBSCHEMADIR}/table/MRK_ClusterMember_create.object

date | tee -a ${LOG}
echo "--- Bind defaults for MRK__create.object" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/default/MRK_Cluster_bind.object

date | tee -a ${LOG}
echo "--- Add indexes to MRK_Cluster*" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/index/MRK_Cluster_create.object
${MGD_DBSCHEMADIR}/index/MRK_ClusterMember_create.object

date | tee -a ${LOG}
echo "--- Add primary key for MRK_Cluster*" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/key/MRK_Cluster_create.object
${MGD_DBSCHEMADIR}/key/MRK_ClusterMember_create.object

date | tee -a ${LOG}
echo "--- Add foreign key relationships for MRK_Cluster*" | tee -a ${LOG}
${MGD_DBSCHEMADIR}/key/VOC_Term_drop.object
${MGD_DBSCHEMADIR}/key/MGI_User_drop.object
${MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object

${MGD_DBSCHEMADIR}/key/VOC_Term_create.object
${MGD_DBSCHEMADIR}/key/MGI_User_create.object
${MGD_DBSCHEMADIR}/key/MRK_Marker_create.object

date | tee -a ${LOG}
echo "--- Create triggers" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/trigger/MRK_Marker_drop.object
${MGD_DBSCHEMADIR}/trigger/VOC_Term_drop.object

${MGD_DBSCHEMADIR}/trigger/MRK_Cluster_create.object
${MGD_DBSCHEMADIR}/trigger/MRK_Marker_create.object
${MGD_DBSCHEMADIR}/trigger/VOC_Term_create.object

date | tee -a ${LOG}
echo '---Create Stored Procedures' | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MRK_reloadLabel_drop.object
${MGD_DBSCHEMADIR}/procedure/MRK_reloadLabel_create.object

${MGD_DBSCHEMADIR}/procedure/VOC_Cache_OMIM_Counts_drop.object
${MGD_DBSCHEMADIR}/procedure/VOC_Cache_OMIM_Counts_create.object

${MGD_DBSCHEMADIR}/procedure/VOC_Cache_OMIM_Markers_drop.object
${MGD_DBSCHEMADIR}/procedure/VOC_Cache_OMIM_Markers_create.object 

date | tee -a ${LOG}
echo "--- Re-setting permissions/schema ---"
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}


