#!/bin/csh

#load_db.csh DEV_MGI mgd_dev /backups/rohan/scrum-dog/mgd.backup

${MGD_DBSCHEMADIR}/index/ALL_Allele_drop.object
${MGD_DBSCHEMADIR}/table/ALL_Allele_truncate.object
bcpin.csh DEV_MGI mgd_dev ALL_Allele
${MGD_DBSCHEMADIR}/index/ALL_Allele_create.object

${MGD_DBSCHEMADIR}/index/ALL_CellLine_Derivation_drop.object
${MGD_DBSCHEMADIR}/table/ALL_CellLine_Derivation_truncate.object
bcpin.csh DEV_MGI mgd_dev ALL_CellLine_Derivation
${MGD_DBSCHEMADIR}/index/ALL_CellLine_Derivation_create.object

${MGD_DBSCHEMADIR}/index/VOC_Term_drop.object
${MGD_DBSCHEMADIR}/table/VOC_Term_truncate.object
bcpin.csh DEV_MGI mgd_dev VOC_Term
${MGD_DBSCHEMADIR}/index/VOC_Term_create.object

