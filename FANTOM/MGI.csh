#!/bin/csh -f

#
# Migration for Fantom
#

cd `dirname $0`

setenv DBUTILITIESDIR	/usr/local/mgi/dbutils/mgidbutilities
setenv PYTHONPATH	/usr/local/mgi/lib/python

#setenv newmgddb /usr/local/mgi/dbutils/mgd
setenv newmgddb /home/lec/db/fantom2
setenv newmgddbschema ${newmgddb}/mgddbschema
setenv newmgddbperms ${newmgddb}/mgddbperms

setenv newnomendb /home/lec/db/fantom2
setenv newnomendbschema ${newmgddb}/nomendbschema
setenv newnomendbperms ${newmgddb}/nomendbperms

# sets database stuff (DBSERVER, DBNAME)
source ${newmgddbschema}/Configuration
setenv NOMEN nomen_fantom2

setenv LOG $0.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
#
# For integration testing purposes...comment out before production load
#

#$DBUTILITIESDIR/bin/dev/load_devdb.csh $DBNAME mgd.backup mgd_dbo >>& $LOG
#date >> $LOG
#$DBUTILITIESDIR/bin/dev/load_devdb.csh $NOMEN nomen.backup mgd_dbo >>& $LOG
#date >> $LOG

#echo "Reconfigure Nomen..." >> $LOG
#$DBUTILITIESDIR/bin/dev/reconfig_nomen.csh ${newnomendb} >>& $LOG
#date >> $LOG

echo "Data Migration..." >> $LOG
./mgifantom.csh >>& $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

drop table MGI_Fantom2_Old
go

checkpoint
go

quit
 
EOSQL
  
date >> $LOG

${newmgddbschema}/key/MGI_Fantom2_drop.logical >>& ${LOG}
${newmgddbschema}/key/MGI_Fantom2_create.logical >>& ${LOG}

date >> $LOG

