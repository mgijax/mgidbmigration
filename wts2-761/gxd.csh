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
${PG_DBUTILS}/bin/dumpTableData.csh ${MGD_DBSERVER} ${MGD_DBNAME} mgd GXD_VisualizationMethod ${MGI_LIVE}/dbutils/mgidbmigration/wts2-761/GXD_VisualizationMethod.bcp "|"

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

-- 151 | GXD_AntibodyClass
delete from voc_term where _vocab_key = 151;
insert into VOC_Term values(nextval('voc_term_seq'), 151, 'Not Applicable', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 151, 'Not Specified', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 151, 'IgA', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 151, 'IgD', null, null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 151, 'IgE', null, null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 151, 'IgG', null, null, 6, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 151, 'IgM', null, null, 7, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 151, 'IgY', null, null, 8, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 151, 'IgG1', null, null, 9, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 151, 'IgG2a', null, null, 10, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 151, 'IgG2b', null, null, 11, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 151, 'IgG3', null, null, 12, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 151, 'IgG2c', null, null, 13, 0, 1001, 1001, now(), now());

-- 152 | GXD_Label; _label_key, label
delete from voc_term where _vocab_key = 152;
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'Not Applicable', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'Not Specified', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'Alexa Fluor', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'Alexa Fluor 350', null, null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'Alexa Fluor 488', null, null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'Alexa Fluor 532', null, null, 6, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'Alexa Fluor 546', null, null, 7, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'Alexa Fluor 555', null, null, 8, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'Alexa Fluor 568', null, null, 9, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'Alexa Fluor 594', null, null, 10, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'Alexa Fluor 633', null, null, 11, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'Alexa Fluor 647', null, null, 12, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'Alexa Fluor 680', null, null, 13, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'alkaline phosphatase', null, null, 14, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'beta-galactosidase', null, null, 15, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'biotin', null, null, 16, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'colloidal gold', null, null, 17, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'Cy2', null, null, 18, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'Cy3', null, null, 19, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'Cy5', null, null, 20, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'cyanine dye', null, null, 21, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'digoxigenin', null, null, 22, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'dinitrophenyl', null, null, 23, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'DyLight', null, null, 24, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'DyLight 488', null, null, 25, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'DyLight 549', null, null, 26, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'DyLight 594', null, null, 27, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'DyLight 649', null, null, 28, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'EvaGreen', null, null, 29, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'FAM', null, null, 30, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'fluorescein', null, null, 31, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'horseradish peroxidase', null, null, 32, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'I125', null, null, 33, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'Oregon Green 488', null, null, 34, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'other - see notes', null, null, 35, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'P32', null, null, 36, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'P33', null, null, 37, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'phycoerythrin', null, null, 38, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'radioactivity', null, null, 39, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'rhodamine', null, null, 40, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'S35', null, null, 41, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'SYBR green', null, null, 42, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'Texas Red', null, null, 43, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 152, 'tritium (H3)', null, null, 44, 0, 1001, 1001, now(), now());

-- 153 | GXD_Pattern, _pattern_key, pattern
delete from voc_term where _vocab_key = 153;
insert into VOC_Term values(nextval('voc_term_seq'), 153, 'Not Applicable', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 153, 'Not Specified', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 153, 'Clusters', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 153, 'Diffuse', null, null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 153, 'Graded', null, null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 153, 'Non-Uniform', null, null, 6, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 153, 'Patchy', null, null, 7, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 153, 'Punctate', null, null, 8, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 153, 'Regionally restricted', null, null, 9, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 153, 'Scattered', null, null, 10, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 153, 'Single cells', null, null, 11, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 153, 'Spotted', null, null, 12, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 153, 'Ubiquitous', null, null, 13, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 153, 'Uniform', null, null, 14, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 153, 'Widespread', null, null, 15, 0, 1001, 1001, now(), now());

