#! /bin/csh -f

# R. Palazola
# 3/10/98
#
# Purpose:
# Load/Reload each of the CV tables for new GXD Schema
#
# Usage:
# GXDload.sh


if ($#argv < 4 ) then
	echo "Server, database, user & pwdFile required."
	exit(1)
endif

set server = $1
set db = $2
set user = $3
set pwdFile = $4

if ( ! -e $pwdFile ) then
	echo "Could not find password file, $pwdFile"
	exit (1)
endif

echo "Loading data to server: $server, database: $db"
echo "Date:" `date`

cat >temp$$.sql <<EOF
use master
go
sp_dboption $db, "select into", true
go
use $db
go
checkpoint
go
EOF

sqsh -r -i temp$$.sql -S $server -D $db -U $user -e -P `cat $pwdFile`

# now bulk load CV
foreach f (*.bcp)
	set tbl=$f:r
	echo $tbl
	# delete from is IDDS compliant
	sqsh -r -S $server -D $db -U $user -e -P `cat $pwdFile` <<EOF
		delete from $tbl
		go
EOF
	if ( -f $f.error ) rm $f.error
	echo "bcp $db..$tbl in $f -c -t '|' -e $f.error -S $server -U $user"
	cat $pwdFile | \
		bcp $db..$tbl in $f -c -t '|' -e $f.error -S $server -U $user
	if ( $status || ( -e $f.error && ! -z $f.error ) ) then
		echo Failed at TABLE: $tbl ($f), using: $server, $db, $user
		exit (1)
	endif
end

# now add the MGI types for new accessionable objects
# if stnd MGI types defined, max(_MGIType_key) will be 5 (Source)
cat >temp$$.sql <<EOF
declare @maxkey int
select @maxkey = (select max(_MGIType_key) from ACC_MGIType holdlock)
if 5 = @maxkey
BEGIN
	insert ACC_MGIType (_MGIType_key, name, tableName, primaryKeyName) values (
	@maxkey + 1, "Antibody", "GXD_Antibody", "_Antibody_key"
	)
	insert ACC_MGIType (_MGIType_key, name, tableName, primaryKeyName) values (
	@maxkey + 2, "Antigen", "GXD_Antigen", "_Antigen_key"
	)
	insert ACC_MGIType (_MGIType_key, name, tableName, primaryKeyName) values (
	@maxkey + 3, "Assay", "GXD_Assay", "_Assay_key"
	)
	insert ACC_MGIType (_MGIType_key, name, tableName, primaryKeyName) values (
	@maxkey + 4, "Image", "IMG_Image", "_Image_key"
	)
END
else
	print "MGI Types appear to be loaded already"
go

declare @ldName varchar(30), @adName varchar(30)
select @ldName = 'MGI Image Archive'
select @adName = 'MGI Image'
if not exists (select 1 from ACC_LogicalDB where name = @ldName)
BEGIN
	declare @ldKey int, @adKey int
	select @ldKey = ( select max(_LogicalDB_key) 
		from ACC_LogicalDB holdlock) + 1

	insert ACC_LogicalDB (_LogicalDB_key, name) values ( @ldKey, @ldName )

	select @adKey = (select max(_ActualDB_key) 
		from ACC_ActualDB holdlock) + 1

	insert ACC_ActualDB (_ActualDB_key, _LogicalDB_key, name, url, active) 
	values ( @adKey, @ldKey, @adName,
	"http://pix.informatics.jax.org/~pixie/PixelDB/public/fetch_pixels.cgi?id=@@@@", 
	1 )
END
else
	print "Logical DB record for MGI Image Archive already exits"
go

use master
go
sp_dboption $db, "select into", false
go
use $db
go
checkpoint
go
EOF

# cat temp$$.sql
sqsh -r -i temp$$.sql -S $server -D $db -U $user -e -P `cat $pwdFile`

rm temp$$.sql
