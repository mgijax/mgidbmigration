#!/bin/csh -f

#
# Migration for TR 1027
# Changing varchar(255) to char(255)
#

setenv SYBASE   /opt/sybase

setenv DSQUERY		$1
setenv DATABASE		$2
setenv NOTETABLE	$3
setenv NOTECOLUMN	$4
setenv NOTEPKEY		$5

set scripts = $SYBASE/admin

set sql = /tmp/$$.sql

cat > $sql << EOSQL
   
use $DATABASE
go

checkpoint
go

sp_rename $NOTETABLE, ${NOTETABLE}_Save
go

create table $NOTETABLE (
        _${NOTEPKEY}_key int not null,
        sequenceNum int not null,
        $NOTECOLUMN char ( 255 ) not null,
        creation_date datetime not null,
        modification_date datetime not null 
)
on mgd_seg_0 
go

insert $NOTETABLE
select * from ${NOTETABLE}_Save
go

/* defaults */

exec sp_bindefault current_date_default, "${NOTETABLE}.creation_date"
go

exec sp_bindefault current_date_default, "${NOTETABLE}.modification_date"
go

/* keys */

sp_primarykey $NOTETABLE, _${NOTEPKEY}_key, sequenceNum
go

/* indexes */

create unique clustered  index _${NOTEPKEY}_sequence_key_index 
on $NOTETABLE ( _${NOTEPKEY}_key, sequenceNum ) on mgd_seg_0
go

create nonclustered  index _${NOTEPKEY}_key_index 
on $NOTETABLE ( _${NOTEPKEY}_key ) on mgd_seg_1
go

create nonclustered  index ${NOTECOLUMN}_index
on $NOTETABLE ( $NOTECOLUMN ) on mgd_seg_1
go

create nonclustered  index modification_date_index
on $NOTETABLE ( modification_date ) on mgd_seg_1
go

drop table ${NOTETABLE}_Save
go

checkpoint
go

grant all on $NOTETABLE to editors
go

grant select on $NOTETABLE to public
go

grant all on $NOTETABLE to progs
go

quit
 
EOSQL
  
$scripts/dbo_sql $sql
rm $sql
