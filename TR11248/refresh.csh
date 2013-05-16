#!/bin/csh

${MGD_DBSCHEMADIR}/index/GXD_AssayNote_drop.object
${MGD_DBSCHEMADIR}/table/GXD_AssayNote_truncate.object
bcpin.csh DEV_MGI mgd_dev GXD_AssayNote
${MGD_DBSCHEMADIR}/index/GXD_AssayNote_create.object

${MGD_DBSCHEMADIR}/index/GXD_Specimen_drop.object
${MGD_DBSCHEMADIR}/table/GXD_Specimen_truncate.object
bcpin.csh DEV_MGI mgd_dev GXD_Specimen
${MGD_DBSCHEMADIR}/index/GXD_Specimen_create.object
