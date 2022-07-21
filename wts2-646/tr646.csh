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
# mgidbmigration-6-0-21-
# mirror_wget-6-0-21-3
# entrezgeneload-6-0-21-
# radardbschema-6-0-21-1
#

rm -rf ${DATADOWNLOADS}/ftp.ncbi.nih.gov/gene/DATA/mim2gene_medgen

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
drop table if exists DP_EntrezGene_MIM;
EOSQL

${ENTREZGENELOAD}/human/annotations.csh | tee -a $LOG

# because radar tables are being obsoleted...
${MGI_JAVALIB}/lib_java_dbsrdr/Install | tee -a $LOG
${MGI_JAVALIB}/lib_java_dla/Install | tee -a $LOG

date |tee -a $LOG

