#!/bin/csh -fx

#
# Migration for TR9037 and 9062 -- schema indexing changes
#

###----------------------###
###--- initialization ---###
###----------------------###

source ../Configuration
setenv CWD `pwd`	# current working directory

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log.$$
rm -rf ${LOG}
touch ${LOG}
date | tee -a ${LOG}
echo "--- Starting in ${CWD}..." | tee -a ${LOG}

# load a backup

if ("${1}" == "dev") then
    echo "--- Loading new database into ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
    load_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /shire/sybase/mgd.backup | tee -a ${LOG}
    date | tee -a ${LOG}
    echo "--- Finished loading database" | tee -a ${LOG}
else
    echo "--- Working on existing database: ${MGD_DBSERVER}..${MGD_DBNAME}" | tee -a ${LOG}
endif

setenv SCHEMA ${MGD_DBSCHEMADIR}
setenv PERMS ${MGD_DBPERMSDIR}
setenv UTILS ${MGI_DBUTILS}

setenv DBCLUSTIDXSEG seg0
setenv DBNONCLUSTIDXSEG seg1

###--------------------------------------------------------------###
###--- remove old indexes, add new ones, update existing ones ---###
###--------------------------------------------------------------###

date | tee -a ${LOG}
echo "--- Altering indexes" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

/*--------------*/
/* image tables */
/*--------------*/

drop index IMG_ImagePane_Assoc.idx_Assoc_key
go
create unique nonclustered index idx_Assoc_key on IMG_ImagePane_Assoc (_Assoc_key) on ${DBNONCLUSTIDXSEG}
go

/*-----------------*/
/* sequence tables */
/*-----------------*/

drop index SEQ_Coord_Cache.idx_Map_key
go

drop index SEQ_Marker_Cache.idx_Sequence_key
go
drop index SEQ_Marker_Cache.idx_Marker_key
go
create nonclustered index idx_Marker_key on SEQ_Marker_Cache (_Marker_key, _Sequence_key) on ${DBNONCLUSTIDXSEG}
go

drop index SEQ_Probe_Cache.idx_Sequence_key
go
drop index SEQ_Probe_Cache.idx_Probe_key
go
create nonclustered index idx_Probe_key on SEQ_Probe_Cache (_Probe_key, _Sequence_key) on ${DBNONCLUSTIDXSEG}
go

/*---------------------------*/
/* vocabulary and DAG tables */
/*---------------------------*/

drop index VOC_AnnotHeader.idx_AnnotType_key
go

drop index VOC_AnnotType.idx_MGIType_key
go

drop index VOC_Text.idx_Term_key
go

drop index VOC_VocabDAG.idx_Vocab_key
go

drop index DAG_Closure.idx_DAG_key
go
drop index DAG_Closure.idx_DAGAncestorDescendent
go
create nonclustered index idx_DAGAncestorDescendent on DAG_Closure (_DAG_key, _Ancestor_key, _Descendent_key) on ${DBNONCLUSTIDXSEG}
go
drop index DAG_Closure.idx_AncestorObject_key
go
create clustered index idx_AncestorObject_key on DAG_Closure (_AncestorObject_key, _DescendentObject_key, _DAG_key) on ${DBCLUSTIDXSEG}
go
drop index DAG_Closure.idx_DescendentObject_key
go
create nonclustered index idx_DescendentObject_key on DAG_Closure (_DescendentObject_key, _AncestorObject_key, _DAG_key) on ${DBNONCLUSTIDXSEG}
go

drop index VOC_Term.idx_term
go
create nonclustered index idx_term on VOC_Term (term, _Term_key, _Vocab_key) on ${DBNONCLUSTIDXSEG}
go
create clustered index idx_primary on VOC_Term (_Vocab_key, sequenceNum, term, _Term_key) on ${DBCLUSTIDXSEG}
go

drop index VOC_Vocab.idx_name
go
create unique nonclustered index idx_name on VOC_Vocab (name, _Vocab_key) on ${DBNONCLUSTIDXSEG}
go

/*------------------*/
/* accession tables */
/*------------------*/

drop index ACC_AccessionReference.idx_Accession_key
go

drop index ACC_Accession.idx_Object_key
go
drop index ACC_Accession.idx_Object_MGIType_key
go
create clustered index idx_Object_MGIType_key on ACC_Accession (_Object_key, _MGIType_key) on ${DBCLUSTIDXSEG}
go

drop index ACC_LogicalDB.idx_name
go
create unique nonclustered index idx_name on ACC_LogicalDB (name, _LogicalDB_key) on ${DBNONCLUSTIDXSEG}
go

