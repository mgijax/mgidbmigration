#!/bin/csh

${MGD_DBSCHEMADIR}/index/ALL_Allele_drop.object
${MGD_DBSCHEMADIR}/table/ALL_Allele_truncate.object
#bcpin.csh DEV_MGI mgd_dev ALL_Allele
bcpin.csh DEV1_MGI mgd_lec1 ALL_Allele
${MGD_DBSCHEMADIR}/index/ALL_Allele_create.object

${MGD_DBSCHEMADIR}/index/ALL_CellLine_Derivation_drop.object
${MGD_DBSCHEMADIR}/table/ALL_CellLine_Derivation_truncate.object
#bcpin.csh DEV_MGI mgd_dev ALL_Allele
bcpin.csh DEV1_MGI mgd_lec1 ALL_Allele
${MGD_DBSCHEMADIR}/index/ALL_CellLine_Derivation_create.object

