#!/bin/csh -f

#
# Migration for TR 1027
# Changing varchar(255) to char(255)
#

setenv SYBASE   /opt/sybase

setenv DSQUERY	 $1
setenv DATABASE	$2

setenv LOG $0.log

set scripts = $SYBASE/admin

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
tr1027_a.sql $DSQUERY $MGD ALL_Molecular_Note note Allele >> $LOG
tr1027_a.sql $DSQUERY $MGD ALL_Note note Allele >> $LOG
tr1027_a.sql $DSQUERY $MGD BIB_Notes note Refs >> $LOG
tr1027_a.sql $DSQUERY $MGD GXD_AssayNote assayNote Assay >> $LOG
tr1027_a.sql $DSQUERY $MGD HMD_Notes notes Homology >> $LOG
tr1027_a.sql $DSQUERY $MGD IMG_ImageNote imageNote Image >> $LOG
tr1027_a.sql $DSQUERY $MGD MLD_Expt_Notes note Expt >> $LOG
tr1027_a.sql $DSQUERY $MGD MLD_Notes note Refs >> $LOG
tr1027_a.sql $DSQUERY $MGD MRK_Notes note Marker >> $LOG
tr1027_a.sql $DSQUERY $MGD PRB_Notes note Probe >> $LOG
tr1027_a.sql $DSQUERY $MGD PRB_Ref_Notes note Reference >> $LOG

set sql = /tmp/$$.sql

cat > $sql <<EOSQL

use $DATABASE
go

sp_foreignkey ALL_Molecular_Note, ALL_Allele, _Allele_key
go

sp_foreignkey ALL_Note, ALL_Allele, _Allele_key
go

sp_foreignkey BIB_Notes, BIB_Refs, _Refs_key
go

sp_foreignkey GXD_AssayNote, GXD_Assay, _Assay_key
go

sp_foreignkey HMD_Notes, HMD_Homology, _Homology_key
go

sp_foreignkey IMG_ImageNote, IMG_Image, _Image_key
go

sp_foreignkey MLD_Expt_Notes, MLD_Expts, _Expt_key
go

sp_foreignkey MLD_Notes, BIB_Refs, _Refs_key
go

sp_foreignkey MRK_Notes, MRK_Marker, _Marker_key
go

sp_foreignkey PRB_Notes, PRB_Probe, _Probe_key
go

sp_foreignkey PRB_Ref_Notes, PRB_Reference, _Reference_key
go

quit
 
EOSQL
  
$scripts/dbo_sql $sql >> $LOG
rm $sql
   
date >> $LOG
