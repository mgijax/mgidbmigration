#!/bin/csh -f

#
# tags needed:
#
# reports_db
# goload
# annotload
# lib_py_report
#
# delete *all* GO Annotations
# run goload
# run uniprotload
# generate reports
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
 
# run goload

${MIRROR_WGET}/download_package purl.obolibrary.org.pr | tee -a $LOG
${MIRROR_WGET}/download_package purl.obolibrary.org.uberon.obo | tee -a $LOG
${MIRROR_WGET}/download_package ftp.ebi.ac.uk.goload | tee -a $LOG
${MIRROR_WGET}/download_package ftp.geneontology.org.goload | tee -a $LOG
${MIRROR_WGET}/download_package snapshot.geneontology.org.goload | tee -a $LOG
${MIRROR_WGET}/download_package snapshot.geneontology.org.goload.noctua | tee -a $LOG
scp bhmgiapp01:/data/downloads/uniprot/uniprotmus.dat /data/downloads/uniprot

${GOLOAD}/go.sh | tee -a $LOG

${UNIPROTLOAD}/bin/uniprotload.sh | tee -a $LOG

cd ${PUBRPTS}
source ./Configuration
cd daily
$PYTHON GO_gene_association.py | tee -a $LOG

cd ${QCRPTS}
source ./Configuration
cd weekly
$PYTHON GO_stats.py

date |tee -a $LOG
