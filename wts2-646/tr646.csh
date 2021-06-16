#!/bin/csh -f

#
# Template
#


if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
#
# TAGS
#
# mirror_wget : remove mim2gene_medgen from mirror_wget/ftp.ncbi.nih.gov
# entrezgeneload
# radardbschema : remove DP_EntrezGene_MIM
#

rm -rf ${DATADOWNLOADS}/ftp.ncbi.nih.gov/gene/DATA/mim2gene_medgen

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

delete from voc_annot where _annottype_key = 1022;
drop table if exists DP_EntrezGene_MIM;
drop table if exists DP_HomoloGene;

EOSQL

rm -rf ${DATALOADSOUTPUT}/entrezgene/entrezgeneload/output/human/annotations.omim1*
${ENTREZGENELOAD}/human/load.csh | tee -a $LOG

# because 2 radar tables are being obsoleted...
${MGI_JAVALIB}/lib_java_dbsrdr/Install | tee -a $LOG
${MGI_JAVALIB}/lib_java_dla/Install | tee -a $LOG

date |tee -a $LOG

