#!/bin/csh -f

#
# Migrate MGI1.0 to MGI2.0
#

setenv DSQUERY $1
setenv MGD $2

setenv LOG `pwd`/MGI.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
# which pixel DB instance for the server/db being loaded:
if ( $DSQUERY == "MGD" && $MGD == "mgd" ) then
	set pdbdir=/home/pixie/public_html/PixelDB
else if ( $DSQUERY == "MGI_DEV" && $MGD == "mgd" ) then
	set pdbdir=/home/pixie/public_html/PixelDB
else if ( $DSQUERY == "MGI_DEV" && $MGD == "mgd_mirror" ) then
	set pdbdir=/home/rpp/public_html/PixelDB
else if ( $DSQUERY == "MGD_DEV" && $MGD == "mgd_new" ) then
	set pdbdir=/home/rpp/public_html/myPixDB
else
	echo "Unexpected Server:DB ${DSQUERY}:$MGD"
	exit (1)
endif

if ( -d $pdbdir ) then
	echo "PixelDB instance: $pdbdir" | tee -a $LOG
else
	echo "Invalid Pixel DB instance: $pdbdir" | tee -a $LOG
	exit (1)
endif

set scripts = $SYBASE/admin

cd $scripts/migration/MGI2.0

#
# Load the Controlled vocabulary lists and insert the appropriate MGI types,
# Actual DB and Logical DB records
#

GXDload.sh $DSQUERY $MGD mgd_dbo $SYBASE/admin/.mgd_dbo_password | tee -a $LOG

set sql = /tmp/$$.sql
 
cat > $sql << EOSQL
 
use master
go
 
sp_dboption $MGD, "select into", true
go
  
use $MGD
go
   
checkpoint
go
 
/* Insert GXD_Genotype records for Not Applicable (-2) and Not Specified (-1) */

insert into GXD_Genotype (_Genotype_key, _Strain_key) values (-1, -1)
go

insert into GXD_Genotype (_Genotype_key, _Strain_key) values (-2, -2)
go

checkpoint
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql
rm $sql
 
# ADI load process 
cd adload 
doload $DSQUERY $MGD
cd .. 

# Tom Freeman's data load 
cd freeman
loadFreemanData $DSQUERY $MGD mgd_dbo $SYBASE/admin/.mgd_dbo_password
mkImageLoadFile $DSQUERY $MGD >! imageFiles.txt
cd ..

# Tom Freeman's Images
echo $DSQUERY $MGD >! freemanImageLoad
date >>freemanImageLoad

set wkdir=`pwd`
cd $pdbdir/private/bin/admin/
./loadImages.py \
	$wkdir/freeman/imageFiles.txt $pdbdir \
	/net/mendel/export/mendel/extra/freeman >>& $wkdir/freemanImageLoad
cd $wkdir
tail -5 freemanImageLoad

# rebuild MRK_Reference
cd $scripts/utilities/MRK
./createMRK.sh $DSQUERY $MGD
cd $scripts/migration/MGI2.0

# add views/triggers/stored procs
$scripts/views/views.sh $DSQUERY $MGD
$scripts/triggers/triggers.sh $DSQUERY $MGD
$scripts/procedures/procedures.sh $DSQUERY $MGD

cd $scripts/migration/MGI2.0

date >> $LOG

