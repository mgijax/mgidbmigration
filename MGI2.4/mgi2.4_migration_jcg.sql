#!/bin/csh -f

#
# Migration for MGI2.4 JCG April 9, 2000 
#
# MGI 2.4 migration script -- TR148, TR 1291 -- mgd section
# Assumes that a binary mgd copy from production is loaded onto development
#
# Notes:
#
# April 19, 2000 jcg -- removed apd from grant statements
# April 28, 2000 jcg -- add changes from tr 1404
# May 8, 2000 jcg    -- added changes to MRK_Label, _Species_Key

setenv SYBASE   /opt/sybase
setenv PYTHONPATH       /usr/local/lib/python1.4:/usr/local/etc/httpd/python
set path = ($path $SYBASE/bin)

setenv DSQUERY	$1
setenv database	$2

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

/* MLC_Marker and MLC_Marker_Edit Changes TR148 */
/*
3.2 MLC_Marker and MLC_Marker_edit
These tables are identical so the changes must be applited to both tables.
1. Change the type of the tag field from varchar(30) to integer.
tag int not null
2. Leave the new table empty. The data migration script will load this table.
*/

execute sp_unbindefault "MLC_Marker.creation_date"
go

execute sp_unbindefault "MLC_Marker.modification_date"
go

execute sp_rename MLC_Marker,MLC_Marker_old
go