/*---------------*/
/* allele tables */
/*---------------*/

drop index ALL_Allele_Mutation.idx_Allele_key
go

drop index ALL_Label.idx_Allele_key
go

/*------------------*/
/* reference tables */
/*------------------*/

drop index BIB_Notes.idx_Refs_key
go

/*------------------*/
/* reference tables */
/*------------------*/

drop index HMD_Homology_Assay.idx_Homology_key
go

drop index HMD_Homology_Marker.idx_Marker_key
go

drop index HMD_Notes.idx_Homology_key
go

/*--------------*/
/* probe tables */
/*--------------*/

drop index PRB_Allele_Strain.idx_Allele_key
go

drop index PRB_Marker.idx_Marker_key
go

drop index PRB_Notes.idx_Probe_key
go

drop index PRB_Probe.idx_SegmentType_key
go

drop index PRB_Ref_Notes.idx_Reference_key
go

/*--------------*/
/* cross tables */
/*--------------*/

drop index CRS_Matrix.idx_Cross_key
go

drop index CRS_Progeny.idx_Cross_key
go

drop index CRS_References.idx_Cross_key
go

drop index CRS_Typings.idx_Cross_key
go

drop index CRS_Typings.idx_Cross_key_rowNumber
go

/*---------------*/
/* strain tables */
/*---------------*/

drop index RI_Summary_Expt_Ref.idx_RISummary_key
go

/*----------------------------------*/
/* mouse locus catalog (mlc) tables */
/*----------------------------------*/

drop index MLC_Marker.idx_Marker_key
go

drop index MLC_Reference.idx_Marker_key
go

/*------------*/
/* mgi tables */
/*------------*/

drop index MGI_AttributeHistory.idx_Object_key
go

drop index MGI_NoteChunk.idx_Note_key
go

drop index MGI_Note.idx_Object_key
go

drop index MGI_Organism_MGIType.idx_Organism_key
go

drop index MGI_Reference_Assoc.idx_Refs_key
go

/*-------------------*/
/* expression tables */
/*-------------------*/

drop index GXD_AlleleGenotype.idx_Genotype_key
go
drop index GXD_AlleleGenotype.idx_Allele_key
go
create nonclustered index idx_Allele_key on GXD_AlleleGenotype (_Allele_key, _Genotype_key) on ${DBNONCLUSTIDXSEG}
go

drop index GXD_AssayNote.idx_Assay_key
go

drop index GXD_GelLaneStructure.idx_GelLane_key
go

drop index GXD_Index.idx_Marker_key
go
drop index GXD_Index.idx_Index_key
go
create unique nonclustered index idx_Index_key on GXD_Index (_Index_key) on ${DBNONCLUSTIDXSEG}
go
drop index GXD_Index.idx_RefsMarker_key
go
create unique clustered index idx_RefsMarker_key on GXD_Index (_Marker_key, _Refs_key) on ${DBCLUSTIDXSEG}
go

drop index GXD_Index_Stages.idx_Index_key
go

drop index GXD_InSituResultImage.idx_Result_key
go

drop index GXD_ISResultStructure.idx_Result_key
go

drop index GXD_StructureClosure.idx_Structure_key
go
drop index GXD_StructureClosure.idx_Descendent_key
go
create nonclustered index idx_Descendent_key on GXD_StructureClosure (_Descendent_key, _Structure_key) on ${DBNONCLUSTIDXSEG}
go

/*---------------*/
/* marker tables */
/*---------------*/

drop index MRK_Alias.idx_Marker_key
go

drop index MRK_Anchors.idx_chromosome
go

drop index MRK_Chromosome.idx_Organism_key
go

drop index MRK_Classes.idx_Marker_key
go

drop index MRK_Current.idx_Current_key
go

drop index MRK_History.idx_Marker_key
go

drop index MRK_Notes.idx_Marker_key
go

drop index MRK_Offset.idx_Marker_key
go

drop index MRK_OMIM_Cache.idx_Term_key
go

drop index MRK_Reference.idx_Marker_key
go

drop index MRK_Marker.idx_Marker_key
go
create unique nonclustered index idx_Marker_key on MRK_Marker (_Marker_key, _Organism_key) on ${DBNONCLUSTIDXSEG}
go
drop index MRK_Marker.idx_Marker_Type_key
go
create nonclustered index idx_Marker_Type_key on MRK_Marker (_Marker_Type_key, _Marker_key) on ${DBNONCLUSTIDXSEG}
go
drop index MRK_Marker.idx_chromosome
go
create clustered index idx_chromosome on MRK_Marker (chromosome) on ${DBCLUSTIDXSEG}
go

