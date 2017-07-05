#!/bin/csh -f

#
# sto38/analysis of existing data sets for migration to new workflow schema
#


if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

--
-- Probes (1000)
--
(
select ds._dataset_key, ds.abbreviation, 'selected/used' as selectedUsed, dbsa.isNeverused, dbsa.isIncomplete, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1000)
and ds._dataset_key = dbsa._dataset_key
and exists (select 1 from PRB_Reference gi where gi._Refs_key = dbsa._Refs_key)
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused, dbsa.isIncomplete
union
select ds._dataset_key, ds.abbreviation, 'selected/not used', dbsa.isNeverused, dbsa.isIncomplete, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1000)
and ds._dataset_key = dbsa._dataset_key
and not exists (select 1 from PRB_Reference gi where gi._Refs_key = dbsa._Refs_key)
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused, dbsa.isIncomplete
union
select 1000 as _dataset_key, 'Probes/Seq' as abbreviation, 'not selected/used', 0 as isNeverused, 0 as isIncomplete, count(distinct r._Refs_key)
from BIB_Citation_Cache r
where not exists (select 1 from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
        where ds._dataset_key in (1000)
        and ds._dataset_key = dbsa._dataset_key
        and r._Refs_key = dbsa._Refs_key
        )
and exists (select 1 from PRB_Reference gi where gi._Refs_key = r._Refs_key)
group by _dataset_key, abbreviation, isNeverused, isIncomplete
)
order by selectedUsed
;

--
-- Mapping (1001)
--
(
select ds._dataset_key, ds.abbreviation, 'selected/used' as selectedUsed, dbsa.isNeverused, dbsa.isIncomplete, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1001)
and ds._dataset_key = dbsa._dataset_key
and exists (select 1 from MLD_Expts gi where gi._Refs_key = dbsa._Refs_key)
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused, dbsa.isIncomplete
union
select ds._dataset_key, ds.abbreviation, 'selected/not used', dbsa.isNeverused, dbsa.isIncomplete, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1001)
and ds._dataset_key = dbsa._dataset_key
and not exists (select 1 from MLD_Expts gi where gi._Refs_key = dbsa._Refs_key)
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused, dbsa.isIncomplete
union
select 1001 as _dataset_key, 'Mapping' as abbreviation, 'not selected/used', 0 as isNeverused, 0 as isIncomplete, count(r._Refs_key)
from BIB_Citation_Cache r
where not exists (select 1 from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
        where ds._dataset_key in (1001)
        and ds._dataset_key = dbsa._dataset_key
        and r._Refs_key = dbsa._Refs_key
        )
and exists (select 1 from MLD_Expts gi where gi._Refs_key = r._Refs_key)
group by _dataset_key, abbreviation, isNeverused, isIncomplete
)
order by selectedUsed
;

--
-- Nomen (1006)
--
(
select ds._dataset_key, ds.abbreviation, 'selected/used' as selectedUsed, dbsa.isNeverused, dbsa.isIncomplete, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1006)
and ds._dataset_key = dbsa._dataset_key
and exists (select 1 from MGI_Reference_Assoc gi where gi._Refs_key = dbsa._Refs_key and gi._MGIType_key = 2)
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused, dbsa.isIncomplete
union
select ds._dataset_key, ds.abbreviation, 'selected/not used', dbsa.isNeverused, dbsa.isIncomplete, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1006)
and ds._dataset_key = dbsa._dataset_key
and not exists (select 1 from MGI_Reference_Assoc gi where gi._Refs_key = dbsa._Refs_key and gi._MGIType_key = 2)
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused, dbsa.isIncomplete
union
select 1006 as _dataset_key, 'Nomen' as abbreviation, 'not selected/used', 0 as isNeverused, 0 as isIncomplete, count(r._Refs_key)
from BIB_Citation_Cache r
where not exists (select 1 from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
        where ds._dataset_key in (1006)
        and ds._dataset_key = dbsa._dataset_key
        and r._Refs_key = dbsa._Refs_key
        )
and exists (select 1 from MGI_Reference_Assoc gi where gi._Refs_key = r._Refs_key and gi._MGIType_key = 2)
group by _dataset_key, abbreviation, isNeverused, isIncomplete
)
order by selectedUsed
;

