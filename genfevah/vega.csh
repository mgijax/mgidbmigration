#!/bin/csh -f

#
# remove VEGA data/code
#
# see sw:VEGA_retired
#
# pgmgddbschema
# genemodelload
# goload
# vocload
# seqcacheload
# qcreports_db
# reports_db
#
# ei
# pwi
#

if ( ${?MGICONFIG} == 0 ) then
        setenv MGICONFIG /usr/local/mgi/live/mgiconfig
endif

source ${MGICONFIG}/master.config.csh

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG

#
# manually remove VEGA from
# http://prodwww.informatics.jax.org/all/wts_projects/10300/10308/RawBioTypeEquivalence/biotypemap.txt
#

#
# remove vega logs
#
rm -rf ${DATALOADSOUTPUT}/mgi/genemodelload/*/vega*
rm -rf ${DATALOADSOUTPUT}/vega
rm -rf ${DATALOADSOUTPUT}/assembly/vega*
rm -rf $DATALOAD}/genemodelload/genemodel_vega.config
rm -rf ${DATALOADSOUTPUT}/mgi/vocload/archiveBiotype/vega
rm -rf ${DATALOADSOUTPUT}/mgi/vocload/runTimeBiotype/vega

date | tee -a $LOG
echo "before counts..." | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select distinct s._Sequenceprovider_key, t.term , t._Vocab_key
from SEQ_Marker_Cache s, VOC_Term t
where s._SequenceProvider_key = t._term_key
and t.term like 'VEGA%'
;

select count(s.*), t.term 
from SEQ_Sequence s, VOC_Term t
where s._SequenceProvider_key in (1865333,5112894,5112895, 615429,5112897,5112896, 706915)
and s._SequenceProvider_key = t._Term_key
group by s._SequenceProvider_key, t.term
order by t.term
;

select count(s.*), t.term, tt.term
from SEQ_Marker_Cache s, VOC_Term t, VOC_Term tt
where s._SequenceProvider_key in (1865333,5112894,5112895, 615429,5112897,5112896, 706915)
and s._SequenceProvider_key = t._Term_key
and s._qualifier_key = tt._Term_key
group by s._SequenceProvider_key, t.term, tt.term
order by t.term
;

select count(s.*), s.provider
from SEQ_Coord_Cache s
group by s.provider
order by s.provider
;

-- VEGA coordinates
select count(*), cn.name
from MAP_Coordinate c, MAP_Coord_Collection cn
where c._Collection_key in (91, 93, 97) 
and c._Collection_key = cn._Collection_key
group by cn.name
;

-- biotype stuff
select count(m.*), t.name
from MRK_BioTypeMapping m, VOC_Vocab t
where m._biotypevocab_key = t._Vocab_key
group by t.name
;

-- VEGA accession associations
select count(*) from ACC_Accession where _Logicaldb_key in (85, 131, 132, 141, 176);
select * from ACC_Logicaldb where _Logicaldb_key in (85, 131, 132, 141, 176);
select * from MGI_User where name ilike ('%vega%');

-- markers that only have VEGA gene models
WITH dataset as (
select s._Marker_key
from SEQ_Marker_Cache s, ACC_Accession sa
where s._LogicalDB_key = 85
and s._Marker_key = sa._Object_key
and sa._MGIType_key = 2
and sa._Logicaldb_key in (9,13,27,41,59,60,85,131,132,133,134)
group by _Marker_key having count(*) = 1
)
select m.symbol, sa.accID
from dataset s, MRK_Marker m, ACC_Accession sa
where s._Marker_key = m._Marker_key
and s._Marker_key = sa._Object_key
and sa._MGIType_key = 2
and sa._Logicaldb_key in (9,13,27,41,59,60,85,131,132,133,134)
order by m.symbol
;

EOSQL

date | tee -a $LOG
echo "delete VEGA data..." | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

-- delete data that relies on _SequenceProvider_key
delete from SEQ_Marker_Cache where _SequenceProvider_key in (1865333,5112894,5112895);

-- delete from Collection; cascaing deletes will delete MAP_Coord_Feature, MAP_Coordinate
delete from MAP_Coord_Collection where _Collection_key = 91;

-- delete sequences
delete from SEQ_Sequence where _SequenceProvider_key in (1865333,5112894,5112895);

-- delete BioType VEGA vocab
delete from MRK_BioTypeMapping where _BiotypeVocab_key = 105;
delete from VOC_Term where _Vocab_key = 105;
delete from VOC_Vocab where _Vocab_key = 105;

-- delete VEGA provider terms
delete from VOC_Term where _Vocab_key = 25 and _Term_key in (1865333,5112894,5112895);

-- delete VEGA accession associations
delete from ACC_Accession where _Logicaldb_key in (85, 131, 132, 141, 176);
delete from ACC_Logicaldb where _Logicaldb_key in (85, 131, 132, 141, 176);
delete from MGI_User where name ilike ('%vega%');

EOSQL

date |tee -a $LOG
echo ${GOLOAD}/go.sh | tee -a $LOG
#${MIRROR_WGET}/download_package pir.georgetown.edu.proisoform
#${MIRROR_WGET}/download_package build.berkeleybop.org.goload
#${MIRROR_WGET}/download_package build.berkeleybop.org.gpad.goload
#${MIRROR_WGET}/download_package ftp.ebi.ac.uk.goload
#${MIRROR_WGET}/download_package ftp.geneontology.org.goload
${GOLOAD}/go.sh | tee -a $LOG

date |tee -a $LOG
echo ${GENEMODELLOAD}/bin/biotypemapping.sh | tee -a $LOG
${GENEMODELLOAD}/bin/biotypemapping.sh | tee -a $LOG

date |tee -a $LOG
echo ${SEQCACHELOAD}/seqmarker.csh | tee -a $LOG
${SEQCACHELOAD}/seqmarker.csh | tee -a $LOG

date |tee -a $LOG
echo ${SEQCACHELOAD}/seqcoord.csh | tee -a $LOG
${SEQCACHELOAD}/seqcoord.csh | tee -a $LOG

# after story passes, the reports can be commented out as they will all run at end of migration
date |tee -a $LOG
echo ${QCRPTS} | tee -a $LOG
cd ${QCRPTS}
source ./Configuration
# fix documentation:  qcr.shtml, mgd/MRK_NoENSEMBL.py
# remove : mgd/MGI_VEGA_Associations.py, mgd/MRK_NoVEGA.py
cd mgd
foreach i (GO_GPI_verify.py MGI_GenesAndPseudogenesWithSequence.py MRK_NoENSEMBL.py)
$i
end
foreach i (MRK_MultMarkerGeneModels.sql MRK_GmNoGeneModel.sql)
${QCRPTS}/reports.csh $i ${QCOUTPUTDIR}/$i.rpt ${PG_DBSERVER} ${PG_DBNAME}
end
cd ../weekly
foreach i (MRK_C4AM_GeneModel.py)
$i
end

date |tee -a $LOG
echo ${PUBRPTS} | tee -a $LOG
cd ${PUBRPTS}
source ./Configuration
# remove : weekly/MRK_VEGA.py
cd daily
foreach i (GO_gene_association GO_gpi.py)
$i
end
cd ../weekly
foreach i (GO_gp2protein.py HGNC_homologene.py MGI_BioTypeConflict.py MGI_Gene_Model_Coord.py MRK_ENSEMBL.py MRK_Sequence.py)
$i
end

cd ${DBUTILS}/mgidbmigration/genfevah

date | tee -a $LOG
echo "after counts..." | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select distinct s._Sequenceprovider_key, t.term , t._Vocab_key
from SEQ_Marker_Cache s, VOC_Term t
where s._SequenceProvider_key = t._term_key
and t.term like 'VEGA%'
;

select count(s.*), t.term 
from SEQ_Sequence s, VOC_Term t
where s._SequenceProvider_key in (1865333,5112894,5112895, 615429,5112897,5112896, 706915)
and s._SequenceProvider_key = t._Term_key
group by s._SequenceProvider_key, t.term
order by t.term
;

scrumdog-> ;
select count(s.*), t.term, tt.term
from SEQ_Marker_Cache s, VOC_Term t, VOC_Term tt
where s._SequenceProvider_key in (1865333,5112894,5112895, 615429,5112897,5112896, 706915)
and s._SequenceProvider_key = t._Term_key
and s._qualifier_key = tt._Term_key
group by s._SequenceProvider_key, t.term, tt.term
order by t.term
;

select count(s.*), s.provider
from SEQ_Coord_Cache s
group by s.provider
order by s.provider
;

-- VEGA coordinates
select count(*), cn.name
from MAP_Coordinate c, MAP_Coord_Collection cn
where c._Collection_key in (91, 93, 97) 
and c._Collection_key = cn._Collection_key
group by cn.name
;

-- biotype stuff
select count(m.*), t.name
from MRK_BioTypeMapping m, VOC_Vocab t
where m._biotypevocab_key = t._Vocab_key
group by t.name
;

-- VEGA accession associations
select count(*) from ACC_Accession where _Logicaldb_key in (85, 131, 132, 141, 176);
select * from ACC_Logicaldb where _Logicaldb_key in (85, 131, 132, 141, 176);
select * from MGI_User where name ilike ('%vega%');

EOSQL

