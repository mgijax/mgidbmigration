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

EOSQL

date | tee -a $LOG
echo "delete VEGA data..." | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select m.*, a._Allele_key, a.symbol 
from MRK_Marker m, ALL_Allele a
where m.symbol in (
'Gm37034', 'Gm37038', 'Gm37149', 'Gm37188', 'Gm37271', 'Gm37379', 'Gm37408', 'Gm37414', 'Gm37471', 
'Gm37546', 'Gm37605', 'Gm37615', 'Gm37823', 'Gm37874', 'Gm37888', 'Gm37938', 'Gm38052', 'Gm38129',
'Gm38175', 'Gm38179', 'Gm38193', 'Gm38206', 'Gm38219', 'Gm38354', 'Gm45138', 'Gm45535',
'Gm42691', 'Gm43543', 'Gm43687', 'Gm11291', 'Gm11345', 'Gm11374', 'Gm11375', 'Gm13434', 'Gm13734',
'Gm13741', 'Gm13747', 'Gm13753', 'Gm13759', 'Gm13760', 'Gm13763', 'Gm15662', 'Gm20497', 'Gm20677',
'Gm20678', 'Gm20699', 'Gm27157', 'Gm28479', 'Gm28498', 'Gm28621', 'Gm28904', 'Gm28933', 'Gm29006',
'Gm29095', 'Gm29172', 'Gm29176', 'Gm29236', 'Gm29375', 'Gm3719', 'Gm37276', 'Gm43296', 'Gm44568',
'Gm44572', 'Gm44774', 'Gm45000', 'Gm45057', 'Gm45302', 'Gm45810'
)
and m._Marker_key = a._Marker_key
;

-- delete VEGA markers that only have VEGA gene models

delete from MGI_Relationship a
using MRK_Marker m
where m.symbol in (
'Gm37034', 'Gm37038', 'Gm37149', 'Gm37188', 'Gm37271', 'Gm37379', 'Gm37408', 'Gm37414', 'Gm37471', 
'Gm37546', 'Gm37605', 'Gm37615', 'Gm37823', 'Gm37874', 'Gm37888', 'Gm37938', 'Gm38052', 'Gm38129',
'Gm38175', 'Gm38179', 'Gm38193', 'Gm38206', 'Gm38219', 'Gm38354', 'Gm45138', 'Gm45535',
'Gm42691', 'Gm43543', 'Gm43687', 'Gm11291', 'Gm11345', 'Gm11374', 'Gm11375', 'Gm13434', 'Gm13734',
'Gm13741', 'Gm13747', 'Gm13753', 'Gm13759', 'Gm13760', 'Gm13763', 'Gm15662', 'Gm20497', 'Gm20677',
'Gm20678', 'Gm20699', 'Gm27157', 'Gm28479', 'Gm28498', 'Gm28621', 'Gm28904', 'Gm28933', 'Gm29006',
'Gm29095', 'Gm29172', 'Gm29176', 'Gm29236', 'Gm29375', 'Gm3719', 'Gm37276', 'Gm43296', 'Gm44568',
'Gm44572', 'Gm44774', 'Gm45000', 'Gm45057', 'Gm45302', 'Gm45810'
)
and m._Marker_key = a._Object_key_2
and a._Category_key = 1003
;

delete from ALL_Allele a
using MRK_Marker m
where m.symbol in (
'Gm37034', 'Gm37038', 'Gm37149', 'Gm37188', 'Gm37271', 'Gm37379', 'Gm37408', 'Gm37414', 'Gm37471', 
'Gm37546', 'Gm37605', 'Gm37615', 'Gm37823', 'Gm37874', 'Gm37888', 'Gm37938', 'Gm38052', 'Gm38129',
'Gm38175', 'Gm38179', 'Gm38193', 'Gm38206', 'Gm38219', 'Gm38354', 'Gm45138', 'Gm45535',
'Gm42691', 'Gm43543', 'Gm43687', 'Gm11291', 'Gm11345', 'Gm11374', 'Gm11375', 'Gm13434', 'Gm13734',
'Gm13741', 'Gm13747', 'Gm13753', 'Gm13759', 'Gm13760', 'Gm13763', 'Gm15662', 'Gm20497', 'Gm20677',
'Gm20678', 'Gm20699', 'Gm27157', 'Gm28479', 'Gm28498', 'Gm28621', 'Gm28904', 'Gm28933', 'Gm29006',
'Gm29095', 'Gm29172', 'Gm29176', 'Gm29236', 'Gm29375', 'Gm3719', 'Gm37276', 'Gm43296', 'Gm44568',
'Gm44572', 'Gm44774', 'Gm45000', 'Gm45057', 'Gm45302', 'Gm45810'
)
and m._Marker_key = a._Marker_key
;

