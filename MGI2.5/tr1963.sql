#!/bin/csh -f

#
# Migration for TR 1963
#

setenv SYBASE   /opt/sybase

setenv DSQUERY	 $1
setenv DATABASE	$2
setenv DBUSER mgd_dbo
setenv DBPASSWORD $SYBASE/admin/.mgd_dbo_password

#setenv TABLES "CRS_Matrix MLC_Marker MLC_Marker_edit PRB_Strain_Marker RI_RISet RI_Summary_Expt_Ref RI_Summary ACC_AccessionReference MLC_Lock_edit MLC_Reference MLC_Reference_edit"
setenv TABLES "CRS_Matrix"

setenv REVENGINEER /home/lec/db/revengineer
setenv BCPDIR /extra2/sybase/data

setenv LOG $0.log

set scripts = $SYBASE/admin

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set sql = /tmp/$$.sql

cat > $sql <<EOSQL

sp_dboption $DATABASE, "select into", true
go

use $DATABASE
go

checkpoint
go

EOSQL

cat $DBPASSWORD | isql -S$DSQUERY -U$DBUSER -i $sql
rm $sql

cd $REVENGINEER

foreach i ($TABLES)
#bcp/${i}_unload.object $DSQUERY $DATABASE $DBUSER $DBPASSWORD $BCPDIR
#tables/${i}_drop.object $DSQUERY $DATABASE $DBUSER $DBPASSWORD $BCPDIR
#tables/${i}_create.object $DSQUERY $DATABASE $DBUSER $DBPASSWORD $BCPDIR
#bcp/${i}_load.object $DSQUERY $DATABASE $DBUSER $DBPASSWORD $BCPDIR
#indexes/${i}_create.object $DSQUERY $DATABASE $DBUSER $DBPASSWORD $BCPDIR
#rules/$i_bind.object $DSQUERY $DATABASE $DBUSER $DBPASSWORD
#defaults/$i_bind.object $DSQUERY $DATABASE $DBUSER $DBPASSWORD
end

#cd keys
#foreach i (`ls *_create.object`)
#$i $DSQUERY $DATABASE $DBUSER $DBPASSWORD $BCPDIR
#end

date >> $LOG
