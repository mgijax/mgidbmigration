#!/bin/csh -f

#
# Template
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

select distinct _object_key as _experiment_key, accid as exp_id 
INTO TEMP temp1 from acc_accession 
where _logicaldb_key = 189 
and _mgitype_key = 42 
and preferred = 1 
and accid in (
'E-ERAD-169', 'E-ERAD-352', 'E-ERAD-401', 'E-ERAD-499', 
'E-GEOD-22131', 'E-GEOD-43717', 'E-GEOD-43721', 'E-GEOD-44366', 
'E-GEOD-45278', 'E-GEOD-55966', 'E-GEOD-70484', 'E-GEOD-72095', 
'E-GEOD-74747', 'E-MTAB-2328', 'E-MTAB-2801', 'E-MTAB-3718', 
'E-MTAB-3725', 'E-MTAB-4644', 'E-MTAB-5013', 'E-MTAB-5020', 
'E-MTAB-599', 'E-GEOD-21860', 'E-GEOD-33141', 'E-GEOD-33979', 
'E-GEOD-37646', 'E-GEOD-45684', 'E-GEOD-53105', 'E-GEOD-55163', 
'E-GEOD-55180', 'E-GEOD-58261', 'E-GEOD-60243', 'E-GEOD-63810', 
'E-GEOD-63813', 'E-GEOD-65388', 'E-GEOD-65775', 'E-GEOD-67991', 
'E-GEOD-68155', 'E-GEOD-68283', 'E-GEOD-68284', 'E-GEOD-69556', 
'E-GEOD-72165', 'E-GEOD-72491', 'E-GEOD-76567', 'E-GEOD-77720', 
'E-GEOD-77997', 'E-GEOD-79929', 'E-MTAB-2791', 'E-MTAB-3662', 
'E-MTAB-4035', 'E-MTAB-4526', 'E-MTAB-4528', 'E-MTAB-5210', 
'E-MTAB-5224', 'E-MTAB-5449', 'E-MTAB-5600', 'E-MTAB-5671', 'E-MTAB-5707', 
'E-MTAB-5772', 'E-MTAB-5914', 'E-MTAB-5986', 'E-MTAB-6133', 'E-MTAB-6435', 
'E-MTAB-6547', 'E-MTAB-698', 'E-MTAB-7182', 'E-MTAB-7277', 'E-MTAB-7279')
;

CREATE INDEX idx1 ON temp1 (_experiment_key)
;

select t1.exp_id, t1._experiment_key, hts._sample_key, hts.name, hts.age, hts._organism_key, 
hts._sex_key, hts._stage_key, hts._emapa_key, hts._genotype_key 
INTO TEMP temp2 
from temp1 t1, gxd_htsample hts 
where hts._relevance_key = 20475450 
and hts._genotype_key != 90560 
and hts._experiment_key = t1._experiment_key
;

CREATE INDEX idx2 ON temp2 (_emapa_key)
;

select t2.exp_id, t2._experiment_key, t2._sample_key, t2.name, t2.age, t2._organism_key, 
t2._sex_key, t2._stage_key, t2._genotype_key, vt.term as structure 
INTO TEMP temp3 
from temp2 t2, voc_term vt 
where vt._vocab_key = 90 
and vt._term_key = t2._emapa_key
;

CREATE INDEX idx3 ON temp3 (_experiment_key, _sample_key, age, _organism_key, _sex_key, 
_stage_key, _genotype_key, structure)
;

select n._object_key as _sample_key, nc.note 
INTO TEMP temp4 
from mgi_note n, mgi_notechunk nc 
where n._notetype_key = 1048 
and n._mgitype_key = 43 
and nc._note_key = n._note_key
;

CREATE INDEX idx4 ON temp4 (_sample_key, note)
;

select t3.exp_id, t3._experiment_key, t3._sample_key, t3.name, t3.age, t3._organism_key, 
t3._sex_key, t3._stage_key, t3._genotype_key, t3.structure, t4.note 
INTO TEMP temp5 
from temp3 t3 LEFT OUTER JOIN temp4 t4 on (t3._sample_key = t4._sample_key)
;

CREATE INDEX idx5 ON temp5 (exp_id, _experiment_key, _sample_key, age, _organism_key, 
_sex_key, _stage_key, _genotype_key, structure, note)
;

select distinct exp_id, _experiment_key, age, _organism_key, _sex_key, _stage_key, structure, 
_genotype_key, note, count(distinct _sample_key) as samples INTO TEMP temp6 
from temp5 
GROUP BY exp_id, _experiment_key, age, _organism_key, _sex_key, _stage_key, structure, 
_genotype_key, note
;

CREATE INDEX idx6 ON temp6 (exp_id, _experiment_key, age, _organism_key, _sex_key, 
_stage_key, structure, _genotype_key, note, samples)
;

select *
from temp6
where note is null
order by samples DESC, structure
;

EOSQL

date |tee -a $LOG

