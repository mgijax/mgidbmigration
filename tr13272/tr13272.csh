#!/bin/csh -f

#
# tags needed:
#
# reports_db
# goload
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
 
#./orcid1.csh | tee -a $LOG
#./orcid2.csh | tee -a $LOG
#./proteincomplex.csh | tee -a $LOG
#./ro.csh | tee -a $LOG

#cd ${PUBRPTS}
#source ./Configuration
#cd daily
#$PYTHON GO_gpi.py | tee -a $LOG

# run goload

#${MIRROR_WGET}/download_package purl.obolibrary.org.pr | tee -a $LOG
#${MIRROR_WGET}/download_package purl.obolibrary.org.uberon.obo | tee -a $LOG
#${MIRROR_WGET}/download_package ftp.ebi.ac.uk.goload | tee -a $LOG
#${MIRROR_WGET}/download_package ftp.geneontology.org.goload | tee -a $LOG
#${MIRROR_WGET}/download_package snapshot.geneontology.org.goload | tee -a $LOG
#${MIRROR_WGET}/download_package snapshot.geneontology.org.goload.noctua | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
delete from voc_annot where _annottype_key = 1000;
EOSQL

#cd ${GOLOAD}/gomousenoctua
#./gomousenoctua.sh | tee -a $LOG

${GOLOAD}/go.sh | tee -a $LOG

cd ${PUBRPTS}
source ./Configuration
cd daily
$PYTHON GO_gene_association.py | tee -a $LOG
cd ../weekly
$PYTHON GO_gene_association_nonmouse.py | tee -a $LOG

date |tee -a $LOG
