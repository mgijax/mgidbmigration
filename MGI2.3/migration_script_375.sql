execute sp_unbindrule "BIB_Refs.NLMstatus"
go

execute sp_unbindefault "BIB_Refs.creation_date"
go

execute sp_unbindefault "BIB_Refs.modification_date"
go
      
DROP TRIGGER BIB_Refs_Delete
go

DROP TRIGGER BIB_Refs_Insert
go

DROP TRIGGER BIB_Refs_Update
go

DROP INDEX BIB_Refs.index_authors
go

DROP INDEX BIB_Refs.index_dbs
go

DROP INDEX BIB_Refs.index_journal
go

DROP INDEX BIB_Refs.index_modification_date
go

DROP INDEX BIB_Refs.index_primary
go

DROP INDEX BIB_Refs.index_ReviewStatus_key
go

DROP INDEX BIB_Refs.index_title
go

DROP INDEX BIB_Refs.index_year
go

execute sp_rename BIB_Refs,BIB_RefsJA5F1008000
go
      
/* ACTION is CREATE Default SetToNull */

CREATE DEFAULT SetToNull
	AS null
go

CREATE TABLE BIB_Refs (
       _Refs_key            int NOT NULL,
       _ReviewStatus_key    int NOT NULL,
       refType              char(4) NOT NULL,
       authors              varchar(255) NULL,
       authors2             varchar(255) NULL,
       _primary             varchar(60) NULL,
       title                varchar(255) NULL,
       title2               varchar(255) NULL,
       journal              varchar(100) NULL,
       vol                  varchar(20) NULL,
       issue                varchar(25) NULL,
       date                 varchar(30) NULL,
       year                 int NULL,
       pgs                  varchar(30) NULL,
       dbs                  varchar(60) NULL,
       NLMstatus            char(1) NOT NULL,
       abstract             text NULL,
       isReviewArticle      bit NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
) on mgd_seg_0
go

exec sp_bindrule check_NLM_status, 'BIB_Refs.NLMstatus'
go

exec sp_bindefault bit_default, 'BIB_Refs.isReviewArticle'
go

exec sp_bindefault current_date_default, 'BIB_Refs.creation_date'
go

exec sp_bindefault current_date_default, 'BIB_Refs.modification_date'
go

INSERT INTO BIB_Refs (_Refs_key, _ReviewStatus_key, refType, authors, authors2, 
    _primary, title, title2, journal, vol, issue, date, year, pgs, dbs, 
    NLMstatus, abstract, isReviewArticle, creation_date, modification_date) 
SELECT _Refs_key, 
    _ReviewStatus_key, refType, authors, authors2, _primary, title, title2, 
    journal, vol, issue, date, year, pgs, dbs, NLMstatus, abstract, 0, 
    creation_date, modification_date FROM BIB_RefsJA5F1008000
go


DROP TABLE BIB_RefsJA5F1008000
go

/* BIB_Refs Indexes */

CREATE UNIQUE CLUSTERED INDEX index_Refs_key ON BIB_Refs
(
       _Refs_key
)
       ON mgd_seg_0
go

CREATE INDEX index_primary ON BIB_Refs
(
       _primary
)
       ON mgd_seg_1
go

CREATE INDEX index_authors ON BIB_Refs
(
       authors
)
       ON mgd_seg_1
go

CREATE INDEX index_year ON BIB_Refs
(
       year
)
       ON mgd_seg_1
go

CREATE INDEX index_journal ON BIB_Refs
(
       journal
)
       ON mgd_seg_1
go

CREATE INDEX index_title ON BIB_Refs
(
       title
)
       ON mgd_seg_1
go

CREATE INDEX index_dbs ON BIB_Refs
(
       dbs
)
       ON mgd_seg_1
go

CREATE INDEX index_modification_date ON BIB_Refs
(
       modification_date
)
       ON mgd_seg_1
go

CREATE INDEX index_ReviewStatus_key ON BIB_Refs
(
       _ReviewStatus_key
)
       ON mgd_seg_1
go

/* Keys for BIB_Refs*/

exec sp_primarykey BIB_Refs, _Refs_key
go

exec sp_foreignkey ACC_AccessionReference, BIB_Refs, _Refs_key
go

exec sp_foreignkey BIB_Books, BIB_Refs, _Refs_key
go

exec sp_foreignkey BIB_Notes, BIB_Refs, _Refs_key
go

exec sp_foreignkey BIB_Refs, BIB_ReviewStatus, _ReviewStatus_key
go

exec sp_foreignkey CRS_References, BIB_Refs, _Refs_key
go

exec sp_foreignkey GXD_Index, BIB_Refs, _Refs_key
go

exec sp_foreignkey HMD_Homology, BIB_Refs, _Refs_key
go

exec sp_foreignkey MLC_Reference, BIB_Refs, _Refs_key
go

