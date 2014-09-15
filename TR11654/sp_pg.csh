#!/bin/csh -fx

###----------------------###
###--- initialization ---###
###----------------------###

if ( ${?MGICONFIG} == 0 ) then
	setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

# start a new log file for this migration, and add a datestamp

setenv LOG $0.log
rm -rf ${LOG}
touch ${LOG}

date | tee -a ${LOG}
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a ${LOG}

--- ACCRef_insert

--select a.accID from ACC_Accession a 
--where not exists (select 1 from ACC_AccessionReference r where a._Accession_key = r._Accession_key)
--and a._LogicalDB_key = 9;

delete from ACC_AccessionReference where _Accession_key = 2619603;

select * from ACC_AccessionReference where _Accession_key = 2619603;

select ACCRef_insert(2619603,100);

select * from ACC_AccessionReference where _Accession_key = 2619603;

delete from ACC_AccessionReference where _Accession_key = 2619603;

--- ACC_setMax

select * from ACC_AccessionMax;

select ACC_setMax(10);
select ACC_setMax(10, 'J:');

--- ALL_mergeAllele

select * from ALL_Allele where _Allele_key in (8440, 18565)
;
select ALL_mergeAllele(8440, 18565)
;
select * from ALL_Allele where _Allele_key in (8440, 18565)
;

--- BIB_getCopyright

select * from BIB_getCopyright(9);
select * from BIB_getCopyright(209521);
select * from BIB_getCopyright(199452);
select * from BIB_getCopyright(209029);

-- GXD_removeBadGelBand
select r._Assay_key
from GXD_GelBand b, GXD_GelRow r, GXD_GelLane l
where b._GelLane_key = l._GelLane_key
and r._GelRow_key = b._GelRow_key
and r._Assay_key != l._Assay_key
and r._Assay_key = 75337
;

select * from GXD_removeBadGelBand(75337);

--- MGI_insertReferenceAssoc

delete from MGI_Reference_Assoc 
where _mgitype_key = 2 and _object_key = 110 and _refs_key = 63991 and _refassoctype_key = 1018;

select * from MGI_insertReferenceAssoc (2, 110, 63991, 'General');

select * from MGI_Reference_Assoc 
where _mgitype_key = 2 and _object_key = 110 and _refs_key = 63991 and _refassoctype_key = 1018;

--- MGI_insertSynonym

delete from MGI_Synonym where _object_key = 32724 and _mgitype_key = 10;

select * from MGI_Synonym where _object_key = 32724 and _mgitype_key = 10;

select MGI_insertSynonym (32724, 10, 1001, '1039CD1');

select * from MGI_Synonym where _object_key = 32724 and _mgitype_key = 10;

--- MRK_insertHistory
delete from MRK_History where _Marker_key = 10603 and sequenceNum = 15;
select * from MRK_History where _Marker_key = 10603 and sequenceNum = 15;
select * from MRK_insertHistory
(10603, 119679,126923,4,-1,'phenotype like Sl or W 3','08/09/2014',1001,1001,'08/09/2014','08/09/2014');

--- MRK_updateOffset
update MRK_Marker set cytogeneticOffset = 'test-1' where _Marker_key in (585022);
update MRK_Marker set cytogeneticOffset = null where _Marker_key in (585023);
update MRK_Offset set cmoffset = 11 where _Marker_key in (585022);
update MRK_Offset set cmoffset = -1 where _Marker_key in (585023);
select _Marker_key, symbol, chromosome, cytogeneticOffset from MRK_Marker where _Marker_key in (585022,585023);
select * from MRK_Offset where _Marker_key in (585022,585023);
select * from MRK_updateOffset(585022,585023);

--- NOM_updateReserved

update NOM_Marker set _NomenStatus_key = 166901 where _Nomen_key = 82576;
select * from NOM_updateReserved('Zxdb');

--- PRB_insertReference

delete from PRB_Reference where _Probe_key = 1 and _Refs_key = 13155;
select * from PRB_Reference where _Probe_key = 1;
select * from PRB_insertReference (13155, 1);

--- PRB_reloadSequence

select * from PRB_reloadSequence(1);
select * from SEQ_Probe_Cache where _Probe_key = 1;

--- SEQ_loadMarkerCache

delete from SEQ_Marker_Cache where _Sequence_key = 15844;
select * from SEQ_Marker_Cache where _Sequence_key = 15844;
select * from SEQ_loadMarkerCache(15844);

--- SEQ_loadProbeCache

delete from SEQ_Probe_Cache where _Sequence_key = 1025;
select * from SEQ_Probe_Cache where _Sequence_key = 1025;
select * from SEQ_loadProbeCache(1025);

--- VOC_mergeTerms
select distinct t._term_key, t.term from VOC_Annot v, VOC_Term t
where v._AnnotType_key = 1000 and v._Term_key = t._Term_key and term like 'z%'
;
select v.* from VOC_Annot v where v._Term_key in (4479378, 52218)
;

select * from VOC_mergeTerms(4479378, 52218)
;

--- VOC_mergeAnnotations

select * from VOC_Annot where _AnnotType_key = 1002 and _Object_key in (1,59)
;
select * from VOC_mergeAnnotations(1002, 1, 59)
;
select * from VOC_Annot where _AnnotType_key = 1002 and _Object_key in (1,59)
;

--- TO-DO

--- ACC_split : needs postgres translations
---select * from ACC_split('MGI:12345');

---select accid, 
---regexp_matches(accid, '(^\\D+)') as prefix_parts, 
---regexp_matches(accid, '(\\d+)(\\w+)') as numeric_parts
---from ACC_Accession
---where _mgitype_key = 2 and _object_key = 10603
---and accid = 'A4ZVL1'
---union
---select accid, null, null
---from ACC_Accession
---where accid ~* '^[0-9]'
---and _mgitype_key = 2 and _object_key = 10603
---order by accid

---select accid, split_part(accid, '(^\\d+)', 1)
---from ACC_Accession
---where accid ~* '^[0-9]'
---and _mgitype_key = 2 and _object_key = 10603
---order by accid

---select accid
---from ACC_Accession
---where _mgitype_key = 2 and _object_key = 10603
---order by accid

---select accid, 
---regexp_matches(reverse(accid), '(\\D+)') as prefix_parts, 
---regexp_matches(reverse(accid), '(^\\d+)(\\w+)') as numeric_parts
---from ACC_Accession
---where _mgitype_key = 2 and _object_key = 10603
---union
---select accid, null, null
---from ACC_Accession
---where accid ~* '^[0-9]'
---and _mgitype_key = 2 and _object_key = 10603
---order by accid

--- MAP_deleteByCollection : move to java library

--- MGI_Table_Column_Cleanup : uses sybase-specific tables

---select * from MGI_Table_Column_Cleanup();

--- MGI_checkUserRole

---select * from MGI_checkUserRole('AlleleModule', 'mgd_dbo');

--- MRK_deleteIMAGESeqAssoc : checking witih Richard ; may be obsolete
--- MRK_updateIMAGESeqAssoc

--- VOC_mergeAnnotations

EOSQL
date | tee -a ${LOG}