-- 154 | GXD_GelControl, _gelcontrol_key, gellanecontent
delete from voc_term where _vocab_key = 154;
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Allele not specified: no data stored', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Control', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Cultured cells: no data stored', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Cultured sample: no data stored', null, null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Fractionated sample: no data stored', null, null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'In vitro data: no data stored', null, null, 6, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Lane not used in this assay', null, null, 7, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Mol. Wt. Marker Lane', null, null, 8, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'No', null, null, 9, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'No data stored', null, null, 10, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Non-mouse sample: no data stored', null, null, 11, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Other lane(s) in blot assay different gene(s)', null, null, 12, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Other lane(s) in blot use different probe(s)', null, null, 13, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Tissue age not specified: no data stored', null, null, 14, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Transgenic sample: no data stored', null, null, 15, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Treated sample: no data stored', null, null, 16, 0, 1001, 1001, now(), now());

-- 155 | GXD_EmbeddingMethod _embedding_key |  embeddingmethod
delete from voc_term where _vocab_key = 155;
insert into VOC_Term values(nextval('voc_term_seq'), 155, 'Not Applicable', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 155, 'Not Specified', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 155, 'Agarose', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 155, 'Cryosection', null, null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 155, 'Gelatin', null, null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 155, 'Methacrylate', null, null, 6, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 155, 'Other - See Notes', null, null, 7, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 155, 'Paraffin', null, null, 8, 0, 1001, 1001, now(), now());

-- 156 | GXD_FixationMethod  _fixation_key |      fixation 
delete from voc_term where _vocab_key = 156;
insert into VOC_Term values(nextval('voc_term_seq'), 156, 'Not Applicable', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 156, 'Not Specified', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 156, '10% Formalin', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 156, '2% Paraformaldehyde', null, null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 156, '3% Paraformaldehyde', null, null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 156, '4% Paraformaldehyde', null, null, 6, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 156, 'Acetone', null, null, 7, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 156, 'Bouin''s Fixative', null, null, 8, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 156, 'Carnoy''s Fixative', null, null, 9, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 156, 'Dent''s Fixative', null, null, 10, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 156, 'Formaldehyde', null, null, 11, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 156, 'Formalin', null, null, 12, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 156, 'Fresh Frozen', null, null, 13, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 156, 'Gendre''s Fixative', null, null, 14, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 156, 'Glutaraldehyde', null, null, 15, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 156, 'Methanol', null, null, 16, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 156, 'Other - See Notes', null, null, 17, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 156, 'Paraformaldehyde', null, null, 18, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 156, 'Ste. Marie''s', null, null, 19, 0, 1001, 1001, now(), now());

-- 157 | GXD_VisualizationMethod _visualization_key |     visualization
delete from voc_term where _vocab_key = 157;
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Not Applicable', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Not Specified', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Alkaline phosphatase', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Autoradiography', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Beta-galactosidase', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Chromogenic', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Cy2', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Cy3', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Cy5', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'cyanine dye', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Ethidium bromide', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Fluorescein', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Fluorescence', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Horseradish peroxidase', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Not Applicable', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Rhodamine', null, null, 2, 0, 1001, 1001, now(), now());

-- 159 | GXD_ProbeSense  _sense_key |      sense
delete from voc_term where _vocab_key = 159;
insert into VOC_Term values(nextval('voc_term_seq'), 159, 'Not Applicable', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 159, 'Not Specified', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 159, 'Antisense', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 159, 'Double stranded', null, null, 4, 0, 1001, 1001, now(), now());

-- 160 | GXD_Secondary  _secondary_key |                   secondary
delete from voc_term where _vocab_key = 160;
insert into VOC_Term values(nextval('voc_term_seq'), 160, 'Not Applicable', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 160, 'Not Specified', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 160, 'Biotinylated secondary antibody/[Strept]avidin', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 160, 'Protein A', null, null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 160, 'Secondary antibody', null, null, 5, 0, 1001, 1001, now(), now());

-- 172 | GXD_GelRNAType _gelrnatype_key |    rnatype
delete from voc_term where _vocab_key = 172;
insert into VOC_Term values(nextval('voc_term_seq'), 172, 'Not Applicable', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 172, 'Not Specified', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 172, 'poly-A+', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 172, 'total', null, null, 4, 0, 1001, 1001, now(), now());

