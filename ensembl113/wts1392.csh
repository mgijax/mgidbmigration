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
 
setenv MRKLOG marker.log
rm -rf $MRKLOG
touch $MRKLOG
 
date | tee -a $LOG
 
#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#EOSQL

# make the Ensembl Reg 108 ID an Exact Synonym of the Marker
# create MRK_Coord text table
$PYTHON marker.py | tee -a $MRKLOG

# delete Ensembl Reg 108
# delete Ensembl Reg 108 Markers that do not have Alleles, or any other object
# has its own log file
./delete108.csh

# sophia will do this herself
#cp mrkcoordload.txt ${DATALOADSOUTPUT}/mgi/mrkcoordload/input
#${MRKCOORDLOAD}/bin/mrkcoordload.sh | tee -a $LOG

# the cascading delete takes care of this
# refresh the cache tables
#${SEQCACHELOAD}/seqmarker.csh | tee -a $LOG
#${MRKCACHELOAD}/mrklabel.csh | tee -a $LOG
#${MRKCACHELOAD}/mrkref.csh | tee -a $LOG
#${MRKCACHELOAD}/mrklocation.csh | tee -a $LOG

date |tee -a $LOG

