#!/bin/csh -fx

#
# Migration for dbSNP 142
# (part 1 - optionally load dev database. etc)
#
# Products:
#
# Delete 'SNP Marker Distance DAG': DAG_DAG._Dag_key = 11
#
# Remove the following 'SNP Function Class' terms (_Vocab_key = 49)
#  10125470 SNP_Marker_Distance_DAG
#  10125471 dbSNP Function Class
#  10125480 Locus-Region (downstream)
#  10125481 Locus-Region (upstream)
#  10125485 within 1000 kb downstream of
#  10125486 within 1000 kb upstream of
#  10125487 within 500 kb of
#  10125488 within 500 kb downstream of
#  10125489 within 500 kb upstream of
#  10125490 within 100 kb of
#  10125491 within 100 kb downstream of
#  10125492 within 100 kb upstream of
#  10125493 within 10 kb of
#  10125494 within 10 kb downstream of
#  10125495 within 10 kb upstream of
#  10125496 within 2 kb of
#  10125497 within 2 kb downstream of
#  10125498 within 2 kb upstream of
#
# Update (reuse the key) the following 'SNP Function Class' term
#  10125472 within 1000 kb of to within distance of
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

echo "--- Delete SNP Fxn Class DAG and update Fxn Class Vocabulary---"  | tee -a ${LOG}

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0

delete from DAG_DAG
        where _DAG_key = 11
;

update VOC_Term
	set term = 'within distance of'
	where _Term_key = 10125472 
;

delete from VOC_Term
	where _Term_key in (10125470, 10125471, 10125480, 10125481, 10125485, 10125486, 10125487, 10125488, 10125489, 10125490, 10125491, 10125492, 10125493, 10125494, 10125495, 10125496, 10125497, 10125498)
;

update mgd.MGI_dbinfo set
        schema_version = '6-0-3',
        public_version = 'MGI 6.03'
	snp_data_version = 'dbSNP Build 142'
;
update snp.mgi_dbinfo set
        schema_version = '6-0-3',
        public_version = 'MGI 6.03'
        snp_data_version = 'dbSNP Build 142'
;

EOSQL

date | tee -a ${LOG}
echo "--- Run Gene Summary Load ---" | tee -a ${LOG}
${GENESUMMARYLOAD}/bin/genesummaryload.sh

date | tee -a ${LOG}
echo "--- Finished" | tee -a ${LOG}
