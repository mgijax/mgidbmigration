#!/bin/csh -f

#
# driver notes
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
delete from MGI_Relationship where _Category_key = 1006;
EOSQL

setenv COLDELIM "|" 
setenv LINEDELIM  "\n"

./drivernotes.py

# need python script to load 
# MRK_Marker (non-mouse)
# MGI_Relationship

${PG_DBUTILS}/bin/bcpin.csh ${PG_DBSERVER} ${PG_DBNAME} MGI_Relationship ${DBUTILS}/mgidbmigration/GMC MGI_Relationship.bcp ${COLDELIM} ${LINEDELIM} mgd | tee -a ${LOG}

# query alleles with no mol reference
./driverref.csh

# query using driver note data
./drivermouse.csh

# query using mgi_relationship data
./drivercheck.csh

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#delete from MGI_Note where _NoteType_key = 1034;
#delete from MGI_NoteType where _NoteType_key = 1034;
#EOSQL

date |tee -a $LOG

