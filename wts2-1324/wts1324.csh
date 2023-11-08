#!/bin/csh -f

#
# Template
#


if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

date
 
# try run of entezgeneload for each table; should fail
./loadFiles.csh
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 
truncate table radar.dp_entrezgene_accession;
EOSQL
${ENTREZGENELOAD}/bin/loadAll.csh

./loadFiles.csh
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 
truncate table radar.dp_entrezgene_dbxref;
EOSQL
${ENTREZGENELOAD}/bin/loadAll.csh

./loadFiles.csh
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 
truncate table radar.dp_entrezgene_history;
EOSQL
${ENTREZGENELOAD}/bin/loadAll.csh

./loadFiles.csh
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 
truncate table radar.dp_entrezgene_info;
EOSQL
${ENTREZGENELOAD}/bin/loadAll.csh

./loadFiles.csh
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 
truncate table radar.dp_entrezgene_mim;
EOSQL
${ENTREZGENELOAD}/bin/loadAll.csh

./loadFiles.csh
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 
truncate table radar.dp_entrezgene_pubmed;
EOSQL
${ENTREZGENELOAD}/bin/loadAll.csh

./loadFiles.csh
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 
truncate table radar.dp_entrezgene_refseq;
EOSQL
${ENTREZGENELOAD}/bin/loadAll.csh

./loadFiles.csh
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 
truncate table radar.dp_entrezgene_synonym;
EOSQL
${ENTREZGENELOAD}/bin/loadAll.csh

# try run of entrezgeneload; should be successful
#./loadFiles.csh
#${ENTREZGENELOAD}/bin/loadAll.csh

date