drop index MRK_Location_Cache.idx_coordinate
go
create clustered index idx_coordinate on MRK_Location_Cache (chromosome, startCoordinate, endCoordinate) on ${DBCLUSTIDXSEG}
go

/*----------------*/
/* mapping tables */
/*----------------*/

drop index MLD_Concordance.idx_Expt_key
go

drop index MLD_ContigProbe.idx_Contig_key_fk
go

drop index MLD_Distance.idx_Expt_key
go

drop index MLD_Expt_Marker.idx_Expt_key
go

drop index MLD_Expt_Notes.idx_Expt_key
go

drop index MLD_FISH_Region.idx_Expt_key
go

drop index MLD_Hit.idx_Expt_key_fk
go

drop index MLD_ISRegion.idx_Expt_key
go

drop index MLD_MC2point.idx_Expt_key
go

drop index MLD_MCDataList.idx_Expt_key
go

drop index MLD_Notes.idx_Refs_key
go

drop index MLD_RI2Point.idx_Expt_key
go

drop index MLD_Statistics.idx_Expt_key
go

EOSQL

###--------------------------------------------###
###--- add new tables and stored procedures ---###
###--------------------------------------------###

date | tee -a ${LOG}
echo "--- Adding tables" | tee -a ${LOG}

${SCHEMA}/table/VOC_Marker_Cache_create.object | tee -a ${LOG}
${SCHEMA}/table/VOC_Annot_Count_Cache_create.object | tee -a ${LOG}
${SCHEMA}/index/VOC_Marker_Cache_create.object | tee -a ${LOG}
${SCHEMA}/index/VOC_Annot_Count_Cache_create.object | tee -a ${LOG}
${PERMS}/public/table/VOC_Marker_Cache_grant.object | tee -a ${LOG}
${PERMS}/public/table/VOC_Annot_Count_Cache_grant.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Adding procedures" | tee -a ${LOG}

${SCHEMA}/procedure/VOC_Cache_Anatomy_Counts_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_Anatomy_Markers_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_GO_Counts_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_InterPro_Counts_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_MP_Counts_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_MP_Markers_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_OMIM_Counts_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_OMIM_Markers_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_Other_Markers_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_PIRSF_Counts_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_Counts_create.object | tee -a ${LOG}
${SCHEMA}/procedure/VOC_Cache_Markers_create.object | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Adding keys" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go
sp_foreignkey VOC_Annot_Count_Cache, ACC_MGIType, _MGIType_key
go
sp_foreignkey VOC_Annot_Count_Cache, VOC_Term, _Term_key
go
sp_foreignkey VOC_Marker_Cache, MRK_Marker, _Marker_key
go
sp_foreignkey VOC_Marker_Cache, VOC_Term, _Term_key
go
EOSQL

###---------------------------###
###--- populate new tables ---###
###---------------------------###

date | tee -a ${LOG}
echo "--- Populating VOC_Marker_Cache" | tee -a ${LOG}
${MGICACHELOAD}/vocmarker.csh | tee -a ${LOG}

date | tee -a ${LOG}
echo "--- Populating VOC_Annot_Count_Cache" | tee -a ${LOG}
${MGICACHELOAD}/voccounts.csh | tee -a ${LOG}

###----------------------------###
###--- check table contents ---###
###----------------------------###

date | tee -a ${LOG}
echo "--- Checking counts in new tables" | tee -a ${LOG}

cat - <<EOSQL | doisql.csh ${MGD_DBSERVER} ${MGD_DBNAME} $0 | tee -a ${LOG}

use ${MGD_DBNAME}
go

select annotType,
    count(distinct _Marker_key) as "markers",
    count(distinct _Term_key) as "terms",
    count(1) as "associations"
from VOC_Marker_Cache
group by annotType
go

select annotType,
    count(distinct _Term_key) as "terms",
    count(distinct _MGIType_key) as "mgi types",
    count(1) as "rows"
from VOC_Annot_Count_Cache
group by annotType
go

EOSQL

###-----------------------###
###--- final datestamp ---###
###-----------------------###

date | tee -a ${LOG}
echo "--- Finished migration" | tee -a ${LOG}

#dump_db.csh ${MGD_DBSERVER} ${MGD_DBNAME} /backups/rohan/jsb/tr9062. | tee -a ${LOG}
#date | tee -a ${LOG}
#echo "--- Finished database dump" | tee -a ${LOG}
