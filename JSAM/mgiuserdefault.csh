#!/bin/csh -f

#
# To remove user_default from:
#
#	ALL_Allele
#	GXD_AlleleGenotype
#	GXD_Assay
#	GXD_Genotype
#	GXD_Index
#	GXD_Index_Stages
#	MGI_Note 
#	MGI_NoteChunk
#	MGI_NoteType
#	MGI_Set
#	MGI_SetMember
#	MGI_Translation
#	MGI_TranslationType
#	MRK_History
# 	VOC_Evidence
#	MLC_Text
#

cd `dirname $0` && source ./Configuration

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date 
echo "MGI User Defaults Migration..." | tee -a $LOG

# remove old user defaults

${oldmgddbschema}/default/ALL_Allele_unbind.object >>& $LOG
${oldmgddbschema}/default/GXD_AlleleGenotype_unbind.object >>& $LOG
${oldmgddbschema}/default/GXD_Assay_unbind.object >>& $LOG
${oldmgddbschema}/default/GXD_Genotype_unbind.object >>& $LOG
${oldmgddbschema}/default/GXD_Index_unbind.object >>& $LOG
${oldmgddbschema}/default/GXD_Index_Stages_unbind.object >>& $LOG
${oldmgddbschema}/default/MGI_Note_unbind.object >>& $LOG
${oldmgddbschema}/default/MGI_NoteChunk_unbind.object >>& $LOG
${oldmgddbschema}/default/MGI_NoteType_unbind.object >>& $LOG
${oldmgddbschema}/default/MGI_RefAssocType_unbind.object >>& $LOG
${oldmgddbschema}/default/MGI_Reference_Assoc_unbind.object >>& $LOG
${oldmgddbschema}/default/MGI_Set_unbind.object >>& $LOG
${oldmgddbschema}/default/MGI_SetMember_unbind.object >>& $LOG
${oldmgddbschema}/default/MGI_Translation_unbind.object >>& $LOG
${oldmgddbschema}/default/MGI_TranslationType_unbind.object >>& $LOG
${oldmgddbschema}/default/MLC_Text_unbind.object >>& $LOG
${oldmgddbschema}/default/MRK_History_unbind.object >>& $LOG
${oldmgddbschema}/default/NOM_Marker_unbind.object >>& $LOG
${oldmgddbschema}/default/NOM_Synonym_unbind.object >>& $LOG
${oldmgddbschema}/default/VOC_Evidence_unbind.object >>& $LOG

#
# drop old user_default and create new user_default
#
${newmgddbschema}/default/user_default_drop.object >>& $LOG
${newmgddbschema}/default/user_default_create.object >>& $LOG

date 

