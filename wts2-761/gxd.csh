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

#151 | GXD_AntibodyClass
#152 | GXD_Label
#153 | GXD_Pattern
#154 | GXD_GelControl
#155 | GXD_EmbeddingMethod
#156 | GXD_FixationMethod
#157 | GXD_VisualizationMethod
#159 | GXD_ProbeSense
#160 | GXD_Secondary
#163 | GXD Strength
#172 | GXD_GelRNAType
#173 | GXD_GelUnits

#158 | GXD Assay Type : do nothing
#162 | GXD Hybridization : just in voc_term; do nothing

${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_AntibodyClass ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_AntibodyClass.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_EmbeddingMethod ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_EmbeddingMethod.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_FixationMethod ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_FixationMethod.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_GelControl ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_GelControl.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_GelRNAType ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_GelRNAType.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_GelUnits ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_GelUnits.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_Label ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_Label.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_Pattern ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_Pattern.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_ProbeSense ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_ProbeSense.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_Secondary ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_Secondary.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_Strength ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_Strength.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_VisualizationMethod ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_VisualizationMethod.bcp "|"

${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_Antibody ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_Antibody.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_AntibodyPrep ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_AntibodyPrep.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_GelLane ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_GelLane.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_GelRow ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_GelRow.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_InSituResult ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_InSituResult.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_ProbePrep ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_ProbePrep.bcp "|"
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_Specimen ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_Specimen.bcp "|"

# drop foreign key contraints
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.GXD_Antibody DROP CONSTRAINT GXD_Antibody__AntibodyClass_key_fkey CASCADE;
ALTER TABLE mgd.GXD_AntibodyPrep DROP CONSTRAINT GXD_AntibodyPrep__Label_key_fkey CASCADE;
ALTER TABLE mgd.GXD_AntibodyPrep DROP CONSTRAINT GXD_AntibodyPrep__Secondary_key_fkey CASCADE;
ALTER TABLE mgd.GXD_GelLane DROP CONSTRAINT GXD_GelLane__GelControl_key_fkey CASCADE;
ALTER TABLE mgd.GXD_GelLane DROP CONSTRAINT GXD_GelLane__GelRNAType_key_fkey CASCADE;
ALTER TABLE mgd.GXD_GelRow DROP CONSTRAINT GXD_GelRow__GelUnits_key_fkey CASCADE;
ALTER TABLE mgd.GXD_InSituResult DROP CONSTRAINT GXD_InSituResult__Pattern_key_fkey CASCADE;
ALTER TABLE mgd.GXD_ProbePrep DROP CONSTRAINT GXD_ProbePrep__Label_key_fkey CASCADE;
ALTER TABLE mgd.GXD_ProbePrep DROP CONSTRAINT GXD_ProbePrep__Sense_key_fkey CASCADE;
ALTER TABLE mgd.GXD_ProbePrep DROP CONSTRAINT GXD_ProbePrep__Visualization_key_fkey CASCADE;
ALTER TABLE mgd.GXD_Specimen DROP CONSTRAINT GXD_Specimen__Embedding_key_fkey CASCADE;
ALTER TABLE mgd.GXD_Specimen DROP CONSTRAINT GXD_Specimen__Fixation_key_fkey CASCADE;
ALTER TABLE mgd.GXD_GelBand DROP CONSTRAINT GXD_GelBand__Strength_key_fkey CASCADE;
ALTER TABLE mgd.GXD_InSituResult DROP CONSTRAINT GXD_InSituResult__Strength_key_fkey CASCADE;
EOSQL

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

--ALTER TABLE mgd.GXD_Antibody DROP CONSTRAINT GXD_Antibody__AntibodyClass_key_fkey CASCADE;
update GXD_Antibody m
set _AntibodyClass_key = t._term_key
from GXD_AntibodyClass e, VOC_Term t
where m._AntibodyClass_key = e._AntibodyClass_key
and e.class = t.term
and t._vocab_key = 151
;

--ALTER TABLE mgd.GXD_AntibodyPrep DROP CONSTRAINT GXD_AntibodyPrep__Label_key_fkey CASCADE;
update GXD_AntibodyPrep m
set _label_key = t._term_key
from GXD_Label e, VOC_Term t
where m._label_key = e._label_key
and e.label = t.term
and t._vocab_key = 152
;

--ALTER TABLE mgd.GXD_ProbePrep DROP CONSTRAINT GXD_ProbePrep__Label_key_fkey CASCADE;
update GXD_ProbePrep m
set _label_key = t._term_key
from GXD_Label e, VOC_Term t
where m._label_key = e._label_key
and e.label = t.term
and t._vocab_key = 152
;

--ALTER TABLE mgd.GXD_InSituResult DROP CONSTRAINT GXD_InSituResult__Pattern_key_fkey CASCADE;
update GXD_InSituResult m
set _pattern_key = t._term_key
from GXD_Pattern e, VOC_Term t
where m._pattern_key = e._pattern_key
and e.pattern = t.term
and t._vocab_key = 153
;

--ALTER TABLE mgd.GXD_GelLane DROP CONSTRAINT GXD_GelLane__GelControl_key_fkey CASCADE;
update GXD_GelLane m
set _gelcontrol_key = t._term_key
from GXD_GelControl e, VOC_Term t
where m._gelcontrol_key = e._gelcontrol_key
and e.gellanecontent = t.term
and t._vocab_key = 154
;

--ALTER TABLE mgd.GXD_Specimen DROP CONSTRAINT GXD_Specimen__Embedding_key_fkey CASCADE;
update GXD_Specimen m
set _Embedding_key = t._term_key
from GXD_EmbeddingMethod e, VOC_Term t
where m._Embedding_key = e._Embedding_key
and e.embeddingmethod = t.term
and t._vocab_key = 155
;

--ALTER TABLE mgd.GXD_Specimen DROP CONSTRAINT GXD_Specimen__Fixation_key_fkey CASCADE;
update GXD_Specimen m
set _Fixation_key = t._term_key
from GXD_FixationMethod e, VOC_Term t
where m._Fixation_key = e._Fixation_key
and e.fixation = t.term
and t._vocab_key = 156
;

--ALTER TABLE mgd.GXD_ProbePrep DROP CONSTRAINT GXD_ProbePrep__Visualization_key_fkey CASCADE;
update GXD_ProbePrep m
set _visualization_key = t._term_key
from GXD_VisualizationMethod e, VOC_Term t
where m._visualization_key = e._visualization_key
and e.visualization = t.term
and t._vocab_key = 157
;

--ALTER TABLE mgd.GXD_ProbePrep DROP CONSTRAINT GXD_ProbePrep__Sense_key_fkey CASCADE;
update GXD_ProbePrep m
set _sense_key = t._term_key
from GXD_ProbeSense e, VOC_Term t
where m._sense_key = e._sense_key
and e.sense = t.term
and t._vocab_key = 159
;

--ALTER TABLE mgd.GXD_AntibodyPrep DROP CONSTRAINT GXD_AntibodyPrep__Secondary_key_fkey CASCADE;
update GXD_AntibodyPrep m
set _secondary_key = t._term_key
from GXD_Secondary e, VOC_Term t
where m._secondary_key = e._secondary_key
and e.secondary = t.term
and t._vocab_key = 160
;

--ALTER TABLE mgd.GXD_GelLane DROP CONSTRAINT GXD_GelLane__GelRNAType_key_fkey CASCADE;
update GXD_GelLane m
set _gelrnatype_key = t._term_key
from GXD_GelRNAType e, VOC_Term t
where m._gelrnatype_key = e._gelrnatype_key
and e.rnatype = t.term
and t._vocab_key = 172
;

--ALTER TABLE mgd.GXD_GelRow DROP CONSTRAINT GXD_GelRow__GelUnits_key_fkey CASCADE;
update GXD_GelRow m
set _gelunits_key = t._term_key
from GXD_GelUnits e, VOC_Term t
where m._gelunits_key = e._gelunits_key
and e.units = t.term
and t._vocab_key = 173
;

--ALTER TABLE mgd.GXD_InSituResult DROP CONSTRAINT GXD_InSituResult__Strength_key_fkey CASCADE;
update GXD_InSituResult m
set _strength_key = t._term_key
from GXD_Strength e, VOC_Term t
where m._strength_key = e._strength_key
and e.strength = t.term
and t._vocab_key = 163
;

--ALTER TABLE mgd.mgd.GXD_GelBand DROP CONSTRAINT mgd.GXD_GelBand__Strength_key_fkey CASCADE;
update mgd.GXD_GelBand m
set _strength_key = t._term_key
from GXD_Strength e, VOC_Term t
where m._strength_key = e._strength_key
and e.strength = t.term
and t._vocab_key = 163
;


EOSQL

${PG_MGD_DBSCHEMADIR}/key/GXD_drop.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/GXD_create.logical | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/view_create.sh | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/trigger/GXD_create.logical | tee -a $LOG

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
drop table mgd.GXD_AntibodyClass;
drop table mgd.GXD_EmbeddingMethod;
drop table mgd.GXD_FixationMethod;
drop table mgd.GXD_GelControl;
drop table mgd.GXD_GelRNAType;
drop table mgd.GXD_GelUnits;
drop table mgd.GXD_Label;
drop table mgd.GXD_Pattern;
drop table mgd.GXD_ProbeSense;
drop table mgd.GXD_Secondary;
drop table mgd.GXD_Strength;
drop table mgd.GXD_VisualizationMethod;
EOSQL

${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG

${MGICACHELOAD}/gxdexpression.csh | tee -a $LOG
${ALLCACHELOAD}/allelecrecache.csh | tee -a $LOG
./gxdreports.csh | tee -a $LOG

date |tee -a $LOG

