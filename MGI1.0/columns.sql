#!/bin/sh   
 
scripts=/usr/sybase/admin
path=/usr/sybase/10.0.2/bin
 
server=$1
database=$2
 
(cat /usr/sybase/10.0.2/admin/.mgd_dbo_password
cat << EOSQL
use master
go
 
sp_dboption $database, "select into", true
go
 
use $database
go
 
checkpoint
go
 
EOSQL
) | $path/isql -I/usr/sybase/11.0.2/interfaces -Umgd_dbo -S$server

(cat /usr/sybase/10.0.2/admin/.mgd_dbo_password
cat << EOSQL

use $database
go

/* Create a temporary table to solve the null date problem */
create table #constant 
	(dt datetime NOT NULL, 
	stat int NOT NULL, 
	sk int NOT NULL,
	rsk int NULL,
	brname varchar(40) not null)
go

insert #constant values (getdate(), 1, -2, 3, 'Peer Reviewed')
go


/* Accession tables have release date */
select
	_Accession_key,
	accID,
	prefixPart,
	numericPart,
	_LogicalDB_key,
	_Object_key,
	_MGIType_key,
	private,
	preferred,
	creation_date = creationDate,
	modification_date = modificationDate,
	release_date = releaseDate
into
$database..ACC_Accession
from
mgd..ACC_Accession	
go	


select
	prefixPart,
	maxNumericPart,
	creation_date = creationDate,
	modification_date = modificationDate,
	release_date = releaseDate
into
$database..ACC_AccessionMax
from
mgd..ACC_AccessionMax	
go	


select
	_Accession_key,
	_Refs_key,
	creation_date = creationDate,
	modification_date = modificationDate,
	release_date = releaseDate
into
$database..ACC_AccessionReference
from
mgd..ACC_AccessionReference	
go	


select
	_ActualDB_key,
	_LogicalDB_key,
	name,
	active,
	url,
	allowsMultiple,
	delimiter,
	creation_date = creationDate,
	modification_date = modificationDate,
	release_date = releaseDate
into
$database..ACC_ActualDB
from
mgd..ACC_ActualDB	
go	


select
	_LogicalDB_key,
	name,
	description,
	_Species_key,
	creation_date = creationDate,
	modification_date = modificationDate,
	release_date = releaseDate
into
$database..ACC_LogicalDB
from
mgd..ACC_LogicalDB	
go	


select
	_MGIType_key,
	name,
	tableName,
	primaryKeyName,
	creation_date = creationDate,
	modification_date = modificationDate,
	release_date = releaseDate
into
$database..ACC_MGIType
from
mgd..ACC_MGIType	
go	


select
	_Refs_key,
	book_au,
	book_title,
	place,
	publisher,
	series_ed,
	creation_date = dt,
	modification_date = dt 
into
$database..BIB_Books
from
mgd..BIB_Books, #constant	
go	


select
	_Refs_key,
	sequenceNum,
	note,
	creation_date = dt,
	modification_date = dt
into
$database..BIB_Notes
from
mgd..BIB_Notes, #constant	
go	

/* Moved abstract field above date field: order change */
select
	_Refs_key,
	_ReviewStatus_key = rsk,
	refType,
	authors,
	authors2,
	_primary,
	title,
	title2,
	journal,
	vol,
	issue,
	date,
	year,
	pgs,
	dbs,
	NLMstatus,
	abstract,
	creation_date,
	modification_date
into
$database..BIB_Refs
from
mgd..BIB_Refs
go	

create table $database.dbo.BIB_ReviewStatus
	(_ReviewStatus_key int not null,
	name varchar(40) not null,
	creation_date datetime not null,
	modification_date datetime not null)
go	

exec sp_primarykey BIB_ReviewStatus, _ReviewStatus_key
go


/* see http://kelso:4444/software/mgi1.0/reviewlevel.html */
/* Lori seems to be loading the data also */

/* Lori will handle CRS_Cross */
select
	_Cross_key,
	_Marker_key,
	otherSymbol,
	chromosome,
	rowNumber,
	notes,
	creation_date = dt,
	modification_date = dt
into
$database..CRS_Matrix
from
mgd..CRS_Matrix, #constant 
go	


select
	_Cross_key,
	sequenceNum,
	name,
	sex,
	notes,
	creation_date = dt,
	modification_date = dt 
into
$database..CRS_Progeny
from
mgd..CRS_Progeny, #constant	
go	


select
	_Cross_key,
	_Marker_key,
	_Refs_key,
	creation_date = dt,
	modification_date = dt 
into
$database..CRS_References
from
mgd..CRS_References, #constant
go	


select
	_Cross_key,
	rowNumber,
	colNumber,
	data,
	creation_date = dt,
	modification_date = dt
into
$database..CRS_Typings
from
mgd..CRS_Typings, #constant	
go	

select
	index_id = convert(int, index_id),
	_Refs_key,
	_Marker_key,
	comments,
	creation_date =dt,
	modification_date = dt 
into
$database..GXD_Index
from
mgd..GXD_Index, #constant
go	

select
	index_id = convert(int, index_id),
	stage_id,
	insitu_protein_section,
	insitu_rna_section,
	insitu_protein_mount,
	insitu_rna_mount,
	northern,
	western,
	rt_pcr,
	clones,
	rnase,
	nuclease,
	primer_extension,
	creation_date = dt,
	modification_date = dt
into
$database..GXD_Index_Stages
from
mgd..GXD_Index_Stages, #constant	
go	

select
	table_name,
	col_name,
	description,
	example,
	creation_date = dt,
	modification_date = dt
into
$database..MGD_Comments
from
mgd..MGD_Comments, #constant	
go	


select
	name,
	description,
	species,
	creation_date = dt,
	modification_date = dt
into
$database..MGD_Tables
from
mgd..MGD_Tables, #constant
go	


select
	_Marker_key,
	time,
	creation_date = dt,
	modification_date = dt
into
$database..MLC_History
from
mgd..MLC_History, #constant	
go	


select
	_Marker_key,
	time,
	creation_date = dt,
	modification_date = dt
into
$database..MLC_History_edit
from
mgd..MLC_History_edit, #constant	
go	


select
	time,
	_Marker_key,
	checkedOut,
	creation_date = dt,
	modification_date = dt
into
$database..MLC_Lock_edit
from
mgd..MLC_Lock_edit, #constant	
go	


select
	_Marker_key,
	tag,
	_Marker_key_2,
	creation_date = dt,
	modification_date = dt
into
$database..MLC_Marker
from
mgd..MLC_Marker, #constant	
go	


select
	_Marker_key,
	tag,
	_Marker_key_2,
	creation_date = dt,
	modification_date = dt
into
$database..MLC_Marker_edit
from
mgd..MLC_Marker_edit, #constant	
go	


select
	_Marker_key,
	_Refs_key,
	tag,
	creation_date = dt,
	modification_date = dt
into
$database..MLC_Reference
from
mgd..MLC_Reference, #constant	
go	


select
	_Marker_key,
	_Refs_key,
	tag,
	creation_date = dt,
	modification_date = dt
into
$database..MLC_Reference_edit
from
mgd..MLC_Reference_edit, #constant	
go	


select
	_Marker_key,
	mode,
	description,
	creation_date = dt,
	modification_date = dt
into
$database..MLC_Text
from
mgd..MLC_Text, #constant	
go	


select
	_Marker_key,
	mode,
	description,
	creation_date = dt,
	modification_date = dt
into
$database..MLC_Text_edit
from
mgd..MLC_Text_edit, #constant	
go	


select
	_Assay_Type_key,
	description,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_Assay_Types
from
mgd..MLD_Assay_Types, #constant	
go	


select
	_Expt_key,
	sequenceNum,
	_Marker_key,
	chromosome,
	cpp,
	cpn,
	cnp,
	cnn,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_Concordance
from
mgd..MLD_Concordance, #constant	
go	


select
	_Contig_key,
	_Expt_key,
	mincm,
	maxcm,
	name,
	minLink,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_Contig
from
mgd..MLD_Contig, #constant	
go	


select
	_Contig_key,
	sequenceNum,
	_Probe_key,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_ContigProbe
from
mgd..MLD_ContigProbe, #constant	
go	


select
	_Expt_key,
	_Marker_key_1,
	_Marker_key_2,
	sequenceNum,
	estDistance,
	endonuclease,
	minFrag,
	notes,
	relativeArrangeCharStr,
	units,
	realisticDist,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_Distance
from
mgd..MLD_Distance, #constant	
go	


select
	_Expt_key,
	_Marker_key,
	_Allele_key,
	_Assay_Type_key,
	sequenceNum,
	gene,
	description,
	matrixData,
	creation_date,
	modification_date
into
$database..MLD_Expt_Marker
from
mgd..MLD_Expt_Marker, #constant	
go	


select
	_Expt_key,
	sequenceNum,
	note,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_Expt_Notes
from
mgd..MLD_Expt_Notes, #constant	
go	


select
	_Expt_key,
	_Refs_key,
	exptType,
	tag,
	chromosome,
	creation_date,
	modification_date 
into
$database..MLD_Expts
from
mgd..MLD_Expts
go	


select
	_Expt_key,
	band,
	_Strain_key = 0,
	cellOrigin,
	karyotype,
	robertsonians,
	label,
	numMetaphase,
	totalSingle,
	totalDouble,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_FISH
from
mgd..MLD_FISH, #constant	
go	

select
	_Expt_key,
	sequenceNum,
	region,
	totalSingle,
	totalDouble,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_FISH_Region
from
mgd..MLD_FISH_Region, #constant	
go	


select
	_Expt_key,
	_Probe_key,
	_Target_key,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_Hit
from
mgd..MLD_Hit, #constant	
go	


select
	_Expt_key,
	chrsOrGenes,
	band,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_Hybrid
from
mgd..MLD_Hybrid, #constant	
go	

select
	_Expt_key,
	band,
	_Strain_key = 0,
	cellOrigin,
	karyotype,
	robertsonians,
	numMetaphase,
	totalGrains,
	grainsOnChrom,
	grainsOtherChrom,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_InSitu
from
mgd..MLD_InSitu, #constant	
go	

select
	_Expt_key,
	sequenceNum,
	region,
	grainCount,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_ISRegion
from
mgd..MLD_ISRegion, #constant	
go	


select
	_Refs_key,
	_Marker_key,
	sequenceNum,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_Marker
from
mgd..MLD_Marker, #constant	
go	


select
	_Expt_key,
	_Cross_key,
	female,
	female2,
	male,
	male2,
	creation_date = dt,
        modification_date = dt
into
$database..MLD_Matrix
from
mgd..MLD_Matrix, #constant	
go	


select
	_Expt_key,
	_Marker_key_1,
	_Marker_key_2,
	sequenceNum,
	numRecombinants,
	numParentals,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_MC2point
from
mgd..MLD_MC2point, #constant	
go	


select
	_Expt_key,
	sequenceNum,
	alleleLine,
	offspringNmbr,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_MCDataList
from
mgd..MLD_MCDataList, #constant	
go	


select
	_Refs_key,
	sequenceNum,
	note,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_Notes
from
mgd..MLD_Notes, #constant	
go	


select
	_Expt_key,
	definitiveOrder,
	geneOrder,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_PhysMap
from
mgd..MLD_PhysMap, #constant	
go	


select
	_Expt_key,
	origin,
	designation,
	abbrev1,
	abbrev2,
	RI_IdList,
	_RISet_key,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_RI
from
mgd..MLD_RI, #constant	
go	


select
	_Expt_key,
	_Marker_key_1,
	_Marker_key_2,
	sequenceNum,
	numRecombinants,
	numTotal,
	RI_Lines,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_RI2Point
from
mgd..MLD_RI2Point, #constant	
go	


select
	_Expt_key,
	_Marker_key,
	sequenceNum,
	alleleLine,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_RIData
from
mgd..MLD_RIData, #constant	
go	


select
	_Expt_key,
	sequenceNum,
	_Marker_key_1,
	_Marker_key_2,
	recomb,
	total,
	pcntrecomb,
	stderr,
	creation_date = dt,
	modification_date = dt
into
$database..MLD_Statistics
from
mgd..MLD_Statistics, #constant	
go	


select
	_Alias_key,
	_Marker_key,
	creation_date = dt,
	modification_date = dt
into
$database..MRK_Alias
from
mgd..MRK_Alias, #constant	
go	


select
	_Allele_key,
	_Marker_key,
	symbol,
	name,
	creation_date = dt,
	modification_date = dt
into
$database..MRK_Allele
from
mgd..MRK_Allele, #constant	
go	


select
	chromosome,
	_Marker_key,
	creation_date = dt,
	modification_date = dt
into
$database..MRK_Anchors
from
mgd..MRK_Anchors, #constant	
go	


select
	_Species_key,
	chromosome,
	sequenceNum,
	creation_date = dt,
	modification_date = dt
into
$database..MRK_Chromosome
from
mgd..MRK_Chromosome, #constant	
go	


select
	_Class_key,
	name,
	creation_date = dt,
	modification_date = dt
into
$database..MRK_Class
from
mgd..MRK_Class, #constant	
go	


select
	_Marker_key,
	_Class_key,
	creation_date = dt,
	modification_date = dt
into
$database..MRK_Classes
from
mgd..MRK_Classes, #constant	
go	


select
	_Current_key,
	_Marker_key,
	creation_date = dt,
	modification_date = dt
into
$database..MRK_Current
from
mgd..MRK_Current, #constant	
go	


/* 1-12-98 Need to get event date from mgd.MRK_History's creation_date*/
select
	_Marker_key,
	_History_key,
	_Refs_key,
	sequenceNum,
	name,
	note,
	event_date = mgd.dbo.MRK_History.modification_date,
	creation_date = mgd.dbo.MRK_History.modification_date,
	modification_date
into
$database..MRK_History
from
mgd..MRK_History
go	

select
	_Marker_key,
	_Species_key,
	_Marker_Type_key,
	symbol,
	name,
	chromosome = convert(varchar(8), chromosome),
	cytogeneticOffset,
	creation_date,
	modification_date
into
$database..MRK_Marker
from
mgd..MRK_Marker
go	


select
	_Marker_key,
	sequenceNum,
	note,
	creation_date = dt,
	modification_date = dt
into
$database..MRK_Notes
from
mgd..MRK_Notes, #constant	
go	


select
	_Marker_key,
	source,
	offset,
	creation_date = dt,
	modification_date = dt
into
$database..MRK_Offset
from
mgd..MRK_Offset, #constant	
go	


select
	_Other_key,
	_Marker_key,
	name,
	creation_date = dt,
	modification_date = dt
into
$database..MRK_Other
from
mgd..MRK_Other, #constant	
go	


select
	_Species_key,
	name,
	species,
	creation_date = dt,
	modification_date = dt
into
$database..MRK_Species
from
mgd..MRK_Species, #constant	
go	


select
	_Marker_Type_key,
	name,
	creation_date = dt,
	modification_date = dt
into
$database..MRK_Types
from
mgd..MRK_Types, #constant	
go	

select 
	_Marker_key, 
	_Marker_Type_key,
	name = convert(varchar(200), name),
	creation_date = dt,
        modification_date = dt	
into
$database..MRK_Name
from mgd..MRK_Name, #constant
go


select
	_Marker_key, 
	_Marker_Type_key,
	symbol,
	creation_date = dt,
        modification_date = dt
into
$database..MRK_Symbol
from
mgd..MRK_Symbol, #constant
go


select
	_Marker_key,
	_Refs_key, 
	auto, 
	creation_date = dt,
	modification_date = dt
into
$database..MRK_Reference
from
mgd..MRK_Reference, #constant
go


/* Need the following Probe tables loaded */
/*PRB_Alias                                    0     rows */ 
/*PRB_Allele                                   0     rows */ 
/*PRB_Marker                                   0     rows */ 
/*PRB_Notes                                    0     rows */ 
/*PRB_Reference                                0     rows */ 
/*PRB_Vector_Types                             0     rows */ 


select

	_Alias_key, 
	_Reference_key,
	alias,
	creation_date = dt,
	modification_date = dt 
into
$database..PRB_Alias
from
mgd..PRB_Alias, #constant
go


select
	_Allele_key,
	_RFLV_key, 
	allele,   
	fragments,
	creation_date = dt, 
	modification_date = dt
into
$database..PRB_Allele
from 
mgd..PRB_Allele, #constant
go


select
	_Probe_key, 
	_Marker_key, 
	relationship,  
	creation_date = dt, 
	modification_date = dt
into
$database..PRB_Marker
from
mgd..PRB_Marker, #constant
go


select
	_Probe_key,
	sequenceNum,
	note,      
	creation_date = dt, 
	modification_date = dt
into
$database..PRB_Notes
from
mgd..PRB_Notes, #constant
go


select
	_Reference_key,
	sequenceNum,  
	note,        
	creation_date = dt,
	modification_date = dt      
into
$database..PRB_Ref_Notes
from 
mgd..PRB_Ref_Notes, #constant
go

select 
  _Probe_key,
  name,
  derivedFrom,
  _Source_key,
  _Vector_key,
  primer1sequence,
  primer2sequence,
  regionCovered,
  regionCovered2,
  insertSite,
  insertSize,
  DNAtype,
  repeatUnit,
  productSize,
  moreProduct,
  creation_date,
  modification_date
into 
$database..PRB_Probe
from
mgd..PRB_Probe
where
mgd..PRB_Probe._Source_key is not NULL
go


insert $database..PRB_Probe
select 
  _Probe_key,
  name,
  derivedFrom,
  _Source_key = -2,
  _Vector_key, 
  primer1sequence,
  primer2sequence,
  regionCovered,
  regionCovered2,
  insertSite,
  insertSize,
  DNAtype,
  repeatUnit,
  productSize,
  moreProduct,
  creation_date,
  modification_date
from mgd..PRB_Probe
where
mgd..PRB_Probe._Source_key is null

select
	_Reference_key,
	_Probe_key,
	_Refs_key,
	holder,
	hasRmap,
	hasSequence,
	creation_date = dt,
	modification_date = dt
into
$database..PRB_Reference
from
mgd..PRB_Reference, #constant
go


select
	_RFLV_key,
	_Reference_key,
	_Marker_key,
	endonuclease,
	creation_date = dt,
	modification_date = dt
into
$database..PRB_RFLV
from
mgd..PRB_RFLV, #constant
go

/* 1-12-98: change cellLine from varchar(50 > 100) */
/* Lori needs to load data */

CREATE TABLE PRB_Source
(
 _Source_key        int                    NOT NULL,
 name               varchar(255)           NULL,
 description        varchar(255)           NULL,
 _Refs_key          int                    NULL,
 species            varchar(40)            NOT NULL,
 _Strain_key        int                    NOT NULL,
 _Tissue_key        int                    NOT NULL,
 age                varchar(50)            NOT NULL,
 ageMin             float                  NULL,
 ageMax             float                  NULL,
 sex                varchar(14)            NOT NULL,
 cellLine           varchar(100)           NULL,
 creation_date      datetime               NOT NULL,
 modification_date  datetime               NOT NULL
)     
go

select
	_Vector_key,
	vectorType,
	creation_date = dt,
	modification_date = dt
into
$database..PRB_Vector_Types
from
mgd..PRB_Vector_Types, #constant
go


/* order change: moved dates to bottom */
select
	_RISet_key,
	origin,
	designation,
	abbrev1,
	abbrev2,
	RI_IdList,
	creation_date, 
	modification_date
into
$database..RI_RISet
from
mgd..RI_RISet	
go	


select
	_RISummary_key,
	_RISet_key,
	_Marker_key,
	summary,
	creation_date = dt,
	modification_date = dt
into
$database..RI_Summary
from
mgd..RI_Summary, #constant	
go	


select
	_RISummary_key,
	_Expt_key,
	_Refs_key,
	creation_date = dt,
	modification_date = dt
into
$database..RI_Summary_Expt_Ref
from
mgd..RI_Summary_Expt_Ref, #constant	
go

drop table constant
go


EOSQL
) | $path/isql -I/usr/sybase/11.0.2/interfaces -Umgd_dbo -S$server


(cat /usr/sybase/10.0.2/admin/.mgd_dbo_password
cat << EOSQL
 
use master
go
 
sp_dboption $database.."select into", false 
go
 
use $database
go
 
checkpoint
go
 
EOSQL
) | $path/isql -I/usr/sybase/11.0.2/interfaces -Umgd_dbo -S$server