--
-- Markers (1010)
--
(
select ds._dataset_key, ds.abbreviation, 'selected/used' as selectedUsed, dbsa.isNeverused, dbsa.isIncomplete, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1010)
and ds._dataset_key = dbsa._dataset_key
and exists (select 1 from MGI_Reference_Assoc gi where gi._Refs_key = dbsa._Refs_key and gi._MGIType_key = 2)
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused, dbsa.isIncomplete
union
select ds._dataset_key, ds.abbreviation, 'selected/not used', dbsa.isNeverused, dbsa.isIncomplete, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1010)
and ds._dataset_key = dbsa._dataset_key
and not exists (select 1 from MGI_Reference_Assoc gi where gi._Refs_key = dbsa._Refs_key and gi._MGIType_key = 2)
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused, dbsa.isIncomplete
union
select 1010 as _dataset_key, 'Markers' as abbreviation, 'not selected/used', 0 as isNeverused, 0 as isIncomplete, count(r._Refs_key)
from BIB_Citation_Cache r
where not exists (select 1 from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
        where ds._dataset_key in (1010)
        and ds._dataset_key = dbsa._dataset_key
        and r._Refs_key = dbsa._Refs_key
        )
and exists (select 1 from MGI_Reference_Assoc gi where gi._Refs_key = r._Refs_key and gi._MGIType_key = 2)
group by _dataset_key, abbreviation, isNeverused, isIncomplete
)
order by selectedUsed
;

--
-- Allele (1002)
--
(
select distinct ds._dataset_key, ds.abbreviation, 'selected/used' as selectedUsed, dbsa.isNeverused, dbsa.isIncomplete, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1002)
and ds._dataset_key = dbsa._dataset_key
and exists (select 1 from MGI_Reference_Assoc gi where gi._MGIType_key = 11 and gi._Refs_key = dbsa._Refs_key)
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused, dbsa.isIncomplete
union
select distinct ds._dataset_key, ds.abbreviation, 'selected/not used', dbsa.isNeverused, dbsa.isIncomplete, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1002)
and ds._dataset_key = dbsa._dataset_key
and not exists (select 1 from MGI_Reference_Assoc gi where gi._MGIType_key = 11 and gi._Refs_key = dbsa._Refs_key)
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused, dbsa.isIncomplete
union
select distinct 1002 as _dataset_key, 'Allele/Pheno' as abbreviation, 'not selected/used', 0 as isNeverused, 0 as isIncomplete, count(distinct r._Refs_key)
from BIB_Citation_Cache r
where not exists (select 1 from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
        where ds._dataset_key in (1002)
        and ds._dataset_key = dbsa._dataset_key
        and r._Refs_key = dbsa._Refs_key
        )
and exists (select 1 from MGI_Reference_Assoc gi where gi._MGIType_key = 11 and gi._Refs_key = r._Refs_key)
group by _dataset_key, abbreviation, isNeverused, isIncomplete
union
select distinct 1002 as _dataset_key, 'Allele/Pheno' as abbreviation, 'not selected/not used', 0 as isNeverused, 0 as isIncomplete, count(distinct r._Refs_key)
from BIB_Citation_Cache r
where not exists (select 1 from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
        where ds._dataset_key in (1002)
        and ds._dataset_key = dbsa._dataset_key
        and r._Refs_key = dbsa._Refs_key
        )
and not exists (select 1 from MGI_Reference_Assoc gi where gi._MGIType_key = 11 and gi._Refs_key = r._Refs_key)
group by _dataset_key, abbreviation, isNeverused, isIncomplete
)
order by selectedUsed
;

--
-- Expression (1004)
--
(
select ds._dataset_key, ds.abbreviation, 'selected/used' as selectedUsed, dbsa.isNeverused, dbsa.isIncomplete, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1004)
and ds._dataset_key = dbsa._dataset_key
and ((exists (select 1 from GXD_Index gi where gi._Refs_key = dbsa._Refs_key)
or exists (select 1 from GXD_Assay ga where ga._Refs_key = dbsa._Refs_key)))
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused, dbsa.isIncomplete
union
select ds._dataset_key, ds.abbreviation, 'selected/not used', dbsa.isNeverused, dbsa.isIncomplete, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1004)
and ds._dataset_key = dbsa._dataset_key
and ((not exists (select 1 from GXD_Index gi where gi._Refs_key = dbsa._Refs_key)
and not exists (select 1 from GXD_Assay ga where ga._Refs_key = dbsa._Refs_key)))
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused, dbsa.isIncomplete
union
select 1004 as _dataset_key, 'Expression' as abbreviation, 'not selected/used', 0 as isNeverused, 0 as isIncomplete, count(r._Refs_key)
from BIB_Citation_Cache r
where not exists (select 1 from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
        where ds._dataset_key in (1004)
        and ds._dataset_key = dbsa._dataset_key
        and r._Refs_key = dbsa._Refs_key
        )