-- 173 | GXD_GelUnits  _gelunits_key |     units
delete from voc_term where _vocab_key = 173;
insert into VOC_Term values(nextval('voc_term_seq'), 173, 'Not Applicable', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 173, 'Not Specified', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 173, 'b', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 173, 'bp', null, null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 173, 'Da', null, null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 173, 'kb', null, null, 6, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 173, 'kDa', null, null, 7, 0, 1001, 1001, now(), now());

update GXD_Antibody m
set _AntibodyClass_key = t._term_key
from GXD_AntibodyClass e, VOC_Term t
where m._AntibodyClass_key = e._AntibodyClass_key
and e.class = t.term
and t._vocab_key = 151
;

update GXD_GelLane m
set _lane_key = t._term_key
from GXD_GelLane e, VOC_Term t
where m._lane_key = e._lane_key
and e.lane = t.term
and t._vocab_key = 152
;

update GXD_AntibodyPrep m
set _lane_key = t._term_key
from GXD_GelLane e, VOC_Term t
where m._lane_key = e._lane_key
and e.lane = t.term
and t._vocab_key = 152
;

update GXD_ProbePrep m
set _label_key = t._term_key
from GXD_Label e, VOC_Term t
where m._label_key = e._label_key
and e.label = t.term
and t._vocab_key = 152
;

update GXD_InSituResult m
set _pattern_key = t._term_key
from GXD_GelUnits e, VOC_Term t
where m._pattern_key = e._pattern_key
and e.pattern = t.term
and t._vocab_key = 153
;

update GXD_GelLane m
set _gelcontrol_key = t._term_key
from GXD_GelLane e, VOC_Term t
where m._gelcontrol_key = e._gelcontrol_key
and e.gellanecontent = t.term
and t._vocab_key = 154
;

update GXD_Specimen m
set _Embedding_key = t._term_key
from GXD_EmbeddingMethod e, VOC_Term t
where m._Embedding_key = e._Embedding_key
and e.embeddingmethod = t.term
and t._vocab_key = 155
;

update GXD_Specimen m
set _Fixation_key = t._term_key
from GXD_FixationMethod e, VOC_Term t
where m._Fixation_key = e._Fixation_key
and e.fixation = t.term
and t._vocab_key = 156
;

update GXD_ProbePrep m
set _visualization_key = t._term_key
from GXD_VisualizationMethod e, VOC_Term t
where m._visualization_key = e._visualization_key
and e.visualization = t.term
and t._vocab_key = 157
;

update GXD_ProbePrep m
set _sense_key = t._term_key
from GXD_ProbeSense e, VOC_Term t
where m._sense_key = e._sense_key
and e.sense = t.term
and t._vocab_key = 159
;

update GXD_AntibodyPrep m
set _secondary_key = t._term_key
from GXD_Secondary e, VOC_Term t
where m._secondary_key = e._secondary_key
and e.secondary = t.term
and t._vocab_key = 160
;

update GXD_GelLane m
set _gelrnatype_key = t._term_key
from GXD_GelLane e, VOC_Term t
where m._gelrnatype_key = e._gelrnatype_key
and e.rnatype = t.term
and t._vocab_key = 172
;

update GXD_GelRow m
set _gelunits_key = t._term_key
from GXD_GelUnits e, VOC_Term t
where m._gelunits_key = e._gelunits_key
and e.units = t.term
and t._vocab_key = 173
;

EOSQL

exit 0

${PG_MGD_DBSCHEMADIR}/key/VOC_Term_drop.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/key/VOC_Term_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/GXD_Antibody_View_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/GXD_AntibodyPrep_View_create.object | tee -a $LOG
${PG_MGD_DBSCHEMADIR}/view/GXD_ProbePrep_View_create.object | tee -a $LOG

#cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG
#drop table mgd.GXD_AntibodyClass;
#drop table mgd.GXD_Label;
#drop table mgd.GXD_Pattern;
#drop table mgd.GXD_GelControl;
#drop table mgd.GXD_EmbeddingMethod;
#drop table mgd.GXD_FixationMethod;
#drop table mgd.GXD_VisualizationMethod;
#drop table mgd.GXD_ProbeSense;
#drop table mgd.GXD_Secondary;
#drop table mgd.GXD_GelRNAType;
#drop table mgd.GXD_GelUnits;
#EOSQL

${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG

date |tee -a $LOG

