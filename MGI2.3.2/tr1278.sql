#!/bin/csh -f

#
# Migration for TR 1278
#

setenv SYBASE   /opt/sybase
setenv PYTHONPATH       /usr/local/lib/python1.4:/usr/local/etc/httpd/python
set path = ($path $SYBASE/bin)

setenv DSQUERY $1
setenv MGD $2

setenv NEWTYPE	"Complex/Cluster/Region"

setenv LOG $0.log

rm -rf $LOG
touch $LOG
 
date >> $LOG
 
set scripts = $SYBASE/admin

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
 
declare @typekey int

if not exists (select 1 from MRK_Types where name = "$NEWTYPE")
begin
	select @typekey = max(_Marker_Type_key) + 1 from MRK_Types
	insert into MRK_Types values (@typekey, "$NEWTYPE", getdate(), getdate())
end

go

declare marker_cursor cursor for
select _Marker_key
from MRK_Marker
where _Species_key = 1
and symbol in (
'Amy',
'Cat2',
'Cd1',
'Cea',
'Cryg',
'Csn',
'Cyp2d',
'Dgcr3l',
'Dgcr5l',
'Dgcr6',
'Gin1',
'Grcl',
'Grr',
'Grr1',
'Grr2',
'Gsta',
'H2',
'H2-I',
'H2-K',
'H2-L',
'H2-Q',
'H2-T',
'Hba',
'Hbb',
'Hdc',
'Hist1',
'Hist2',
'Hoxa',
'Hoxb',
'Hoxc',
'Hoxd',
'Hsd3b',
'Ifna',
'Igh',
'Igh-C',
'Igh-D',
'Igh-J',
'Igh-V',
'Igh-V10',
'Igh-V11',
'Igh-V12',
'Igh-V15',
'Igh-V24',
'Igh-V31',
'Igh-V3609',
'Igh-V3609N',
'Igh-V3660',
'Igh-V7183',
'Igh-VGAM3.8',
'Igh-VJ558',
'Igh-VJ606',
'Igh-VQ52',
'Igh-VQ52N',
'Igh-VS107',
'Igh-VSM7',
'Igh-VX24',
'Igk',
'Igk-C',
'Igk-J',
'Igk-V',
'Igk-V1',
'Igk-V10',
'Igk-V11',
'Igk-V12/13',
'Igk-V14',
'Igk-V15',
'Igk-V19',
'Igk-V2',
'Igk-V20',
'Igk-V21',
'Igk-V22',
'Igk-V23',
'Igk-V24',
'Igk-V28',
'Igk-V31',
'Igk-V32',
'Igk-V33',
'Igk-V34',
'Igk-V35',
'Igk-V38',
'Igk-V4',
'Igk-V5',
'Igk-V8',
'Igk-V9',
'IgK-Vt-pending',
'Igl',
'Igl-1',
'Igl-2',
'Igl-J',
'Il1',
'Krt1',
'Krt2',
'Ly49',
'Ly55',
'Ly6',
'Myhc',
'Olfr1',
'Olfr10',
'Olfr11',
'Olfr12',
'Olfr2',
'Olfr3',
'Olfr37',
'Olfr4',
'Olfr5',
'Olfr6',
'Olfr7',
'Olfr8',
'Olfr9',
'Prn',
'Qa2',
'Rnr11',
'Rnr12',
'Rnr13',
'Rnr15',
'Rnr16',
'Rnr18',
'Rnr19-1',
'Rnr4',
'Rnu3b',
'Saa',
'Spt',
'Surf',
'Tcra',
'Tcra-C',
'Tcra-J',
'Tcra-V',
'Tcra-V1',
'Tcra-V10',
'Tcra-V11',
'Tcra-V12',
'Tcra-V13',
'Tcra-V14',
'Tcra-V15',
'Tcra-V16',
'Tcra-V17',
'Tcra-V18',
'Tcra-V19',
'Tcra-V2',
'Tcra-V20',
'Tcra-V3',
'Tcra-V4',
'Tcra-V5',
'Tcra-V6',
'Tcra-V7',
'Tcra-V8',
'Tcra-V9',
'Tlsr1',
'Tsp1',
'Wbscr1',
'Wbscr9',
'Xlr',
'Xlr3'
)
or
name = 't-complex'
for read only
go

declare @markerkey int
declare @typekey int

select @typekey = _Marker_Type_key from MRK_Types where name = "$NEWTYPE"

open marker_cursor
fetch marker_cursor into @markerkey

while (@@sqlstatus = 0)
begin
	update MRK_Marker
	set _Marker_Type_key = @typekey
	where _Marker_key = @markerkey

	fetch marker_cursor into @markerkey
end

close marker_cursor
deallocate cursor marker_cursor

go

/* Remove UniGene accession numbers from Markers of this new type */

declare @typekey int

select @typekey = _Marker_Type_key from MRK_Types where name = "$NEWTYPE"

delete ACC_Accession
from ACC_Accession a, MRK_Marker m
where m._Marker_Type_key = @typeKey
and m._Marker_key = a._Object_key
and a._LogicalDB_key = 23
go

checkpoint
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql
rm $sql
 
date >> $LOG
