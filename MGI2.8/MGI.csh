#!/bin/csh -f

#
# Migration for MGI 2.8
#
# Tables:	159
# Procedures:	 68
# Triggers:	119
# Views:	113
#

cd `dirname $0`

setenv NOMEN nomen_release
setenv STRAINS strains_release

setenv SYBASE	/opt/sybase
setenv DBUTILITIESDIR	/usr/local/mgi/dbutils/mgidbutilities
set path = ($DBUTILITIESDIR/bin $DBUTILITIESDIR/bin/dev $path $SYBASE/bin)

setenv oldstrainsdbschema /usr/local/mgi/dbutils/strains/strainsdbschema

setenv newmgddb /usr/local/mgi/dbutils/mgd_release
setenv newmgddbschema ${newmgddb}/mgddbschema
setenv newmgddbperms ${newmgddb}/mgddbperms
setenv newnomendb /usr/local/mgi/dbutils/nomen_release
setenv newnomendbschema ${newnomendb}/nomendbschema
setenv newnomendbperms ${newnomendb}/nomendbperms

source ${newmgddbschema}/Configuration

setenv LOG MGI.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
#
# For integration testing purposes...comment out before production load
#

load_devdb.csh $DBNAME mgd.backup mgd_dbo >>& $LOG
load_devdb.csh $NOMEN nomen.backup mgd_dbo >>& $LOG
load_devdb.csh $STRAINS strains.backup mgd_dbo >>& $LOG

echo "Update MGI DB Info..." >> $LOG
updateSchemaVersion.csh $DBSERVER $DBNAME "mgddbschema-2-0-0" >>& $LOG
updateSchemaVersion.csh $DBSERVER $NOMEN "nomendbschema-3-0-3" >>& $LOG

echo "Data Migration..." >> $LOG
./MGItables.csh >>& LOG
./tr256.csh >>& $LOG
./tr2714.csh >>& $LOG
./tr2718.csh >>& $LOG
./tr2902.csh >>& $LOG
./tr2916.csh >>& $LOG
./tr2358.csh >>& $LOG
./tr2541.csh >>& $LOG

#
# Re-create all triggers, sps, views....
#

reconfig_mgd.csh ${newmgddb} >>& $LOG
reconfig_nomen.csh ${newnomendb} >>& $LOG

date >> $LOG

#
# drop old/obsolete objects
#

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

drop table GXD_AllelePair_Old
go

drop table GXD_Antibody_Old
go

drop table GXD_GelLane_Old
go

drop table PRB_Strain_Old
go

drop table PRB_Source_Old
go

drop table RI_RISet_Old
go

drop table MLD_RI_Old
go

drop table MGI_Tables_Old
go

drop table MGI_Columns_Old
go

exec MGI_Table_Column_Cleanup
go

checkpoint
go

quit
 
EOSQL
  
date >> $LOG

