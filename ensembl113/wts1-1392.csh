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
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

EOSQL

# make the Ensembl Reg 108 ID an Exact Synonym of the Marker
$PYTHON marker.py | tee -a $LOG

# delete Ensembl Reg 108
# delete Ensembl Reg 108 Markers that do not have Alleles, or any other object
./delete108.csh | tee -a $LOG

cp mrkcoordload.txt ${DATALOADSOUTPUT}/mgi/mrkcoordload/input
${MRKCOORDLOAD}/bin/mrkcoordload.sh | tee -a $LOG
${GENEMODELLOAD}/bin/runGeneModelCache.sh | tee -a $LOG

date |tee -a $LOG

