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

cat - <<EOSQL | ${PG_DBUTILS}/bin/doisql.csh $0 | tee -a $LOG

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
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Allele not specified: no data stored', 'Allele Not Spec', null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Control', 'Control', null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Cultured cells: no data stored', 'Cultured cells', null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Cultured sample: no data stored', 'Cultured samp', null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Fractionated sample: no data stored', 'Fractionated', null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'In vitro data: no data stored', 'In vitro', null, 6, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Lane not used in this assay', 'Lane not used', null, 7, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Mol. Wt. Marker Lane', 'Mol Wt Marker', null, 8, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'No', 'No', null, 9, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'No data stored', 'No data stored', null, 10, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Non-mouse sample: no data stored', 'Non-mouse', null, 11, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Other lane(s) in blot assay different gene(s)', 'Diff gene(s)', null, 12, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Other lane(s) in blot use different probe(s)', 'Diff probe(s)', null, 13, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Tissue age not specified: no data stored', 'Age Not Spec', null, 14, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Transgenic sample: no data stored', 'Transgenic', null, 15, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 154, 'Treated sample: no data stored', 'Treated', null, 16, 0, 1001, 1001, now(), now());

-- 155 | GXD_EmbeddingMethod _embedding_key |  embeddingmethod
delete from voc_term where _vocab_key = 155;
insert into VOC_Term values(nextval('voc_term_seq'), 155, 'Not Applicable', 'Not Appl', null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 155, 'Not Specified', 'Not Spec', null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 155, 'Agarose', 'Agarose', null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 155, 'Cryosection', 'Cryosection', null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 155, 'Gelatin', 'Gelatin', null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 155, 'Methacrylate', 'Methacrylate', null, 6, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 155, 'Other - See Notes', 'Other - See Notes', null, 7, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 155, 'Paraffin', 'Paraffin', null, 8, 0, 1001, 1001, now(), now());

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
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Alkaline phosphatase', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Autoradiography', null, null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Beta-galactosidase', null, null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Chromogenic', null, null, 6, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Cy2', null, null, 7, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Cy3', null, null, 8, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Cy5', null, null, 9, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'cyanine dye', null, null, 10, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Ethidium bromide', null, null, 11, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Fluorescein', null, null, 12, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Fluorescence', null, null, 13, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Horseradish peroxidase', null, null, 14, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Phosphorimaging', null, null, 15, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 157, 'Rhodamine', null, null, 16, 0, 1001, 1001, now(), now());

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
insert into VOC_Term values(nextval('voc_term_seq'), 172, 'Not Applicable', 'Not Appl', null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 172, 'Not Specified', 'Not Spec', null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 172, 'poly-A+', 'poly-A+', null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 172, 'total', 'total', null, 4, 0, 1001, 1001, now(), now());

-- 173 | GXD_GelUnits  _gelunits_key |     units
delete from voc_term where _vocab_key = 173;
insert into VOC_Term values(nextval('voc_term_seq'), 173, 'Not Applicable', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 173, 'Not Specified', null, null, 2, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 173, 'b', null, null, 3, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 173, 'bp', null, null, 4, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 173, 'Da', null, null, 5, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 173, 'kb', null, null, 6, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 173, 'kDa', null, null, 7, 0, 1001, 1001, now(), now());

-- 163 | GXD_Strength _strength_key | strength
delete from voc_term where _vocab_key = 163;
insert into VOC_Term values(nextval('voc_term_seq'), 163, 'Not Applicable', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 163, 'Not Specified', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 163, 'Absent', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 163, 'Present', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 163, 'Ambiguous', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 163, 'Trace', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 163, 'Weak', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 163, 'Moderate', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 163, 'Strong', null, null, 1, 0, 1001, 1001, now(), now());
insert into VOC_Term values(nextval('voc_term_seq'), 163, 'Very strong', null, null, 1, 0, 1001, 1001, now(), now());

EOSQL

${PG_MGD_DBSCHEMADIR}/objectCounter.sh | tee -a $LOG

date |tee -a $LOG

