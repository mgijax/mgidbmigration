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

#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene2accession ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene2accession.mgi ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene2accession.new ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene2pubmed ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene2pubmed.mgi ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene2refseq ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene2refseq.mgi ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene2refseq.new ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene_dbxref.bcp ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene_history ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene_history.mgi ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene_info ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene_info.bcp ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene_info.mgi ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/gene_synonym.bcp ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/mim2gene_medgen ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input
#rcp bhmgiapp01:/data/loads/entrezgene/entrezgeneload/input/mim2gene_medgen.mgi ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/input

# try run of entezgeneload for each table; should fail
./loadFiles.csh
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 
truncate table radar.dp_entrezgene_accession;
EOSQL
${ENTREZGENELOAD}/bin/loadAll.csh

#./loadFiles.csh
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 
#truncate table radar.dp_entrezgene_dbxref;
#EOSQL
#${ENTREZGENELOAD}/bin/loadAll.csh

#./loadFiles.csh
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 
#truncate table radar.dp_entrezgene_history;
#EOSQL
#${ENTREZGENELOAD}/bin/loadAll.csh

#./loadFiles.csh
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 
#truncate table radar.dp_entrezgene_info;
#EOSQL
#${ENTREZGENELOAD}/bin/loadAll.csh

#./loadFiles.csh
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 
#truncate table radar.dp_entrezgene_mim;
#EOSQL
#${ENTREZGENELOAD}/bin/loadAll.csh

#./loadFiles.csh
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 
#truncate table radar.dp_entrezgene_pubmed;
#EOSQL
#${ENTREZGENELOAD}/bin/loadAll.csh

#./loadFiles.csh
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 
#truncate table radar.dp_entrezgene_refseq;
#EOSQL
#${ENTREZGENELOAD}/bin/loadAll.csh

#./loadFiles.csh
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 
#truncate table radar.dp_entrezgene_synonym;
#EOSQL
#${ENTREZGENELOAD}/bin/loadAll.csh

# try run of entrezgeneload; should be successful
#./loadFiles.csh
#${ENTREZGENELOAD}/bin/loadAll.csh

date

