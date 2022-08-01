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
 
#${RADAR_DBSCHEMADIR}/table/DP_EntrezGene_MIM_drop.object | tee -a $LOG
${RADAR_DBSCHEMADIR}/table/DP_EntrezGene_MIM_create.object | tee -a $LOG
${RADAR_DBSCHEMADIR}/index/DP_EntrezGene_MIM_create.object | tee -a $LOG

${MIRROR_WGET}/download_package ftp.ncbi.nih.gov.entrez_gene | tee -a $LOG
${ENTREZGENELOAD}/loadFiles.csh | tee -a $LOG
${ENTREZGENELOAD}/loadHuman.csh | tee -a $LOG

#${MGI_JAVALIB}/lib_java_dbsrdr/Install | tee -a $LOG
#${MGI_JAVALIB}/lib_java_dla/Install | tee -a $LOG

date |tee -a $LOG