CREATE TABLE MLC_Marker (
       _Marker_key          int NOT NULL,
       tag                  int NOT NULL,
       _Marker_key_2        int NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
go

CREATE UNIQUE CLUSTERED INDEX index_Marker_tag_key ON MLC_Marker
(
       _Marker_key,
       _Marker_key_2,
       tag
)
go

CREATE INDEX index_modification_date ON MLC_Marker
(
       modification_date
)
go

CREATE INDEX index_Marker_key_2 ON MLC_Marker
(
       _Marker_key_2
)
go

CREATE INDEX index_Marker_key ON MLC_Marker
(
       _Marker_key
)
go

exec sp_primarykey MLC_Marker, _Marker_key, _Marker_key_2
go

exec sp_bindefault current_date_default, 'MLC_Marker.creation_date'
go

exec sp_bindefault current_date_default, 'MLC_Marker.modification_date'
go

DROP TABLE MLC_Marker_old
go


/* MLC_Marker_edit */

execute sp_unbindefault "MLC_Marker_edit.creation_date"
go

execute sp_unbindefault "MLC_Marker_edit.modification_date"
go

execute sp_rename MLC_Marker_edit,MLC_Marker_Old
go


CREATE TABLE MLC_Marker_edit (
       _Marker_key          int NOT NULL,
       tag                  int NOT NULL,
       _Marker_key_2        int NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
go

CREATE INDEX index_Marker_key ON MLC_Marker_edit
(
       _Marker_key
)
go

CREATE INDEX index_modification_date ON MLC_Marker_edit
(
       modification_date
)
go

CREATE INDEX index_Marker_key_2 ON MLC_Marker_edit
(
       _Marker_key_2
)
go

exec sp_primarykey MLC_Marker_edit, _Marker_key, _Marker_key_2
go

exec sp_bindefault current_date_default, 'MLC_Marker_edit.creation_date'
go

exec sp_bindefault current_date_default, 'MLC_Marker_edit.modification_date'
go

DROP TABLE MLC_Marker_Old
go

/* 4.12 MRK_EventReason */

CREATE TABLE MRK_EventReason (
       _Marker_EventReason_key int NOT NULL,
       eventReason          varchar(255) NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
) on mgd_seg_0
go

CREATE UNIQUE CLUSTERED INDEX _MRK_EventReason_index ON MRK_EventReason
(
       _Marker_EventReason_key
) on mgd_seg_0
go

CREATE INDEX index_creation_date ON MRK_EventReason
(
       creation_date
) on mgd_seg_1
go

CREATE INDEX index_modification_date ON MRK_EventReason
(
       modification_date
) on mgd_seg_1
go

exec sp_primarykey MRK_EventReason, _Marker_EventReason_key
go

exec sp_bindefault current_date_default, 'MRK_EventReason.creation_date'
go

exec sp_bindefault current_date_default, 'MRK_EventReason.modification_date'
go

grant all on MRK_EventReason to progs, tier4, ljm, rmb, djr
go

grant select on MRK_EventReason to editors
go

grant select on MRK_EventReason to public
go


insert into MRK_EventReason values (1, "to conform w/Human Nomenclature", getDate(), getDate())
go

insert into MRK_EventReason values (2, "per gene family revision", getDate(), getDate())
go

insert into MRK_EventReason values (3, "per personal comm w/Authors(s)", getDate(), getDate())
go

insert into MRK_EventReason values (4, "per personal comm w/Chromosome Committee", getDate(), getDate())
go

insert into MRK_EventReason values (-1, "Not Specified", getDate(), getDate())
go

insert into MRK_EventReason values (-2, "Not Applicable", getDate(), getDate())
go


/* 4.11 MRK_Event */

CREATE TABLE MRK_Event (
       _Marker_Event_key    int NOT NULL,
       event                varchar(255) NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
) on mgd_seg_0
go

CREATE UNIQUE CLUSTERED INDEX _MRK_Event_key_index ON MRK_Event
(
       _Marker_Event_key
) on mgd_seg_0
go

CREATE INDEX index_creation_date ON MRK_Event
(
       creation_date
) on mgd_seg_1
go

CREATE INDEX index_modification_date ON MRK_Event
(
       modification_date
) on mgd_seg_1
go

exec sp_primarykey MRK_Event, _Marker_Event_key
go

exec sp_bindefault current_date_default, 'MRK_Event.creation_date'
go

exec sp_bindefault current_date_default, 'MRK_Event.modification_date'
go

grant all on MRK_Event to progs
go

grant select on MRK_Event to editors
go

grant select on MRK_Event to public
go

insert into MRK_Event values (1, "assigned", getDate(), getDate())
go

insert into  MRK_Event values (2, "withdrawn", getDate(), getDate())
go

insert into MRK_Event values (3, "merged", getDate(), getDate())
go

insert into MRK_Event values (4, "allele of", getDate(), getDate())
go

insert into MRK_Event values (5, "split", getDate(), getDate())
go

insert into MRK_Event values (6, "deleted", getDate(), getDate())
go

insert into MRK_Event values (-1, "Not Specified", getDate(), getDate())
go

insert into MRK_Event values (-2, "Not Applicable", getDate(), getDate())
go


/* 4.9 MRK_Status */

CREATE TABLE MRK_Status (
       _Marker_Status_key   int NOT NULL,
       status               varchar(255) NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
) on mgd_seg_0
go

CREATE UNIQUE CLUSTERED INDEX _Marker_status_index ON MRK_Status
(
       _Marker_Status_key
)
       ON mgd_seg_0
go

CREATE INDEX index_modification_date ON MRK_Status
(
       modification_date
)
       ON mgd_seg_1
go

exec sp_primarykey MRK_Status, _Marker_Status_key
go

exec sp_bindefault current_date_default, 'MRK_Status.creation_date'
go

exec sp_bindefault current_date_default, 'MRK_Status.modification_date'
go

grant all on MRK_Status to progs
go

grant select on MRK_Status to public
go

grant select on MRK_Status to public
go

grant select on MRK_Status to editors
go


insert MRK_Status values ( 1, "approved", getDate(), getDate())
go

insert MRK_Status values (2, "withdrawn", getDate(), getDate())
go

insert MRK_Status values (-1, "Not Specified", getDate(), getDate())
go

insert MRK_Status values (-2, "Not Applicable", getDate(), getDate())
go




/* 4.10 MRK_Marker */

execute sp_unbindefault "MRK_Marker.creation_date"
go

execute sp_unbindefault "MRK_Marker.modification_date"
go

execute sp_rename MRK_Marker,MRK_Marker_Old
go


CREATE TABLE MRK_Marker (
       _Marker_key          int NOT NULL,
       _Species_key         int NOT NULL,
       _Marker_Status_key   int NOT NULL,
       _Marker_Type_key     int NOT NULL,
       symbol               varchar(25) NOT NULL,
       name                 varchar(255) NOT NULL,
       chromosome           varchar(8) NOT NULL,
       cytogeneticOffset    varchar(20) NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
) on mgd_seg_0
go


INSERT INTO MRK_Marker
(
_Marker_key, 
_Species_key, 
_Marker_Status_key,
_Marker_Type_key, 
symbol, 
name, 
chromosome, 
cytogeneticOffset, 
creation_date, 
modification_date
) 
SELECT 
_Marker_key, 
_Species_key,
-1, 
_Marker_Type_key, 
symbol, 
name, 
chromosome, 
cytogeneticOffset, 
creation_date, 
modification_date 
FROM 
MRK_Marker_Old
go


DROP TABLE MRK_Marker_Old
go

exec sp_primarykey MRK_Marker, _Marker_key
go

exec sp_foreignkey MRK_Marker, MRK_Status, _Marker_Status_key
go

CREATE UNIQUE CLUSTERED INDEX index_Marker_key ON MRK_Marker
(
       _Marker_key
)
       ON mgd_seg_0
go

CREATE INDEX _Marker_Status_key_index ON MRK_Marker
(
       _Marker_Status_key
) on mgd_seg_1
go

CREATE INDEX index_modification_date ON MRK_Marker
(
       modification_date
)
       ON mgd_seg_1
go

CREATE INDEX index_chromosome ON MRK_Marker
(
       chromosome
)
       ON mgd_seg_1
go

CREATE INDEX index_Marker_Type_key ON MRK_Marker
(
       _Marker_Type_key
)
       ON mgd_seg_1
go

CREATE INDEX index_symbol ON MRK_Marker
(
       symbol
)
       ON mgd_seg_1
go

CREATE INDEX index_Species_key ON MRK_Marker
(
       _Species_key
)
       ON mgd_seg_1
go

CREATE INDEX index_Species_symbol ON MRK_Marker
(
       _Species_key,
       symbol
)
       ON mgd_seg_1
go

exec sp_bindefault current_date_default, 'MRK_Marker.creation_date'
go

exec sp_bindefault current_date_default, 'MRK_Marker.modification_date'
go

grant delete on MRK_Marker to cgw, cml, tier3, dbradt, djr, jblake, tier4, ljm, lmm, neb, plg, progs, rmb, sr
go

grant update on MRK_Marker to cgw, cml, tier3, dbradt, djr, jblake, tier2, lglass, tier4, ljm, lmm, neb, plg, progs, rmb, sr
go

grant select on MRK_Marker to public
go

grant references on MRK_Marker to cgw, cml, tier3, dbradt, djr, jblake, tier4, ljm, lmm, neb, plg, progs, rmb, sr
go

grant insert on MRK_Marker to cgw, cml, tier3, dbradt, djr, jblake, tier4, ljm, lmm, neb, plg, progs, rmb, sr
go


/* 4.13 MRK_History */

execute sp_unbindefault "MRK_History.creation_date"
go

execute sp_unbindefault "MRK_History.modification_date"
go

execute sp_rename MRK_History,MRK_History_Old
go

CREATE TABLE MRK_History (
       _Marker_key          int NOT NULL,
       _Marker_Event_key    int NOT NULL,
       _Marker_EventReason_key int NOT NULL,
       _History_key         int NOT NULL,
       _Refs_key            int NULL,
       sequenceNum          int NOT NULL,
       name                 varchar(255) NULL,
       event_date           datetime NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
) on mgd_seg_0
go

INSERT INTO MRK_History (
_Marker_key, 
_Marker_Event_key,
_Marker_EventReason_key,
_History_key, 
_Refs_key, 
sequenceNum,  
name, 
event_date, 
creation_date, 
modification_date
) 
SELECT 
_Marker_key, 
-1,
-1,
_History_key, 
_Refs_key, 
sequenceNum,  
name, 
event_date, 
creation_date, 
modification_date 
FROM 
MRK_History_Old
go

DROP TABLE MRK_History_Old
go

CREATE UNIQUE CLUSTERED INDEX index_sequenceNum_Marker_key ON MRK_History
(
       sequenceNum,
       _Marker_key,
       _History_key
)
       ON mgd_seg_0
go

CREATE INDEX _Marker_Event_key_index ON MRK_History
(
       _Marker_Event_key
) on mgd_seg_1
go

CREATE INDEX _Marker_EventReason_key_index ON MRK_History
(
       _Marker_EventReason_key
) on mgd_seg_1
go

CREATE INDEX index_Refs_key ON MRK_History
(
       _Refs_key
)
       ON mgd_seg_1
go

CREATE INDEX index_modification_date ON MRK_History
(
       modification_date
)
       ON mgd_seg_1
go

CREATE INDEX index_Marker_key ON MRK_History
(
       _Marker_key
)
       ON mgd_seg_1
go

CREATE INDEX index_History_key ON MRK_History
(
       _History_key
)
       ON mgd_seg_1
go

CREATE INDEX MRK_EventReason_key_index ON MRK_History
(
       _Marker_EventReason_key
) on mgd_seg_1
go

exec sp_primarykey MRK_History, _Marker_key, sequenceNum
go

exec sp_foreignkey MRK_History, MRK_EventReason, _Marker_EventReason_key
go

exec sp_foreignkey MRK_History, MRK_Event, _Marker_Event_key
go

exec sp_foreignkey MRK_History, MRK_Marker, _History_key
go

exec sp_foreignkey MRK_History, MRK_Marker, _Marker_key
go

exec sp_foreignkey MRK_History, BIB_Refs, _Refs_key
go

exec sp_bindefault current_date_default, 'MRK_History.creation_date'
go

exec sp_bindefault current_date_default, 'MRK_History.modification_date'
go

/* grant all to tier4, ljm, djr, rmb, tier4 - grant all to group progs - select to public */
/* no one else needs permission on this table. */


grant delete on MRK_History to djr, tier4, ljm, rmb, progs, tier4 
go

grant update on MRK_History to djr, tier4, ljm, rmb, progs, tier4
go

grant select on MRK_History to public
go

grant references on MRK_History to djr, tier4, ljm, rmb, progs, tier4 
go

grant insert on MRK_History to djr, tier4, ljm, rmb, progs, tier4 
go

/* From CRS_tr1291 */

revoke  all on CRS_Cross from tier4, ljm, djr, rmb
go

revoke  all on CRS_Progeny from tier4, ljm, djr, rmb
go

revoke  all on CRS_References from tier4, ljm, djr, rmb
go

revoke  all on CRS_Typings from tier4, ljm, djr, rmb
go

revoke  all on CRS_Matrix from tier4, ljm, djr, rmb
go

revoke  all on CRS_Cross_View from tier4, ljm, djr, rmb
go

/* From GXD_tr12921 */

revoke all on GXD_AntibodyType from tier4, ljm, djr, rmb
go

revoke all on GXD_AntibodyMarker from tier4, ljm, djr, rmb
go

revoke all on GXD_Structure from tier4, ljm, djr, rmb
go

revoke all on GXD_StructureName from tier4, ljm, djr, rmb
go

revoke all on GXD_StructureClosure from tier4, ljm, djr, rmb
go

revoke all on GXD_TheilerStage from tier4, ljm, djr, rmb
go

revoke all on GXD_ProbePrep from tier4, ljm, djr, rmb
go

revoke all on GXD_ProbeSense from tier4, ljm, djr, rmb
go

revoke all on GXD_Index from tier4, ljm, djr, rmb
go

revoke all on GXD_Label from tier4, ljm, djr, rmb
go

revoke all on GXD_Index_Stages from tier4, ljm, djr, rmb
go

revoke all on GXD_LabelCoverage from tier4, ljm, djr, rmb
go

revoke all on GXD_VisualizationMethod from tier4, ljm, djr, rmb
go

revoke all on GXD_GelControl from tier4, ljm, djr, rmb
go

revoke all on GXD_AntibodyPrep from tier4, ljm, djr, rmb
go

revoke all on GXD_GelLane from tier4, ljm, djr, rmb
go

revoke all on GXD_Secondary from tier4, ljm, djr, rmb
go

revoke all on GXD_Assay from tier4, ljm, djr, rmb
go

revoke all on GXD_AssayType from tier4, ljm, djr, rmb
go

revoke all on GXD_AssayNote from tier4, ljm, djr, rmb
go

revoke all on GXD_Specimen from tier4, ljm, djr, rmb
go

revoke all on GXD_GelRNAType from tier4, ljm, djr, rmb
go

revoke all on GXD_GelLaneStructure from tier4, ljm, djr, rmb
go

revoke all on GXD_GelRow from tier4, ljm, djr, rmb
go

revoke all on GXD_GelBand from tier4, ljm, djr, rmb
go

revoke all on GXD_Strength from tier4, ljm, djr, rmb
go

revoke all on GXD_GelUnits from tier4, ljm, djr, rmb
go

revoke all on GXD_EmbeddingMethod from tier4, ljm, djr, rmb
go

revoke all on GXD_FixationMethod from tier4, ljm, djr, rmb
go

revoke all on GXD_InSituResult from tier4, ljm, djr, rmb
go

revoke all on GXD_ISResultStructure from tier4, ljm, djr, rmb
go

revoke all on GXD_InSituResultImage from tier4, ljm, djr, rmb
go

revoke all on GXD_Pattern from tier4, ljm, djr, rmb
go

revoke all on GXD_Expression from tier4, ljm, djr, rmb
go

revoke all on GXD_Genotype from tier4, ljm, djr, rmb
go

revoke all on GXD_AllelePair from tier4, ljm, djr, rmb
go

revoke all on GXD_Antigen from tier4, ljm, djr, rmb
go

revoke all on GXD_Antibody from tier4, ljm, djr, rmb
go

revoke all on GXD_AntibodyAlias from tier4, ljm, djr, rmb
go

revoke all on GXD_AntibodyClass from tier4, ljm, djr, rmb
go

revoke all on GXD_Antigen_Acc_View from tier4, ljm, djr, rmb
go

revoke all on GXD_Antibody_Acc_View from tier4, ljm, djr, rmb
go

revoke all on GXD_Assay_Acc_View from tier4, ljm, djr, rmb
go

revoke all on GXD_Antigen_View from tier4, ljm, djr, rmb
go

revoke all on GXD_Antibody_View from tier4, ljm, djr, rmb
go

revoke all on GXD_AntibodyRef_View from tier4, ljm, djr, rmb
go

revoke all on GXD_AntibodyAntigen_View from tier4, ljm, djr, rmb
go

revoke all on GXD_AntibodyMarker_View from tier4, ljm, djr, rmb
go

revoke all on GXD_AntibodyAlias_View from tier4, ljm, djr, rmb
go

revoke all on GXD_AntibodyAliasRef_View from tier4, ljm, djr, rmb
go

revoke all on GXD_Assay_View from tier4, ljm, djr, rmb
go

revoke all on GXD_AntibodyPrep_View from tier4, ljm, djr, rmb
go

revoke all on GXD_ProbePrep_View from tier4, ljm, djr, rmb
go

revoke all on GXD_Genotype_View from tier4, ljm, djr, rmb
go

revoke all on GXD_AllelePair_View from tier4, ljm, djr, rmb
go

revoke all on GXD_Antibody_Summary_View from tier4, ljm, djr, rmb
go

revoke all on GXD_Specimen_View from tier4, ljm, djr, rmb
go

revoke all on GXD_Antigen_Summary_View from tier4, ljm, djr, rmb
go

revoke all on GXD_InSituResult_View from tier4, ljm, djr, rmb
go

revoke all on GXD_Assay_Summary_View from tier4, ljm, djr, rmb
go

revoke all on GXD_ISResultImage_View from tier4, ljm, djr, rmb
go

revoke all on GXD_GelLane_View from tier4, ljm, djr, rmb
go

revoke all on GXD_GelRow_View from tier4, ljm, djr, rmb
go

revoke all on GXD_GelBand_View from tier4, ljm, djr, rmb
go

revoke all on GXD_GelLaneStructure_View from tier4, ljm, djr, rmb
go

revoke all on GXD_ISResultStructure_View from tier4, ljm, djr, rmb
go

revoke all on GXD_Index_View from tier4, ljm, djr, rmb
go

revoke all on GXD_GelLane from tier4, ljm, djr, rmb
go

/* IMG_tr1291 */

revoke all on IMG_ImageNote from tier4, ljm, djr, rmb
go

revoke all on IMG_Image from tier4, ljm, djr, rmb
go

revoke all on IMG_ImagePane from tier4, ljm, djr, rmb
go

revoke all on IMG_FieldType from tier4, ljm, djr, rmb
go

revoke all on IMG_Image_Summary_View from tier4, ljm, djr, rmb
go

revoke all on IMG_Image_Acc_View from tier4, ljm, djr, rmb
go

revoke all on IMG_Image_View from tier4, ljm, djr, rmb
go

revoke all on IMG_ImagePane_View from tier4, ljm, djr, rmb
go

revoke all on IMG_ImagePaneRef_View from tier4, ljm, djr, rmb
go

/* MLD_tr1291 */

revoke all on MLD_Expts from tier4, ljm, djr, rmb
go
revoke all on MLD_Assay_Types from tier4, ljm, djr, rmb
go
revoke all on MLD_Contig from tier4, ljm, djr, rmb
go
revoke all on MLD_ContigProbe from tier4, ljm, djr, rmb
go
revoke all on MLD_Distance from tier4, ljm, djr, rmb
go
revoke all on MLD_Expt_Marker from tier4, ljm, djr, rmb
go
revoke all on MLD_Expt_Notes from tier4, ljm, djr, rmb
go
revoke all on MLD_FISH from tier4, ljm, djr, rmb
go
revoke all on MLD_FISH_Region from tier4, ljm, djr, rmb
go
revoke all on MLD_Hit from tier4, ljm, djr, rmb
go
revoke all on MLD_Hybrid from tier4, ljm, djr, rmb
go
revoke all on MLD_InSitu from tier4, ljm, djr, rmb
go
revoke all on MLD_ISRegion from tier4, ljm, djr, rmb
go
revoke all on MLD_Marker from tier4, ljm, djr, rmb
go
revoke all on MLD_Matrix from tier4, ljm, djr, rmb
go
revoke all on MLD_MC2point from tier4, ljm, djr, rmb
go
revoke all on MLD_MCDataList from tier4, ljm, djr, rmb
go
revoke all on MLD_Notes from tier4, ljm, djr, rmb
go
revoke all on MLD_PhysMap from tier4, ljm, djr, rmb
go
revoke all on MLD_RI from tier4, ljm, djr, rmb
go
revoke all on MLD_RI2Point from tier4, ljm, djr, rmb
go
revoke all on MLD_RIData from tier4, ljm, djr, rmb
go
revoke all on MLD_Statistics from tier4, ljm, djr, rmb
go
revoke all on MLD_Concordance from tier4, ljm, djr, rmb
go
revoke all on MLD_Summary_View from tier4, ljm, djr, rmb
go
revoke all on MLD_Acc_View from tier4, ljm, djr, rmb
go
revoke all on MLD_Marker_View from tier4, ljm, djr, rmb
go
revoke all on MLD_Expt_View from tier4, ljm, djr, rmb
go
revoke all on MLD_Expt_Marker_View from tier4, ljm, djr, rmb
go
revoke all on MLD_FISH_View from tier4, ljm, djr, rmb
go
revoke all on MLD_Hybrid_View from tier4, ljm, djr, rmb
go
revoke all on MLD_Concordance_View from tier4, ljm, djr, rmb
go
revoke all on MLD_InSitu_View from tier4, ljm, djr, rmb
go
revoke all on MLD_Matrix_View from tier4, ljm, djr, rmb
go
revoke all on MLD_MC2point_View from tier4, ljm, djr, rmb
go
revoke all on MLD_Statistics_View from tier4, ljm, djr, rmb
go
revoke all on MLD_Distance_View from tier4, ljm, djr, rmb
go
revoke all on MLD_RI_View from tier4, ljm, djr, rmb
go
revoke all on MLD_RIData_View from tier4, ljm, djr, rmb
go
revoke all on MLD_RI2Point_View from tier4, ljm, djr, rmb
go
revoke all on MLD_Hit_View from tier4, ljm, djr, rmb
go

/* RI_tr1291 */

revoke all on RI_RISet from tier4, ljm, djr, rmb
go

revoke all on RI_Summary from tier4, ljm, djr, rmb
go

revoke all on RI_Summary_Expt_Ref from tier4, ljm, djr, rmb
go

/* ------------------- TR 1360 Go Additions ------------------------- */

CREATE TABLE GO_Evidence (
       _Evidence_key        int NOT NULL,
       abbreviation         char(3) NOT NULL,
       evidence             varchar(255) NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
) on mgd_seg_0
go

insert into GO_Evidence values (1, "IMP", "inferred from mutant phenotype", getDate(), getDate())
go

insert into GO_Evidence values (2, "IGI", "inferred from genetic interaction", getDate(), getDate())
go

insert into GO_Evidence values (3, "IPI", "inferred from physical interaction", getDate(), getDate())
go

insert into GO_Evidence values (4, "ISS", "inferred from sequence or structural similarity", getDate(), getDate())
go

insert into GO_Evidence values (5, "IDA", "inferred from direct assay", getDate(), getDate())
go

insert into GO_Evidence values (6, "IEP", "inferred from expression pattern", getDate(), getDate())
go

insert into GO_Evidence values (7, "SBA", "stated by author", getDate(), getDate())
go

insert into GO_Evidence values (8, "NA", "not available", getDate(), getDate())
go

insert into GO_Evidence values (9, "EA", "electronic annotation", getDate(), getDate())
go

CREATE UNIQUE CLUSTERED INDEX _Evidence_key_index ON GO_Evidence
(
       _Evidence_key
)
       ON mgd_seg_0
go

CREATE INDEX modification_date_index ON GO_Evidence
(
       modification_date
)
       ON mgd_seg_1
go

exec sp_primarykey GO_Evidence, _Evidence_key
go

exec sp_bindefault current_date_default, 'GO_Evidence.creation_date'
go

exec sp_bindefault current_date_default, 'GO_Evidence.modification_date'
go

grant all on GO_Evidence to progs
go

grant select on GO_Evidence to public
go

/* GO_Ontology */

CREATE TABLE GO_Ontology (
       _Ontology_key        int NOT NULL,
       abbreviation         char(1) NOT NULL,
       ontologyName         varchar(255) NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
) on mgd_seg_0
go

insert into GO_Ontology values (1, "F", "Molecular Function", getDate(), getDate())
go

insert into GO_Ontology values (2, "P", "Biological Process", getDate(), getDate())
go

insert into GO_Ontology values (3, "C", "Cellular Component", getDate(), getDate())
go

exec sp_primarykey GO_Ontology, _Ontology_key
go

CREATE UNIQUE CLUSTERED INDEX _Ontology_key_index ON GO_Ontology
(
       _Ontology_key
)
       ON mgd_seg_0
go

CREATE INDEX modification_date_index ON GO_Ontology
(
       modification_date
)
       ON mgd_seg_1
go

exec sp_bindefault current_date_default, 'GO_Ontology.creation_date'
go

exec sp_bindefault current_date_default, 'GO_Ontology.modification_date'
go

grant all on GO_Ontology to progs
go

grant select on GO_Ontology to public
go

/* GO_DataEvidence */

CREATE TABLE GO_DataEvidence (
       _MarkerGO_key        int NOT NULL,
       _Evidence_key        int NOT NULL,
       _Refs_key            int NOT NULL,
       creation_date        datetime NOT NULL,
       modifcation_date     datetime NOT NULL
) on mgd_seg_0
go

exec sp_primarykey GO_DataEvidence, _MarkerGO_key, _Evidence_key
go

CREATE UNIQUE CLUSTERED INDEX _MarkerGO_key_Index ON GO_DataEvidence
(
       _MarkerGO_key,
       _Evidence_key
)
       ON mgd_seg_0
go

CREATE INDEX _Refs_key_index ON GO_DataEvidence
(
       _Refs_key
)
       ON mgd_seg_1
go

CREATE INDEX modification_date_index ON GO_DataEvidence
(
       modifcation_date
)
       ON mgd_seg_1
go

exec sp_bindefault current_date_default, 'GO_DataEvidence.creation_date'
go

exec sp_bindefault current_date_default, 'GO_DataEvidence.modifcation_date'
go

grant all on GO_DataEvidence to progs
go

grant select on GO_DataEvidence to public
go


/* GO_MarkerGO */

CREATE TABLE GO_MarkerGO (
       _MarkerGO_key        int NOT NULL,
       _Marker_key          int NOT NULL,
       _Term_key            int NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
) on mgd_seg_0
go

exec sp_primarykey GO_MarkerGO, _MarkerGO_key
go

exec sp_foreignkey GO_MarkerGO, MRK_Marker, _Marker_key
go


CREATE UNIQUE CLUSTERED INDEX _MarkerGO_key_Index ON GO_MarkerGO
(
       _MarkerGO_key
)
       ON mgd_seg_0
go

CREATE INDEX _Term_key_index ON GO_MarkerGO
(
       _Term_key
) on mgd_seg_1
go

CREATE INDEX _Marker_key_index ON GO_MarkerGO
(
       _Marker_key
) on mgd_seg_1
go

CREATE INDEX modification_date_index ON GO_MarkerGO
(
       modification_date
) on mgd_seg_1
go

exec sp_bindefault current_date_default, 'GO_MarkerGO.creation_date'
go

exec sp_bindefault current_date_default, 'GO_MarkerGO.modification_date'
go

grant all on GO_MarkerGO to progs
go

grant select on GO_MarkerGO to public
go

/* GO_Term */

CREATE TABLE GO_Term (
       _Term_key            int NOT NULL,
       _Ontology_key        int NOT NULL,
       goTerm               varchar(255) NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
) on mgd_seg_0
go

exec sp_primarykey GO_Term, _Term_key
go

CREATE UNIQUE CLUSTERED INDEX _Go_key_index ON GO_Term
(
       _Term_key
)
       ON mgd_seg_0
go

CREATE INDEX _Ontology_key_index ON GO_Term
(
       _Ontology_key
) on mgd_seg_1
go

CREATE INDEX modification_date_index ON GO_Term
(
       modification_date
)
       ON mgd_seg_1
go

exec sp_bindefault current_date_default, 'GO_Term.creation_date'
go

exec sp_bindefault current_date_default, 'GO_Term.modification_date'
go

grant all on GO_Term to progs
go

grant select on GO_Term to public
go

exec sp_foreignkey GO_DataEvidence, BIB_Refs, _Refs_key
go

exec sp_foreignkey GO_MarkerGO, GO_Term, _Term_key
go

exec sp_foreignkey GO_Term, GO_Ontology, _Ontology_key
go

/* -------------------------- tr 1177 Alleles -------------------------------------------*/

/* ALL_Inheritance */

CREATE TABLE ALL_Inheritance_Mode (
       _Mode_key            int NOT NULL,
       mode                 varchar(255) NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
ON mgd_seg_0
go

CREATE UNIQUE CLUSTERED INDEX _mode_key_index ON ALL_Inheritance_Mode
(
       _Mode_key
)
       ON mgd_seg_0
go

CREATE INDEX modification_date_index ON ALL_Inheritance_Mode
(
       modification_date
)
       ON mgd_seg_1
go

exec sp_primarykey ALL_Inheritance_Mode, _Mode_key
go

exec sp_bindefault current_date_default, 'ALL_Inheritance_Mode.creation_date'
go

exec sp_bindefault current_date_default, 'ALL_Inheritance_Mode.modification_date'
go


/* ALL_Type */

CREATE TABLE ALL_Type (
       _Allele_Type_key     int NOT NULL,
       alleleType           varchar(255) NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
ON mgd_seg_0
go

CREATE UNIQUE CLUSTERED INDEX _Allele_Type_key_index ON ALL_Type
(
       _Allele_Type_key
)
       ON mgd_seg_0
go

CREATE INDEX modification_date_index ON ALL_Type
(
       modification_date
)
       ON mgd_seg_1
go

exec sp_primarykey ALL_Type, _Allele_Type_key
go

exec sp_bindefault current_date_default, 'ALL_Type.creation_date'
go

exec sp_bindefault current_date_default, 'ALL_Type.modification_date'
go


/* ALL_Allele - replaces MRK_Allele */

execute sp_unbindefault "MRK_Allele.creation_date"
go

execute sp_unbindefault "MRK_Allele.modification_date"
go

execute sp_rename MRK_Allele,MRK_Allele_Old
go

CREATE TABLE ALL_Allele (
       _Allele_key          int NOT NULL,
       _Refs_key            int NULL,
       _Molecular_Refs_key  int NULL,
       _Marker_key          int NOT NULL,
       _Strain_key          int NOT NULL,
       _Mode_key            int NOT NULL,
       _Allele_Type_key     int NOT NULL,
       reviewed             bit NOT NULL,
       userID               varchar(30) NOT NULL,
       symbol               varchar(50) NOT NULL,
       name                 varchar(255) NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
ON mgd_seg_0
go

INSERT INTO All_Allele (
       _Allele_key, 
       _Refs_key,
       _Molecular_Refs_key,
       _Marker_key,
       _Strain_key,
       _Mode_key,
       _Allele_Type_key,
       reviewed,
       userID,
       symbol,
       name,
       creation_date,
       modification_date
) 
SELECT 
_Allele_key, 
NULL,          /* Refs_key */
NULL,          /* Molecular_Refs_key */
_Marker_key, 
-1,            /* Strain_key */
-1,            /* Mode_key unspecified */
-1,            /* Allele_Type_key unspecified */ 
0,             /* reviewed */
"cml",         /* user id */
symbol,
name,
creation_date, 
modification_date 
FROM 
MRK_Allele_Old
go

DROP TABLE MRK_Allele_Old
go


CREATE UNIQUE CLUSTERED INDEX index_Allele_key ON ALL_Allele
(
       _Allele_key
)
       ON mgd_seg_0
go

CREATE INDEX _Allele_Type_key_index ON ALL_Allele
(
       _Allele_Type_key
) on mgd_seg_1
go

CREATE INDEX _Strain_key_index ON ALL_Allele
(
       _Strain_key
) on mgd_seg_1
go

CREATE INDEX _Mode_key_index ON ALL_Allele
(
       _Mode_key
) on mgd_seg_1
go

CREATE INDEX _Molecular_Refs_key_index ON ALL_Allele
(
       _Molecular_Refs_key
) on mgd_seg_1
go

CREATE INDEX _Refs_key_index ON ALL_Allele
(
       _Refs_key
) on mgd_seg_1
go

CREATE INDEX index_name ON ALL_Allele
(
       name
)
       ON mgd_seg_1
go

CREATE INDEX index_modification_date ON ALL_Allele
(
       modification_date
)
       ON mgd_seg_1
go

CREATE INDEX index_Marker_key ON ALL_Allele
(
       _Marker_key
)
       ON mgd_seg_1
go

CREATE INDEX index_symbol ON ALL_Allele
(
       symbol
)
       ON mgd_seg_1
go


exec sp_primarykey ALL_Allele, _Allele_key
go

exec sp_bindefault current_date_default, 'ALL_Allele.creation_date'
go

exec sp_bindefault current_date_default, 'ALL_Allele.modification_date'
go

/* ALL_Molecular_Mutation */

CREATE TABLE ALL_Molecular_Mutation (
       _Mutation_key        int NOT NULL,
       mutation             varchar(255) NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
ON mgd_seg_0
go

CREATE UNIQUE CLUSTERED INDEX _Mutation_key_index ON ALL_Molecular_Mutation
(
       _Mutation_key
)
       ON mgd_seg_0
go

CREATE INDEX modification_date_index ON ALL_Molecular_Mutation
(
       modification_date
)
       ON mgd_seg_1
go

exec sp_primarykey ALL_Molecular_Mutation, _Mutation_key
go

exec sp_bindefault current_date_default, 'ALL_Molecular_Mutation.creation_date'
go

exec sp_bindefault current_date_default, 'ALL_Molecular_Mutation.modification_date'
go


/* ALL_Allele_Mutation */

CREATE TABLE ALL_Allele_Mutation (
       _Allele_key          int NOT NULL,
       _Mutation_key        int NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
ON mgd_seg_0
go

CREATE UNIQUE CLUSTERED INDEX _Allele_Mutation_key_index ON ALL_Allele_Mutation
(
       _Allele_key,
       _Mutation_key
)
       ON mgd_seg_0
go

CREATE INDEX _Allele_key_index ON ALL_Allele_Mutation
(
       _Allele_key
) on mgd_seg_1
go

CREATE INDEX _Mutation_key_index ON ALL_Allele_Mutation
(
       _Mutation_key
) on mgd_seg_1
go

CREATE INDEX modification_date_index ON ALL_Allele_Mutation
(
       modification_date
)
       ON mgd_seg_1
go


exec sp_primarykey ALL_Allele_Mutation, _Allele_key, _Mutation_key
go

exec sp_bindefault current_date_default, 'ALL_Allele_Mutation.creation_date'
go

exec sp_bindefault current_date_default, 'ALL_Allele_Mutation.modification_date'
go

/* ALL_Molecular_Note */

CREATE TABLE ALL_Molecular_Note (
       _Allele_key          int NOT NULL,
       sequenceNum          int NOT NULL,
       note                 varchar(255) NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
ON mgd_seg_0
go

CREATE UNIQUE CLUSTERED INDEX _Allele_sequence_key_index ON ALL_Molecular_Note
(
       _Allele_key,
       sequenceNum
)
       ON mgd_seg_0
go

CREATE INDEX _Allele_key_index ON ALL_Molecular_Note
(
       _Allele_key
) on mgd_seg_1
go


CREATE INDEX modification_date_key ON ALL_Molecular_Note
(
       modification_date
)
       ON mgd_seg_1
go

exec sp_primarykey ALL_Molecular_Note, _Allele_key, sequenceNum
go

exec sp_bindefault current_date_default, 'ALL_Molecular_Note.creation_date'
go

exec sp_bindefault current_date_default, 'ALL_Molecular_Note.modification_date'
go

/* ALL_Note */

CREATE TABLE ALL_Note (
       _Allele_key          int NOT NULL,
       sequenceNum          int NOT NULL,
       note            varchar(255) NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
ON mgd_seg_0
go

CREATE UNIQUE CLUSTERED INDEX _allele_Sequence_key_index ON ALL_Note
(
       _Allele_key,
       sequenceNum
)
       ON mgd_seg_0
go

CREATE INDEX _Allele_key_index ON ALL_Note
(
       _Allele_key
) on mgd_seg_1
go

CREATE INDEX modification_date_index ON ALL_Note
(
       modification_date
)
       ON mgd_seg_1
go

exec sp_primarykey ALL_Note, _Allele_key, sequenceNum
go

exec sp_bindefault current_date_default, 'ALL_Note.creation_date'
go

exec sp_bindefault current_date_default, 'ALL_Note.modification_date'
go

/* ALL_Synonym */

CREATE TABLE ALL_Synonym (
       _Synonym_key         int NOT NULL,
       _Allele_key          int NOT NULL,
       _Refs_key            int NOT NULL,
       synonym              varchar(255) NOT NULL,       
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
ON mgd_seg_0
go

exec sp_primarykey ALL_Synonym, _Synonym_key
go

CREATE UNIQUE CLUSTERED INDEX _Synonym_key_index ON ALL_Synonym
(
       _Synonym_key
)
       ON mgd_seg_0
go

CREATE INDEX _Allele_key_index ON ALL_Synonym
(
       _Allele_key
) on mgd_seg_1
go

CREATE INDEX modification_date_index ON ALL_Synonym
(
       modification_date
)
       ON mgd_seg_1
go

exec sp_foreignkey ALL_Allele, BIB_Refs, _Refs_key
go

exec sp_foreignkey ALL_Allele, BIB_Refs, _Molecular_Refs_key
go

exec sp_foreignkey ALL_Allele, ALL_Inheritance_Mode, _Mode_key
go

exec sp_foreignkey ALL_Allele, PRB_Strain, _Strain_key
go

exec sp_foreignkey ALL_Allele, ALL_Type, _Allele_Type_key
go

exec sp_foreignkey ALL_Allele, MRK_Marker, _Marker_key
go

exec sp_foreignkey MLD_Expt_Marker, ALL_Allele, _Allele_key
go

exec sp_foreignkey GXD_AllelePair, ALL_Allele, _Allele_key_1
go

exec sp_foreignkey GXD_AllelePair, ALL_Allele, _Allele_key_2
go

exec sp_foreignkey ALL_Allele_Mutation, ALL_Molecular_Mutation, _Mutation_key
go

exec sp_foreignkey ALL_Allele_Mutation, ALL_Allele, _Allele_key
go

exec sp_foreignkey ALL_Molecular_Note, ALL_Allele, _Allele_key
go

exec sp_foreignkey ALL_Note, ALL_Allele, _Allele_key
go

exec sp_foreignkey ALL_Synonym, ALL_Allele, _Allele_key
go

exec sp_bindefault current_date_default, 'ALL_Synonym.creation_date'
go

exec sp_bindefault current_date_default, 'ALL_Synonym.modification_date'
go

/* data loads */

/* MGI type  -- requires some extra logic */

insert into ACC_MGIType values (11, "Allele", "ALL_Allele", "_Allele_key", getDate(), getDate(), getDate())
go

/* Allele Types */

insert into ALL_Type values (-2, "Not Applicable", getDate(), getDate())
go

insert into ALL_Type values (-1, "Not Specified", getDate(), getDate())
go

insert into ALL_Type values (1, "Spontaneous", getDate(), getDate())
go

insert into ALL_Type values (2, "Transgene induced", getDate(), getDate())
go

insert into ALL_Type values (3, "Transgene induced (gene targeted)", getDate(), getDate())
go

insert into ALL_Type values (4, "Transgene induced (gene trapped)", getDate(), getDate())
go

insert into ALL_Type values (5, "Viral induced", getDate(), getDate())
go

insert into ALL_Type values (6, "Transposon induced", getDate(), getDate())
go

insert into ALL_Type values (7, "Retrotransposon induced", getDate(), getDate())
go

insert into ALL_Type values (8, "Radiation induced", getDate(), getDate())
go

insert into ALL_Type values (9, "Chemical induced", getDate(), getDate())
go

insert into ALL_Type values (10, "Chemical induced (ENU)", getDate(), getDate())
go

insert into ALL_Type values (11, "Chemical induced (chlorambucil)", getDate(), getDate())
go

insert into ALL_Type values (12, "Chemical induced (EMS)", getDate(), getDate())
go

insert into ALL_Type values (13, "Other (see notes)", getDate(), getDate())
go

insert into ALL_Type values (14, "Not Curated", getDate(), getDate())
go

/* Inheritance modes */

insert into ALL_Inheritance_Mode values (-2, "Not Applicable", getDate(), getDate())
go

insert into ALL_Inheritance_Mode values (-1, "Not Specified", getDate(), getDate())
go

insert into ALL_Inheritance_Mode values (1, "Dominant", getDate(), getDate())
go

insert into ALL_Inheritance_Mode values (2, "Codominant", getDate(), getDate())
go

insert into ALL_Inheritance_Mode values (3, "Semidominant", getDate(), getDate())
go

insert into ALL_Inheritance_Mode values (4, "Recessive", getDate(), getDate())
go

insert into ALL_Inheritance_Mode values (5, "Other (see notes)", getDate(), getDate())
go

insert into ALL_Inheritance_Mode values (6, "Not Curated", getDate(), getDate())
go

/* Molecular mutations */

insert into ALL_Molecular_Mutation values (-2, "Not Applicable", getDate(), getDate())
go

insert into ALL_Molecular_Mutation values (-1, "Not Specified", getDate(), getDate())
go

insert into ALL_Molecular_Mutation values (1, "Deletion", getDate(), getDate())
go

insert into ALL_Molecular_Mutation values (2, "Inversion", getDate(), getDate())
go

insert into ALL_Molecular_Mutation values (3, "Insertion", getDate(), getDate())
go

insert into ALL_Molecular_Mutation values (4, "Nucleotide repeat expansion", getDate(), getDate())
go

insert into ALL_Molecular_Mutation values (5, "Translocation", getDate(), getDate())
go

insert into ALL_Molecular_Mutation values (6, "Nucleotide substitution", getDate(), getDate())
go

insert into ALL_Molecular_Mutation values (7, "Point mutation (transversion)", getDate(), getDate())
go

insert into ALL_Molecular_Mutation values (8, "Point mutation (transition)", getDate(), getDate())
go

insert into ALL_Molecular_Mutation values (9, "Other (see notes)", getDate(), getDate())
go

/* permissions */

/*
 1. For all CV tables (ALL_Type, ALL_Inheritance_Mode, ALL_Molecular_Mutation),
grant all to cml, progs; grant select to public.

2. For all other tables (ALL_Allele, ALL_Allele_Mutation, ALL_Molecular_Note,
ALL_Note, ALL_Synonym), grant all to editors, progs.
*/

grant all on ALL_Type to cml, progs
go

grant select on ALL_Type to public
go

grant all on ALL_Inheritance_Mode to cml, progs
go

grant select on ALL_Inheritance_Mode to public
go

grant all on ALL_Molecular_Mutation to cml, progs
go

grant select on ALL_Molecular_Mutation to public
go

grant all on ALL_Allele to editors, progs
go

grant all on ALL_Allele_Mutation to editors, progs
go

grant all on ALL_Molecular_Note to editors, progs
go

grant all on ALL_Note to editors, progs
go

grant all on ALL_Synonym to editors, progs
go

grant select on ALL_Type to public
go

grant select on ALL_Inheritance_Mode to public
go

grant select on ALL_Molecular_Mutation to public
go

grant select on ALL_Allele to public
go

grant select on ALL_Allele_Mutation to public
go

grant select on ALL_Molecular_Note to public
go

grant select on ALL_Note to public
go

grant select on ALL_Synonym to public
go

/* MLC permissions TR148 sec 3.0 */
/* all MLC tables: cgw, cml, tier3, dbradt, dph, jblake, lmm, rmb, sr, wjb */

/* MLC_Text_edit */

revoke all on MLC_Text_edit from public
go

grant all on MLC_Text_edit to progs
go

grant select on MLC_Text_edit to public
go

grant all on MLC_Text_edit to tier3, dbradt, sr, cml, rmb, jblake, wjb, lmm, cgw, dph
go

/* MLC_Reference_edit */

revoke all on MLC_Reference_edit from public
go

grant all on MLC_Reference_edit to progs
go

grant all on MLC_Reference_edit to tier3, dbradt, sr, cml, rmb, jblake, wjb, lmm, cgw, dph
go

grant select on MLC_Reference_edit to public
go

/* MLC_Lock_edit */

revoke all on MLC_Lock_edit from public
go

grant all on MLC_Lock_edit to progs
go

grant select on MLC_Lock_edit to public
go

grant all on MLC_Lock_edit to  tier3, dbradt, sr, cml, rmb, jblake, wjb, lmm, cgw, dph
go

/* MLC_Marker_edit */

revoke all on MLC_Marker_edit from public
go

grant all on MLC_Marker_edit to progs
go

grant select on MLC_Marker_edit to public
go

grant all on MLC_Marker_edit to  tier3, dbradt, sr, cml, rmb, jblake, wjb, lmm, cgw, dph
go

/* MLC_Text */

revoke all on MLC_Text from public
go

grant all on MLC_Text to progs
go

grant all on MLC_Text to tier3, dbradt, sr, cml, rmb, jblake, wjb, lmm, cgw, dph
go

grant select on MLC_Text to public
go

/* MLC_Reference */

revoke all on MLC_Reference from public
go

grant all on MLC_Reference to progs
go

grant all on MLC_Reference to tier3, dbradt, sr, cml, rmb, jblake, wjb, lmm, cgw, dph
go

grant select on MLC_Reference to public
go

/* MLC_Marker */

revoke all on MLC_Marker from public
go

grant all on MLC_Marker to progs
go

grant all on MLC_Marker to tier3, dbradt, sr, cml, rmb, jblake, wjb, lmm, cgw, dph
go

grant select on MLC_Marker to public
go

/* add tr 1404 changes */

CREATE RULE check_labelType
	AS @col IN ('S', 'N', 'Y')
go

CREATE TABLE MRK_Label (
       _Marker_key          int NOT NULL,
       _Marker_Status_key   int NOT NULL,
       _Species_key         int NOT NULL,
       label                varchar(255) NOT NULL,
       labelType            char(1) NOT NULL,
       creation_date        datetime NOT NULL,
       modification_date    datetime NOT NULL
)
ON mgd_seg_0

CREATE UNIQUE CLUSTERED INDEX primary_key_index ON MRK_Label
(
       _Marker_key, _Marker_Status_key, labelType, label
)
       ON mgd_seg_0
go

CREATE INDEX _Marker_key_index ON MRK_Label
(
       _Marker_key
)
       ON mgd_seg_1
go

CREATE INDEX _Label_key_index ON MRK_Label
(
       label
)
       ON mgd_seg_1
go

CREATE INDEX  _Species_key_index ON MRK_Label
(
       _Species_key
) on mgd_seg_1
go


CREATE INDEX _Marker_status_key_index ON MRK_Label
(
       _Marker_Status_key
)
       on mgd_seg_1
go

CREATE INDEX modification_index_date ON MRK_Label
(
       modification_date
)
       ON mgd_seg_1
go

Drop table MRK_Name
go

Drop table MRK_Symbol
go

exec sp_bindrule check_labelType, 'MRK_Label.labelType'
go

exec sp_bindefault current_date_default, 'MRK_Label.creation_date'
go

exec sp_bindefault current_date_default, 'MRK_Label.modification_date'
go

grant all on MRK_Label to progs
go

grant select on MRK_Label to public
go

grant select on MRK_Label to editors
go

sp_primarykey MRK_Label, _Marker_key, labelType, label
go

exec sp_foreignkey MRK_Label, MRK_Status, _Marker_Status_key
go

exec sp_foreignkey MRK_Label, MRK_Marker, _Marker_key
go 

exec sp_foreignkey MRK_Label, MRK_Species,_Species_key
go

/* MLC Foreign keys: same as on production */

exec sp_foreignkey MLC_Text, MRK_Marker,
       _Marker_key
go

exec sp_foreignkey MLC_Marker, MRK_Marker,
       _Marker_key_2
go

exec sp_foreignkey MLC_Marker, MLC_Text,
       _Marker_key
go

exec sp_foreignkey MLC_Marker_edit, MLC_Text_edit,
       _Marker_key
go

exec sp_foreignkey MLC_Marker_edit, MRK_Marker,
       _Marker_key_2
go

commit
go

checkpoint
go

quit
 
EOSQL
 
$scripts/dbo_sql $sql
rm $sql
 
date >> $LOG
