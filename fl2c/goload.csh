#!/bin/csh -fx

#
# wts2-1155/GOC taking over GOA mouse, GOA human, etc.
#

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
echo '--- starting goload.csh' | tee -a $LOG

echo 'MGD_DBNAME='$MGD_DBNAME | tee -a $LOG 
echo 'MGD_DBPASSWORDFILE='$MGD_DBPASSWORDFILE | tee -a $LOG 
echo 'MGD_DBSERVER='$MGD_DBSERVER | tee -a $LOG 
echo 'MGD_DBUSER='$MGD_DBUSER | tee -a $LOG 

date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
EOSQL
date | tee -a ${LOG}

rm -rf ${DATADOWNLOADS}/snapshot.geneontology.org/products/upstream_and_raw_data/noctua_mgi.gpad.gz
rm -rf ${DATADOWNLOADS}/go_noctua
rm -rf ${DATALOAD}/go/gomousenoctua/input/noctua_mgi.gpad
rm -rf ${DATALOAD}/go/gomousenoctua/input/noctua_pr.gpad
${MIRROR_WGET}/download_package snapshot.geneontology.org.goload.annotations
${MIRROR_WGET}/download_package snapshot.geneontology.org.goload.products
cd ${DATADOWNLOADS}
rm -rf go_noctua
ln -s snapshot.geneontology.org/annotations go_noctua

${GOLOAD}/go.sh

cd ${PUBRPTS}
source ./Configuration
cd daily
${PYTHON} GO_gpi.py
${PYTHON} GO_gene_association.py

echo '--- finished goload.csh' | tee -a ${LOG}

