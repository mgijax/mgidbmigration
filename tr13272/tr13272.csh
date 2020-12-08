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
 
./orcid1.csh | tee -a $LOG
./orcid2.csh | tee -a $LOG
./proteincomplex.csh | tee -a $LOG
./ro.csh | tee -a $LOG

# run goload/goamouse/goamouse.csh
${MIRROR_WGET}/download_package purl.obolibrary.org.uberon.obo | tee -a $LOG
${MIRROR_WGET}/download_package ftp.ebi.ac.uk.goload | tee -a $LOG
${GOLOAD}/goamouse/goamouse.sh | tee -a $LOG

cd ${PUBRPTS}
source ./Configuration
cd daily
$PYTHON GO_gene_association2.py | tee -a $LOG
$PYTHON GO_gpi2.py | tee -a $LOG

date |tee -a $LOG
