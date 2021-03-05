#!/bin/csh -f

#
# new tags:
# goload-6-0-16-5
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
 
#${PYTHON} proteincomplex.py | tee -a $LOG

${MIRROR_WGET}/download_package purl.obolibrary.org.pr.obo
${MIRROR_WGET}/download_package purl.obolibrary.org.uberon.obo
${MIRROR_WGET}/download_package ftp.ebi.ac.uk.goload
${MIRROR_WGET}/download_package ftp.geneontology.org.goload
${MIRROR_WGET}/download_package snapshot.geneontology.org.goload
${MIRROR_WGET}/download_package snapshot.geneontology.org.goload.noctua
${MIRROR_WGET}/download_package current.geneontology.org/annotations/rgd.gaf.gz

${PYTHON} ${GOLOLOAD}/go.sh | tee -a $LOG

cd ${PUBRPTS}
source ./Configuration
cd daily
${PYTHON} GO_gene_association.py | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
EOSQL

date |tee -a $LOG

