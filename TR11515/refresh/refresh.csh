#!/bin/csh

#load_db.csh DEV_MGI mgd_dev /backups/rohan/scrum-dog/mgd.backup

#bcpout.csh DEV_MGI mgd_dev ALL_Allele
#bcpout.csh DEV_MGI mgd_dev ALL_CellLine_Derivation
#bcpout.csh DEV_MGI mgd_dev VOC_Term
#bcpout.csh DEV_MGI mgd_dev VOC_Annot
#exit 0

#${MGD_DBSCHEMADIR}/index/ALL_Allele_drop.object
#${MGD_DBSCHEMADIR}/table/ALL_Allele_truncate.object
#bcpin.csh DEV_MGI mgd_dev ALL_Allele
#${MGD_DBSCHEMADIR}/index/ALL_Allele_create.object

${MGD_DBSCHEMADIR}/index/ALL_CellLine_drop.object
${MGD_DBSCHEMADIR}/table/ALL_CellLine_truncate.object
bcpin.csh DEV_MGI mgd_dev ALL_CellLine
${MGD_DBSCHEMADIR}/index/ALL_CellLine_create.object

${MGD_DBSCHEMADIR}/index/ALL_CellLine_Derivation_drop.object
${MGD_DBSCHEMADIR}/table/ALL_CellLine_Derivation_truncate.object
bcpin.csh DEV_MGI mgd_dev ALL_CellLine_Derivation
${MGD_DBSCHEMADIR}/index/ALL_CellLine_Derivation_create.object

#${MGD_DBSCHEMADIR}/index/VOC_Term_drop.object
#${MGD_DBSCHEMADIR}/table/VOC_Term_truncate.object
#bcpin.csh DEV_MGI mgd_dev VOC_Term
#${MGD_DBSCHEMADIR}/index/VOC_Term_create.object

#${MGD_DBSCHEMADIR}/index/VOC_Annot_drop.object
#${MGD_DBSCHEMADIR}/table/VOC_Annot_truncate.object
#bcpin.csh DEV_MGI mgd_dev VOC_Annot
#${MGD_DBSCHEMADIR}/index/VOC_Annot_create.object
