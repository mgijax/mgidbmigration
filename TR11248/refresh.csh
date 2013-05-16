#!/bin/csh

${MGD_DBSCHEMADIR}/index/MGI_NoteChunk_drop.object
${MGD_DBSCHEMADIR}/table/MGI_NoteChunk_truncate.object
bcpin.csh DEV_MGI mgd_dev MGI_NoteChunk
${MGD_DBSCHEMADIR}/index/MGI_NoteChunk_create.object

${MGD_DBSCHEMADIR}/index/GXD_Specimen_drop.object
${MGD_DBSCHEMADIR}/table/GXD_Specimen_truncate.object
bcpin.csh DEV_MGI mgd_dev GXD_Specimen
${MGD_DBSCHEMADIR}/index/GXD_Specimen_create.object
