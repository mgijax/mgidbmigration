#!/bin/csh

${MGD_DBSCHEMADIR}/index/MGI_NoteChunk_drop.object
${MGD_DBSCHEMADIR}/table/MGI_NoteChunk_truncate.object
bcpin.csh DEV_MGI mgd_dev MGI_NoteChunk
${MGD_DBSCHEMADIR}/index/MGI_NoteChunk_create.object
