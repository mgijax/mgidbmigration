#!/bin/csh -fx

#
# Migration for C4AM -- 
# (part 1 - optionally load dev database. Migration of existing data 
# into new structures)

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
# Migrate data
#
date | tee -a ${LOG}

echo "--- Direct Marker and Gene Model Collection Deletes" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

exec MAP_deleteByCollection "ENSEMBL Gene Model"
go

exec MAP_deleteByCollection "VEGA Gene Model"
go

exec MAP_deleteByCollection "NCBI Gene Model"
go

exec MAP_deleteByCollection "MGI QTL"
go

exec MAP_deleteByCollection "Roopenian STS"
go

exec MAP_deleteByCollection "NCBI UniSTS"
go

exec MAP_deleteByCollection "TR9601 DNA sequences"
go

exec MAP_deleteByCollection "miRBase"
go

EOSQL

echo "--- Finished  Direct Marker and Gene Model Collection Deletes" | tee -a ${LOG}

date | tee -a ${LOG}

echo "--- Delete MirBase Ids from Markers " | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

select _Accession_key
into #toDelete
from ACC_Accession
where _LogicalDB_key = 83
and _MGIType_key = 2
go

create index idx1 on #toDelete(_Accession_key)
go

delete from ACC_AccessionReference
where _Accession_key in (
select _Accession_key
from #toDelete)
go

delete from ACC_Accession
where _Accession_key in (
select _Accession_key
from #toDelete)
go

EOSQL

echo "--- Finished Deleting MirBase Ids from Markers " | tee -a ${LOG}

#
# Migrate database structures
#
date | tee -a ${LOG}
echo "--- Add column to MRK_Location_Cache" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/table/MRK_Location_Cache_drop.object
${MGD_DBSCHEMADIR}/table/MRK_Location_Cache_create.object

date | tee -a ${LOG}
echo "--- Bind defaults for MRK_Location_Cache" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/default/MRK_Location_Cache_bind.object

date | tee -a ${LOG}
echo "--- Add indexes to MRK_Location_Cache" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/index/MRK_Location_Cache_create.object

date | tee -a ${LOG}
echo "--- Add primary key for MRK_Location_Cache" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/key/MRK_Location_Cache_create.object

date | tee -a ${LOG}
echo "--- Add foreign key relationships for MRK_Location_Cache" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/key/MGI_Organism_drop.object
${MGD_DBSCHEMADIR}/key/MGI_User_drop.object
${MGD_DBSCHEMADIR}/key/MRK_Marker_drop.object

${MGD_DBSCHEMADIR}/key/MGI_Organism_create.object
${MGD_DBSCHEMADIR}/key/MGI_User_create.object
${MGD_DBSCHEMADIR}/key/MRK_Marker_create.object

date | tee -a ${LOG}
echo "--- Re-build dependent trigger on MRK_Marker" | tee -a ${LOG}

${MGD_DBSCHEMADIR}/trigger/MRK_Marker_drop.object
${MGD_DBSCHEMADIR}/trigger/MRK_Marker_create.object

date | tee -a ${LOG}
echo 'Drop and Recreate Stored Procedures' | tee -a ${LOG}
${MGD_DBSCHEMADIR}/procedure/MRK_reloadLocation_drop.object
${MGD_DBSCHEMADIR}/procedure/MRK_reloadLocation_create.object

date | tee -a ${LOG}
echo "--- Re-setting permissions/schema ---"
${MGD_DBSCHEMADIR}/all_perms.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo 'Reload Marker Location Cache table' | tee -a ${LOG}
${MRKCACHELOAD}/mrklocation.csh

###-------------------------------------------------------------------------###
### Broadcast the build 38 novel genes.  The broadcast script also runs the
### mapping load using the input file created by the initial nomen load.
###-------------------------------------------------------------------------###
date | tee -a ${LOG}
echo 'Running Nomen Broadcast' | tee -a ${LOG}
./broadcast.csh | tee -a ${LOG}

date | tee -a ${LOG}
