#!/bin/csh -f

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG
 
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd ACC_LogicalDB ${MGI_LIVE}/dbutils/mgidbmigration/fl2b/ACC_LogicalDB.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd ACC_ActualDB ${MGI_LIVE}/dbutils/mgidbmigration/fl2b/ACC_ActualDB.bcp "|"

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- list of ACC_LogicalDB/ACC_ActualDB used in backend;do not remove
-- mgicacheload/go_isoforms_display_load.py, go_annot_extensions_display_load.py, 
-- mgicacheload/inferredfrom.py (1,
-- qcreports_db
-- egload
-- mouseminie_etl

-- check mgicacheload
--select adb.name, adb.url
--from acc_logicaldb ldb
--join acc_actualdb adb on
--adb._logicaldb_key = ldb._logicaldb_key
--where (ldb.name, adb.name) in (('Sequence DB','EMBL'),('RefSeq','RefSeq'),('Protein Ontology','Protein Ontology'),('SWISS-PROT','UniProt'))
--;
--select adb._logicaldb_key, adb.name, adb.url
--from acc_logicaldb ldb
--join acc_actualdb adb on
--adb._logicaldb_key = ldb._logicaldb_key
--where (ldb.name, adb.name) in (('Sequence DB','EMBL'),('RefSeq','RefSeq'),('Protein Ontology','Protein Ontology'),('SWISS-PROT','UniProt'))
--;

-- mgicacheload/inferredfrom.py (1,
--select count(l._logicaldb_key), l._logicaldb_key, l.name, a.url
--from acc_accession aa, acc_logicaldb l, acc_actualdb a
--where l._logicaldb_key in (8,9,13,27,28,47,64,78,111,114,115,119,127,135,147,160,204,205,211,214)
--and l._logicaldb_key = aa._logicaldb_key
--and l._logicaldb_key = a._logicaldb_key
--group by l._logicaldb_key, l.name, a.url
--order by l._logicaldb_key
--;

-- check asscload
--select * from acc_logicaldb where name in (
--'ABA',
--'Consensus CDS Project',
--'Download data from the QTL Archive',
--'EC',
--'Ensembl Gene Model',
--'Ensembl Protein',
--'Ensembl Regulatory Feature',
--'Ensembl Transcript',
--'miRBase',
--'NCBI Gene Model',
--'neXtProt',
--'PDB',
--'Protein Ontology',
--'RefSeq',
--'Sequence DB',
--'SWISS-PROT',
--'TrEMBL',
--'VISTA Enhancer Element'
--)
--order by name;

-- qcreports_db
--select url from ACC_ActualDB where _LogicalDB_key = 29
--egload
--select * from acc_logialdb where _logicaldb_key in (9,27,55)

-- used by femover/marker_link_gatherer.py
--select l._logicaldb_key, l.name, a._actualdb_key, a.url
--from acc_logicaldb l, acc_actualdb a
--where l._logicaldb_key = a._logicaldb_key
--and l._logicaldb_key in (1,15,47,55,60,64,172)
--order by l._logicaldb_key
--;

-- ignore the Strain logicaldbs
-- ignore the SNP logicaldbs (73,74,75,76,77)
-- ignore the BioType logicaldbs/used in VOC_Vocab (174,175,210)
-- ignore the GO logicaldbs (9,13,27,60,125,173)
-- ignore those in Richard's spreadsheet NO (66,129,87,129,49,50,126,109)

-- logicaldb that are used in acc_accession and cannot be removed
(
select l._logicaldb_key, l.name, l.description, a._actualdb_key, a.name as actualname, a.url
into temp keep
from acc_logicaldb l left outer join acc_actualdb a on ( l._logicaldb_key = a._logicaldb_key)
where exists (select 1 from acc_accession aa where l._logicaldb_key = aa._logicaldb_key)
union
select l._logicaldb_key, l.name, l.description, a._actualdb_key, a.name as actualname, a.url
from acc_logicaldb l left outer join acc_actualdb a on ( l._logicaldb_key = a._logicaldb_key)
where l._logicaldb_key in (22,38,37,39,40,54,56,57,58,70,71,83,87,90,91,93,94,154,161,177,184,188,200,206,207,208,213,215,216,217,219,220,224,73,74,75,76,77,174,175,210,9,13,27,60,125,173,9,27,55,29,66,129,87,129,49,50,126,109,195)
)
order by _logicaldb_key
;

-- logicaldb that are not used in acc_accession and can be removed
select l._logicaldb_key, l.name, l.description, a._actualdb_key, a.name as actualname, a.url
into temp table todelete1
from acc_logicaldb l left outer join acc_actualdb a on ( l._logicaldb_key = a._logicaldb_key)
where not exists (select 1 from acc_accession aa where l._logicaldb_key = aa._logicaldb_key)
and not exists (select 1 from keep k where l._logicaldb_key = k._logicaldb_key)
order by l._logicaldb_key
;
select * from todelete1;
delete from acc_logicaldb a using todelete1 d where d._logicaldb_key = a._logicaldb_key ;

-- delete acc_logicaldb and acc_actualdb as noted in fl2-110
select l._logicaldb_key, l.name, l.description
into temp table todelete2
from acc_logicaldb l
where l._logicaldb_key in (46,61,62,63,72,110,124)
order by l.name
;
select * from todelete2;
delete from acc_accession a using todelete2 d where d._logicaldb_key = a._logicaldb_key ;
delete from acc_logicaldb a using todelete2 d where d._logicaldb_key = a._logicaldb_key ;

-- delete acc_actualdb as noted in fl2-110
select l._logicaldb_key, l.name, l.description, a._actualdb_key, a.name as actualname, a.url
into temp table todelete3
from acc_logicaldb l, acc_actualdb a
where l._logicaldb_key = a._logicaldb_key
and a._actualdb_key in (51,52,66,84,107,112,114,122)
order by l.name
;
select * from todelete3;
delete from acc_actualdb a using todelete3 d where d._logicaldb_key = a._logicaldb_key;

-- per Cindy, ok to remove:  92 | MTG | Mouse TransGenics, Consortium for Functional Glycomics, TSRI  
delete from acc_logicaldb where _logicaldb_key in (92);

-- logicaldb that are used in acc_accession and cannot be removed
--select l._logicaldb_key, l.name, a._actualdb_key, a.url
--from acc_logicaldb l left outer join acc_actualdb a on ( l._logicaldb_key = a._logicaldb_key)
--where exists (select 1 from acc_accession aa where l._logicaldb_key = aa._logicaldb_key)
--order by l._logicaldb_key
--;

-- what is left; should be 0
-- left in acc_logicaldb
select l._logicaldb_key, l.name, a._actualdb_key, a.url
from acc_logicaldb l left outer join acc_actualdb a on ( l._logicaldb_key = a._logicaldb_key)
where not exists (select 1 from acc_accession aa where l._logicaldb_key = aa._logicaldb_key)
and not exists (select 1 from keep k where l._logicaldb_key = k._logicaldb_key)
order by l._logicaldb_key
;

-- left in acc_actualdb; ldb not used in acc_accession
select l._logicaldb_key, l.name, a._actualdb_key, a.url
from acc_logicaldb l, acc_actualdb a
where l._logicaldb_key = a._logicaldb_key
and not exists (select 1 from keep k where l._logicaldb_key = k._logicaldb_key)
order by l._logicaldb_key
;

-- ignore used in qcreports_db : _actualdb_key in (29)
-- ignore used in egload : _actualdb_key in (12,35,57), _logicaldb_key in (9,27,55)
-- ignore used in mgicacheload: _actualdb_key in (19,62,119,139), _logicaldb_key in (1,13,60,135,173)
-- ignore used in mgicacheload: _actualdb_key in (14,19,35,119), _logicaldb_key in (1,9,13,27,135)
-- ignore used in mgicacheload/inferredfrom.py
-- ignore used in pwi/littriage: _logicaldb_key in (29,65)
-- left in acc_actualdb; ldb used in acc_accession
select count(l._logicaldb_key) as counter, aa._mgitype_key, l._logicaldb_key, l.name, a._actualdb_key, a.url
from acc_accession aa, acc_logicaldb l, acc_actualdb a
where l._logicaldb_key = a._logicaldb_key
and l._logicaldb_key = aa._logicaldb_key
and l._logicaldb_key not in (1,9,13,27,29,32,55,60,65,115,119,127,125,173,160,193,204,211,214)
group by aa._mgitype_key, l._logicaldb_key, l.name, a._actualdb_key, a.url
order by _mgitype_key, counter
;

-- must exist : count = 81
select _logicaldb_key, name, description from acc_logicaldb 
where _logicaldb_key in (
9, 12, 13, 15, 16, 17, 19, 22, 26, 27, 29,
31, 32, 34, 37, 38, 39, 40, 41, 44, 47, 48, 49,
50, 51, 52, 55, 59, 60, 64, 65, 66, 73, 74, 75, 76, 77, 82, 87, 95, 96, 97, 98, 99,
100, 101, 102, 103, 104, 108, 109,
121, 125, 126, 128, 129,
133, 137, 142, 146,
150, 152, 165, 169,
170, 172, 173, 174, 175, 181, 183, 185, 189,
190, 191, 209, 210, 212, 222, 223, 225
)
order by _logicaldb_key
;

EOSQL

${MGICACHELOAD}/go_annot_extensions_display_load.csh | tee -a $LOG
${MGICACHELOAD}/go_isoforms_display_load.csh | tee -a $LOG
${MGICACHELOAD}/inferredfrom.csh | tee -a $LOG