and ((exists (select 1 from GXD_Index gi where gi._Refs_key = r._Refs_key)
or exists (select 1 from GXD_Assay ga where ga._Refs_key = r._Refs_key)))
group by _dataset_key, abbreviation, isNeverused, isIncomplete
union
select 1004 as _dataset_key, 'Expression' as abbreviation, 'not selected/not used', 0 as isNeverused, 0 as isIncomplete, count(r._Refs_key)
from BIB_Citation_Cache r
where not exists (select 1 from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
        where ds._dataset_key in (1004)
        and ds._dataset_key = dbsa._dataset_key
        and r._Refs_key = dbsa._Refs_key
        )
and ((not exists (select 1 from GXD_Index gi where gi._Refs_key = r._Refs_key)
and not exists (select 1 from GXD_Assay ga where ga._Refs_key = r._Refs_key)))
group by _dataset_key, abbreviation, isNeverused, isIncomplete
)
order by selectedUsed
;

--
-- GO (1005)
--
(
select ds._dataset_key, ds.abbreviation, 'selected/used' as selectedUsed, dbsa.isNeverused, dbsa.isIncomplete, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1005)
and ds._dataset_key = dbsa._dataset_key
and exists (select 1 from VOC_Evidence e, VOC_Annot a
	where e._Refs_key = dbsa._Refs_key 
        and e._Annot_key = a._Annot_key
        and a._AnnotType_key = 1000)
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused, dbsa.isIncomplete
union
select ds._dataset_key, ds.abbreviation, 'selected/not used', dbsa.isNeverused, dbsa.isIncomplete, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1005)
and ds._dataset_key = dbsa._dataset_key
and not exists (select 1 from VOC_Evidence e, VOC_Annot a
	where e._Refs_key = dbsa._Refs_key 
        and e._Annot_key = a._Annot_key
        and a._AnnotType_key = 1000)
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused, dbsa.isIncomplete
union
select 1005 as _dataset_key, 'GO' as abbreviation, 'not selected/used', 0 as isNeverused, 0 as isIncomplete, count(r._Refs_key)
from BIB_Citation_Cache r
where not exists (select 1 from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
        where ds._dataset_key in (1005)
        and ds._dataset_key = dbsa._dataset_key
        and r._Refs_key = dbsa._Refs_key
        )
and exists (select 1 from VOC_Evidence e, VOC_Annot a
	where e._Refs_key = r._Refs_key 
        and e._Annot_key = a._Annot_key
        and a._AnnotType_key = 1000)
group by _dataset_key, abbreviation, isNeverused, isIncomplete
union
select 1005 as _dataset_key, 'GO' as abbreviation, 'not selected/not used', 0 as isNeverused, 0 as isIncomplete, count(r._Refs_key)
from BIB_Citation_Cache r
where not exists (select 1 from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
        where ds._dataset_key in (1005)
        and ds._dataset_key = dbsa._dataset_key
        and r._Refs_key = dbsa._Refs_key
        )
and not exists (select 1 from VOC_Evidence e, VOC_Annot a
	where e._Refs_key = r._Refs_key 
        and e._Annot_key = a._Annot_key
        and a._AnnotType_key = 1000)
group by _dataset_key, abbreviation, isNeverused, isIncomplete
)
order by selectedUsed
;

--
-- QTL (1011)
--
(
select ds._dataset_key, ds.abbreviation, 'selected/used' as selectedUsed, dbsa.isNeverused, dbsa.isIncomplete, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1011)
and ds._dataset_key = dbsa._dataset_key
and exists (select 1 from MLD_Expts gi where gi._Refs_key = dbsa._Refs_key
	and gi.exptType in ('TEXT', 'TEXT-QTL', 'TEXT-QTL-Candidate Genes', 'TEXT-Congenic', 'TEXT-Meta Analysis'))
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused, dbsa.isIncomplete
union
select ds._dataset_key, ds.abbreviation, 'selected/not used', dbsa.isNeverused, dbsa.isIncomplete, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1011)
and ds._dataset_key = dbsa._dataset_key
and not exists (select 1 from MLD_Expts gi where gi._Refs_key = dbsa._Refs_key
	and gi.exptType in ('TEXT', 'TEXT-QTL', 'TEXT-QTL-Candidate Genes', 'TEXT-Congenic', 'TEXT-Meta Analysis'))
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused, dbsa.isIncomplete
union
select 1011 as _dataset_key, 'QTL' as abbreviation, 'not selected/used', 0 as isNeverused, 0 as isIncomplete, count(r._Refs_key)
from BIB_Citation_Cache r
where not exists (select 1 from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
        where ds._dataset_key in (1011)
        and ds._dataset_key = dbsa._dataset_key
        and r._Refs_key = dbsa._Refs_key
        )
