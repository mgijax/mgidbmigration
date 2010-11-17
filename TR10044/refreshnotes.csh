#!/bin/csh -f

#
# re-fresh the saved note data
#

source ../Configuration

cd `dirname $0`

setenv LOG $0.log
rm -rf $LOG
touch $LOG
 
date | tee -a $LOG

${MGD_DBSCHEMADIR}/index/MGI_Note_drop.object
${MGD_DBSCHEMADIR}/index/MGI_NoteChunk_drop.object
bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} MGI_Note_save
bcpin.csh ${MGD_DBSERVER} ${MGD_DBNAME} MGI_NoteChunk_save
${MGD_DBSCHEMADIR}/index/MGI_Note_create.object
${MGD_DBSCHEMADIR}/index/MGI_NoteChunk_create.object

date |tee -a $LOG