delete from MLD_Expt_Marker a
using MRK_Marker m
where m.symbol in (
'Gm37034', 'Gm37038', 'Gm37149', 'Gm37188', 'Gm37271', 'Gm37379', 'Gm37408', 'Gm37414', 'Gm37471', 
'Gm37546', 'Gm37605', 'Gm37615', 'Gm37823', 'Gm37874', 'Gm37888', 'Gm37938', 'Gm38052', 'Gm38129',
'Gm38175', 'Gm38179', 'Gm38193', 'Gm38206', 'Gm38219', 'Gm38354', 'Gm45138', 'Gm45535',
'Gm42691', 'Gm43543', 'Gm43687', 'Gm11291', 'Gm11345', 'Gm11374', 'Gm11375', 'Gm13434', 'Gm13734',
'Gm13741', 'Gm13747', 'Gm13753', 'Gm13759', 'Gm13760', 'Gm13763', 'Gm15662', 'Gm20497', 'Gm20677',
'Gm20678', 'Gm20699', 'Gm27157', 'Gm28479', 'Gm28498', 'Gm28621', 'Gm28904', 'Gm28933', 'Gm29006',
'Gm29095', 'Gm29172', 'Gm29176', 'Gm29236', 'Gm29375', 'Gm3719', 'Gm37276', 'Gm43296', 'Gm44568',
'Gm44572', 'Gm44774', 'Gm45000', 'Gm45057', 'Gm45302', 'Gm45810'
)
and m._Marker_key = a._Marker_key
;

delete from VOC_Annot a
using MRK_Marker m
where m.symbol in (
'Gm37034', 'Gm37038', 'Gm37149', 'Gm37188', 'Gm37271', 'Gm37379', 'Gm37408', 'Gm37414', 'Gm37471', 
'Gm37546', 'Gm37605', 'Gm37615', 'Gm37823', 'Gm37874', 'Gm37888', 'Gm37938', 'Gm38052', 'Gm38129',
'Gm38175', 'Gm38179', 'Gm38193', 'Gm38206', 'Gm38219', 'Gm38354', 'Gm45138', 'Gm45535',
'Gm42691', 'Gm43543', 'Gm43687', 'Gm11291', 'Gm11345', 'Gm11374', 'Gm11375', 'Gm13434', 'Gm13734',
'Gm13741', 'Gm13747', 'Gm13753', 'Gm13759', 'Gm13760', 'Gm13763', 'Gm15662', 'Gm20497', 'Gm20677',
'Gm20678', 'Gm20699', 'Gm27157', 'Gm28479', 'Gm28498', 'Gm28621', 'Gm28904', 'Gm28933', 'Gm29006',
'Gm29095', 'Gm29172', 'Gm29176', 'Gm29236', 'Gm29375', 'Gm3719', 'Gm37276', 'Gm43296', 'Gm44568',
'Gm44572', 'Gm44774', 'Gm45000', 'Gm45057', 'Gm45302', 'Gm45810'
)
and m._Marker_key = a._Object_key
and a._AnnotType_key in (1000, 1003, 1007, 1010, 1011, 1015, 1022, 1023, 1017)
;

