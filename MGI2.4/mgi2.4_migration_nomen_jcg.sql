#!/bin/csh -f

#
# Migration for MGI2.4 JCG April 9, 2000
#
# MGI 2.4 migration script -- TR 1291 -- nomen section
# Assumes that a binary nomen copy from production is loaded onto development
#
# Notes
#
# may 1, 2000 jcg -- tier2, tier3, and tier4 permissions changes tr 1533

setenv SYBASE   /opt/sybase
setenv PYTHONPATH       /usr/local/lib/python1.4:/usr/local/etc/httpd/python
set path = ($path $SYBASE/bin)

setenv DSQUERY  $1
setenv database $2

setenv LOG $0.log

rm -rf $LOG
touch $LOG

date >> $LOG

set scripts = $SYBASE/admin

set sql = /tmp/$$.sql

cat > $sql << EOSQL

use $database
go

dump transaction $database with no_log
go

commit
go

checkpoint
go

/* Drop MRK_Event */

DROP TABLE MRK_Event
go

/* Changes to MRK_Nomen */

execute sp_unbindefault "MRK_Nomen.creation_date"
go

execute sp_unbindefault "MRK_Nomen.modification_date"
go

execute sp_rename MRK_Nomen,MRK_Nomen_Old
go

CREATE TABLE MRK_Nomen (
       _Nomen_key           int NOT NULL,
       _Marker_Type_key     int NOT NULL,
       _Marker_Status_key   int NOT NULL,
       _Marker_Event_key    int NOT NULL,
       _Suid_key            int NOT NULL,
       _Suid_broadcast_key  int NOT NULL,
       _Marker_EventReason_key int NOT NULL,
       mgiAccID             varchar(30) NULL,
       symbol               varchar(25) NOT NULL,
       name                 varchar(255) NOT NULL,
       chromosome           varchar(8) NOT NULL,
       humanSymbol          varchar(25) NULL,
       statusNote           varchar(255) NULL,
       broadcast_date       datetime NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
go

INSERT INTO MRK_Nomen 
(
       _Nomen_key,
       _Marker_Type_key,
       _Marker_Status_key,
       _Marker_Event_key,
       _Suid_key,
       _Suid_broadcast_key,
       _Marker_EventReason_key,
       mgiAccID,
       symbol,
       name,
       chromosome,
       humanSymbol,
       statusNote,
       broadcast_date,
       creation_date,
       modification_date
) SELECT 
      _Nomen_key,
      _Marker_Type_key, 
      _Marker_Status_key, 
      _Marker_Event_key, 
      _Suid_key, 
      -1,
      -1,
       NULL,
       approvedSymbol, 
       approvedName, 
       chromosome, 
       humanSymbol, 
       statusNote, 
       broadcast_date, 
       creation_date, 
       modification_date 
FROM 
MRK_Nomen_Old
go

DROP TABLE MRK_Nomen_Old
go

CREATE UNIQUE CLUSTERED INDEX _Nomen_key_index ON MRK_Nomen
(
       _Nomen_key
)
 
go

CREATE INDEX _Marker_Event_index ON MRK_Nomen
(
       _Marker_Event_key
)
go

CREATE INDEX index_modification_date ON MRK_Nomen
(
       modification_date
)
 
go

CREATE INDEX _Marker_EventReason_key_index ON MRK_Nomen
(
       _Marker_EventReason_key
)
go

CREATE INDEX _Marker_Status_key_Index ON MRK_Nomen
(
       _Marker_Status_key
)
 
go

CREATE INDEX _Suid_key_index ON MRK_Nomen
(
       _Suid_key
)
 
go

CREATE INDEX _Suid_Broadcast_key_index ON MRK_Nomen
(
       _Suid_broadcast_key
)
go

CREATE INDEX _Marker_type_Index ON MRK_Nomen
(
       _Marker_Type_key
)
 
go

CREATE INDEX index_symbol ON MRK_Nomen
(
       symbol
)
 
go

CREATE INDEX index_chromosome ON MRK_Nomen
(
       chromosome
)
 
go

CREATE INDEX index_broadcast_date ON MRK_Nomen
(
       broadcast_date
)
 
go

exec sp_primarykey MRK_Nomen,
       _Nomen_key
go

exec sp_foreignkey MRK_Nomen, MRK_Status,
       _Marker_Status_key
go

exec sp_bindefault current_date_default, 'MRK_Nomen.creation_date'
go

exec sp_bindefault current_date_default, 'MRK_Nomen.modification_date'
go

revoke all on MRK_Nomen from editors
go

revoke all on MRK_Nomen from public
go

revoke all on MRK_Nomen from progs
go

grant all on MRK_Nomen to tier2, lglass, lmm, cgw, tier3, dbradt, dph, sr, tier4, ljm, rmb, djr
go

grant select on MRK_Nomen to editors
go
 
grant select on MRK_Nomen to public
go

grant all on MRK_Nomen to progs
go


/* MRK_Nomen_Other */

execute sp_unbindefault "MRK_Nomen_Other.creation_date"
go

execute sp_unbindefault "MRK_Nomen_Other.modification_date"
go

execute sp_rename MRK_Nomen_Other,MRK_Nomen_Other_Old
go

CREATE TABLE MRK_Nomen_Other (
       _Other_key           int NOT NULL,
       _Nomen_key           int NOT NULL,
       _Refs_key            int NULL,
       name                 varchar(200) NOT NULL,
       isAuthor             bit NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
go

INSERT INTO MRK_Nomen_Other
(
       _Other_key,
       _Nomen_key,
       _Refs_key,
       name,
       isAuthor,
       creation_date,
       modification_date
) SELECT 
       _Other_key,
       _Nomen_key,
       NULL,
       name,
       isAuthor,
       creation_date,
       modification_date      
FROM 
MRK_Nomen_Other_Old
go

DROP TABLE MRK_Nomen_Other_Old
go

CREATE UNIQUE CLUSTERED INDEX _Nomen_Other_Index ON MRK_Nomen_Other
(
       _Other_key
)
 
go

CREATE UNIQUE INDEX index_Nomen_key_name ON MRK_Nomen_Other
(
       name,
       _Nomen_key
)
 
go

CREATE INDEX _Nomen_key_Index ON MRK_Nomen_Other
(
       _Nomen_key
)
 
go

CREATE INDEX index_name ON MRK_Nomen_Other
(
       name
)
 
go

CREATE INDEX index_modification_date ON MRK_Nomen_Other
(
       modification_date
)
 
go

CREATE INDEX _Refs_key_index ON MRK_Nomen_Other
(
       _Refs_key
)
go

exec sp_primarykey MRK_Nomen_Other,
       _Other_key
go

exec sp_bindefault current_date_default, 'MRK_Nomen_Other.creation_date'
go

exec sp_bindefault current_date_default, 'MRK_Nomen_Other.modification_date'
go

revoke all on MRK_Nomen_Other from editors
go

revoke all on MRK_Nomen_Other from public
go

revoke all on MRK_Nomen_Other from progs
go

grant all on MRK_Nomen_Other to tier2, lglass, lmm, cgw, tier3, dbradt, dph, sr, tier4, ljm, rmb, djr
go

grant select on MRK_Nomen_Other to editors
go

grant select on MRK_Nomen_Other to public
go

grant all on MRK_Nomen_Other to progs
go

/* MRK_Nomen_Reference */

execute sp_unbindefault "MRK_Nomen_Reference.creation_date"
go

execute sp_unbindefault "MRK_Nomen_Reference.modification_date"
go

execute sp_rename MRK_Nomen_Reference,MRK_Nomen_Reference_Old
go

CREATE TABLE MRK_Nomen_Reference (
       _Nomen_key           int NOT NULL,
       _Refs_key            int NOT NULL,
       broadcastToMGD       bit NOT NULL,
       isPrimary            bit NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
go


insert into MRK_Nomen_Reference(
       _Nomen_key ,
       _Refs_key ,
       broadcastToMGD,
       isPrimary,
       creation_date,
       modification_date
)
select
       _Nomen_key,
       _Refs_key ,
       0,
       isPrimary,
       creation_date,
       modification_date
from 
MRK_Nomen_Reference_Old
go

DROP TABLE MRK_Nomen_Reference_Old
go


CREATE UNIQUE CLUSTERED INDEX _Refs_index ON MRK_Nomen_Reference
(
       _Refs_key,
       _Nomen_key
)
go

CREATE INDEX _Refs_key_Index ON MRK_Nomen_Reference
(
       _Refs_key
)
go

CREATE INDEX index_modification_date ON MRK_Nomen_Reference
(
       modification_date
)
go

CREATE INDEX index_nomen_key ON MRK_Nomen_Reference
(
       _Nomen_key
)
go

exec sp_primarykey MRK_Nomen_Reference,
       _Refs_key,
       _Nomen_key
go

exec sp_bindefault bit_default, 'MRK_Nomen_Reference.isPrimary'
go

exec sp_bindefault bit_default, 'MRK_Nomen_Reference.broadcastToMGD'
go


exec sp_bindefault current_date_default, 'MRK_Nomen_Reference.creation_date'
go

exec sp_bindefault current_date_default, 'MRK_Nomen_Reference.modification_date'
go

revoke all on MRK_Nomen_Reference from editors
go

revoke all on MRK_Nomen_Reference from public
go

revoke all on MRK_Nomen_Reference from progs
go

grant all on MRK_Nomen_Reference to progs
go

grant all on MRK_Nomen_Reference to dph, cgw, sr, tier3, dbradt, djr, tier2, lglass, tier4, ljm, lmm, rmb
go

grant all on MRK_Nomen_Reference to progs
go

grant select on MRK_Nomen_Reference to editors
go

grant select on MRK_Nomen_Reference to public
go


/* permissions MRK_Nomen_Notes */

revoke all on MRK_Nomen_Notes from editors
go

revoke all on MRK_Nomen_Notes from public
go

revoke all on MRK_Nomen_Notes from progs
go

grant all on MRK_Nomen_Notes to tier2, lglass, lmm, cgw, tier3, dbradt, dph, sr, tier4, ljm, rmb, djr
go

grant select on MRK_Nomen_Notes to editors
go

grant all on MRK_Nomen_Notes to progs
go

grant select on  MRK_Nomen_Notes to public
go


/* permissions MRK_GeneFamily */

revoke all on MRK_GeneFamily from editors
go

revoke all on MRK_GeneFamily from public
go

revoke all on MRK_GeneFamily from progs
go

grant all on MRK_GeneFamily to tier4, ljm, rmb, djr
go

grant select on MRK_GeneFamily to editors
go

grant select on MRK_GeneFamily to public 
go

grant all on MRK_GeneFamily to progs
go

/* permissions MRK_Nomen_GeneFamily */

revoke all on MRK_Nomen_GeneFamily from editors
go

revoke all on MRK_Nomen_GeneFamily from public
go

revoke all on MRK_Nomen_GeneFamily from progs
go

grant all on MRK_Nomen_GeneFamily to tier2, lglass, lmm, cgw, tier3, dbradt, dph, sr, tier4, ljm, rmb, djr
go

grant select on MRK_Nomen_GeneFamily to editors
go

grant select on MRK_Nomen_GeneFamily to public 
go

grant all on MRK_Nomen_GeneFamily to progs
go


/* permissions MRK_Status */

revoke all on MRK_Status from editors
go

revoke all on MRK_Status from public
go

revoke all on MRK_Status from progs
go

grant all on MRK_Status to tier4, ljm, rmb, djr
go

grant select on MRK_Status to editors
go

grant select on MRK_Status to public 
go

grant all on MRK_Status to progs
go

/* permissions ACC_AccessionReference */

revoke all on ACC_AccessionReference from editors
go

revoke all on ACC_AccessionReference from public
go

revoke all on ACC_AccessionReference from progs
go

grant all on ACC_AccessionReference to tier2, lglass, lmm, cgw, tier3, dbradt, dph, sr, tier4, ljm, rmb, djr
go

grant select on ACC_AccessionReference to editors
go

grant select on ACC_AccessionReference to public 
go

grant all on ACC_AccessionReference to progs
go


/* permissions ACC_Accession */

revoke all on ACC_Accession from editors
go

revoke all on ACC_Accession from public
go

revoke all on ACC_Accession from progs
go

grant all on ACC_Accession to tier2, lglass, lmm, cgw, tier3, dbradt, dph, sr, tier4, ljm, rmb, djr
go

grant select on ACC_Accession to editors
go

grant select on ACC_Accession to public 
go

grant all on ACC_Accession to progs
go


/* permissions ACC_MGIType */

revoke all on ACC_MGIType from editors
go

revoke all on ACC_MGIType from public
go

revoke all on ACC_MGIType from progs
go

grant all on ACC_Accession to tier2, lglass, lmm, rmb, djr
go

grant select on ACC_MGIType to editors
go
 
grant select on ACC_MGIType to public 
go

grant all on ACC_MGIType to progs
go


/* permissions system tables */

revoke all on sysusers from editors
go

revoke all on sysusers from public
go

revoke all on sysusers from progs
go

revoke all on sysusers from editors
go

revoke all on sysusers from public
go

revoke all on sysusers from progs
go

revoke all on sysobjects from editors
go

revoke all on sysobjects from public
go

revoke all on sysobjects from progs
go

revoke all on syscolumns from editors
go

revoke all on syscolumns from public
go

revoke all on syscolumns from progs
go

revoke all on MGI_Columns from editors
go

revoke all on MGI_Columns from public
go

revoke all on MGI_Columns from progs
go

revoke all on MGI_Tables from editors
go

revoke all on MGI_Tables from public
go

revoke all on MGI_Tables from progs
go

grant select on sysusers to editors
go

grant select on sysusers to editors
go

grant select on syscolumns to editors
go

grant select on MGI_Columns to editors
go

grant select on MGI_Columns to public 
go

grant select on MGI_Tables to editors
go

grant select on MGI_Tables to public 
go

grant all on sysusers to progs
go

grant all on sysobjects to progs
go

grant all on syscolumns to progs
go

grant all on MGI_Columns to progs
go

grant all on MGI_Tables to progs
go

checkpoint
go

quit

EOSQL

$scripts/dbo_sql $sql
rm $sql

date >> $LOG
