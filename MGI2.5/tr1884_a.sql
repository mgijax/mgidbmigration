#!/bin/csh -f

#
# Migration for TR 1884
#

setenv SYBASE   /opt/sybase

setenv DSQUERY	$1
setenv DATABASE	$2
setenv TBLSEGMENT	"$3"
setenv IDXSEGMENT	"$4"
setenv BCPFILE	$5

set scripts = $SYBASE/admin

set sql = /tmp/$$.sql

#
# Create the table in each database
#

cat > $sql << EOSQL
   
use $DATABASE
go

checkpoint
go

drop table MGI_dbinfo
go

create table MGI_dbinfo (
        public_version  varchar(30) not null,
        product_name    varchar(30) not null,
        schema_version  varchar(30) not null,
        lastdump_date   datetime not null,
        creation_date   datetime not null,
        modification_date datetime not null
)
$TBLSEGMENT
go

/* defaults */

exec sp_bindefault current_date_default, "MGI_dbinfo.lastdump_date"
go

exec sp_bindefault current_date_default, "MGI_dbinfo.creation_date"
go

exec sp_bindefault current_date_default, "MGI_dbinfo.modification_date"
go

/* keys */

sp_primarykey MGI_dbinfo, public_version
go

/* indexes */

/* get rid of MGD_LastLoad table */

drop table MGD_LastLoad
go

/* set permissions */

grant select on MGI_dbinfo to public
go

checkpoint
go

quit
 
EOSQL
  
$scripts/dbo_sql $sql >> $LOG

rm $sql
   
#
# Load MGI_dbinfo 
#

cat $scripts/.mgd_dbo_password | bcp $DATABASE..MGI_dbinfo in $BCPFILE -c -t\| -Umgd_dbo >> $LOG

date >> $LOG