and exists (select 1 from MLD_Expts gi where gi._Refs_key = r._Refs_key
	and gi.exptType in ('TEXT', 'TEXT-QTL', 'TEXT-QTL-Candidate Genes', 'TEXT-Congenic', 'TEXT-Meta Analysis'))
group by _dataset_key, abbreviation, isNeverused, isIncomplete
union
select 1011 as _dataset_key, 'QTL' as abbreviation, 'not selected/not used', 0 as isNeverused, 0 as isIncomplete, count(r._Refs_key)
from BIB_Citation_Cache r
where not exists (select 1 from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
        where ds._dataset_key in (1011)
        and ds._dataset_key = dbsa._dataset_key
        and r._Refs_key = dbsa._Refs_key
        )
and not exists (select 1 from MLD_Expts gi where gi._Refs_key = r._Refs_key
	and gi.exptType in ('TEXT', 'TEXT-QTL', 'TEXT-QTL-Candidate Genes', 'TEXT-Congenic', 'TEXT-Meta Analysis'))
group by _dataset_key, abbreviation, isNeverused, isIncomplete
)
order by selectedUsed
;

--
-- PRO (1012)
--
(
select ds._dataset_key, ds.abbreviation, 'selected/used' as selectedUsed, dbsa.isNeverused, dbsa.isIncomplete, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1012)
and ds._dataset_key = dbsa._dataset_key
and exists (select 1 from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p
	where e._Refs_key = dbsa._Refs_key
        and a._AnnotType_key = 1000
        and a._Annot_key = e._Annot_key
        and e._AnnotEvidence_key = p._AnnotEvidence_key
	and p._PropertyTerm_key = 6481775
	)
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused, dbsa.isIncomplete
union
select ds._dataset_key, ds.abbreviation, 'selected/not used', dbsa.isNeverused, dbsa.isIncomplete, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1012)
and ds._dataset_key = dbsa._dataset_key
and not exists (select 1 from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p
	where e._Refs_key = dbsa._Refs_key
        and a._AnnotType_key = 1000
        and a._Annot_key = e._Annot_key
        and e._AnnotEvidence_key = p._AnnotEvidence_key
	and p._PropertyTerm_key = 6481775
	)
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused, dbsa.isIncomplete
union
select 1012 as _dataset_key, 'PRO' as abbreviation, 'not selected/used', 0 as isNeverused, 0 as isIncomplete, count(r._Refs_key)
from BIB_Citation_Cache r
where not exists (select 1 from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
        where ds._dataset_key in (1012)
        and ds._dataset_key = dbsa._dataset_key
        and r._Refs_key = dbsa._Refs_key
        )
and exists (select 1 from VOC_Annot a, VOC_Evidence e, VOC_Evidence_Property p
	where e._Refs_key = r._Refs_key
        and a._AnnotType_key = 1000
        and a._Annot_key = e._Annot_key
        and e._AnnotEvidence_key = p._AnnotEvidence_key
	and p._PropertyTerm_key = 6481775
	)
)
order by selectedUsed
;

--
-- Tumor (1007)
-- SCC (1008) Strain Characteristic Catalog
-- GXD HT Exp (1013)
--
(
select ds._dataset_key, ds.abbreviation, 'selected' as selectedUsed, dbsa.isNeverused, count(distinct dbsa._Refs_key)
from BIB_DataSet ds, BIB_DataSet_Assoc dbsa
where ds._dataset_key in (1007, 1008, 1013)
and ds._dataset_key = dbsa._dataset_key
group by ds._dataset_key, ds.abbreviation, dbsa.isNeverused
)
order by selectedUsed
;

EOSQL

date |tee -a $LOG

