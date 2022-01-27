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
 
#${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_Antibody ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_Antibody.bcp "|"
#${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_AntibodyPrep ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_AntibodyPrep.bcp "|"
#${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_ProbePrep ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_ProbePrep.bcp "|"

# drop foreign key contraints
${PG_MGD_DBSCHEMADIR}/key/GXD_AntibodyClass_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_AntibodyType_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_EmbeddingMethod_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_FixationMethod_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_GelControl_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_GelRNAType_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_GelUnits_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_Label_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_Pattern_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_ProbeSense_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_Secondary_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_Strength_drop.object
${PG_MGD_DBSCHEMADIR}/key/GXD_VisualizationMethod_drop.object

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

#./vocab.py | tee -a $LOG

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

date |tee -a $LOG

