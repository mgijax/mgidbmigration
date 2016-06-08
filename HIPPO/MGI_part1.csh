#!/bin/csh -fx

#
# Migration for HIPPO TR12267 
# (part 1 - optionally load dev database. etc)
#
# Products:
#

###----------------------###
###--- initialization ---###
###----------------------###

cd `dirname $0` && source ../Configuration
setenv CWD `pwd`	# current working directory
echo "Server: ${PG_DBSERVER}"
echo "Database: ${PG_DBNAME}"

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
    echo "--- Loading new database into ${PG_DBSERVER}.${PG_DBNAME}.mgd" | tee -a ${LOG}
    ${PG_DBUTILS}/bin/loadDB.csh -a ${PG_DBSERVER} ${PG_DBNAME} mgd /bhmgidb01/dump/mgd.dump  | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${PG_DBSERVER}.${PG_DBNAME}.mgd" | tee -a ${LOG}
endif

if ("${1}" == "dev") then
    echo "--- Loading new database into ${PG_DBSERVER}.${PG_DBNAME}.radar" | tee -a ${LOG}
    ${PG_DBUTILS}/bin/loadDB.csh  ${PG_DBSERVER} ${PG_DBNAME} radar /bhmgidb01/dump/radar.dump | tee -a ${LOG}
    date | tee -a ${LOG}
else
    echo "--- Working on existing database: ${PG_DBSERVER}.${PG_DBNAME}.radar" | tee -a ${LOG}
endif

echo "--- Finished loading databases " | tee -a ${LOG}

#
# run migration
#
echo "--- Drop/create VOC_Term triggers ---"
${PG_MGD_DBSCHEMADIR}/trigger/VOC_Term_create.object

echo "--- Delete Old Sanger/Euph Annotations, properties, evidence ---"  | tee -a ${LOG}

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0
select distinct a._Annot_key
into temporary table toDelete
from VOC_Annot a, VOC_Evidence ve
where a._AnnotType_key = 1002
and a._Annot_key = ve._Annot_key
and ve._Refs_key in (167061, 176391)
;

create index idx1 on toDelete(_Annot_key)
;

delete from VOC_Annot a
using toDelete d
where d._Annot_key = a._Annot_key
;

EOSQL

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