exec sp_foreignkey MLC_Reference_edit, BIB_Refs, _Refs_key
go

exec sp_foreignkey MLD_Expts, BIB_Refs, _Refs_key
go

exec sp_foreignkey MLD_Marker, BIB_Refs, _Refs_key
go

exec sp_foreignkey MLD_Notes, BIB_Refs, _Refs_key
go

exec sp_foreignkey MRK_History, BIB_Refs, _Refs_key
go

exec sp_foreignkey MRK_Reference, BIB_Refs, _Refs_key
go

exec sp_foreignkey PRB_Reference, BIB_Refs, _Refs_key
go

exec sp_foreignkey PRB_Source, BIB_Refs, _Refs_key
go

exec sp_foreignkey RI_Summary_Expt_Ref, BIB_Refs, _Refs_key
go

exec sp_foreignkey GXD_Antibody, BIB_Refs, _Refs_key
go

exec sp_foreignkey GXD_AntibodyAlias, BIB_Refs, _Refs_key
go

exec sp_foreignkey GXD_Assay, BIB_Refs, _Refs_key
go

exec sp_foreignkey IMG_Image, BIB_Refs, _Refs_key
go

/* MRK_Other Data and Table*/

execute sp_rename MRK_Other,MRK_OtherJA7C5006000
go

drop table MRK_Other
go

CREATE TABLE MRK_Other (
       _Other_key           int NOT NULL,
       _Marker_key          int NOT NULL,
       _Refs_key            int NULL,
       name                 varchar(200) NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
on mgd_seg_0
go

sp_primarykey MRK_Other,_Other_key
go

INSERT INTO MRK_Other
(_Other_key, _Marker_key, _Refs_key, name, creation_date, modification_date)
SELECT
_Other_key, _Marker_key, NULL, name, creation_date, modification_date
FROM
MRK_OtherJA7C5006000
go

DROP TABLE MRK_OtherJA7C5006000
go

/* Defaults for MRK_Other */
exec sp_bindefault current_date_default, 'MRK_Other.creation_date'
go

exec sp_bindefault current_date_default, 'MRK_Other.modification_date'
go

/* Indexes for MRK_Other */

CREATE UNIQUE CLUSTERED INDEX index_Marker_key ON MRK_Other
(
       _Other_key
) ON mgd_seg_0
go

CREATE INDEX index_refs_key ON MRK_Other
(
       _Refs_key
) on mgd_seg_1
go


CREATE INDEX index_name ON MRK_Other
(
       name
)
       ON mgd_seg_1
go

CREATE INDEX index_modification_date ON MRK_Other
(
       modification_date
)
       ON mgd_seg_1
go

/* Triggers for MRK_Other */

create trigger MRK_Other_Insert
on MRK_Other
for insert
as

/* Insert entry into Name bucket */

insert MRK_Name (_Marker_key, _Marker_Type_key, name)
select inserted._Marker_key, MRK_Marker._Marker_Type_key, inserted.name
from inserted, MRK_Marker
where inserted._Marker_key = MRK_Marker._Marker_key
go

create trigger MRK_Other_Update
on MRK_Other
for update
as

if @@rowcount = 1
begin
        /* Update entry in Name bucket */

        if update(name) and (select name from inserted) != NULL
        begin
                update MRK_Name set name = inserted.name
                from MRK_Name, inserted, deleted
                where MRK_Name._Marker_key = inserted._Marker_key and
                MRK_Name._Marker_Type_key is null and
                MRK_Name.name = deleted.name
        end
end
go

create trigger MRK_Other_Delete
on MRK_Other
for delete
as

/* Delete entry from Name bucket */

delete MRK_Name from MRK_Name, deleted
where MRK_Name._Marker_key = deleted._Marker_key and
      MRK_Name._Marker_Type_key is null and
      MRK_Name.name = deleted.name
go

exec sp_foreignkey MRK_Other, BIB_Refs, _Refs_key
go

exec sp_foreignkey MRK_Other, MRK_Marker, _Marker_key
go

revoke all on BIB_Refs from progs
go

revoke all on BIB_Refs from editors
go

grant all on BIB_Refs to progs
go

grant all on BIB_Refs to rmb, wjb, djr, neb, jeo, sr, ljm, apd, cml
go

grant update on BIB_Refs to editors
go

grant select on BIB_Refs to public
go

grant all on MRK_Other to progs
go

/* see tr #800 */
grant all on MRK_Other to editors
go

/* see tr375 change */
DROP INDEX MRK_Reference.index_Marker_Refs_key
go

CREATE UNIQUE CLUSTERED INDEX index_Marker_Refs_key ON MRK_Reference
(
       _Marker_key,
       _Refs_key,
       auto
)
ON mgd_seg_0
go

grant select on MRK_Other to public
go

/* added MGI_Table update here */
execute MGI_Table_Column_Cleanup
go