delete from MRK_Marker m
where m.symbol in (
'Gm37034', 'Gm37038', 'Gm37149', 'Gm37188', 'Gm37271', 'Gm37379', 'Gm37408', 'Gm37414', 'Gm37471', 
'Gm37546', 'Gm37605', 'Gm37615', 'Gm37823', 'Gm37874', 'Gm37888', 'Gm37938', 'Gm38052', 'Gm38129',
'Gm38175', 'Gm38179', 'Gm38193', 'Gm38206', 'Gm38219', 'Gm38354', 'Gm45138', 'Gm45535',
'Gm42691', 'Gm43543', 'Gm43687', 'Gm11291', 'Gm11345', 'Gm11374', 'Gm11375', 'Gm13434', 'Gm13734',
'Gm13741', 'Gm13747', 'Gm13753', 'Gm13759', 'Gm13760', 'Gm13763', 'Gm15662', 'Gm20497', 'Gm20677',
'Gm20678', 'Gm20699', 'Gm27157', 'Gm28479', 'Gm28498', 'Gm28621', 'Gm28904', 'Gm28933', 'Gm29006',
'Gm29095', 'Gm29172', 'Gm29176', 'Gm29236', 'Gm29375', 'Gm3719', 'Gm37276', 'Gm43296', 'Gm44568',
'Gm44572', 'Gm44774', 'Gm45000', 'Gm45057', 'Gm45302', 'Gm45810'
)
;

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

-- J:109762
delete from MLD_Expts a
where a._Refs_key = 110841;
;

EOSQL

date |tee -a $LOG
echo ${GOLOAD}/go.sh | tee -a $LOG
#${MIRROR_WGET}/download_package pir.georgetown.edu.proisoform
#${MIRROR_WGET}/download_package build.berkeleybop.org.goload
#${MIRROR_WGET}/download_package build.berkeleybop.org.gpad.goload
#${MIRROR_WGET}/download_package ftp.ebi.ac.uk.goload
#${MIRROR_WGET}/download_package ftp.geneontology.org.goload
#${MIRROR_WGET}/download_package purl.obolibrary.org.pr.obo
${GOLOAD}/go.sh | tee -a $LOG

date |tee -a $LOG
echo ${GENEMODELLOAD}/bin/biotypemapping.sh | tee -a $LOG
${GENEMODELLOAD}/bin/biotypemapping.sh | tee -a $LOG

date |tee -a $LOG
echo ${SEQCACHELOAD}/seqcoord.csh | tee -a $LOG
${SEQCACHELOAD}/seqcoord.csh | tee -a $LOG

date |tee -a $LOG
echo ${SEQCACHELOAD}/seqmarker.csh | tee -a $LOG
${SEQCACHELOAD}/seqmarker.csh | tee -a $LOG

date |tee -a $LOG
echo ${MRKCACHELOAD}/mrkref.csh | tee -a $LOG
${MRKCACHELOAD}/mrkref.csh | tee -a $LOG

date |tee -a $LOG
echo ${MRKCACHELOAD}/mrklocation.csh | tee -a $LOG
${MRKCACHELOAD}/mrklocation.csh | tee -a $LOG

date | tee -a $LOG
echo "after counts..." | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

select m.*, a._Allele_key, a.symbol
from MRK_Marker m, ALL_Allele a
where m.symbol in (
'Gm37034', 'Gm37038', 'Gm37149', 'Gm37188', 'Gm37271', 'Gm37379', 'Gm37408', 'Gm37414', 'Gm37471',
'Gm37546', 'Gm37605', 'Gm37615', 'Gm37823', 'Gm37874', 'Gm37888', 'Gm37938', 'Gm38052', 'Gm38129',
'Gm38175', 'Gm38179', 'Gm38193', 'Gm38206', 'Gm38219', 'Gm38354', 'Gm45138', 'Gm45535',
'Gm42691', 'Gm43543', 'Gm43687', 'Gm11291', 'Gm11345', 'Gm11374', 'Gm11375', 'Gm13434', 'Gm13734',
'Gm13741', 'Gm13747', 'Gm13753', 'Gm13759', 'Gm13760', 'Gm13763', 'Gm15662', 'Gm20497', 'Gm20677',
'Gm20678', 'Gm20699', 'Gm27157', 'Gm28479', 'Gm28498', 'Gm28621', 'Gm28904', 'Gm28933', 'Gm29006',
'Gm29095', 'Gm29172', 'Gm29176', 'Gm29236', 'Gm29375', 'Gm3719', 'Gm37276', 'Gm43296', 'Gm44568',
'Gm44572', 'Gm44774', 'Gm45000', 'Gm45057', 'Gm45302', 'Gm45810'
)
and m._Marker_key = a._Marker_key
;

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

EOSQL

