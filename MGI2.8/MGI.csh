#!/bin/csh -f

#
# Migration for MGI 2.8
#
# Tables:	162
# Procedures:	 70
# Triggers:	119
# Views:	116
#

cd `dirname $0`

setenv NOMEN nomen_release
setenv STRAINS strains_release

setenv SYBASE	/opt/sybase
setenv DBUTILITIESDIR	/usr/local/mgi/dbutils/mgidbutilities

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

$DBUTILITIESDIR/bin/dev/load_devdb.csh $DBNAME mgd.backup mgd_dbo >>& $LOG
date >> $LOG
$DBUTILITIESDIR/bin/dev/load_devdb.csh $NOMEN nomen.backup mgd_dbo >>& $LOG
date >> $LOG
$DBUTILITIESDIR/bin/dev/load_devdb.csh $STRAINS strains.backup mgd_dbo >>& $LOG
date >> $LOG

echo "Update MGI DB Info..." >> $LOG
$DBUTILITIESDIR/bin/updatePublicVersion.csh $DBSERVER $DBNAME "MGI 2.8" >>& $LOG
$DBUTILITIESDIR/bin/updateSchemaVersion.csh $DBSERVER $DBNAME "mgddbschema-2-0-0" >>& $LOG
$DBUTILITIESDIR/bin/updateSchemaVersion.csh $DBSERVER $NOMEN "nomendbschema-3-0-3" >>& $LOG

echo "Data Migration..." >> $LOG
./MGItables.csh >>& $LOG
./tr256.csh >>& $LOG
./tr2714.csh >>& $LOG
./tr2718.csh >>& $LOG
./tr2916.csh >>& $LOG
./tr2358.csh >>& $LOG
./tr2541.csh >>& $LOG
./tr2239.csh >>& $LOG
./tr2867.csh >>& $LOG

#
# drop old/obsolete objects
#

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

drop table BIB_Refs_Old
go

drop table GXD_Antibody_Old
go

drop table GXD_GelLane_Old
go

drop table GXD_Genotype_Old
go

drop table GXD_AllelePair_Old
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

drop table GO_DataEvidence
go

drop table GO_Evidence
go

drop table GO_MarkerGO
go

drop table GO_Ontology
go

drop table GO_Term
go

use ${NOMEN}
go

drop table MGI_Tables_Old
go

drop table MGI_Columns_Old
go

checkpoint
go

quit
 
EOSQL
  
date >> $LOG

#
# Re-create all triggers, sps, views....
#

$DBUTILITIESDIR/bin/dev/reconfig_mgd.csh ${newmgddb} >>& $LOG
$DBUTILITIESDIR/bin/dev/reconfig_nomen.csh ${newnomendb} >>& $LOG

cat - <<EOSQL | doisql.csh $0 >> $LOG
  
use ${DBNAME}
go

exec MGI_Table_Column_Cleanup
go

checkpoint
go

quit
 
EOSQL

date >> $LOG

