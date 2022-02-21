#!/bin/csh -f

#
# merge single table vocabularies to voc_vocab/voc_term
#
# 1. make backups
# 2. drop foreign keys
# 3. add any new voc_vocab
# 4. call vocab.py; add new terms to voc_term; move old key to new voc_term._term_key
# 5. drop old single tables
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
 
#${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_Antibody ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_Antibody.bcp "|"
#${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_AntibodyPrep ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_AntibodyPrep.bcp "|"
#${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_ProbePrep ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_ProbePrep.bcp "|"
#${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_Specimen ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_Specimen.bcp "|"
#${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_InSituResult ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_InSituResult.bcp "|"
#${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_GelLane ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_GelLane.bcp "|"
#${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_GelBand ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_GelBand.bcp "|"
#${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_GelRow ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_GelRow.bcp "|"

# drop foreign key contraints
cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
ALTER TABLE mgd.GXD_Antibody DROP CONSTRAINT GXD_Antibody__AntibodyClass_key_fkey CASCADE;
ALTER TABLE mgd.GXD_AntibodyClass DROP CONSTRAINT GXD_AntibodyClass_pkey CASCADE;
ALTER TABLE mgd.GXD_Antibody DROP CONSTRAINT GXD_Antibody__AntibodyType_key_fkey CASCADE;
ALTER TABLE mgd.GXD_AntibodyType DROP CONSTRAINT GXD_AntibodyType_pkey CASCADE;
ALTER TABLE mgd.GXD_Specimen DROP CONSTRAINT GXD_Specimen__Embedding_key_fkey CASCADE;
ALTER TABLE mgd.GXD_EmbeddingMethod DROP CONSTRAINT GXD_EmbeddingMethod_pkey CASCADE;
ALTER TABLE mgd.GXD_Specimen DROP CONSTRAINT GXD_Specimen__Fixation_key_fkey CASCADE;
ALTER TABLE mgd.GXD_FixationMethod DROP CONSTRAINT GXD_FixationMethod_pkey CASCADE;
ALTER TABLE mgd.GXD_GelLane DROP CONSTRAINT GXD_GelLane__GelControl_key_fkey CASCADE;
ALTER TABLE mgd.GXD_GelControl DROP CONSTRAINT GXD_GelControl_pkey CASCADE;
ALTER TABLE mgd.GXD_GelLane DROP CONSTRAINT GXD_GelLane__GelRNAType_key_fkey CASCADE;
ALTER TABLE mgd.GXD_GelRNAType DROP CONSTRAINT GXD_GelRNAType_pkey CASCADE;
ALTER TABLE mgd.GXD_GelRow DROP CONSTRAINT GXD_GelRow__GelUnits_key_fkey CASCADE;
ALTER TABLE mgd.GXD_GelUnits DROP CONSTRAINT GXD_GelUnits_pkey CASCADE;
ALTER TABLE mgd.GXD_AntibodyPrep DROP CONSTRAINT GXD_AntibodyPrep__Label_key_fkey CASCADE;
ALTER TABLE mgd.GXD_ProbePrep DROP CONSTRAINT GXD_ProbePrep__Label_key_fkey CASCADE;
ALTER TABLE mgd.GXD_Label DROP CONSTRAINT GXD_Label_pkey CASCADE;
ALTER TABLE mgd.GXD_InSituResult DROP CONSTRAINT GXD_InSituResult__Pattern_key_fkey CASCADE;
ALTER TABLE mgd.GXD_Pattern DROP CONSTRAINT GXD_Pattern_pkey CASCADE;
ALTER TABLE mgd.GXD_ProbePrep DROP CONSTRAINT GXD_ProbePrep__Sense_key_fkey CASCADE;
ALTER TABLE mgd.GXD_ProbeSense DROP CONSTRAINT GXD_ProbeSense_pkey CASCADE;
ALTER TABLE mgd.GXD_AntibodyPrep DROP CONSTRAINT GXD_AntibodyPrep__Secondary_key_fkey CASCADE;
ALTER TABLE mgd.GXD_Secondary DROP CONSTRAINT GXD_Secondary_pkey CASCADE;
ALTER TABLE mgd.GXD_InSituResult DROP CONSTRAINT GXD_InSituResult__Strength_key_fkey CASCADE;
ALTER TABLE mgd.GXD_GelBand DROP CONSTRAINT GXD_GelBand__Strength_key_fkey CASCADE;
ALTER TABLE mgd.GXD_Strength DROP CONSTRAINT GXD_Strength_pkey CASCADE;
ALTER TABLE mgd.GXD_ProbePrep DROP CONSTRAINT GXD_ProbePrep__Visualization_key_fkey CASCADE;
ALTER TABLE mgd.GXD_VisualizationMethod DROP CONSTRAINT GXD_VisualizationMethod_pkey CASCADE;
EOSQL

# these already exists in the voc_vocab; so let's just check that there are no changes
# 151 | GXD Antibody Class
# 161 | GXD Assay Age
# 158 | GXD Assay Type
# 156 | GXD Fixation Method
# 155 | GXD Embedding Method
# 154 | GXD Gel Control
# 172 | GXD Gel RNA Type
# 173 | GXD Gel Units
# 162 | GXD Hybridization
# 152 | GXD Label
# 153 | GXD Pattern
# 159 | GXD Probe Sense
# 160 | GXD Secondary
# 163 | GXD Strength
# 157 | GXD Visualization Method

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

insert into VOC_Vocab values(175,22864,1,1,0,'GXD Antibody Type',now(), now());

delete from VOC_Term where _vocab_key = 175;

insert into VOC_Term values(nextval('voc_term_seq'), 175, 'Not Specified', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 175, 'Not Applicable', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 175, 'Monoclondal', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 175, 'Polyclonal', null, null, 4, 0, 1001, 1001, now(), now());

EOSQL

./vocab.py | tee -a $LOG

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#drop table mgd.GXD_AntibodyClass;
#drop table mgd.GXD_AntibodyType;
#drop table mgd.GXD_EmbeddingMethod;
#drop table mgd.GXD_FixationMethod;
#drop table mgd.GXD_GelControl;
#drop table mgd.GXD_GelRNAType;
#drop table mgd.GXD_GelUnits;
#drop table mgd.GXD_Label;
#drop table mgd.GXD_Pattern;
#drop table mgd.GXD_ProbeSense;
#drop table mgd.GXD_Secondary;
#drop table mgd.GXD_Strength;
#drop table mgd.GXD_VisualizationMethod;
#EOSQL

#
# add these tables to key/VOC_Term_create.object/VOC_Term_drop.object
#
# _antibodyclass_key ['GXD_Antibody']),
# _label_key', ', ['GXD_AntibodyPrep', 'GXD_ProbePrep']),
# _pattern_key', ', ['GXD_InSituResult']),
# _gelcontrol_key', ['GXD_GelLane']),
# _embedding_key', ['GXD_Specimen']),
# _Fixation_key', ['GXD_Specimen']),
# _Visualization_key', ['GXD_ProbePrep']),
# _sense_key', ', ['GXD_ProbePrep']),
# _secondary_key', ['GXD_AntibodyPrep']),
# _strength_key', ['GXD_GelBand', 'GXD_InSituResult']),
# _gelrnatype_key', ['GXD_GelLane']),
# _gelunits_key', ['GXD_GelRow']),
# _antibodytype_key', ['GXD_Antibody'])
#

#${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object
#${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object

date |tee -a $LOG

