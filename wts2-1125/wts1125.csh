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
 
rm -rf /data/downloads/go_noctua/noctua_pr.gpad.gz

${MIRROR_WGET}/download_package purl.obolibrary.org.pr
${MIRROR_WGET}/download_package purl.obolibrary.org.uberon.obo
${MIRROR_WGET}/download_package ftp.ebi.ac.uk.goload
${MIRROR_WGET}/download_package ftp.geneontology.org.goload
${MIRROR_WGET}/download_package snapshot.geneontology.org.goload
${MIRROR_WGET}/download_package snapshot.geneontology.org.goload.noctua

cd ${GOLOAD}
go.sh

cd $PUBRPTS
source ./Configuration
cd ${PUBRPTS}/daily
$PYTHON GO_gene_association.py
$PYTHON GO_gpi.py

date |tee -a $LOG

