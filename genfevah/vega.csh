#!/bin/csh -f

#
# remove VEGA data/code
#
# see sw:VEGA_retired
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
echo "before counts..." | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select distinct s._Sequenceprovider_key, t.term , t._Vocab_key
from SEQ_Marker_Cache s, VOC_Term t
where s._SequenceProvider_key = t._term_key
and t.term like 'VEGA%'
;

select count(*) from SEQ_Sequence where _SequenceProvider_key in (1865333,5112894,5112895);
select count(*) from SEQ_Sequence where _SequenceProvider_key in (615429,5112897,5112896);
select count(*) from SEQ_Sequence where _SequenceProvider_key in (706915);
select count(*) from SEQ_Sequence;

select count(*) from SEQ_Marker_Cache where _SequenceProvider_key in (1865333,5112894,5112895);
select count(*) from SEQ_Marker_Cache where _SequenceProvider_key in (615429,5112897,5112896);
select count(*) from SEQ_Marker_Cache where _SequenceProvider_key in (706915);
select count(*) from SEQ_Marker_Cache;

select count(s.*) from SEQ_Coord_Cache s, MAP_Coordinate c where c._Collection_key = 91 and c._Map_key = s._Map_key;
select count(s.*) from SEQ_Coord_Cache s, MAP_Coordinate c where c._Collection_key = 93 and c._Map_key = s._Map_key;
select count(s.*) from SEQ_Coord_Cache s, MAP_Coordinate c where c._Collection_key = 97 and c._Map_key = s._Map_key;
select count(s.*) from SEQ_Coord_Cache s;

-- VEGA coordinates
select count(*) from MAP_Coordinate where _Collection_key = 91;
select count(*) from MAP_Coordinate where _Collection_key = 93;
select count(*) from MAP_Coordinate where _Collection_key = 97;
select count(f.*) from MAP_Coordinate c , MAP_Coord_Feature f where c._Collection_key = 91 and c._Map_key = f._Map_key;
select count(f.*) from MAP_Coordinate c , MAP_Coord_Feature f where c._Collection_key = 93 and c._Map_key = f._Map_key;
select count(f.*) from MAP_Coordinate c , MAP_Coord_Feature f where c._Collection_key = 97 and c._Map_key = f._Map_key;

-- biotype stuff
select count(*) from VOC_Vocab where name like 'BioType%';
select count(*) from MRK_BioTypeMapping where _BiotypeVocab_key = 105;
select count(*) from MRK_BioTypeMapping where _BiotypeVocab_key = 103;
select count(*) from MRK_BioTypeMapping where _BiotypeVocab_key = 104;
select count(*) from MRK_BioTypeMapping where _BiotypeVocab_key = 136;
select count(*) from MRK_BioTypeMapping where _BiotypeVocab_key = 76;
select count(*) from MRK_BioTypeMapping;

-- VEGA accession associations
select count(*) from ACC_Accession where _Logicaldb_key in (85, 131, 132, 141, 176);
select count(*) from ACC_Logicaldb where _Logicaldb_key in (85, 131, 132, 141, 176);

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

EOSQL

date |tee -a $LOG
date |tee -a $LOG
echo ${GOLOAD}/go.sh | tee -a $LOG
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

date | tee -a $LOG
echo "after counts..." | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select count(*) from SEQ_Sequence where _SequenceProvider_key in (1865333,5112894,5112895);
select count(*) from SEQ_Sequence where _SequenceProvider_key in (615429,5112897,5112896);
select count(*) from SEQ_Sequence where _SequenceProvider_key in (706915);
select count(*) from SEQ_Sequence;

select count(*) from SEQ_Marker_Cache where _SequenceProvider_key in (1865333,5112894,5112895);
select count(*) from SEQ_Marker_Cache where _SequenceProvider_key in (615429,5112897,5112896);
select count(*) from SEQ_Marker_Cache where _SequenceProvider_key in (706915);
select count(*) from SEQ_Marker_Cache;

select count(s.*) from SEQ_Coord_Cache s, MAP_Coordinate c where c._Collection_key = 91 and c._Map_key = s._Map_key;
select count(s.*) from SEQ_Coord_Cache s, MAP_Coordinate c where c._Collection_key = 93 and c._Map_key = s._Map_key;
select count(s.*) from SEQ_Coord_Cache s, MAP_Coordinate c where c._Collection_key = 97 and c._Map_key = s._Map_key;
select count(s.*) from SEQ_Coord_Cache s;

-- VEGA coordinates
select count(*) from MAP_Coordinate where _Collection_key = 91; 
select count(*) from MAP_Coordinate where _Collection_key = 93; 
select count(*) from MAP_Coordinate where _Collection_key = 97; 
select count(f.*) from MAP_Coordinate c , MAP_Coord_Feature f where c._Collection_key = 91 and c._Map_key = f._Map_key;
select count(f.*) from MAP_Coordinate c , MAP_Coord_Feature f where c._Collection_key = 93 and c._Map_key = f._Map_key;
select count(f.*) from MAP_Coordinate c , MAP_Coord_Feature f where c._Collection_key = 97 and c._Map_key = f._Map_key;

-- biotype stuff
select count(*) from VOC_Vocab where name like 'BioType%';
select count(*) from MRK_BioTypeMapping where _BiotypeVocab_key = 105;
select count(*) from MRK_BioTypeMapping where _BiotypeVocab_key = 103;
select count(*) from MRK_BioTypeMapping where _BiotypeVocab_key = 104;
select count(*) from MRK_BioTypeMapping where _BiotypeVocab_key = 136;
select count(*) from MRK_BioTypeMapping where _BiotypeVocab_key = 76; 
select count(*) from MRK_BioTypeMapping;

-- VEGA accession associations
select count(*) from ACC_Accession where _Logicaldb_key in (85, 131, 132, 141, 176);
select count(*) from ACC_Logicaldb where _Logicaldb_key in (85, 131, 132, 141, 176);

EOSQL

